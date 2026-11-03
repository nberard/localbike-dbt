with products as (
    select * from {{ ref('stg_localbike__products') }}
),
brands as (
    select * from {{ ref('stg_localbike__brands') }}
),
categories as (
    select * from {{ ref('stg_localbike__categories') }}
),
stock as (
    select product_id, sum(stock_quantity) as total_stock_quantity
    from {{ ref('stg_localbike__stocks') }}
    group by product_id
)

select
    products.product_id,
    products.product_name,
    brands.brand_name,
    categories.category_name,
    products.model_year,
    products.list_price,
    coalesce(stock.total_stock_quantity, 0) as total_stock_quantity
from products
left join brands     on products.brand_id = brands.brand_id
left join categories on products.category_id = categories.category_id
left join stock      on products.product_id = stock.product_id
