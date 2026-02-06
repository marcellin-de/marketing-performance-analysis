
with source as (
    select 
        website_pageview_id,created_at,website_session_id,pageview_url
    from {{source("marketing_perf_source","website_pages")}}
)

select * from source

