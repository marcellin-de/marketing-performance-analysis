with source as (
    select 
        website_session_id,created_at,user_id,is_repeat_session,utm_source,utm_campaign,utm_content,device_type,http_referer
    from {{source("marketing_perf_source","website_sessions")}}
)

select * from source

