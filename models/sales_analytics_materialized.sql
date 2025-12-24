-- Materialize the sales_analytics semantic view as a regular view
-- This allows it to be used in another semantic view

{{ config(
    materialized='view',
    alias='SALES_ANALYTICS_MATERIALIZED'
) }}

SELECT * FROM SEMANTIC_VIEW(
    {{ ref('sales_analytics') }}
    DIMENSIONS OrdersTable.CUSTOMER_ID, OrdersTable.ORDER_ID, OrdersTable.ORDER_TYPE, OrdersTable.STORE_ID
    METRICS OrdersTable.GROSS_REVENUE
)
