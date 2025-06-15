-- This file is part of the FabricDB ELT project.
-- It creates a fact table that aggregates customer orders with product details.
-- The fact table combines order items with orders and products to provide a comprehensive view of customer purchases.

SELECT
    order_date,
    item_id,
    order_id,
    product_id,
    customer_id,
    quantity,
    line_amount
FROM
    {{ ref('int_customer_orders') }}