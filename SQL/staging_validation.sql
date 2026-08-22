-- =========================================================
-- 02_STAGING_VALIDATION.SQL
-- Banking Transaction & Fraud Analytics Database
-- Staging Data Quality Validation Layer
-- =========================================================


-- =========================================================
-- 1. ROW COUNTS
-- =========================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM staging.customers

UNION ALL

SELECT
    'branches',
    COUNT(*)
FROM staging.branches

UNION ALL

SELECT
    'accounts',
    COUNT(*)
FROM staging.accounts

UNION ALL

SELECT
    'cards',
    COUNT(*)
FROM staging.cards

UNION ALL

SELECT
    'merchants',
    COUNT(*)
FROM staging.merchants

UNION ALL

SELECT
    'transactions',
    COUNT(*)
FROM staging.transactions

UNION ALL

SELECT
    'transfers',
    COUNT(*)
FROM staging.transfers

UNION ALL

SELECT
    'fraud_alerts',
    COUNT(*)
FROM staging.fraud_alerts

ORDER BY table_name;


-- =========================================================
-- 2. NULL / EMPTY PRIMARY KEY CHECKS
-- =========================================================

SELECT
    'customers' AS table_name,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(customer_id), '') IS NULL
    ) AS invalid_id_count
FROM staging.customers

UNION ALL

SELECT
    'branches',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(branch_id), '') IS NULL
    )
FROM staging.branches

UNION ALL

SELECT
    'accounts',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(account_id), '') IS NULL
    )
FROM staging.accounts

UNION ALL

SELECT
    'cards',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(card_id), '') IS NULL
    )
FROM staging.cards

UNION ALL

SELECT
    'merchants',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(merchant_id), '') IS NULL
    )
FROM staging.merchants

UNION ALL

SELECT
    'transactions',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(transaction_id), '') IS NULL
    )
FROM staging.transactions

UNION ALL

SELECT
    'transfers',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(transfer_id), '') IS NULL
    )
FROM staging.transfers

UNION ALL

SELECT
    'fraud_alerts',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(alert_id), '') IS NULL
    )
FROM staging.fraud_alerts

ORDER BY table_name;


-- =========================================================
-- 3. IMPORTANT FOREIGN KEY NULL CHECKS
-- =========================================================

SELECT
    'accounts.customer_id' AS column_name,
    COUNT(*) AS null_or_empty_count
FROM staging.accounts
WHERE NULLIF(TRIM(customer_id), '') IS NULL

UNION ALL

SELECT
    'accounts.branch_id',
    COUNT(*)
FROM staging.accounts
WHERE NULLIF(TRIM(branch_id), '') IS NULL

UNION ALL

SELECT
    'cards.account_id',
    COUNT(*)
FROM staging.cards
WHERE NULLIF(TRIM(account_id), '') IS NULL

UNION ALL

SELECT
    'transactions.account_id',
    COUNT(*)
FROM staging.transactions
WHERE NULLIF(TRIM(account_id), '') IS NULL

UNION ALL

SELECT
    'transfers.source_account_id',
    COUNT(*)
FROM staging.transfers
WHERE NULLIF(TRIM(source_account_id), '') IS NULL

UNION ALL

SELECT
    'transfers.destination_account_id',
    COUNT(*)
FROM staging.transfers
WHERE NULLIF(TRIM(destination_account_id), '') IS NULL

UNION ALL

SELECT
    'fraud_alerts.transaction_id',
    COUNT(*)
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(transaction_id), '') IS NULL;


-- =========================================================
-- 4. EMAIL / EMPTY STRING CHECKS
-- =========================================================

SELECT
    'customers.email' AS field_name,
    COUNT(*) AS empty_count
FROM staging.customers
WHERE NULLIF(TRIM(email), '') IS NULL

UNION ALL

SELECT
    'customers.customer_status',
    COUNT(*)
FROM staging.customers
WHERE NULLIF(TRIM(customer_status), '') IS NULL

UNION ALL

SELECT
    'accounts.account_number',
    COUNT(*)
FROM staging.accounts
WHERE NULLIF(TRIM(account_number), '') IS NULL

UNION ALL

SELECT
    'accounts.account_type',
    COUNT(*)
FROM staging.accounts
WHERE NULLIF(TRIM(account_type), '') IS NULL

UNION ALL

SELECT
    'transactions.transaction_type',
    COUNT(*)
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_type), '') IS NULL

UNION ALL

SELECT
    'transactions.status',
    COUNT(*)
FROM staging.transactions
WHERE NULLIF(TRIM(status), '') IS NULL

UNION ALL

SELECT
    'transfers.status',
    COUNT(*)
FROM staging.transfers
WHERE NULLIF(TRIM(status), '') IS NULL

UNION ALL

SELECT
    'fraud_alerts.alert_status',
    COUNT(*)
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(alert_status), '') IS NULL;


-- =========================================================
-- 5. DUPLICATE BUSINESS / PRIMARY KEYS
-- =========================================================

SELECT
    'customers' AS table_name,
    customer_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.customers
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) > 1;


SELECT
    'branches' AS table_name,
    branch_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.branches
WHERE NULLIF(TRIM(branch_id), '') IS NOT NULL
GROUP BY branch_id
HAVING COUNT(*) > 1;


