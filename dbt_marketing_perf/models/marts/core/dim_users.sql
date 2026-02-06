with sessions as (
    select
        distinct
        user_id,
        min(created_at) as first_session_at,
        max(created_at) as last_session_at,
        count(*) as total_sessions
    from {{ ref('stg_website_sessions') }}
    group by 1
),

orders as (
    select distinct
        user_id,
        min(created_at) as first_order_at,
        max(created_at) as last_order_at,
        count(*) as total_orders,
        sum(price_usd) as lifetime_revenue_usd
    from {{ ref('stg_orders') }}
    group by 1
)

select
    s.user_id,
    s.first_session_at,
    s.last_session_at,
    s.total_sessions,
    o.first_order_at,
    o.last_order_at,
    coalesce(o.total_orders, 0) as total_orders,
    coalesce(o.lifetime_revenue_usd, 0) as lifetime_revenue_usd,
    case when o.total_orders is null then 0 else 1 end as is_customer
from sessions s
left join orders o
    on s.user_id = o.user_id
