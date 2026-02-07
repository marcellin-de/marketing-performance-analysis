{{ config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='sync_all_columns'
) }}

with orders as (
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
),

sessions as (
    select
        website_session_id,
        created_at as session_created_at,
        utm_source,
        utm_campaign,
        utm_content,
        device_type,
        is_repeat_session
    from {{ ref('stg_website_sessions') }}
)

select
    o.order_id,
    o.order_created_at,
    o.order_date,
    o.website_session_id,
    o.user_id,
    o.primary_product_id,
    o.items_purchased,
    o.price_usd as order_revenue_usd,
    o.cogs_usd as order_cogs_usd,
    (o.price_usd - o.cogs_usd) as order_gross_margin_usd,
    s.session_created_at,
    s.utm_source,
    s.utm_campaign,
    s.utm_content,
    s.device_type,
    s.is_repeat_session
from orders o
left join sessions s
    on o.website_session_id = s.website_session_id
{% if is_incremental() %}
where o.order_created_at >= (
    select dateadd(day, -3, max(order_created_at)) from {{ this }}
)
{% endif %}