SELECT
    'accounts' AS table_name,
    account_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.accounts
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL
GROUP BY account_id
HAVING COUNT(*) > 1;


SELECT
    'cards' AS table_name,
    card_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.cards
WHERE NULLIF(TRIM(card_id), '') IS NOT NULL
GROUP BY card_id
HAVING COUNT(*) > 1;


SELECT
    'merchants' AS table_name,
    merchant_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.merchants
WHERE NULLIF(TRIM(merchant_id), '') IS NOT NULL
GROUP BY merchant_id
HAVING COUNT(*) > 1;


SELECT
    'transactions' AS table_name,
    transaction_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_id), '') IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1;


SELECT
    'transfers' AS table_name,
    transfer_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.transfers
WHERE NULLIF(TRIM(transfer_id), '') IS NOT NULL
GROUP BY transfer_id
HAVING COUNT(*) > 1;


SELECT
    'fraud_alerts' AS table_name,
    alert_id AS duplicate_id,
    COUNT(*) AS duplicate_count
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(alert_id), '') IS NOT NULL
GROUP BY alert_id
HAVING COUNT(*) > 1;


-- =========================================================
-- 6. INVALID NUMERIC VALUES
-- =========================================================

SELECT
    COUNT(*) AS invalid_account_ids
FROM staging.accounts
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL
  AND TRIM(account_id) !~ '^[0-9]+$';


SELECT
    COUNT(*) AS invalid_customer_ids
FROM staging.accounts
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
  AND TRIM(customer_id) !~ '^[0-9]+$';


SELECT
    COUNT(*) AS invalid_branch_ids
FROM staging.accounts
WHERE NULLIF(TRIM(branch_id), '') IS NOT NULL
  AND TRIM(branch_id) !~ '^[0-9]+$';


SELECT
    COUNT(*) AS invalid_balances
FROM staging.accounts
WHERE NULLIF(TRIM(balance), '') IS NOT NULL
  AND TRIM(balance) !~ '^-?[0-9]+(\.[0-9]+)?$';


SELECT
    COUNT(*) AS invalid_transaction_amounts
FROM staging.transactions
WHERE NULLIF(TRIM(amount), '') IS NOT NULL
  AND TRIM(amount) !~ '^[0-9]+(\.[0-9]+)?$';


SELECT
    COUNT(*) AS invalid_risk_scores
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(risk_score), '') IS NOT NULL
  AND TRIM(risk_score) !~ '^[0-9]+(\.[0-9]+)?$';


-- =========================================================
-- 7. BUSINESS RULE CHECKS
-- =========================================================

-- Transaction amounts must be greater than zero

SELECT
    COUNT(*) AS invalid_transaction_amounts
FROM staging.transactions
WHERE TRIM(amount) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) <= 0;


-- Transfer amounts must be greater than zero

SELECT
    COUNT(*) AS invalid_transfer_amounts
FROM staging.transfers
WHERE TRIM(amount) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(amount)::DECIMAL(15,2) <= 0;


-- Fraud risk score must be between 0 and 100

SELECT
    COUNT(*) AS invalid_risk_scores
FROM staging.fraud_alerts
WHERE TRIM(risk_score) ~ '^[0-9]+(\.[0-9]+)?$'
  AND TRIM(risk_score)::DECIMAL(5,2) NOT BETWEEN 0 AND 100;


-- Transfers between the same account

SELECT
    COUNT(*) AS same_account_transfers
FROM staging.transfers
WHERE NULLIF(TRIM(source_account_id), '') IS NOT NULL
  AND NULLIF(TRIM(destination_account_id), '') IS NOT NULL
  AND TRIM(source_account_id) = TRIM(destination_account_id);


-- =========================================================
-- 8. DATE FORMAT CHECKS
-- =========================================================

SELECT
    COUNT(*) AS invalid_customer_dates
FROM staging.customers
WHERE NULLIF(TRIM(date_of_birth), '') IS NOT NULL
  AND TRIM(date_of_birth) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_customer_since_dates
FROM staging.customers
WHERE NULLIF(TRIM(customer_since), '') IS NOT NULL
  AND TRIM(customer_since) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_account_dates
FROM staging.accounts
WHERE NULLIF(TRIM(opened_date), '') IS NOT NULL
  AND TRIM(opened_date) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_card_issue_dates
FROM staging.cards
WHERE NULLIF(TRIM(issue_date), '') IS NOT NULL
  AND TRIM(issue_date) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_card_expiry_dates
FROM staging.cards
WHERE NULLIF(TRIM(expiry_date), '') IS NOT NULL
  AND TRIM(expiry_date) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_transaction_dates
FROM staging.transactions
WHERE NULLIF(TRIM(transaction_date), '') IS NOT NULL
  AND TRIM(transaction_date) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_transfer_dates
FROM staging.transfers
WHERE NULLIF(TRIM(transfer_date), '') IS NOT NULL
  AND TRIM(transfer_date) !~ '^\d{4}-\d{2}-\d{2}$';


SELECT
    COUNT(*) AS invalid_fraud_created_dates
FROM staging.fraud_alerts
WHERE NULLIF(TRIM(created_at), '') IS NOT NULL
  AND TRIM(created_at) !~ '^\d{4}-\d{2}-\d{2}';


-- =========================================================
-- END OF STAGING VALIDATION
-- =========================================================