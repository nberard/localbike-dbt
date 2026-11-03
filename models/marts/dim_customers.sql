-- Un client par ligne, avec son historique d'achat (hors commandes rejetées).
with customers as (
    select * from {{ ref('stg_localbike__customers') }}
),
orders as (
    select
        customer_id,
        count(*)            as nb_orders,
        min(order_date)     as first_order_date,
        max(order_date)     as last_order_date,
        sum(net_revenue)    as lifetime_net_revenue
    from {{ ref('int_localbike__orders_enriched') }}
    where is_revenue_recognized
    group by customer_id
)

select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.city,
    customers.state,
    coalesce(orders.nb_orders, 0)            as nb_orders,
    orders.first_order_date,
    orders.last_order_date,
    coalesce(orders.lifetime_net_revenue, 0) as lifetime_net_revenue,
    coalesce(orders.nb_orders, 0) > 1        as is_repeat_customer
from customers
left join orders on customers.customer_id = orders.customer_id
