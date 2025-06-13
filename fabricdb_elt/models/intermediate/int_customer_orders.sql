
-- This SQL file is part of the FabricDB ELT project.
-- It creates a view that aggregates customer orders with product details.
-- The view combines order items with orders and products to provide a comprehensive view of customer purchases.
    
    SELECT
        ord.order_date,
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        ord.customer_id,
        prd.price,
        oi.quantity_sold,
        prd.price * oi.quantity_sold AS line_amount
    FROM 
        {{ ref('stg_order_items') }} AS oi
    LEFT JOIN {{ ref('stg_orders') }} AS ord
        ON oi.order_id = ord.order_id
    LEFT JOIN {{ ref('stg_products') }} AS prd
        ON oi.product_id = prd.productId
