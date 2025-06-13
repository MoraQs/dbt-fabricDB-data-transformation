-- Auto-generated DBT model for order_items
{{ config(materialized='view') }}

SELECT * FROM dbo.order_items
