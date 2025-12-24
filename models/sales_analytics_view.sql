-- Regular view that materializes sales analytics logic
-- This allows the semantic view to reference pre-computed metrics like TOTAL_ORDER_REVENUE

{{ config(
    materialized='view',
    alias='SALES_ANALYTICS_VIEW'
) }}

SELECT
    -- Dimensions from Orders
    o.ORDER_ID,
    o.CUSTOMER_ID,
    o.ORDER_TYPE,
    o.STORE_ID,
    o.ORDER_TOTAL,

    -- Dimensions from Transactions
    t.TRANSACTION_ID,
    t.PAYMENT_METHOD,
    t.TRANSACTION_DATE,
    t.TRANSACTION_TYPE,
    t.TRANSACTION_AMOUNT,

    -- Pre-computed: TOTAL_ORDER_REVENUE = ORDER_TOTAL + TRANSACTION_AMOUNT
    -- (At row level, actual aggregation happens in semantic view)
    o.ORDER_TOTAL + COALESCE(t.TRANSACTION_AMOUNT, 0) AS TOTAL_ORDER_REVENUE

FROM {{ source('coffee_shop_source', 'ORDERS') }} o
LEFT JOIN {{ source('coffee_shop_source', 'TRANSACTIONS') }} t
    ON o.ORDER_ID = t.ORDER_ID
