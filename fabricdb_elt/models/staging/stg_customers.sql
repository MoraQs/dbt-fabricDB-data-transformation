-- This file is part of the dbt project for the Fabric Data Warehouse.
-- It is used to create a staging view for the customers table.

SELECT
    customer_id,
    name as customer_name,
    email as customer_email,
    city
FROM {{ source('fabricdb', 'customers') }}
