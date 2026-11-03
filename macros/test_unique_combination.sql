{% test unique_combination(model, columns) %}
-- Échoue si une combinaison de colonnes apparaît plus d'une fois.
select {{ columns | join(', ') }}, count(*) as nb
from {{ model }}
group by {{ columns | join(', ') }}
having count(*) > 1
{% endtest %}
