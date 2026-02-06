select
    date_day,
    sum(sessions) as sessions,
    sum(repeat_sessions) as repeat_sessions,
    sum(orders) as orders,
    sum(revenue_usd) as revenue_usd,
    sum(gross_margin_usd) as gross_margin_usd,
    sum(refunds_usd) as refunds_usd,
    case when sum(sessions) = 0 then 0 else sum(orders) / sum(sessions) end as conversion_rate,
    case when sum(orders) = 0 then 0 else sum(revenue_usd) / sum(orders) end as revenue_per_order_usd,
    case when sum(sessions) = 0 then 0 else sum(revenue_usd) / sum(sessions) end as revenue_per_session_usd
from {{ ref('kpi_daily_marketing_channels') }}
group by 1
