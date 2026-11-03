select
    cast(customer_id as int64)       as customer_id,
    trim(first_name)                 as first_name,
    trim(last_name)                  as last_name,
    nullif(trim(phone), 'NULL')      as phone,
    lower(trim(email))               as email,
    trim(street)                     as street,
    trim(city)                       as city,
    trim(state)                      as state,
    trim(zip_code)                   as zip_code
from {{ source('localbike', 'customers') }}
