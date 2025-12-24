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

-- Test: Try to access semantic view's exposed columns
FACTS (
    -- From semantic view
    SalesView.ORDER_TOTAL AS SV_ORDER_TOTAL
        COMMENT='ORDER_TOTAL fact from sales_analytics semantic view',

    SalesView.TRANSACTION_AMOUNT AS SV_TRANSACTION_AMOUNT
        COMMENT='TRANSACTION_AMOUNT fact from sales_analytics semantic view',

    -- From source table
    O.ORDER_TOTAL AS RAW_ORDER_TOTAL
        COMMENT='ORDER_TOTAL directly from ORDERS source table'
)

DIMENSIONS (
    -- From semantic view
    SalesView.CUSTOMER_ID AS SV_CUSTOMER_ID
        COMMENT='CUSTOMER_ID dimension from sales_analytics semantic view',

    -- From source table
    O.ORDER_ID AS RAW_ORDER_ID
        COMMENT='ORDER_ID directly from ORDERS source table'
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
