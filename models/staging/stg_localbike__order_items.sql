select
    -- clé technique : une ligne de commande = (order_id, item_id)
    concat(order_id, '-', item_id)    as order_item_id,
    cast(order_id as int64)           as order_id,
    cast(item_id as int64)            as item_id,
    cast(product_id as int64)         as product_id,
    cast(quantity as int64)           as quantity,
    cast(list_price as numeric)       as list_price,
    cast(discount as numeric)         as discount_rate
from {{ source('localbike', 'order_items') }}
