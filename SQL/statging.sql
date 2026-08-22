-- =========================================================
-- 01_STAGING.SQL
-- Banking Transaction & Fraud Analytics Database
-- =========================================================


-- =========================================================
-- CREATE STAGING SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS staging;


-- =========================================================
-- STAGING TABLE: CUSTOMERS
-- =========================================================

CREATE TABLE staging.customers (
    customer_id TEXT,
    first_name TEXT,
    last_name TEXT,
    date_of_birth TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    customer_since TEXT,
    customer_status TEXT
);


-- =========================================================
-- STAGING TABLE: BRANCHES
-- =========================================================

CREATE TABLE staging.branches (
    branch_id TEXT,
    branch_name TEXT,
    city TEXT,
    country TEXT,
    branch_type TEXT
);


-- =========================================================
-- STAGING TABLE: ACCOUNTS
-- =========================================================

CREATE TABLE staging.accounts (
    account_id TEXT,
    customer_id TEXT,
    account_number TEXT,
    account_type TEXT,
    currency TEXT,
    balance TEXT,
    opened_date TEXT,
    account_status TEXT,
    branch_id TEXT
);


-- =========================================================
-- STAGING TABLE: CARDS
-- =========================================================

CREATE TABLE staging.cards (
    card_id TEXT,
    account_id TEXT,
    card_type TEXT,
    card_number_hash TEXT,
    issue_date TEXT,
    expiry_date TEXT,
    card_status TEXT
);


-- =========================================================
-- STAGING TABLE: MERCHANTS
-- =========================================================

CREATE TABLE staging.merchants (
    merchant_id TEXT,
    merchant_name TEXT,
    merchant_category TEXT,
    city TEXT,
    country TEXT,
    risk_level TEXT
);


-- =========================================================
-- STAGING TABLE: TRANSACTIONS
-- =========================================================

CREATE TABLE staging.transactions (
    transaction_id TEXT,
    account_id TEXT,
    card_id TEXT,
    merchant_id TEXT,
    transaction_type TEXT,
    amount TEXT,
    currency TEXT,
    transaction_date TEXT,
    channel TEXT,
    location TEXT,
    status TEXT
);


-- =========================================================
-- STAGING TABLE: TRANSFERS
-- =========================================================

CREATE TABLE staging.transfers (
    transfer_id TEXT,
    source_account_id TEXT,
    destination_account_id TEXT,
    amount TEXT,
    currency TEXT,
    transfer_date TEXT,
    transfer_type TEXT,
    status TEXT
);


-- =========================================================
-- STAGING TABLE: FRAUD ALERTS
-- =========================================================

CREATE TABLE staging.fraud_alerts (
    alert_id TEXT,
    transaction_id TEXT,
    alert_type TEXT,
    risk_score TEXT,
    description TEXT,
    created_at TEXT,
    alert_status TEXT
);

SELECT 'customers' AS table_name, COUNT(*) FROM staging.customers
UNION ALL
SELECT 'branches', COUNT(*) FROM staging.branches
UNION ALL
SELECT 'accounts', COUNT(*) FROM staging.accounts
UNION ALL
SELECT 'cards', COUNT(*) FROM staging.cards
UNION ALL
SELECT 'merchants', COUNT(*) FROM staging.merchants
UNION ALL
SELECT 'transactions', COUNT(*) FROM staging.transactions
UNION ALL
SELECT 'transfers', COUNT(*) FROM staging.transfers
UNION ALL
SELECT 'fraud_alerts', COUNT(*) FROM staging.fraud_alerts;