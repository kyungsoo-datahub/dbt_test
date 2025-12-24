-- models/customer_revenue_analytics.sql

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

-- This semantic view "chains" on top of another semantic view (SALES_ANALYTICS)
-- and a raw source table (CUSTOMERS) to create more complex, layered metrics.

TABLES (
    -- Reference your existing semantic view using ref()
    {{ ref('SALES_ANALYTICS') }},

    -- Reference the raw customers table using source()
    {{ source('coffee_shop_source', 'CUSTOMERS') }}
)

RELATIONSHIPS (
    -- Define the join key between the two tables
    SALES_ANALYTICS(CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
)

-- Expose underlying columns as facts and dimensions to make them available for metrics
FACTS (
    -- This fact comes from the upstream SALES_ANALYTICS semantic view
    SALES_ANALYTICS.TOTAL_ORDER_REVENUE
)

DIMENSIONS (
    -- These dimensions come from the CUSTOMERS source table
    CUSTOMERS.COUNTRY,
    CUSTOMERS.LOYALTY_TIER
)

METRICS (
    -- Define a new, chained metric that uses data from both upstream tables.
    -- This metric calculates a customer's revenue adjusted for their loyalty status.
    LOYALTY_ADJUSTED_REVENUE AS
        CASE
            WHEN CUSTOMERS.LOYALTY_TIER = 'GOLD' THEN SALES_ANALYTICS.TOTAL_ORDER_REVENUE * 0.9
            ELSE SALES_ANALYTICS.TOTAL_ORDER_REVENUE
        END
        COMMENT='Total order revenue adjusted for customer loyalty discounts.'
)

COMMENT='A chained semantic view that combines sales analytics with customer loyalty data.'
