with sessions as (
    select
        session_date as date_day,
        utm_source,
        count(*) as sessions,
        count_if(is_repeat_session = 1) as repeat_sessions
    from {{ ref('fct_sessions') }}
    group by 1, 2
),

orders as (
    select
        order_date as date_day,
        utm_source,
        count(*) as orders,
        sum(order_revenue_usd) as revenue_usd,
        sum(order_gross_margin_usd) as gross_margin_usd
    from {{ ref('fct_orders') }}
    group by 1, 2
),

refunds as (
    select
        o.order_date as date_day,
        o.utm_source,
        sum(oi.refund_amount_usd) as refunds_usd
    from {{ ref('fct_order_items') }} oi
    left join {{ ref('fct_orders') }} o
        on oi.order_id = o.order_id
    group by 1, 2
),

combined as (
    select
        coalesce(s.date_day, o.date_day) as date_day,
        coalesce(s.utm_source, o.utm_source) as utm_source,
        coalesce(s.sessions, 0) as sessions,
        coalesce(s.repeat_sessions, 0) as repeat_sessions,
        coalesce(o.orders, 0) as orders,
        coalesce(o.revenue_usd, 0) as revenue_usd,
        coalesce(o.gross_margin_usd, 0) as gross_margin_usd,
        coalesce(r.refunds_usd, 0) as refunds_usd
    from sessions s
    full outer join orders o
        on s.date_day = o.date_day
        and s.utm_source = o.utm_source
    left join refunds r
        on coalesce(s.date_day, o.date_day) = r.date_day
        and coalesce(s.utm_source, o.utm_source) = r.utm_source
)

select
    date_day,
    utm_source,
    sessions,
    repeat_sessions,
    orders,
    revenue_usd,
    gross_margin_usd,
    refunds_usd,
    case when sessions = 0 then 0 else orders / sessions end as conversion_rate,
    case when orders = 0 then 0 else revenue_usd / orders end as revenue_per_order_usd,
    case when sessions = 0 then 0 else revenue_usd / sessions end as revenue_per_session_usd
from combined
