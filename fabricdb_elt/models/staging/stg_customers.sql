-- Auto-generated DBT model for customers
{{ config(materialized='view') }}

SELECT * FROM dbo.customers
