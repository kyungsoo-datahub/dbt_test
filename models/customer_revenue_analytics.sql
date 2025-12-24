-- Semantic view combining: materialized semantic view + raw table
-- Pattern: semantic view -> SEMANTIC_VIEW() function -> regular view -> new semantic view

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

TABLES (
    -- Reference the materialized view (from sales_analytics semantic view)
    SalesView AS {{ ref('sales_analytics_view') }}
        PRIMARY KEY (ORDER_ID),

    -- Reference raw ORDERS table for additional columns
    O AS {{ source('coffee_shop_source', 'ORDERS') }}
        PRIMARY KEY (ORDER_ID)
)

RELATIONSHIPS (
    SALES_ORDER_LINK AS SalesView(ORDER_ID)
        REFERENCES O(ORDER_ID)
)

FACTS (
    -- From materialized semantic view (TOTAL_ORDER_REVENUE metric is now a column)
    SalesView.TOTAL_ORDER_REVENUE AS TOTAL_ORDER_REVENUE
        COMMENT='Total order revenue from sales_analytics semantic view',

    SalesView.GROSS_REVENUE AS GROSS_REVENUE
        COMMENT='Gross revenue from sales_analytics semantic view',

    -- From raw orders table
    O.ORDER_TOTAL AS ORDER_TOTAL
        COMMENT='Order total directly from ORDERS table'
)

DIMENSIONS (
    SalesView.CUSTOMER_ID AS CUSTOMER_ID
        COMMENT='Customer ID from sales_analytics',

    SalesView.ORDER_TYPE AS ORDER_TYPE
        COMMENT='Order type from sales_analytics',

    O.STORE_ID AS STORE_ID
        COMMENT='Store ID from ORDERS table'
)

METRICS (
    -- Metric using materialized semantic view metric (now a fact)
    SalesView.TOTAL_REVENUE_SUM AS SUM(TOTAL_ORDER_REVENUE)
        COMMENT='Sum of total order revenue from materialized semantic view',

    -- Metric from raw table
    O.RAW_REVENUE AS SUM(ORDER_TOTAL)
        COMMENT='Sum of order totals from raw ORDERS table',

    -- Combined metric: semantic view metric + raw table metric
    COMBINED_REVENUE AS SalesView.TOTAL_REVENUE_SUM + O.RAW_REVENUE
        COMMENT='Combined: materialized semantic view metric + raw table metric'
)

COMMENT='Semantic view chaining: sales_analytics -> materialized view -> new semantic view + ORDERS table'
