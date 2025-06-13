-- Auto-generated DBT model for orders
{{ config(materialized='view') }}

SELECT * FROM dbo.orders
