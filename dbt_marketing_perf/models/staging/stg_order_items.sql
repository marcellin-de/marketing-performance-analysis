with source as (
    select
        order_item_id,created_at,order_id,product_id,is_primary_item,price_usd,cogs_usd
    from {{source("marketing_perf_source","order_items")}}
)


select * from source