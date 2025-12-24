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
    -- Test: Reference a metric defined in the semantic view
    SalesView.GROSS_REVENUE AS SV_GROSS_REVENUE
        COMMENT='GROSS_REVENUE metric from sales_analytics semantic view',

    -- Test: Create new metric from source table
    RAW_TOTAL_REVENUE AS SUM(O.ORDER_TOTAL)
        COMMENT='New metric from source table',

    -- Test: Combine semantic view metric with source table metric
    COMBINED_METRIC AS SalesView.GROSS_REVENUE + SUM(O.ORDER_TOTAL)
        COMMENT='Combining semantic view metric with source table aggregation'
)

COMMENT='Test: semantic view + source table column/metric access'
