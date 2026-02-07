{{ config(
    materialized='incremental',
    unique_key='website_session_id',
    on_schema_change='sync_all_columns'
) }}

with sessions_orders as (
    select
        website_session_id,
        session_created_at,
        session_date,
        user_id,
        is_repeat_session,
        utm_source,
        utm_campaign,
        utm_content,
        device_type,
        http_referer,
        order_id,
        order_created_at,
        items_purchased,
        price_usd,
        cogs_usd,
        is_order_session
    from {{ ref('int_sessions_orders') }}
)

select
    website_session_id,
    session_created_at,
    session_date,
    user_id,
    is_repeat_session,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer,
    order_id,
    order_created_at,
    items_purchased,
    price_usd as order_revenue_usd,
    cogs_usd as order_cogs_usd,
    (price_usd - cogs_usd) as order_gross_margin_usd,
    is_order_session
from sessions_orders
{% if is_incremental() %}
where session_created_at >= (
    select dateadd(day, -3, max(session_created_at)) from {{ this }}
)
{% endif %}
