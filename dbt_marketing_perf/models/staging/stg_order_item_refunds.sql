with source as (
    select 
    order_item_refund_id,created_at,order_item_id,order_id,refund_amount_usd

    from {{source('marketing_perf_source','order_item_refunds')}}
)


select * from source
