-- KPIs mensuels par magasin pour l'équipe des opérations.
-- Le CA ne compte que les commandes non rejetées.
with orders as (
    select * from {{ ref('int_localbike__orders_enriched') }}
)

select
    store_id,
    store_name,
    order_month,
    count(*)                                                    as nb_orders,
    countif(order_status = 'Rejected')                          as nb_rejected_orders,
    countif(not is_shipped and order_status != 'Rejected')      as nb_open_orders,
    count(distinct customer_id)                                 as nb_customers,
    sum(if(is_revenue_recognized, total_quantity, 0))           as units_sold,
    sum(if(is_revenue_recognized, gross_revenue, 0))            as gross_revenue,
    sum(if(is_revenue_recognized, discount_amount, 0))          as discount_amount,
    sum(if(is_revenue_recognized, net_revenue, 0))              as net_revenue,
    safe_divide(
        sum(if(is_revenue_recognized, net_revenue, 0)),
        countif(is_revenue_recognized)
    )                                                           as avg_order_value,
    safe_divide(countif(is_shipped_late), countif(is_shipped))  as late_shipment_rate,
    avg(shipping_delay_days)                                    as avg_shipping_delay_days
from orders
group by store_id, store_name, order_month
