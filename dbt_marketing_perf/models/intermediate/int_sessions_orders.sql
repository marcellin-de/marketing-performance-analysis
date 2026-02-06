with sessions as (
    select
        website_session_id,
        created_at as session_created_at,
        date_trunc('day', created_at) as session_date,
        user_id,
        is_repeat_session,
        utm_source,
        utm_campaign,
        utm_content,
        device_type,
        http_referer
    from {{ ref('stg_website_sessions') }}
),

orders as (
    select
        order_id,
        created_at as order_created_at,
        date_trunc('day', created_at) as order_date,
        website_session_id,
        user_id,
        primary_product_id,
        items_purchased,
        price_usd,
        cogs_usd
    from {{ ref('stg_orders') }}
)

select
    s.website_session_id,
    s.session_created_at,
    s.session_date,
    s.user_id,
    s.is_repeat_session,
    s.utm_source,
    s.utm_campaign,
    s.utm_content,
    s.device_type,
    s.http_referer,
    o.order_id,
    o.order_created_at,
    o.order_date,
    o.primary_product_id,
    o.items_purchased,
    o.price_usd,
    o.cogs_usd,
    case when o.order_id is null then 0 else 1 end as is_order_session
from sessions s
left join orders o
    on s.website_session_id = o.website_session_id
