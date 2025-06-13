
SELECT 
    productId,
    productName,
    productCategory 
FROM 
    {{ ref('stg_products') }}