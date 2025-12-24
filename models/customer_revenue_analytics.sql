-- models/customer_revenue_analytics.sql

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

TABLES (
    -- Reference the existing semantic view
    {{ ref('SALES_ANALYTICS') }},

    -- Explicitly include the raw TRANSACTIONS source table again, giving it an alias 'T'
    {{ source('coffee_shop_source', 'TRANSACTIONS') }} AS T
)

RELATIONSHIPS (
    -- Define how the SALES_ANALYTICS view joins back to the raw TRANSACTIONS table
    -- We'll use ORDER_ID as the join key.
    SALES_ANALYTICS(ORDER_ID) REFERENCES T(ORDER_ID)
)

-- Expose columns from both upstream sources
FACTS (
    -- This fact comes from the SALES_ANALYTICS semantic view
    SALES_ANALYTICS.ORDER_TOTAL,

    -- This fact comes directly from the newly joined TRANSACTIONS table (aliased as T)
    T.TRANSACTION_AMOUNT
)

DIMENSIONS (
    -- This dimension comes from the newly joined TRANSACTIONS table
    T.PAYMENT_METHOD
)

METRICS (
    -- This metric explicitly combines a column from the SALES_ANALYTICS view
    -- with a column from the directly-joined TRANSACTIONS table.
    REVENUE_TO_TRANSACTION_RATIO AS SUM(SALES_ANALYTICS.ORDER_TOTAL) / NULLIF(SUM(T.TRANSACTION_AMOUNT), 0)
        COMMENT='The ratio of total order revenue from the sales view to the total transaction amount from the raw transactions table.'
)

COMMENT='A semantic view that explicitly joins an existing view with a source table.'