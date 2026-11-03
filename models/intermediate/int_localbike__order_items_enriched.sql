-- Une ligne par article commandé, enrichie du produit et des montants.
with items as (
    select * from {{ ref('stg_localbike__order_items') }}
),
products as (
    select * from {{ ref('stg_localbike__products') }}
),
brands as (
    select * from {{ ref('stg_localbike__brands') }}
),
categories as (
    select * from {{ ref('stg_localbike__categories') }}
)

select
    items.order_item_id,
    items.order_id,
    items.item_id,
    items.product_id,
    products.product_name,
    products.model_year,
    brands.brand_name,
    categories.category_name,
    items.quantity,
    items.list_price,
    items.discount_rate,
    items.quantity * items.list_price                              as gross_revenue,
    items.quantity * items.list_price * items.discount_rate        as discount_amount,
    items.quantity * items.list_price * (1 - items.discount_rate)  as net_revenue
from items
left join products   on items.product_id = products.product_id
left join brands     on products.brand_id = brands.brand_id
left join categories on products.category_id = categories.category_id
