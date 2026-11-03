select
    cast(category_id as int64) as category_id,
    trim(category_name)        as category_name
from {{ source('localbike', 'categories') }}
