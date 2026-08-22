-- =========================================================
-- 04_PRODUCTION.SQL
-- Banking Transaction & Fraud Analytics Database
-- Production Layer
-- =========================================================


-- =========================================================
-- 1. CREATE PRODUCTION SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS production;


-- =========================================================
-- 2. DROP ANALYTICAL OBJECTS
-- =========================================================

DROP MATERIALIZED VIEW IF EXISTS production.customer_risk_summary;

DROP VIEW IF EXISTS public.transaction_fraud_analysis;
DROP VIEW IF EXISTS public.customer_accounts_overview;
DROP VIEW IF EXISTS public.monthly_transaction_summary;
DROP VIEW IF EXISTS public.customer_transaction_summary;


-- =========================================================
-- 3. DROP OLD PRODUCTION TABLES
-- =========================================================

DROP TABLE IF EXISTS production.fraud_alerts;
DROP TABLE IF EXISTS production.transfers;
DROP TABLE IF EXISTS production.transactions;
DROP TABLE IF EXISTS production.cards;
DROP TABLE IF EXISTS production.merchants;
DROP TABLE IF EXISTS production.accounts;
DROP TABLE IF EXISTS production.branches;
DROP TABLE IF EXISTS production.customers;


-- =========================================================
-- 4. CUSTOMERS
-- =========================================================

CREATE TABLE production.customers (
    customer_id INT PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    date_of_birth DATE NOT NULL,

    email VARCHAR(100) UNIQUE NOT NULL,

    phone VARCHAR(50),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),

    customer_since DATE NOT NULL,

    customer_status VARCHAR(30) NOT NULL
);


-- =========================================================
-- 5. BRANCHES
-- =========================================================

CREATE TABLE production.branches (
    branch_id INT PRIMARY KEY,

    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,

    branch_type VARCHAR(50) NOT NULL
);


-- =========================================================
-- 6. ACCOUNTS
-- =========================================================

CREATE TABLE production.accounts (
    account_id INT PRIMARY KEY,

    customer_id INT NOT NULL,

    account_number VARCHAR(30) UNIQUE NOT NULL,

    account_type VARCHAR(50) NOT NULL,

    currency VARCHAR(10) NOT NULL,

    balance DECIMAL(15,2) NOT NULL,

    opened_date DATE NOT NULL,

    account_status VARCHAR(30) NOT NULL,

    branch_id INT NOT NULL,

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES production.customers(customer_id),

    CONSTRAINT fk_accounts_branch
        FOREIGN KEY (branch_id)
        REFERENCES production.branches(branch_id),

    CONSTRAINT chk_accounts_balance
        CHECK (balance >= 0)
);


-- =========================================================
-- 7. CARDS
-- =========================================================

CREATE TABLE production.cards (
    card_id INT PRIMARY KEY,

    account_id INT NOT NULL,

    card_type VARCHAR(50) NOT NULL,

    card_number_hash VARCHAR(255) UNIQUE NOT NULL,

    issue_date DATE NOT NULL,

    expiry_date DATE NOT NULL,

    card_status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_cards_account
        FOREIGN KEY (account_id)
        REFERENCES production.accounts(account_id),

    CONSTRAINT chk_cards_dates
        CHECK (expiry_date >= issue_date)
);


-- =========================================================
-- 8. MERCHANTS
-- =========================================================

CREATE TABLE production.merchants (
    merchant_id INT PRIMARY KEY,

    merchant_name VARCHAR(150) NOT NULL,

    merchant_category VARCHAR(100) NOT NULL,

    city VARCHAR(100) NOT NULL,

    country VARCHAR(100) NOT NULL,

    risk_level VARCHAR(30) NOT NULL
);


-- =========================================================
-- 9. TRANSACTIONS
-- =========================================================

CREATE TABLE production.transactions (
    transaction_id INT PRIMARY KEY,

    account_id INT NOT NULL,

    card_id INT,

    merchant_id INT,

    transaction_type VARCHAR(50) NOT NULL,

    amount DECIMAL(15,2) NOT NULL,

    currency VARCHAR(10) NOT NULL,

    transaction_date TIMESTAMP NOT NULL,

    channel VARCHAR(50) NOT NULL,

    location VARCHAR(255),

    status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES production.accounts(account_id),

    CONSTRAINT fk_transactions_card
        FOREIGN KEY (card_id)
        REFERENCES production.cards(card_id),

    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES production.merchants(merchant_id),

    CONSTRAINT chk_transactions_amount
        CHECK (amount > 0)
);


-- =========================================================
-- 10. TRANSFERS
-- =========================================================

