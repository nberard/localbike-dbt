-- Une ligne par commande : magasin, vendeur, montants agrégés et logistique.
with orders as (
    select * from {{ ref('stg_localbike__orders') }}
),
items as (
    select
        order_id,
        count(*)            as nb_lines,
        sum(quantity)       as total_quantity,
        sum(gross_revenue)  as gross_revenue,
        sum(discount_amount) as discount_amount,
        sum(net_revenue)    as net_revenue
    from {{ ref('int_localbike__order_items_enriched') }}
    group by order_id
),
stores as (
    select * from {{ ref('stg_localbike__stores') }}
),
staffs as (
    select * from {{ ref('stg_localbike__staffs') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.store_id,
    stores.store_name,
    stores.state                                   as store_state,
    orders.staff_id,
    staffs.staff_full_name,
    orders.order_status_code,
    orders.order_status,
    orders.order_status != 'Rejected'              as is_revenue_recognized,
    orders.order_date,
    date_trunc(orders.order_date, month)           as order_month,
    orders.required_date,
    orders.shipped_date,
    orders.shipped_date is not null                as is_shipped,
    date_diff(orders.shipped_date, orders.order_date, day) as shipping_delay_days,
    orders.shipped_date > orders.required_date     as is_shipped_late,
    items.nb_lines,
    items.total_quantity,
    items.gross_revenue,
    items.discount_amount,
    items.net_revenue
from orders
left join items  on orders.order_id = items.order_id
left join stores on orders.store_id = stores.store_id
left join staffs on orders.staff_id = staffs.staff_id
