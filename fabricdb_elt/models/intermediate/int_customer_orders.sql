
-- This SQL file is part of the FabricDB ELT project.
-- It creates a view that aggregates customer orders with product details.
-- The view combines order items with orders and products to provide a comprehensive view of customer purchases.
    
    SELECT
        od.order_date,
        oi.item_id,
        oi.order_id,
        oi.product_id,
        od.customer_id,
        pr.price,
        oi.quantity,
        pr.price * oi.quantity AS line_amount
    FROM 
        {{ ref('stg_order_items') }} AS oi
    LEFT JOIN {{ ref('stg_orders') }} AS od
        ON oi.order_id = od.order_id
    LEFT JOIN {{ ref('stg_products') }} AS pr
        ON oi.product_id = pr.product_id