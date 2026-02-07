{{ config(
    materialized='incremental',
    unique_key='order_item_id',
    on_schema_change='sync_all_columns'
) }}

select
    order_item_id,
    order_item_created_at,
    order_id,
    order_created_at,
    website_session_id,
    user_id,
    product_id,
    product_name,
    product_created_at,
    is_primary_item,
    price_usd as item_revenue_usd,
    cogs_usd as item_cogs_usd,
    (price_usd - cogs_usd) as item_gross_margin_usd,
    refund_amount_usd
from {{ ref('int_order_items_enriched') }}
{% if is_incremental() %}
where order_item_created_at >= (
    select dateadd(day, -3, max(order_item_created_at)) from {{ this }}
)
{% endif %}
