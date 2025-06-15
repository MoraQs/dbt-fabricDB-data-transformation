
SELECT 
    product_id,
    product_name,
    product_category 
FROM 
    {{ ref('stg_products') }}