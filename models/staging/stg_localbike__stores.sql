select
    cast(store_id as int64)   as store_id,
    trim(store_name)          as store_name,
    trim(phone)               as phone,
    lower(trim(email))        as email,
    trim(street)              as street,
    trim(city)                as city,
    trim(state)               as state,
    trim(zip_code)            as zip_code
from {{ source('localbike', 'stores') }}
