select
    cast(order_id as int64)                                   as order_id,
    cast(customer_id as int64)                                as customer_id,
    cast(store_id as int64)                                   as store_id,
    cast(staff_id as int64)                                   as staff_id,
    cast(order_status as int64)                               as order_status_code,
    case cast(order_status as int64)
        when 1 then 'Pending'
        when 2 then 'Processing'
        when 3 then 'Rejected'
        when 4 then 'Completed'
    end                                                       as order_status,
    cast(order_date as date)                                  as order_date,
    cast(required_date as date)                               as required_date,
    safe_cast(nullif(shipped_date, 'NULL') as date)           as shipped_date
from {{ source('localbike', 'orders') }}
