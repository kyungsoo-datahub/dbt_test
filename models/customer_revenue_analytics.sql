-- models/customer_revenue_analytics.sql

{{ config(
    materialized='semantic_view',
    alias='CUSTOMER_REVENUE_ANALYTICS'
) }}

TABLES (
    -- Reference the existing semantic view
    SalesView AS {{ ref('sales_analytics') }},

    -- Explicitly include the raw TRANSACTIONS source table again, giving it an alias 'T'
    T AS {{ source('coffee_shop_source', 'TRANSACTIONS') }}
        PRIMARY KEY (TRANSACTION_ID),

    -- Include the ORDERS source table for direct access to ORDER_TOTAL
    O AS {{ source('coffee_shop_source', 'ORDERS') }}
        PRIMARY KEY (ORDER_ID)
)

RELATIONSHIPS (
    -- Define how the SALES_ANALYTICS view joins back to the raw TRANSACTIONS table
    SALES_TO_TRANSACTIONS AS SalesView(ORDER_ID) REFERENCES T(ORDER_ID),

    -- Link ORDERS to TRANSACTIONS via ORDER_ID
    ORDERS_TO_TRANSACTIONS AS O(ORDER_ID) REFERENCES T(ORDER_ID)
)

-- Expose columns from both upstream sources
FACTS (
    -- This fact comes from the ORDERS source table
    O.ORDER_TOTAL AS ORDER_TOTAL
        COMMENT='Total order amount from the orders table',

    -- This fact comes directly from the newly joined TRANSACTIONS table (aliased as T)
    T.TRANSACTION_AMOUNT AS TRANSACTION_AMOUNT
        COMMENT='Transaction amount from the raw transactions table'
)

DIMENSIONS (
    -- This dimension comes from the newly joined TRANSACTIONS table
    T.PAYMENT_METHOD AS PAYMENT_METHOD
        COMMENT='Payment method from the raw transactions table'
)

METRICS (
    -- This metric explicitly combines a column from the SALES_ANALYTICS view
    -- with a column from the directly-joined TRANSACTIONS table.
    REVENUE_TO_TRANSACTION_RATIO AS SUM(ORDER_TOTAL) / NULLIF(SUM(TRANSACTION_AMOUNT), 0)
        COMMENT='The ratio of total order revenue from the sales view to the total transaction amount from the raw transactions table.'
)

COMMENT='A semantic view that explicitly joins an existing view with a source table.'