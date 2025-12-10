CREATE OR REPLACE SEMANTIC VIEW WAREHOUSE_COFFEE_COMPANY.PUBLIC.WAREHOUSE_SALES_PAYMENT_ANALYTICS
        

TABLES (
    -- USE SOURCE FUNCTION HERE
    WAREHOUSE_COFFEE_COMPANY.PUBLIC.ORDERS
        PRIMARY KEY (ORDER_ID, CUSTOMER_ID) 
        WITH SYNONYMS=('Sales','Purchase_Orders','Customer_Orders'),
        
    WAREHOUSE_COFFEE_COMPANY.PUBLIC.TRANSACTIONS
        PRIMARY KEY (TRANSACTION_ID) 
        UNIQUE (ORDER_ID, TRANSACTION_ID) 
        WITH SYNONYMS=('Payments','Financial_Transactions') 
        COMMENT='Financial transaction records including payment methods and transaction types for all customer orders'
)

RELATIONSHIPS (
    -- Important: The names inside RELATIONSHIPS refer to the *aliases* or *table names* -- defined in the TABLES block above. Since source() returns the full path (DB.SCHEMA.TABLE),
    -- Snowflake's Semantic View usually expects you to refer to them by their base name 
    -- or the alias you give them.
    
    -- In Semantic View syntax, if you don't provide an alias in the TABLES block, 
    -- the implicit name is the table name (ORDERS, TRANSACTIONS).
    
    ORDER_PAYMENT_LINK AS ORDERS(ORDER_ID, STORE_ID) 
        REFERENCES TRANSACTIONS(ORDER_ID, TRANSACTION_ID)
)

FACTS (
    orders.ORDER_TOTAL AS ORDER_TOTAL 
        COMMENT='Total order amount in USD - used for revenue calculations and financial reporting',
    transactions.ORDER_ID AS ORDER_ID 
        COMMENT='Transaction count metric - used to track number of payment attempts per order and identify split payments',
    transactions.TRANSACTION_AMOUNT AS TRANSACTION_AMOUNT 
        COMMENT='Individual payment transaction amount - supports multi-payment orders and partial refunds'
)

DIMENSIONS (
    ORDERS.CUSTOMER_ID AS CUSTOMER_ID 
        COMMENT='Unique customer identifier - links to customer master data and loyalty program',
    ORDERS.ORDER_ID AS ORDER_ID 
        COMMENT='Primary order identifier - used for order lookup, tracking, and customer service inquiries',
    ORDERS.ORDER_TYPE AS ORDER_TYPE 
        COMMENT='Order channel classification (in-store, mobile, web, drive-thru) - aligns with Order Channel Types business glossary term',
    ORDERS.STORE_ID AS STORE_ID 
        COMMENT='Store location identifier - connects to store master data for regional analysis and performance metrics',
    TRANSACTIONS.PAYMENT_METHOD AS PAYMENT_METHOD 
        COMMENT='Payment type (credit card, debit card, mobile wallet, cash, gift card) - used for payment mix analysis and reconciliation',
    TRANSACTIONS.TRANSACTION_DATE AS TRANSACTION_DATE 
        COMMENT='Payment processing timestamp - enables time-series analysis of payment patterns and reconciliation reporting',
    TRANSACTIONS.TRANSACTION_ID AS TRANSACTION_ID 
        COMMENT='Unique payment transaction identifier - used for payment gateway reconciliation and dispute resolution',
    TRANSACTIONS.TRANSACTION_TYPE AS TRANSACTION_TYPE 
        COMMENT='Transaction classification (sale, refund, adjustment, gift_card_purchase, gift_card_redemption) - excludes gift card transactions from revenue calculations per finance team guidelines'
)

METRICS (
    ORDERS.GROSS_REVENUE AS SUM(ORDER_TOTAL) 
        COMMENT='Total gross revenue from all orders - primary top-line metric for financial reporting and executive dashboards',
    TRANSACTIONS.NET_PAYMENT_AMOUNT AS SUM(TRANSACTION_AMOUNT) 
        COMMENT='Total payment amount processed - includes refunds and adjustments for reconciliation with payment gateway',
    TOTAL_ORDER_REVENUE AS ORDERS.GROSS_REVENUE + TRANSACTIONS.NET_PAYMENT_AMOUNT 
        COMMENT='Combined revenue metric - consolidates order value and actual payments received for comprehensive revenue analysis'
)

COMMENT='Unified sales and payment analytics semantic view - provides integrated view of order and transaction data for revenue reporting, payment reconciliation, and business intelligence'

WITH EXTENSION (
    CA='{"tables":[{"name":"ORDERS","dimensions":[{"name":"CUSTOMER_ID"},{"name":"ORDER_ID"},{"name":"ORDER_TYPE"},{"name":"STORE_ID"}],"facts":[{"name":"ORDER_TOTAL"}],"metrics":[{"name":"GROSS_REVENUE"}]},{"name":"TRANSACTIONS","dimensions":[{"name":"PAYMENT_METHOD"},{"name":"TRANSACTION_ID"},{"name":"TRANSACTION_TYPE"}],"facts":[{"name":"ORDER_ID"},{"name":"TRANSACTION_AMOUNT"}],"metrics":[{"name":"NET_PAYMENT_AMOUNT"}],"time_dimensions":[{"name":"TRANSACTION_DATE"}]}],"relationships":[{"name":"ORDER_PAYMENT_LINK"}]}'
)