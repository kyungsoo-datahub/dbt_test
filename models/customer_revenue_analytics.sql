-- Test: combining semantic view columns/metrics with source table columns

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

TABLES (
    -- Reference the existing semantic view
    SalesView AS {{ ref('sales_analytics') }},

    -- Include a source table
    O AS {{ source('coffee_shop_source', 'ORDERS') }}
        PRIMARY KEY (ORDER_ID)
)

METRICS (
    -- Test: Create metric using FACT from semantic view (ORDER_TOTAL is a FACT in sales_analytics)
    SV_TOTAL_REVENUE AS SUM(SalesView.ORDER_TOTAL)
        COMMENT='Revenue metric using ORDER_TOTAL fact from sales_analytics semantic view',

    -- Test: Create new metric from source table
    RAW_TOTAL_REVENUE AS SUM(O.ORDER_TOTAL)
        COMMENT='New metric from source table',

    -- Test: Combine semantic view fact with source table column
    COMBINED_METRIC AS SUM(SalesView.ORDER_TOTAL) + SUM(O.ORDER_TOTAL)
        COMMENT='Combining semantic view fact with source table aggregation'
)

COMMENT='Test: semantic view + source table column/metric access'
