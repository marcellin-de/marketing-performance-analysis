select
    order_item_refund_id,
    created_at as refund_created_at,
    date_trunc('day', created_at) as refund_date,
    order_item_id,
    order_id,
    refund_amount_usd
from {{ ref('stg_order_item_refunds') }}
