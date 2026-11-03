select
    cast(staff_id as int64)                          as staff_id,
    trim(first_name)                                 as first_name,
    trim(last_name)                                  as last_name,
    concat(trim(first_name), ' ', trim(last_name))   as staff_full_name,
    lower(trim(email))                               as email,
    trim(phone)                                      as phone,
    cast(active as int64) = 1                        as is_active,
    cast(store_id as int64)                          as store_id,
    safe_cast(nullif(manager_id, 'NULL') as int64)   as manager_id
from {{ source('localbike', 'staffs') }}
