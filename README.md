# Local Bike — projet dbt (cas final Analytics Engineer, DataBird)

Local Bike est une chaîne de 3 magasins de vélos aux États-Unis (Santa Cruz CA, Baldwin NY, Rowlett TX).
Ce projet modélise ses données de ventes et de stock dans BigQuery pour donner à l'équipe des opérations
un premier tableau de bord orienté **optimisation des ventes et du chiffre d'affaires**.

## Axes d'analyse retenus

| Axe | Question opérationnelle | Modèle |
|---|---|---|
| Performance magasin | Quel magasin porte le CA, comment évoluent volume et panier moyen dans le temps ? | `mart_store_monthly_performance` |
| Mix produit | Quelles catégories et marques génèrent le CA ? Quelle part de remise accordée ? | `fct_sales` |
| Stock | Où est le stock dormant à déstocker, quels produits vendus sont en rupture ? | `mart_product_store_performance` |
| Logistique | Quelle part des commandes est expédiée en retard par rapport à la date promise ? | `mart_store_monthly_performance` |
| Clients | Quelle part du CA vient de clients récurrents ? | `dim_customers` |

## Architecture

```
localbike_raw (sources, CSV bruts, tout en STRING)
   └── staging       (views)  typage, nettoyage, 'NULL' texte -> NULL, statut décodé
         └── intermediate (views)  lignes et commandes enrichies, montants calculés
               └── marts      (tables) prêtes pour la BI, sans jointure à faire
```

| Couche | Modèles |
|---|---|
| staging | `stg_localbike__{orders, order_items, customers, products, brands, categories, stores, staffs, stocks}` |
| intermediate | `int_localbike__order_items_enriched`, `int_localbike__orders_enriched` |
| marts | `fct_sales`, `dim_products`, `dim_customers`, `mart_store_monthly_performance`, `mart_product_store_performance` |

### Règles métier

- **CA net** = `quantity × list_price × (1 − discount_rate)`.
- Le CA n'inclut que les commandes **non rejetées** (`is_revenue_recognized`).
- Statuts : 1 Pending, 2 Processing, 3 Rejected, 4 Completed.
- Une commande est **en retard** si `shipped_date > required_date`.
- **Stock dormant** : du stock mais aucune vente sur les 12 mois précédant la dernière commande.
  **Rupture** : stock à zéro alors que le produit s'est vendu sur cette période.

## Tests

70 tests : `unique`, `not_null`, `relationships` et `accepted_values` sur les clés et les statuts,
un test générique maison `unique_combination` (grain magasin × mois), et trois tests singuliers :

- `assert_discount_rate_between_0_and_1`
- `assert_shipped_after_ordered`
- `assert_net_revenue_reconciles` : le CA de `fct_sales` doit égaler celui recalculé depuis le staging.

## Premiers enseignements

- **Baldwin (NY) fait 68 % du CA** (5,14 M$ sur 7,48 M$), loin devant Santa Cruz (1,56 M$) et Rowlett (0,78 M$).
  Le panier moyen est proche dans les trois magasins (~4,6 k$ à 5,0 k$) : l'écart vient du volume de commandes.
- **Mountain Bikes et Road Bikes = 57 % du CA**. Cruisers et Children vendent beaucoup d'unités mais à petit prix.
- **32 % des commandes expédiées partent après la date promise** (37 % à Santa Cruz, 31 % à Baldwin, 26 % à Rowlett).
- **~7 M$ de stock (prix catalogue) dorment** sur 303 couples magasin × produit sans vente sur 12 mois,
  alors que 23 références vendues sont en rupture.
- **Seuls 125 clients sur 1 445 ont commandé plus d'une fois**, pour 19 % du CA.

> ⚠️ **Limite des données** : l'activité s'arrête fin avril 2018. Les 125 commandes d'avril 2018 sont toutes
> encore en attente ou en préparation, et les mois suivants ne contiennent que quelques commandes rejetées.
> La baisse apparente du CA 2018 vient de cette troncature, pas d'un recul de l'activité.
> Les analyses temporelles doivent se limiter à janvier 2016 – mars 2018.


### Rapport Data Studio

https://datastudio.google.com/s/iIVPgXTheVo

## Lancer le projet

```bash
pip install dbt-bigquery
cp profiles.yml.example ~/.dbt/profiles.yml   # adapter project / dataset
gcloud auth application-default login
dbt build      # run + test
dbt docs generate && dbt docs serve
```
