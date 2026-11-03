-- Table de faits principale, une ligne par article commandé.
-- Toutes les dimensions utiles sont déjà jointes : utilisable en self-service sans jointure.
with items as (
    select * from {{ ref('int_localbike__order_items_enriched') }}
),
orders as (
    select * from {{ ref('int_localbike__orders_enriched') }}
),
customers as (
    select * from {{ ref('stg_localbike__customers') }}
)

select
    items.order_item_id,
    items.order_id,
    orders.order_date,
    orders.order_month,
    orders.order_status,
    orders.is_revenue_recognized,
    orders.store_id,
    orders.store_name,
    orders.staff_id,
    orders.staff_full_name,
    orders.customer_id,
    customers.city   as customer_city,
    customers.state  as customer_state,
    items.product_id,
    items.product_name,
    items.brand_name,
    items.category_name,
    items.model_year,
    items.quantity,
    items.list_price,
    items.discount_rate,
    items.gross_revenue,
    items.discount_amount,
    items.net_revenue
from items
inner join orders on items.order_id = orders.order_id
left join customers on orders.customer_id = customers.customer_id
