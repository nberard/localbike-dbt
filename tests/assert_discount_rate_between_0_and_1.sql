-- Une remise doit être comprise entre 0 et 1.
select *
from {{ ref('stg_localbike__order_items') }}
where discount_rate < 0 or discount_rate > 1
