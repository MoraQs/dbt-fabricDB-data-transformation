-- This file is part of the dbt project for the Fabric Data Warehouse.
-- It is used to create a staging view for the products table.
-- Fabric: stg_products


-- {{ config(materialized='view') }}

SELECT
    product_id as productId,
    product_name as productName,
    category as productCategory,
    price
FROM dbo.products