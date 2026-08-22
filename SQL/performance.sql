-- =========================================================
-- 10_PERFORMANCE.SQL
-- Banking Transaction & Fraud Analytics Database
-- Performance Testing & Benchmarking Layer
-- =========================================================


-- =========================================================
-- STEP 1: UPDATE TABLE STATISTICS
-- PostgreSQL uses statistics to choose the best query plan.
-- =========================================================

ANALYZE production.customers;
ANALYZE production.branches;
ANALYZE production.accounts;
ANALYZE production.cards;
ANALYZE production.merchants;
ANALYZE production.transactions;
ANALYZE production.transfers;
ANALYZE production.fraud_alerts;


-- =========================================================
-- TEST 1: ACCOUNT-BASED QUERY
-- Tests index:
-- idx_production_transactions_account_id
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE account_id = 759;


-- =========================================================
-- TEST 2: DATE-RANGE QUERY
-- Tests index:
-- idx_production_transactions_date
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE transaction_date >= '2026-01-01'
  AND transaction_date < '2026-02-01';


-- =========================================================
-- TEST 3: HIGH-VALUE TRANSACTION QUERY
-- Tests index:
-- idx_production_transactions_amount
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE amount > 10000;


-- =========================================================
-- TEST 4: COMPOSITE TRANSACTION INDEX
-- Tests index:
-- idx_production_transactions_account_date
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE account_id = 759
  AND transaction_date >= '2026-01-01'
  AND transaction_date < '2026-02-01'
ORDER BY
    transaction_date;


-- =========================================================
-- TEST 5: CARD-BASED TRANSACTION QUERY
-- Tests index:
-- idx_production_transactions_card_id
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    card_id,
    amount,
    transaction_date
FROM production.transactions
WHERE card_id = 759;


-- =========================================================
-- TEST 6: FRAUD RISK QUERY
-- Tests index:
-- idx_production_fraud_alerts_risk_score
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    alert_id,
    transaction_id,
    risk_score,
    alert_type,
    alert_status
FROM production.fraud_alerts
WHERE risk_score >= 80
ORDER BY
    risk_score DESC;


-- =========================================================
-- TEST 7: FRAUD STATUS + RISK QUERY
-- Tests composite index:
-- idx_production_fraud_alerts_status_risk
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    alert_id,
    transaction_id,
    risk_score,
    alert_type,
    alert_status
FROM production.fraud_alerts
WHERE alert_status = 'Open'
  AND risk_score >= 80
ORDER BY
    risk_score DESC;


-- =========================================================
-- TEST 8: MERCHANT RISK QUERY
-- Tests index:
-- idx_production_merchants_risk_level
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    risk_level
FROM production.merchants
WHERE risk_level = 'High';


-- =========================================================
-- TEST 9: INDEX SCAN VS SEQUENTIAL SCAN
--
-- Temporarily disable index and bitmap scans.
-- This is only for benchmarking purposes.
-- =========================================================

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE account_id = 759;


-- =========================================================
-- TEST 10: RESTORE NORMAL POSTGRESQL SETTINGS
-- =========================================================

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;


-- =========================================================
-- TEST 11: SAME QUERY WITH INDEXES ENABLED
-- Compare with TEST 9.
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date
FROM production.transactions
WHERE account_id = 759;


-- =========================================================
-- TEST 12: JOIN PERFORMANCE
-- Customer → Account → Transaction
--
-- Tests:
-- accounts.customer_id index
-- transactions.account_id index
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id) AS transaction_count,

    SUM(t.amount) AS total_amount

FROM production.customers c

JOIN production.accounts a
    ON c.customer_id = a.customer_id

JOIN production.transactions t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY
    total_amount DESC

LIMIT 10;


-- =========================================================
-- TEST 13: TRANSACTION AGGREGATION PERFORMANCE
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    account_id,

    COUNT(*) AS transaction_count,

    SUM(amount) AS total_amount

FROM production.transactions

GROUP BY
    account_id

HAVING COUNT(*) > 20

ORDER BY
    transaction_count DESC;


-- =========================================================
-- TEST 14: FRAUD JOIN PERFORMANCE
-- Transactions + Fraud Alerts
--
-- Tests:
-- fraud_alerts.transaction_id index
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    t.transaction_id,
    t.account_id,
    t.amount,
    t.transaction_date,

    f.risk_score,
    f.alert_type,
    f.alert_status

FROM production.transactions t

JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id

WHERE f.risk_score >= 80

ORDER BY
    f.risk_score DESC;


-- =========================================================
-- TEST 15: TRANSFER ACCOUNT LOOKUP
-- Tests:
-- idx_production_transfers_source_account
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transfer_id,
    source_account_id,
    destination_account_id,
    amount,
    transfer_date,
    status

FROM production.transfers

WHERE source_account_id = 759

ORDER BY
    transfer_date DESC;


-- =========================================================
-- TEST 16: TRANSFER DATE + STATUS QUERY
-- Tests composite index:
-- idx_production_transfers_date_status
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transfer_id,
    source_account_id,
    destination_account_id,
    amount,
    transfer_date,
    status

FROM production.transfers

WHERE transfer_date >= '2026-01-01'
  AND transfer_date < '2026-02-01'
  AND status = 'Completed'

ORDER BY
    transfer_date;


-- =========================================================
-- TEST 17: CARDS → ACCOUNTS JOIN
-- Tests:
-- idx_production_cards_account_id
-- =========================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.card_id,
    c.card_type,
    c.card_status,
    a.account_id,
    a.account_number

FROM production.cards c

JOIN production.accounts a
    ON c.account_id = a.account_id

WHERE a.account_id = 759;


-- =========================================================
-- FINAL: CURRENT QUERY PLANNER SETTINGS
-- =========================================================

SELECT
    name,
    setting
FROM pg_settings
WHERE name IN (
    'enable_indexscan',
    'enable_bitmapscan',
    'enable_seqscan'
)
ORDER BY
    name;