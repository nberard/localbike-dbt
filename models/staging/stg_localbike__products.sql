select
    cast(product_id as int64)     as product_id,
    trim(product_name)            as product_name,
    cast(brand_id as int64)       as brand_id,
    cast(category_id as int64)    as category_id,
    cast(model_year as int64)     as model_year,
    cast(list_price as numeric)   as list_price
from {{ source('localbike', 'products') }}
