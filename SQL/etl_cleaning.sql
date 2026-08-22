-- =========================================================
-- 03_ETL_CLEANING.SQL
-- Banking Transaction & Fraud Analytics Database
-- =========================================================
-- Purpose:
--     Transform raw staging data into clean, typed datasets.
--
-- ETL Flow:
--     STAGING
--        ↓
--     VALIDATION
--        ↓
--     CLEANING / STANDARDIZATION
--        ↓
--     CLEANING TABLES
--        ↓
--     PRODUCTION
--
-- Invalid records are captured in:
--     cleaning.rejected_records
-- =========================================================


-- =========================================================
-- 1. CREATE CLEANING SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS cleaning;


-- =========================================================
-- 2. DROP PREVIOUS CLEANING TABLES
-- =========================================================

DROP TABLE IF EXISTS cleaning.clean_customers;
DROP TABLE IF EXISTS cleaning.clean_branches;
DROP TABLE IF EXISTS cleaning.clean_accounts;
DROP TABLE IF EXISTS cleaning.clean_cards;
DROP TABLE IF EXISTS cleaning.clean_merchants;
DROP TABLE IF EXISTS cleaning.clean_transactions;
DROP TABLE IF EXISTS cleaning.clean_transfers;
DROP TABLE IF EXISTS cleaning.clean_fraud_alerts;

DROP TABLE IF EXISTS cleaning.rejected_records;


-- =========================================================
-- 3. REJECTED RECORDS TABLE
-- =========================================================

