with order_items as (
    select
        order_item_id,
        created_at as order_item_created_at,
        order_id,
        product_id,
        is_primary_item,
        price_usd,
        cogs_usd
    from {{ ref('stg_order_items') }}
),

orders as (
    select
        order_id,
        created_at as order_created_at,
        website_session_id,
        user_id,
        primary_product_id
    from {{ ref('stg_orders') }}
),

products as (
    select
        product_id,
        created_at as product_created_at,
        product_name
    from {{ ref('stg_products') }}
),

refunds as (
    select
        order_item_id,
        sum(refund_amount_usd) as refund_amount_usd
    from {{ ref('stg_order_item_refunds') }}
    group by 1
)

select
    oi.order_item_id,
    oi.order_item_created_at,
    oi.order_id,
    o.order_created_at,
    o.website_session_id,
    o.user_id,
    oi.product_id,
    p.product_name,
    p.product_created_at,
    oi.is_primary_item,
    oi.price_usd,
    oi.cogs_usd,
    coalesce(r.refund_amount_usd, 0) as refund_amount_usd
from order_items oi
left join orders o
    on oi.order_id = o.order_id
left join products p
    on oi.product_id = p.product_id
left join refunds r
    on oi.order_item_id = r.order_item_id
