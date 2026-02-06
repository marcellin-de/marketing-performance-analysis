with source as (
    select 
        website_session_id,
        created_at,
        user_id,
        is_repeat_session,
        utm_source,
        utm_campaign,
        utm_content,
        device_type,
        http_referer
    from {{source("marketing_perf_source","website_sessions")}}
)

select
    website_session_id,
    created_at,
    user_id,
    is_repeat_session,
    case
        when utm_source is null or utm_source = 'NULL' then 'direct'
        when utm_source = 'gsearch' then 'google'
        when utm_source = 'bsearch' then 'bing'
        when utm_source = 'socialbook' then 'facebook'
        else 'other'
    end as utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
from source
