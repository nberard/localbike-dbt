select
    cast(brand_id as int64) as brand_id,
    trim(brand_name)        as brand_name
from {{ source('localbike', 'brands') }}
