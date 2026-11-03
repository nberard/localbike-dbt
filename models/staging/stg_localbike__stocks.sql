select
    concat(store_id, '-', product_id)  as stock_id,
    cast(store_id as int64)            as store_id,
    cast(product_id as int64)          as product_id,
    cast(quantity as int64)            as stock_quantity
from {{ source('localbike', 'stocks') }}
