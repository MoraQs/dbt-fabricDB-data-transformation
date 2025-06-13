-- Auto-generated DBT model for products
{{ config(materialized='view') }}

SELECT * FROM dbo.products
