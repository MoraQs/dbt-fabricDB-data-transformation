-- Fabric: stg_orders


-- {{ config(materialized='view') }}

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM dbo.orders