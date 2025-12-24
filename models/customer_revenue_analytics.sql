-- Semantic view combining: regular view (from sales_analytics logic) + ORDERS table
-- Demonstrates using pre-computed metrics from a view + raw table columns

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

TABLES (
    -- Reference the materialized view (contains TOTAL_ORDER_REVENUE_RAW)
    SalesView AS {{ ref('sales_analytics_view') }}
        PRIMARY KEY (ORDER_ID),

    -- Reference raw ORDERS table for additional columns
    O AS {{ source('coffee_shop_source', 'ORDERS') }}
        PRIMARY KEY (ORDER_ID)
)

RELATIONSHIPS (
    -- Join the view with the orders table on ORDER_ID
    SALES_ORDER_LINK AS SalesView(ORDER_ID)
        REFERENCES O(ORDER_ID)
)

FACTS (
    -- From the view (pre-computed total order revenue)
    SalesView.TOTAL_ORDER_REVENUE_RAW AS TOTAL_ORDER_REVENUE
        COMMENT='Pre-computed total order revenue from sales analytics view',

    -- From raw orders table
    O.ORDER_TOTAL AS RAW_ORDER_TOTAL
        COMMENT='Order total directly from ORDERS table'
)

DIMENSIONS (
    -- From the view
    SalesView.CUSTOMER_ID AS CUSTOMER_ID
        COMMENT='Customer ID from sales analytics view',

    SalesView.ORDER_TYPE AS ORDER_TYPE
        COMMENT='Order type from sales analytics view',

    -- From raw orders table
    O.STORE_ID AS STORE_ID
        COMMENT='Store ID from ORDERS table'
)

METRICS (
    -- Table-scoped metric from view (must use TableAlias.MetricName syntax)
    SalesView.TOTAL_REVENUE AS SUM(TOTAL_ORDER_REVENUE)
        COMMENT='Sum of total order revenue from view',

    -- Table-scoped metric from raw table
    O.RAW_REVENUE AS SUM(RAW_ORDER_TOTAL)
        COMMENT='Sum of order totals from raw ORDERS table',

    -- Derived metric: combines table-scoped metrics (not facts)
    COMBINED_REVENUE AS SalesView.TOTAL_REVENUE + O.RAW_REVENUE
        COMMENT='Combined metric using view metric + raw table metric'
)

COMMENT='Semantic view combining sales analytics view with raw ORDERS table'
