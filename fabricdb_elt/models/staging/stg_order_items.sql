-- Fabric: stg_order_items
-- This file is part of the dbt project for the Fabric Data Warehouse.
-- It is used to create a staging view for the order_items table.
-- Fabric: stg_order_items


-- {{ config(materialized='view') }}

SELECT
    item_id as order_item_id,
    order_id,
    product_id,
    quantity as quantity_sold
FROM dbo.order_items