CREATE TABLE production.transfers (
    transfer_id INT PRIMARY KEY,

    source_account_id INT NOT NULL,

    destination_account_id INT NOT NULL,

    amount DECIMAL(15,2) NOT NULL,

    currency VARCHAR(10) NOT NULL,

    transfer_date TIMESTAMP NOT NULL,

    transfer_type VARCHAR(50) NOT NULL,

    status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_transfers_source_account
        FOREIGN KEY (source_account_id)
        REFERENCES production.accounts(account_id),

    CONSTRAINT fk_transfers_destination_account
        FOREIGN KEY (destination_account_id)
        REFERENCES production.accounts(account_id),

    CONSTRAINT chk_transfers_amount
        CHECK (amount > 0),

    CONSTRAINT chk_transfers_different_accounts
        CHECK (source_account_id <> destination_account_id)
);


-- =========================================================
-- 11. FRAUD ALERTS
-- =========================================================

CREATE TABLE production.fraud_alerts (
    alert_id INT PRIMARY KEY,

    transaction_id INT NOT NULL,

    alert_type VARCHAR(50) NOT NULL,

    risk_score DECIMAL(5,2) NOT NULL,

    description VARCHAR(255),

    created_at TIMESTAMP NOT NULL,

    alert_status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_fraud_alerts_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES production.transactions(transaction_id),

    CONSTRAINT chk_fraud_risk_score
        CHECK (risk_score BETWEEN 0 AND 100)
);


-- =========================================================
-- 12. LOAD CLEAN DATA INTO PRODUCTION
-- =========================================================


-- ---------------------------------------------------------
-- CUSTOMERS
-- ---------------------------------------------------------

INSERT INTO production.customers (
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    email,
    phone,
    address,
    city,
    country,
    customer_since,
    customer_status
)
SELECT
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    email,
    phone,
    address,
    city,
    country,
    customer_since,
    customer_status
FROM cleaning.clean_customers
WHERE customer_id IS NOT NULL
  AND first_name IS NOT NULL
  AND TRIM(first_name) <> ''
  AND last_name IS NOT NULL
  AND TRIM(last_name) <> ''
  AND date_of_birth IS NOT NULL
  AND email IS NOT NULL
  AND TRIM(email) <> ''
  AND customer_since IS NOT NULL
  AND customer_status IS NOT NULL
  AND TRIM(customer_status) <> ''
ON CONFLICT (customer_id) DO NOTHING;


-- ---------------------------------------------------------
-- BRANCHES
-- ---------------------------------------------------------

INSERT INTO production.branches (
    branch_id,
    branch_name,
    city,
    country,
    branch_type
)
SELECT
    branch_id,
    branch_name,
    city,
    country,
    branch_type
FROM cleaning.clean_branches
WHERE branch_id IS NOT NULL
  AND branch_name IS NOT NULL
  AND TRIM(branch_name) <> ''
  AND city IS NOT NULL
  AND TRIM(city) <> ''
  AND country IS NOT NULL
  AND TRIM(country) <> ''
  AND branch_type IS NOT NULL
  AND TRIM(branch_type) <> ''
ON CONFLICT (branch_id) DO NOTHING;


-- ---------------------------------------------------------
-- ACCOUNTS
-- ---------------------------------------------------------

INSERT INTO production.accounts (
    account_id,
    customer_id,
    account_number,
    account_type,
    currency,
    balance,
    opened_date,
    account_status,
    branch_id
)
SELECT
    ca.account_id,
    ca.customer_id,
    ca.account_number,
    ca.account_type,
    ca.currency,
    ca.balance,
    ca.opened_date,
    ca.account_status,
    ca.branch_id
FROM cleaning.clean_accounts ca

INNER JOIN production.customers c
    ON ca.customer_id = c.customer_id

INNER JOIN production.branches b
    ON ca.branch_id = b.branch_id

WHERE ca.account_id IS NOT NULL
  AND ca.account_number IS NOT NULL
  AND TRIM(ca.account_number) <> ''
  AND ca.account_type IS NOT NULL
  AND TRIM(ca.account_type) <> ''
  AND ca.currency IS NOT NULL
  AND TRIM(ca.currency) <> ''
  AND ca.balance IS NOT NULL
  AND ca.balance >= 0
  AND ca.opened_date IS NOT NULL
  AND ca.account_status IS NOT NULL
  AND TRIM(ca.account_status) <> ''

ON CONFLICT (account_id) DO NOTHING;


-- ---------------------------------------------------------
-- CARDS
-- ---------------------------------------------------------

