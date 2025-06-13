-- This file is part of the FabricDB ELT project.
-- It creates a staging table for customer data, which is used in the customer dimension model.
-- The staging table aggregates customer information from various sources to provide a comprehensive view of customer data.

SELECT * FROM {{ ref('stg_customers') }}