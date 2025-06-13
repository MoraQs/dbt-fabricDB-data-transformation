-- This file is part of the dbt project for the Fabric Data Warehouse.
-- It is used to create a staging view for the customers table.

-- {{ config(materialized='view') }}

SELECT
    customer_id as customerId,
    name as customerName,
    email as customerEmail,
    city
FROM dbo.customers
