-- Le CA net de fct_sales doit être identique au CA calculé depuis les données staging.
with mart as (
    select round(sum(net_revenue), 2) as total from {{ ref('fct_sales') }}
),
source as (
    select round(sum(quantity * list_price * (1 - discount_rate)), 2) as total
    from {{ ref('stg_localbike__order_items') }}
)
select mart.total as mart_total, source.total as source_total
from mart cross join source
where mart.total != source.total