INSERT INTO production.cards (
    card_id,
    account_id,
    card_type,
    card_number_hash,
    issue_date,
    expiry_date,
    card_status
)
SELECT
    cc.card_id,
    cc.account_id,
    cc.card_type,
    cc.card_number_hash,
    cc.issue_date,
    cc.expiry_date,
    cc.card_status
FROM cleaning.clean_cards cc

INNER JOIN production.accounts a
    ON cc.account_id = a.account_id

WHERE cc.card_id IS NOT NULL
  AND cc.card_type IS NOT NULL
  AND TRIM(cc.card_type) <> ''
  AND cc.card_number_hash IS NOT NULL
  AND TRIM(cc.card_number_hash) <> ''
  AND cc.issue_date IS NOT NULL
  AND cc.expiry_date IS NOT NULL
  AND cc.expiry_date >= cc.issue_date
  AND cc.card_status IS NOT NULL
  AND TRIM(cc.card_status) <> ''

ON CONFLICT (card_id) DO NOTHING;


-- ---------------------------------------------------------
-- MERCHANTS
-- ---------------------------------------------------------

INSERT INTO production.merchants (
    merchant_id,
    merchant_name,
    merchant_category,
    city,
    country,
    risk_level
)
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    city,
    country,
    risk_level
FROM cleaning.clean_merchants
WHERE merchant_id IS NOT NULL
  AND merchant_name IS NOT NULL
  AND TRIM(merchant_name) <> ''
  AND merchant_category IS NOT NULL
  AND TRIM(merchant_category) <> ''
  AND city IS NOT NULL
  AND TRIM(city) <> ''
  AND country IS NOT NULL
  AND TRIM(country) <> ''
  AND risk_level IS NOT NULL
  AND TRIM(risk_level) <> ''
ON CONFLICT (merchant_id) DO NOTHING;


-- ---------------------------------------------------------
-- TRANSACTIONS
-- ---------------------------------------------------------

INSERT INTO production.transactions (
    transaction_id,
    account_id,
    card_id,
    merchant_id,
    transaction_type,
    amount,
    currency,
    transaction_date,
    channel,
    location,
    status
)
SELECT
    ct.transaction_id,
    ct.account_id,
    ct.card_id,
    ct.merchant_id,
    ct.transaction_type,
    ct.amount,
    ct.currency,
    ct.transaction_date,
    ct.channel,
    ct.location,
    ct.status
FROM cleaning.clean_transactions ct

INNER JOIN production.accounts a
    ON ct.account_id = a.account_id

LEFT JOIN production.cards c
    ON ct.card_id = c.card_id

LEFT JOIN production.merchants m
    ON ct.merchant_id = m.merchant_id

WHERE ct.transaction_id IS NOT NULL
  AND ct.transaction_type IS NOT NULL
  AND TRIM(ct.transaction_type) <> ''
  AND ct.amount IS NOT NULL
  AND ct.amount > 0
  AND ct.currency IS NOT NULL
  AND TRIM(ct.currency) <> ''
  AND ct.transaction_date IS NOT NULL
  AND ct.channel IS NOT NULL
  AND TRIM(ct.channel) <> ''
  AND ct.status IS NOT NULL
  AND TRIM(ct.status) <> ''

  -- Optional relationships must exist when provided
  AND (
        ct.card_id IS NULL
        OR c.card_id IS NOT NULL
      )

  AND (
        ct.merchant_id IS NULL
        OR m.merchant_id IS NOT NULL
      )

ON CONFLICT (transaction_id) DO NOTHING;


-- ---------------------------------------------------------
-- TRANSFERS
-- ---------------------------------------------------------

INSERT INTO production.transfers (
    transfer_id,
    source_account_id,
    destination_account_id,
    amount,
    currency,
    transfer_date,
    transfer_type,
    status
)
SELECT
    tr.transfer_id,
    tr.source_account_id,
    tr.destination_account_id,
    tr.amount,
    tr.currency,
    tr.transfer_date,
    tr.transfer_type,
    tr.status
FROM cleaning.clean_transfers tr

INNER JOIN production.accounts source_account
    ON tr.source_account_id = source_account.account_id

INNER JOIN production.accounts destination_account
    ON tr.destination_account_id = destination_account.account_id

WHERE tr.transfer_id IS NOT NULL
  AND tr.source_account_id <> tr.destination_account_id
  AND tr.amount IS NOT NULL
  AND tr.amount > 0
  AND tr.currency IS NOT NULL
  AND TRIM(tr.currency) <> ''
  AND tr.transfer_date IS NOT NULL
  AND tr.transfer_type IS NOT NULL
  AND TRIM(tr.transfer_type) <> ''
  AND tr.status IS NOT NULL
  AND TRIM(tr.status) <> ''

