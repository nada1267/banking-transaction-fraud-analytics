-- =========================================================
-- 06_ANALYTICAL_LAYER.SQL
-- Banking Transaction & Fraud Analytics Database
-- Analytical Layer
-- =========================================================


-- =========================================================
-- 1. CUSTOMER ACCOUNTS OVERVIEW
-- Business-facing analytical view
-- =========================================================

CREATE OR REPLACE VIEW public.customer_accounts_overview AS

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,

    a.account_id,
    a.account_number,
    a.account_type,
    a.currency,
    a.balance,
    a.account_status,

    b.branch_id,
    b.branch_name,
    b.city AS branch_city,
    b.country AS branch_country

FROM production.customers c

JOIN production.accounts a
    ON c.customer_id = a.customer_id

JOIN production.branches b
    ON a.branch_id = b.branch_id;


-- =========================================================
-- 2. TRANSACTION FRAUD ANALYSIS
-- Combines transaction, customer, account,
-- merchant and fraud information.
--
-- LEFT JOIN is used for fraud alerts because
-- transactions without alerts must remain visible.
-- =========================================================

CREATE OR REPLACE VIEW public.transaction_fraud_analysis AS

SELECT
    t.transaction_id,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.currency,
    t.channel,
    t.location,
    t.status AS transaction_status,

    -- Account information
    a.account_id,
    a.account_number,
    a.account_type,

    -- Customer information
    c.customer_id,
    c.first_name,
    c.last_name,

    -- Merchant information
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.risk_level,

    -- Fraud information
    f.alert_id,
    f.alert_type,
    f.risk_score,
    f.alert_status,
    f.created_at AS alert_created_at,

    -- Derived fraud risk level
    CASE
        WHEN f.risk_score >= 80
            THEN 'High Risk'

        WHEN f.risk_score >= 50
            THEN 'Medium Risk'

        WHEN f.risk_score IS NOT NULL
            THEN 'Low Risk'

        ELSE 'No Alert'
    END AS fraud_risk_level

FROM production.transactions t

JOIN production.accounts a
    ON t.account_id = a.account_id

JOIN production.customers c
    ON a.customer_id = c.customer_id

LEFT JOIN production.merchants m
    ON t.merchant_id = m.merchant_id

LEFT JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id;


-- =========================================================
-- 3. MONTHLY TRANSACTION SUMMARY
-- Aggregated analytical view for reporting.
-- =========================================================

CREATE OR REPLACE VIEW public.monthly_transaction_summary AS

SELECT
    DATE_TRUNC('month', transaction_date) AS transaction_month,

    COUNT(*) AS transaction_count,

    COALESCE(SUM(amount), 0) AS total_amount,

    COALESCE(
        ROUND(AVG(amount), 2),
        0
    ) AS average_amount,

    COALESCE(MIN(amount), 0) AS minimum_amount,

    COALESCE(MAX(amount), 0) AS maximum_amount

FROM production.transactions

WHERE transaction_date IS NOT NULL

GROUP BY
    DATE_TRUNC('month', transaction_date);


-- =========================================================
-- 4. CUSTOMER TRANSACTION SUMMARY
-- Customer-level aggregation.
--
-- LEFT JOIN keeps customers with no transactions.
-- =========================================================

CREATE OR REPLACE VIEW public.customer_transaction_summary AS

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id) AS transaction_count,

    COALESCE(
        SUM(t.amount),
        0
    ) AS total_transaction_amount,

    COALESCE(
        ROUND(AVG(t.amount), 2),
        0
    ) AS average_transaction_amount,

    COALESCE(
        MIN(t.amount),
        0
    ) AS minimum_transaction_amount,

    COALESCE(
        MAX(t.amount),
        0
    ) AS maximum_transaction_amount

FROM production.customers c

LEFT JOIN production.accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN production.transactions t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;


