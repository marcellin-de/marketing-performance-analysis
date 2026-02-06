WITH source AS (
    select
        product_id,created_at,product_name
    from {{source("marketing_perf_source","products")}}
)


select * from source