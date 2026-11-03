-- Une commande ne peut pas être expédiée avant d'avoir été passée.
select *
from {{ ref('stg_localbike__orders') }}
where shipped_date < order_date
