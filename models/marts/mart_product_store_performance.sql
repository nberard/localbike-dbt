-- Ventes et stock par produit et par magasin : repérer best-sellers, ruptures et stock dormant.
-- "12 derniers mois" = relatif à la dernière date de commande du dataset.
with sales as (
    select * from {{ ref('fct_sales') }}
    where is_revenue_recognized
),
max_date as (
    select max(order_date) as max_order_date from sales
),
sales_agg as (
    select
        sales.store_id,
        sales.product_id,
        sum(sales.quantity)       as units_sold,
        sum(sales.net_revenue)    as net_revenue,
        sum(sales.discount_amount) as discount_amount,
        sum(if(sales.order_date > date_sub(max_date.max_order_date, interval 12 month), sales.quantity, 0))
                                  as units_sold_last_12m
    from sales
    cross join max_date
    group by sales.store_id, sales.product_id
),
stocks as (
    select * from {{ ref('stg_localbike__stocks') }}
),
store_products as (
    -- tous les couples magasin x produit présents en stock ou vendus
    select store_id, product_id from stocks
    union distinct
    select store_id, product_id from sales_agg
),
products as (
    select * from {{ ref('dim_products') }}
),
stores as (
    select * from {{ ref('stg_localbike__stores') }}
)

select
    concat(sp.store_id, '-', sp.product_id)          as store_product_id,
    sp.store_id,
    stores.store_name,
    sp.product_id,
    products.product_name,
    products.brand_name,
    products.category_name,
    products.list_price,
    coalesce(sales_agg.units_sold, 0)                as units_sold,
    coalesce(sales_agg.units_sold_last_12m, 0)       as units_sold_last_12m,
    coalesce(sales_agg.net_revenue, 0)               as net_revenue,
    safe_divide(sales_agg.discount_amount, sales_agg.net_revenue + sales_agg.discount_amount)
                                                     as avg_discount_rate,
    coalesce(stocks.stock_quantity, 0)               as stock_quantity,
    coalesce(stocks.stock_quantity, 0) * products.list_price as stock_value_at_list_price,
    -- mois de stock au rythme de vente des 12 derniers mois
    safe_divide(coalesce(stocks.stock_quantity, 0), coalesce(sales_agg.units_sold_last_12m, 0) / 12)
                                                     as months_of_stock,
    coalesce(stocks.stock_quantity, 0) > 0
        and coalesce(sales_agg.units_sold_last_12m, 0) = 0 as is_dormant_stock,
    coalesce(stocks.stock_quantity, 0) = 0
        and coalesce(sales_agg.units_sold_last_12m, 0) > 0 as is_out_of_stock_seller
from store_products sp
left join sales_agg on sp.store_id = sales_agg.store_id and sp.product_id = sales_agg.product_id
left join stocks    on sp.store_id = stocks.store_id and sp.product_id = stocks.product_id
left join products  on sp.product_id = products.product_id
left join stores    on sp.store_id = stores.store_id