CREATE TABLE cleaning.rejected_records (
    rejection_id BIGSERIAL PRIMARY KEY,
    source_table VARCHAR(100) NOT NULL,
    record_id TEXT,
    rejection_reason TEXT NOT NULL,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- 4. CAPTURE INVALID CUSTOMERS
-- =========================================================

INSERT INTO cleaning.rejected_records (
    source_table,
    record_id,
    rejection_reason
)
SELECT
    'customers',
    customer_id,
    'Missing customer_id'
FROM staging.customers
WHERE NULLIF(TRIM(customer_id), '') IS NULL;


INSERT INTO cleaning.rejected_records (
    source_table,
    record_id,
    rejection_reason
)
SELECT
    'customers',
    customer_id,
    'Invalid customer_id: must be numeric'
FROM staging.customers
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
  AND TRIM(customer_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records (
    source_table,
    record_id,
    rejection_reason
)
SELECT
    'customers',
    customer_id,
    'Invalid date_of_birth: expected YYYY-MM-DD'
FROM staging.customers
WHERE NULLIF(TRIM(date_of_birth), '') IS NOT NULL
  AND TRIM(date_of_birth) !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';


-- =========================================================
-- 5. CAPTURE INVALID BRANCHES
-- =========================================================

INSERT INTO cleaning.rejected_records (
    source_table,
    record_id,
    rejection_reason
)
SELECT
    'branches',
    branch_id,
    'Missing branch_id'
FROM staging.branches
WHERE NULLIF(TRIM(branch_id), '') IS NULL;


INSERT INTO cleaning.rejected_records (
    source_table,
    record_id,
    rejection_reason
)
SELECT
    'branches',
    branch_id,
    'Invalid branch_id: must be numeric'
FROM staging.branches
WHERE NULLIF(TRIM(branch_id), '') IS NOT NULL
  AND TRIM(branch_id) !~ '^[0-9]+$';


-- =========================================================
-- 6. CAPTURE INVALID ACCOUNTS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Missing account_id'
FROM staging.accounts
WHERE NULLIF(TRIM(account_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Invalid account_id: must be numeric'
FROM staging.accounts
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL
  AND TRIM(account_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Missing customer_id'
FROM staging.accounts
WHERE NULLIF(TRIM(customer_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Invalid customer_id: must be numeric'
FROM staging.accounts
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
  AND TRIM(customer_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Invalid balance: must be numeric'
FROM staging.accounts
WHERE NULLIF(TRIM(balance), '') IS NOT NULL
  AND TRIM(balance) !~ '^-?[0-9]+(\.[0-9]+)?$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Missing branch_id'
FROM staging.accounts
WHERE NULLIF(TRIM(branch_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Invalid branch_id: must be numeric'
FROM staging.accounts
WHERE NULLIF(TRIM(branch_id), '') IS NOT NULL
  AND TRIM(branch_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'accounts',
    account_id,
    'Invalid opened_date: expected YYYY-MM-DD'
FROM staging.accounts
WHERE NULLIF(TRIM(opened_date), '') IS NOT NULL
  AND TRIM(opened_date) !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';


-- =========================================================
-- 7. CAPTURE INVALID CARDS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Missing card_id'
FROM staging.cards
WHERE NULLIF(TRIM(card_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Invalid card_id: must be numeric'
FROM staging.cards
WHERE NULLIF(TRIM(card_id), '') IS NOT NULL
  AND TRIM(card_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Missing account_id'
FROM staging.cards
WHERE NULLIF(TRIM(account_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Invalid account_id: must be numeric'
FROM staging.cards
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL
  AND TRIM(account_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Invalid issue_date: expected YYYY-MM-DD'
FROM staging.cards
WHERE NULLIF(TRIM(issue_date), '') IS NOT NULL
  AND TRIM(issue_date) !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'cards',
    card_id,
    'Invalid expiry_date: expected YYYY-MM-DD'
FROM staging.cards
WHERE NULLIF(TRIM(expiry_date), '') IS NOT NULL
  AND TRIM(expiry_date) !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';


-- =========================================================
-- 8. CAPTURE INVALID MERCHANTS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'merchants',
    merchant_id,
    'Missing merchant_id'
FROM staging.merchants
WHERE NULLIF(TRIM(merchant_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'merchants',
    merchant_id,
    'Invalid merchant_id: must be numeric'
FROM staging.merchants
WHERE NULLIF(TRIM(merchant_id), '') IS NOT NULL
  AND TRIM(merchant_id) !~ '^[0-9]+$';


-- =========================================================
-- 9. CAPTURE INVALID TRANSACTIONS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Missing transaction_id'
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid transaction_id: must be numeric'
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_id), '') IS NOT NULL
  AND TRIM(transaction_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Missing account_id'
FROM staging.transactions
WHERE NULLIF(TRIM(account_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid account_id: must be numeric'
FROM staging.transactions
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL
  AND TRIM(account_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid card_id: must be numeric'
FROM staging.transactions
WHERE NULLIF(TRIM(card_id), '') IS NOT NULL
  AND TRIM(card_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid merchant_id: must be numeric'
FROM staging.transactions
WHERE NULLIF(TRIM(merchant_id), '') IS NOT NULL
  AND TRIM(merchant_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid amount: must be numeric'
FROM staging.transactions
WHERE NULLIF(TRIM(amount), '') IS NOT NULL
  AND TRIM(amount) !~ '^-?[0-9]+(\.[0-9]+)?$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid amount: must be greater than zero'
FROM staging.transactions
WHERE TRIM(amount) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) <= 0;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transactions',
    transaction_id,
    'Invalid transaction_date: expected timestamp format'
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_date), '') IS NOT NULL
  AND TRIM(transaction_date)
      !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$';


-- =========================================================
-- 10. CAPTURE INVALID TRANSFERS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Missing transfer_id'
FROM staging.transfers
WHERE NULLIF(TRIM(transfer_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid transfer_id: must be numeric'
FROM staging.transfers
WHERE NULLIF(TRIM(transfer_id), '') IS NOT NULL
  AND TRIM(transfer_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Missing source_account_id'
FROM staging.transfers
WHERE NULLIF(TRIM(source_account_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid source_account_id: must be numeric'
FROM staging.transfers
WHERE NULLIF(TRIM(source_account_id), '') IS NOT NULL
  AND TRIM(source_account_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Missing destination_account_id'
FROM staging.transfers
WHERE NULLIF(TRIM(destination_account_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid destination_account_id: must be numeric'
FROM staging.transfers
WHERE NULLIF(TRIM(destination_account_id), '') IS NOT NULL
  AND TRIM(destination_account_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid amount: must be numeric'
FROM staging.transfers
WHERE NULLIF(TRIM(amount), '') IS NOT NULL
  AND TRIM(amount) !~ '^-?[0-9]+(\.[0-9]+)?$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid amount: must be greater than zero'
FROM staging.transfers
WHERE TRIM(amount) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) <= 0;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Source and destination accounts must be different'
FROM staging.transfers
WHERE TRIM(source_account_id) ~ '^[0-9]+$'
  AND TRIM(destination_account_id) ~ '^[0-9]+$'
  AND TRIM(source_account_id)::INT
      = TRIM(destination_account_id)::INT;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'transfers',
    transfer_id,
    'Invalid transfer_date: expected timestamp format'
FROM staging.transfers
WHERE NULLIF(TRIM(transfer_date), '') IS NOT NULL
  AND TRIM(transfer_date)
      !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$';


-- =========================================================
-- 11. CAPTURE INVALID FRAUD ALERTS
-- =========================================================

INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Missing alert_id'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(alert_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Invalid alert_id: must be numeric'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(alert_id), '') IS NOT NULL
  AND TRIM(alert_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Missing transaction_id'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(transaction_id), '') IS NULL;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Invalid transaction_id: must be numeric'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(transaction_id), '') IS NOT NULL
  AND TRIM(transaction_id) !~ '^[0-9]+$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Invalid risk_score: must be numeric'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(risk_score), '') IS NOT NULL
  AND TRIM(risk_score) !~ '^-?[0-9]+(\.[0-9]+)?$';


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Invalid risk_score: must be between 0 and 100'
FROM staging.fraud_alerts
WHERE TRIM(risk_score) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND TRIM(risk_score)::DECIMAL(5,2) NOT BETWEEN 0 AND 100;


INSERT INTO cleaning.rejected_records
    (source_table, record_id, rejection_reason)
SELECT
    'fraud_alerts',
    alert_id,
    'Invalid created_at: expected timestamp format'
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(created_at), '') IS NOT NULL
  AND TRIM(created_at)
      !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$';


-- =========================================================
-- 12. CLEAN CUSTOMERS
-- =========================================================

CREATE TABLE cleaning.clean_customers AS
SELECT
    TRIM(customer_id)::INT AS customer_id,
    NULLIF(TRIM(first_name), '') AS first_name,
    NULLIF(TRIM(last_name), '') AS last_name,
    NULLIF(TRIM(date_of_birth), '')::DATE AS date_of_birth,
    LOWER(NULLIF(TRIM(email), '')) AS email,
    NULLIF(TRIM(phone), '') AS phone,
    NULLIF(TRIM(address), '') AS address,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(country), '') AS country,
    NULLIF(TRIM(customer_since), '')::DATE AS customer_since,
    INITCAP(NULLIF(TRIM(customer_status), '')) AS customer_status
FROM staging.customers
WHERE TRIM(customer_id) ~ '^[0-9]+$'
  AND (
        NULLIF(TRIM(date_of_birth), '') IS NULL
        OR TRIM(date_of_birth) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      );


-- =========================================================
-- 13. CLEAN BRANCHES
-- =========================================================

CREATE TABLE cleaning.clean_branches AS
SELECT
    TRIM(branch_id)::INT AS branch_id,
    NULLIF(TRIM(branch_name), '') AS branch_name,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(country), '') AS country,
    INITCAP(NULLIF(TRIM(branch_type), '')) AS branch_type
FROM staging.branches
WHERE TRIM(branch_id) ~ '^[0-9]+$';


-- =========================================================
-- 14. CLEAN ACCOUNTS
-- =========================================================

CREATE TABLE cleaning.clean_accounts AS
SELECT
    TRIM(account_id)::INT AS account_id,
    TRIM(customer_id)::INT AS customer_id,
    NULLIF(TRIM(account_number), '') AS account_number,
    INITCAP(NULLIF(TRIM(account_type), '')) AS account_type,
    UPPER(NULLIF(TRIM(currency), '')) AS currency,
    TRIM(balance)::DECIMAL(15,2) AS balance,
    NULLIF(TRIM(opened_date), '')::DATE AS opened_date,
    INITCAP(NULLIF(TRIM(account_status), '')) AS account_status,
    TRIM(branch_id)::INT AS branch_id
FROM staging.accounts
WHERE TRIM(account_id) ~ '^[0-9]+$'
  AND TRIM(customer_id) ~ '^[0-9]+$'
  AND TRIM(branch_id) ~ '^[0-9]+$'
  AND TRIM(balance) ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND (
        NULLIF(TRIM(opened_date), '') IS NULL
        OR TRIM(opened_date) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      );


-- =========================================================
-- 15. CLEAN CARDS
-- =========================================================

CREATE TABLE cleaning.clean_cards AS
SELECT
    TRIM(card_id)::INT AS card_id,
    TRIM(account_id)::INT AS account_id,
    INITCAP(NULLIF(TRIM(card_type), '')) AS card_type,
    NULLIF(TRIM(card_number_hash), '') AS card_number_hash,
    NULLIF(TRIM(issue_date), '')::DATE AS issue_date,
    NULLIF(TRIM(expiry_date), '')::DATE AS expiry_date,
    INITCAP(NULLIF(TRIM(card_status), '')) AS card_status
FROM staging.cards
WHERE TRIM(card_id) ~ '^[0-9]+$'
  AND TRIM(account_id) ~ '^[0-9]+$'
  AND (
        NULLIF(TRIM(issue_date), '') IS NULL
        OR TRIM(issue_date) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      )
  AND (
        NULLIF(TRIM(expiry_date), '') IS NULL
        OR TRIM(expiry_date) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      )
  AND (
        NULLIF(TRIM(issue_date), '') IS NULL
        OR NULLIF(TRIM(expiry_date), '') IS NULL
        OR TRIM(expiry_date)::DATE >= TRIM(issue_date)::DATE
      );


-- =========================================================
-- 16. CLEAN MERCHANTS
-- =========================================================

CREATE TABLE cleaning.clean_merchants AS
SELECT
    TRIM(merchant_id)::INT AS merchant_id,
    NULLIF(TRIM(merchant_name), '') AS merchant_name,
    INITCAP(NULLIF(TRIM(merchant_category), '')) AS merchant_category,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(country), '') AS country,
    INITCAP(NULLIF(TRIM(risk_level), '')) AS risk_level
FROM staging.merchants
WHERE TRIM(merchant_id) ~ '^[0-9]+$';


-- =========================================================
-- 17. CLEAN TRANSACTIONS
-- =========================================================

CREATE TABLE cleaning.clean_transactions AS
SELECT
    TRIM(transaction_id)::INT AS transaction_id,
    TRIM(account_id)::INT AS account_id,
    NULLIF(TRIM(card_id), '')::INT AS card_id,
    NULLIF(TRIM(merchant_id), '')::INT AS merchant_id,
    INITCAP(NULLIF(TRIM(transaction_type), '')) AS transaction_type,
    TRIM(amount)::DECIMAL(15,2) AS amount,
    UPPER(NULLIF(TRIM(currency), '')) AS currency,
    NULLIF(TRIM(transaction_date), '')::TIMESTAMP AS transaction_date,
    INITCAP(NULLIF(TRIM(channel), '')) AS channel,
    NULLIF(TRIM(location), '') AS location,
    INITCAP(NULLIF(TRIM(status), '')) AS status
FROM staging.transactions
WHERE TRIM(transaction_id) ~ '^[0-9]+$'
  AND TRIM(account_id) ~ '^[0-9]+$'
  AND TRIM(amount) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) > 0
  AND (
        NULLIF(TRIM(card_id), '') IS NULL
        OR TRIM(card_id) ~ '^[0-9]+$'
      )
  AND (
        NULLIF(TRIM(merchant_id), '') IS NULL
        OR TRIM(merchant_id) ~ '^[0-9]+$'
      )
  AND (
        NULLIF(TRIM(transaction_date), '') IS NULL
        OR TRIM(transaction_date)
           ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$'
      );


-- =========================================================
-- 18. CLEAN TRANSFERS
-- =========================================================

CREATE TABLE cleaning.clean_transfers AS
SELECT
    TRIM(transfer_id)::INT AS transfer_id,
    TRIM(source_account_id)::INT AS source_account_id,
    TRIM(destination_account_id)::INT AS destination_account_id,
    TRIM(amount)::DECIMAL(15,2) AS amount,
    UPPER(NULLIF(TRIM(currency), '')) AS currency,
    NULLIF(TRIM(transfer_date), '')::TIMESTAMP AS transfer_date,
    INITCAP(NULLIF(TRIM(transfer_type), '')) AS transfer_type,
    INITCAP(NULLIF(TRIM(status), '')) AS status
FROM staging.transfers
WHERE TRIM(transfer_id) ~ '^[0-9]+$'
  AND TRIM(source_account_id) ~ '^[0-9]+$'
  AND TRIM(destination_account_id) ~ '^[0-9]+$'
  AND TRIM(source_account_id)::INT
      <> TRIM(destination_account_id)::INT
  AND TRIM(amount) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) > 0
  AND (
        NULLIF(TRIM(transfer_date), '') IS NULL
        OR TRIM(transfer_date)
           ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$'
      );


-- =========================================================
-- 19. CLEAN FRAUD ALERTS
-- =========================================================

CREATE TABLE cleaning.clean_fraud_alerts AS
SELECT
    TRIM(alert_id)::INT AS alert_id,
    TRIM(transaction_id)::INT AS transaction_id,
    INITCAP(NULLIF(TRIM(alert_type), '')) AS alert_type,
    TRIM(risk_score)::DECIMAL(5,2) AS risk_score,
    NULLIF(TRIM(description), '') AS description,
    NULLIF(TRIM(created_at), '')::TIMESTAMP AS created_at,
    INITCAP(NULLIF(TRIM(alert_status), '')) AS alert_status
FROM staging.fraud_alerts
WHERE TRIM(alert_id) ~ '^[0-9]+$'
  AND TRIM(transaction_id) ~ '^[0-9]+$'
  AND TRIM(risk_score) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(risk_score)::DECIMAL(5,2) BETWEEN 0 AND 100
  AND (
        NULLIF(TRIM(created_at), '') IS NULL
        OR TRIM(created_at)
           ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2}:[0-9]{2})?$'
      );


-- =========================================================
-- 20. ETL ROW STATISTICS
-- =========================================================

SELECT
    'customers' AS table_name,
    (SELECT COUNT(*) FROM staging.customers) AS rows_read,
    (SELECT COUNT(*) FROM cleaning.clean_customers) AS rows_cleaned,
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'customers') AS rejected_rows

UNION ALL

SELECT
    'branches',
    (SELECT COUNT(*) FROM staging.branches),
    (SELECT COUNT(*) FROM cleaning.clean_branches),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'branches')

UNION ALL

SELECT
    'accounts',
    (SELECT COUNT(*) FROM staging.accounts),
    (SELECT COUNT(*) FROM cleaning.clean_accounts),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'accounts')

UNION ALL

SELECT
    'cards',
    (SELECT COUNT(*) FROM staging.cards),
    (SELECT COUNT(*) FROM cleaning.clean_cards),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'cards')

UNION ALL

SELECT
    'merchants',
    (SELECT COUNT(*) FROM staging.merchants),
    (SELECT COUNT(*) FROM cleaning.clean_merchants),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'merchants')

UNION ALL

SELECT
    'transactions',
    (SELECT COUNT(*) FROM staging.transactions),
    (SELECT COUNT(*) FROM cleaning.clean_transactions),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'transactions')

UNION ALL

SELECT
    'transfers',
    (SELECT COUNT(*) FROM staging.transfers),
    (SELECT COUNT(*) FROM cleaning.clean_transfers),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'transfers')

UNION ALL

SELECT
    'fraud_alerts',
    (SELECT COUNT(*) FROM staging.fraud_alerts),
    (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts),
    (SELECT COUNT(DISTINCT record_id)
     FROM cleaning.rejected_records
     WHERE source_table = 'fraud_alerts')

ORDER BY table_name;


-- =========================================================
-- 21. REJECTED RECORDS SUMMARY
-- =========================================================

SELECT
    source_table,
    rejection_reason,
    COUNT(*) AS rejected_count
FROM cleaning.rejected_records
GROUP BY
    source_table,
    rejection_reason
ORDER BY
    source_table,
    rejected_count DESC;


-- =========================================================
-- 22. CLEANING TABLE ROW COUNTS
-- =========================================================

SELECT 'clean_customers' AS table_name, COUNT(*) AS row_count
FROM cleaning.clean_customers

UNION ALL
SELECT 'clean_branches', COUNT(*)
FROM cleaning.clean_branches

UNION ALL
SELECT 'clean_accounts', COUNT(*)
FROM cleaning.clean_accounts

UNION ALL
SELECT 'clean_cards', COUNT(*)
FROM cleaning.clean_cards

UNION ALL
SELECT 'clean_merchants', COUNT(*)
FROM cleaning.clean_merchants

UNION ALL
SELECT 'clean_transactions', COUNT(*)
FROM cleaning.clean_transactions

UNION ALL
SELECT 'clean_transfers', COUNT(*)
FROM cleaning.clean_transfers

UNION ALL
SELECT 'clean_fraud_alerts', COUNT(*)
FROM cleaning.clean_fraud_alerts

ORDER BY table_name;


-- =========================================================
-- END OF ETL CLEANING
-- =========================================================