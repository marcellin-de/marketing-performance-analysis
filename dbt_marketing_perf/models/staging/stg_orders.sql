
WITH source_orders AS (

    SELECT 
    order_id,created_at,website_session_id,user_id,primary_product_id,items_purchased,price_usd,cogs_usd

    FROM {{source('marketing_perf_source','orders')}}
)

SELECT * FROM source_orders