-- =========================================================
-- 5. CUSTOMER RISK SUMMARY
-- Materialized View
--
-- Customer-level fraud analytics.
-- =========================================================

DROP MATERIALIZED VIEW IF EXISTS
production.customer_risk_summary;


CREATE MATERIALIZED VIEW production.customer_risk_summary AS

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(DISTINCT t.transaction_id)
        AS total_transactions,

    COUNT(DISTINCT f.transaction_id)
        AS fraud_transactions,

    COALESCE(
        ROUND(AVG(f.risk_score), 2),
        0
    ) AS average_risk_score,

    COALESCE(
        MAX(f.risk_score),
        0
    ) AS maximum_risk_score,

    CASE
        WHEN COALESCE(MAX(f.risk_score), 0) >= 80
            THEN 'High Risk'

        WHEN COALESCE(MAX(f.risk_score), 0) >= 50
            THEN 'Medium Risk'

        WHEN MAX(f.risk_score) IS NOT NULL
            THEN 'Low Risk'

        ELSE 'No Risk Data'
    END AS customer_risk_level

FROM production.customers c

LEFT JOIN production.accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN production.transactions t
    ON a.account_id = t.account_id

LEFT JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;


-- =========================================================
-- 6. INDEX FOR MATERIALIZED VIEW
-- Improves lookup performance by customer_id.
-- =========================================================

CREATE UNIQUE INDEX IF NOT EXISTS
idx_customer_risk_summary_customer_id

ON production.customer_risk_summary(customer_id);


-- =========================================================
-- 7. REFRESH MATERIALIZED VIEW
-- =========================================================

REFRESH MATERIALIZED VIEW
production.customer_risk_summary;


-- =========================================================
-- 8. ANALYTICAL VALIDATION
-- =========================================================


-- ---------------------------------------------------------
-- CUSTOMER ACCOUNTS OVERVIEW
-- ---------------------------------------------------------

SELECT *
FROM public.customer_accounts_overview
LIMIT 10;


-- ---------------------------------------------------------
-- TRANSACTION FRAUD ANALYSIS
-- ---------------------------------------------------------

SELECT *
FROM public.transaction_fraud_analysis
LIMIT 10;


-- ---------------------------------------------------------
-- MONTHLY TRANSACTION SUMMARY
-- ---------------------------------------------------------

SELECT *
FROM public.monthly_transaction_summary
ORDER BY transaction_month;


-- ---------------------------------------------------------
-- CUSTOMER TRANSACTION SUMMARY
-- ---------------------------------------------------------

SELECT *
FROM public.customer_transaction_summary
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- ---------------------------------------------------------
-- CUSTOMER RISK SUMMARY
-- ---------------------------------------------------------

SELECT *
FROM production.customer_risk_summary
ORDER BY maximum_risk_score DESC
LIMIT 10;


-- =========================================================
-- 9. ANALYTICAL QUALITY CHECKS
-- =========================================================

-- Check number of analytical records

SELECT
    'customer_accounts_overview' AS object_name,
    COUNT(*) AS row_count
FROM public.customer_accounts_overview

UNION ALL

SELECT
    'transaction_fraud_analysis',
    COUNT(*)
FROM public.transaction_fraud_analysis

UNION ALL

SELECT
    'monthly_transaction_summary',
    COUNT(*)
FROM public.monthly_transaction_summary

UNION ALL

SELECT
    'customer_transaction_summary',
    COUNT(*)
FROM public.customer_transaction_summary

UNION ALL

SELECT
    'customer_risk_summary',
    COUNT(*)
FROM production.customer_risk_summary;


-- =========================================================
-- 10. FRAUD RISK DISTRIBUTION
-- =========================================================

SELECT
    fraud_risk_level,
    COUNT(*) AS transaction_count
FROM public.transaction_fraud_analysis
GROUP BY fraud_risk_level
ORDER BY transaction_count DESC;


-- =========================================================
-- END OF ANALYTICAL LAYER
-- =========================================================