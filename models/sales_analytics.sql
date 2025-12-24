{{ config(
    materialized='semantic_view',
    alias='SALES_ANALYTICS'
) }}

TABLES (
    -- Alias the sources for consistent referencing throughout the semantic view
    OrdersTable AS {{ source('coffee_shop_source', 'ORDERS') }}
        PRIMARY KEY (ORDER_ID, CUSTOMER_ID)
        WITH SYNONYMS=('Sales','Purchase_Orders','Customer_Orders'),

    TransactionsTable AS {{ source('coffee_shop_source', 'TRANSACTIONS') }}
        PRIMARY KEY (TRANSACTION_ID)
        UNIQUE (ORDER_ID, TRANSACTION_ID)
        WITH SYNONYMS=('Payments','Financial_Transactions')
        COMMENT='Financial transaction records including payment methods and transaction types for all customer orders'
)

RELATIONSHIPS (
    ORDER_PAYMENT_LINK AS OrdersTable(ORDER_ID, STORE_ID) -- Use alias here
        REFERENCES TransactionsTable(ORDER_ID, TRANSACTION_ID) -- Use alias here
)

FACTS (
    OrdersTable.ORDER_TOTAL AS ORDER_TOTAL -- Use alias here
        COMMENT='Total order amount in USD - used for revenue calculations and financial reporting',
    TransactionsTable.ORDER_ID AS ORDER_ID -- Use alias here
        COMMENT='Transaction count metric - used to track number of payment attempts per order and identify split payments',
    TransactionsTable.TRANSACTION_AMOUNT AS TRANSACTION_AMOUNT -- Use alias here
        COMMENT='Individual payment transaction amount - supports multi-payment orders and partial refunds'
)

DIMENSIONS (
    OrdersTable.CUSTOMER_ID AS CUSTOMER_ID -- Use alias here
        COMMENT='Unique customer identifier - links to customer master data and loyalty program',
    OrdersTable.ORDER_ID AS ORDER_ID -- Use alias here
        COMMENT='Primary order identifier - used for order lookup, tracking, and customer service inquiries',
    OrdersTable.ORDER_TYPE AS ORDER_TYPE -- Use alias here
        COMMENT='Order channel classification (in-store, mobile, web, drive-thru) - aligns with Order Channel Types business glossary term',
    OrdersTable.STORE_ID AS STORE_ID -- Use alias here
        COMMENT='Store location identifier - connects to store master data for regional analysis and performance metrics',
    TransactionsTable.PAYMENT_METHOD AS PAYMENT_METHOD -- Use alias here
        COMMENT='Payment type (credit card, debit card, mobile wallet, cash, gift card) - used for payment mix analysis and reconciliation',
    TransactionsTable.TRANSACTION_DATE AS TRANSACTION_DATE -- Use alias here
        COMMENT='Payment processing timestamp - enables time-series analysis of payment patterns and reconciliation reporting',
    TransactionsTable.TRANSACTION_ID AS TRANSACTION_ID -- Use alias here
        COMMENT='Unique payment transaction identifier - used for payment gateway reconciliation and dispute resolution',
    TransactionsTable.TRANSACTION_TYPE AS TRANSACTION_TYPE -- Use alias here
        COMMENT='Transaction classification (sale, refund, adjustment, gift_card_purchase, gift_card_redemption) - excludes gift card transactions from revenue calculations per finance team guidelines'
)

METRICS (
    OrdersTable.GROSS_REVENUE AS SUM(ORDER_TOTAL) -- Use alias here
        COMMENT='Total gross revenue from all orders - primary top-line metric for financial reporting and executive dashboards',
    TransactionsTable.NET_PAYMENT_AMOUNT AS SUM(TRANSACTION_AMOUNT) -- Use alias here
        COMMENT='Total payment amount processed - includes refunds and adjustments for reconciliation with payment gateway',
    TOTAL_ORDER_REVENUE AS OrdersTable.GROSS_REVENUE + TransactionsTable.NET_PAYMENT_AMOUNT -- Use alias here
        COMMENT='Combined revenue metric - consolidates order value and actual payments received for comprehensive revenue analysis'
)

COMMENT='Unified sales and payment analytics semantic view - provides integrated view of order and transaction data for revenue reporting, payment reconciliation, and business intelligence'