ON CONFLICT (transfer_id) DO NOTHING;


-- ---------------------------------------------------------
-- FRAUD ALERTS
-- ---------------------------------------------------------

INSERT INTO production.fraud_alerts (
    alert_id,
    transaction_id,
    alert_type,
    risk_score,
    description,
    created_at,
    alert_status
)
SELECT
    fa.alert_id,
    fa.transaction_id,
    fa.alert_type,
    fa.risk_score,
    fa.description,
    fa.created_at,
    fa.alert_status
FROM cleaning.clean_fraud_alerts fa

INNER JOIN production.transactions t
    ON fa.transaction_id = t.transaction_id

WHERE fa.alert_id IS NOT NULL
  AND fa.alert_type IS NOT NULL
  AND TRIM(fa.alert_type) <> ''
  AND fa.risk_score IS NOT NULL
  AND fa.risk_score BETWEEN 0 AND 100
  AND fa.created_at IS NOT NULL
  AND fa.alert_status IS NOT NULL
  AND TRIM(fa.alert_status) <> ''

ON CONFLICT (alert_id) DO NOTHING;


-- =========================================================
-- 13. PRODUCTION ROW COUNT VALIDATION
-- =========================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM production.customers

UNION ALL

SELECT
    'branches',
    COUNT(*)
FROM production.branches

UNION ALL

SELECT
    'accounts',
    COUNT(*)
FROM production.accounts

UNION ALL

SELECT
    'cards',
    COUNT(*)
FROM production.cards

UNION ALL

SELECT
    'merchants',
    COUNT(*)
FROM production.merchants

UNION ALL

SELECT
    'transactions',
    COUNT(*)
FROM production.transactions

UNION ALL

SELECT
    'transfers',
    COUNT(*)
FROM production.transfers

UNION ALL

SELECT
    'fraud_alerts',
    COUNT(*)
FROM production.fraud_alerts

ORDER BY table_name;


-- =========================================================
-- 14. PRODUCTION LOAD QUALITY CHECK
-- =========================================================

SELECT
    'customers' AS table_name,
    (SELECT COUNT(*) FROM cleaning.clean_customers) AS cleaning_count,
    (SELECT COUNT(*) FROM production.customers) AS production_count,
    (SELECT COUNT(*) FROM cleaning.clean_customers)
    -
    (SELECT COUNT(*) FROM production.customers) AS row_difference

UNION ALL

SELECT
    'branches',
    (SELECT COUNT(*) FROM cleaning.clean_branches),
    (SELECT COUNT(*) FROM production.branches),
    (SELECT COUNT(*) FROM cleaning.clean_branches)
    -
    (SELECT COUNT(*) FROM production.branches)

UNION ALL

SELECT
    'accounts',
    (SELECT COUNT(*) FROM cleaning.clean_accounts),
    (SELECT COUNT(*) FROM production.accounts),
    (SELECT COUNT(*) FROM cleaning.clean_accounts)
    -
    (SELECT COUNT(*) FROM production.accounts)

UNION ALL

SELECT
    'cards',
    (SELECT COUNT(*) FROM cleaning.clean_cards),
    (SELECT COUNT(*) FROM production.cards),
    (SELECT COUNT(*) FROM cleaning.clean_cards)
    -
    (SELECT COUNT(*) FROM production.cards)

UNION ALL

SELECT
    'merchants',
    (SELECT COUNT(*) FROM cleaning.clean_merchants),
    (SELECT COUNT(*) FROM production.merchants),
    (SELECT COUNT(*) FROM cleaning.clean_merchants)
    -
    (SELECT COUNT(*) FROM production.merchants)

UNION ALL

SELECT
    'transactions',
    (SELECT COUNT(*) FROM cleaning.clean_transactions),
    (SELECT COUNT(*) FROM production.transactions),
    (SELECT COUNT(*) FROM cleaning.clean_transactions)
    -
    (SELECT COUNT(*) FROM production.transactions)

UNION ALL

SELECT
    'transfers',
    (SELECT COUNT(*) FROM cleaning.clean_transfers),
    (SELECT COUNT(*) FROM production.transfers),
    (SELECT COUNT(*) FROM cleaning.clean_transfers)
    -
    (SELECT COUNT(*) FROM production.transfers)

UNION ALL

SELECT
    'fraud_alerts',
    (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts),
    (SELECT COUNT(*) FROM production.fraud_alerts),
    (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts)

    -
    (SELECT COUNT(*) FROM production.fraud_alerts)

ORDER BY table_name;