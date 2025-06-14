-- This file is part of the dbt project for the Fabric Data Warehouse.
-- It is used to create a staging view for the products table.
-- Fabric: stg_products

SELECT
    product_id,
    product_name,
    category as product_category,
    price
FROM {{ source('fabricdb', 'products') }}