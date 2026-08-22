-- =========================================================
-- 05_PRODUCTION_VALIDATION.SQL
-- Banking Transaction & Fraud Analytics Database
-- Production Data Quality & ETL Validation
-- =========================================================


-- =========================================================
-- 1. PRODUCTION ROW COUNTS
-- Verify that data was successfully loaded into production.
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
-- 2. STAGING → CLEANING → PRODUCTION VALIDATION
--
-- Expected ETL flow:
--
-- STAGING
--    ↓
-- CLEANING
--    ↓
-- PRODUCTION
--
-- Invalid records may be rejected during cleaning.
-- Therefore:
--
-- staging_count >= cleaned_count
-- cleaned_count = production_count
--
-- IMPORTANT:
-- rejected_records contains rejection EVENTS.
-- One source row may generate more than one rejection reason,
-- so rejected_records COUNT must NOT be treated as the
-- exact number of rejected rows.
-- =========================================================

SELECT
    'customers' AS table_name,
    (SELECT COUNT(*) FROM staging.customers) AS staging_count,
    (SELECT COUNT(*) FROM cleaning.clean_customers) AS cleaned_count,
    (SELECT COUNT(*) FROM production.customers) AS production_count,
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'customers') AS rejection_events,
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_customers)
           = (SELECT COUNT(*) FROM production.customers)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

UNION ALL

SELECT
    'branches',
    (SELECT COUNT(*) FROM staging.branches),
    (SELECT COUNT(*) FROM cleaning.clean_branches),
    (SELECT COUNT(*) FROM production.branches),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'branches'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_branches)
           = (SELECT COUNT(*) FROM production.branches)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'accounts',
    (SELECT COUNT(*) FROM staging.accounts),
    (SELECT COUNT(*) FROM cleaning.clean_accounts),
    (SELECT COUNT(*) FROM production.accounts),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'accounts'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_accounts)
           = (SELECT COUNT(*) FROM production.accounts)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'cards',
    (SELECT COUNT(*) FROM staging.cards),
    (SELECT COUNT(*) FROM cleaning.clean_cards),
    (SELECT COUNT(*) FROM production.cards),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'cards'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_cards)
           = (SELECT COUNT(*) FROM production.cards)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'merchants',
    (SELECT COUNT(*) FROM staging.merchants),
    (SELECT COUNT(*) FROM cleaning.clean_merchants),
    (SELECT COUNT(*) FROM production.merchants),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'merchants'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_merchants)
           = (SELECT COUNT(*) FROM production.merchants)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'transactions',
    (SELECT COUNT(*) FROM staging.transactions),
    (SELECT COUNT(*) FROM cleaning.clean_transactions),
    (SELECT COUNT(*) FROM production.transactions),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'transactions'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_transactions)
           = (SELECT COUNT(*) FROM production.transactions)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'transfers',
    (SELECT COUNT(*) FROM staging.transfers),
    (SELECT COUNT(*) FROM cleaning.clean_transfers),
    (SELECT COUNT(*) FROM production.transfers),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'transfers'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_transfers)
           = (SELECT COUNT(*) FROM production.transfers)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'fraud_alerts',
    (SELECT COUNT(*) FROM staging.fraud_alerts),
    (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts),
    (SELECT COUNT(*) FROM production.fraud_alerts),
    (SELECT COUNT(*)
     FROM cleaning.rejected_records
     WHERE source_table = 'fraud_alerts'),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts)
           = (SELECT COUNT(*) FROM production.fraud_alerts)
        THEN 'PASS'
        ELSE 'FAIL'
    END

ORDER BY table_name;


-- =========================================================
-- 3. CLEANING → PRODUCTION ROW COUNT VALIDATION
-- Every successfully cleaned record should be loaded
-- into its corresponding production table.
-- =========================================================

SELECT
    'customers' AS table_name,
    (SELECT COUNT(*) FROM cleaning.clean_customers) AS cleaned_count,
    (SELECT COUNT(*) FROM production.customers) AS production_count,
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_customers)
           = (SELECT COUNT(*) FROM production.customers)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status

UNION ALL

SELECT
    'branches',
    (SELECT COUNT(*) FROM cleaning.clean_branches),
    (SELECT COUNT(*) FROM production.branches),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_branches)
           = (SELECT COUNT(*) FROM production.branches)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'accounts',
    (SELECT COUNT(*) FROM cleaning.clean_accounts),
    (SELECT COUNT(*) FROM production.accounts),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_accounts)
           = (SELECT COUNT(*) FROM production.accounts)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'cards',
    (SELECT COUNT(*) FROM cleaning.clean_cards),
    (SELECT COUNT(*) FROM production.cards),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_cards)
           = (SELECT COUNT(*) FROM production.cards)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'merchants',
    (SELECT COUNT(*) FROM cleaning.clean_merchants),
    (SELECT COUNT(*) FROM production.merchants),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_merchants)
           = (SELECT COUNT(*) FROM production.merchants)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'transactions',
    (SELECT COUNT(*) FROM cleaning.clean_transactions),
    (SELECT COUNT(*) FROM production.transactions),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_transactions)
           = (SELECT COUNT(*) FROM production.transactions)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'transfers',
    (SELECT COUNT(*) FROM cleaning.clean_transfers),
    (SELECT COUNT(*) FROM production.transfers),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_transfers)
           = (SELECT COUNT(*) FROM production.transfers)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'fraud_alerts',
    (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts),
    (SELECT COUNT(*) FROM production.fraud_alerts),
    CASE
        WHEN (SELECT COUNT(*) FROM cleaning.clean_fraud_alerts)
           = (SELECT COUNT(*) FROM production.fraud_alerts)
        THEN 'PASS'
        ELSE 'FAIL'
    END

ORDER BY table_name;


-- =========================================================
-- 4. NULL CHECKS ON PRIMARY KEYS
-- Production primary keys must never be NULL.
-- =========================================================

SELECT
    'customers.customer_id' AS column_name,
    COUNT(*) AS null_count
FROM production.customers
WHERE customer_id IS NULL

UNION ALL

SELECT
    'branches.branch_id',
    COUNT(*)
FROM production.branches
WHERE branch_id IS NULL

UNION ALL

SELECT
    'accounts.account_id',
    COUNT(*)
FROM production.accounts
WHERE account_id IS NULL

UNION ALL

SELECT
    'cards.card_id',
    COUNT(*)
FROM production.cards
WHERE card_id IS NULL

UNION ALL

SELECT
    'merchants.merchant_id',
    COUNT(*)
FROM production.merchants
WHERE merchant_id IS NULL

UNION ALL

SELECT
    'transactions.transaction_id',
    COUNT(*)
FROM production.transactions
WHERE transaction_id IS NULL

UNION ALL

SELECT
    'transfers.transfer_id',
    COUNT(*)
FROM production.transfers
WHERE transfer_id IS NULL

UNION ALL

SELECT
    'fraud_alerts.alert_id',
    COUNT(*)
FROM production.fraud_alerts
WHERE alert_id IS NULL;


-- =========================================================
-- 5. REFERENTIAL INTEGRITY
-- Accounts → Customers
-- =========================================================

SELECT COUNT(*) AS invalid_accounts_customers
FROM production.accounts a
LEFT JOIN production.customers c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- =========================================================
-- 6. REFERENTIAL INTEGRITY
-- Accounts → Branches
-- =========================================================

SELECT COUNT(*) AS invalid_accounts_branches
FROM production.accounts a
LEFT JOIN production.branches b
    ON a.branch_id = b.branch_id
WHERE b.branch_id IS NULL;


-- =========================================================
-- 7. REFERENTIAL INTEGRITY
-- Cards → Accounts
-- =========================================================

SELECT COUNT(*) AS invalid_cards_accounts
FROM production.cards c
LEFT JOIN production.accounts a
    ON c.account_id = a.account_id
WHERE a.account_id IS NULL;


-- =========================================================
-- 8. REFERENTIAL INTEGRITY
-- Transactions → Accounts
-- =========================================================

SELECT COUNT(*) AS invalid_transactions_accounts
FROM production.transactions t
LEFT JOIN production.accounts a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- =========================================================
-- 9. REFERENTIAL INTEGRITY
-- Transactions → Cards
-- =========================================================

SELECT COUNT(*) AS invalid_transactions_cards
FROM production.transactions t
LEFT JOIN production.cards c
    ON t.card_id = c.card_id
WHERE t.card_id IS NOT NULL
  AND c.card_id IS NULL;


-- =========================================================
-- 10. REFERENTIAL INTEGRITY
-- Transactions → Merchants
-- =========================================================

SELECT COUNT(*) AS invalid_transactions_merchants
FROM production.transactions t
LEFT JOIN production.merchants m
    ON t.merchant_id = m.merchant_id
WHERE t.merchant_id IS NOT NULL
  AND m.merchant_id IS NULL;


-- =========================================================
-- 11. REFERENTIAL INTEGRITY
-- Transfers → Source Accounts
-- =========================================================

SELECT COUNT(*) AS invalid_transfer_source_accounts
FROM production.transfers tr
LEFT JOIN production.accounts a
    ON tr.source_account_id = a.account_id
WHERE a.account_id IS NULL;


-- =========================================================
-- 12. REFERENTIAL INTEGRITY
-- Transfers → Destination Accounts
-- =========================================================

SELECT COUNT(*) AS invalid_transfer_destination_accounts
FROM production.transfers tr
LEFT JOIN production.accounts a
    ON tr.destination_account_id = a.account_id
WHERE a.account_id IS NULL;


-- =========================================================
-- 13. REFERENTIAL INTEGRITY
-- Fraud Alerts → Transactions
-- =========================================================

SELECT COUNT(*) AS invalid_fraud_alert_transactions
FROM production.fraud_alerts f
LEFT JOIN production.transactions t
    ON f.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;


-- =========================================================
-- 14. DUPLICATE BUSINESS KEYS
-- =========================================================

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids
FROM production.customers;


SELECT
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT account_number) AS unique_account_numbers,
    COUNT(*) - COUNT(DISTINCT account_number) AS duplicate_account_numbers
FROM production.accounts;


SELECT
    COUNT(*) AS total_cards,
    COUNT(DISTINCT card_number_hash) AS unique_card_hashes,
    COUNT(*) - COUNT(DISTINCT card_number_hash) AS duplicate_card_hashes
FROM production.cards;


-- =========================================================
-- 15. BUSINESS RULE VALIDATION
-- Account balances must not be negative.
-- =========================================================

SELECT
    COUNT(*) AS negative_balance_accounts
FROM production.accounts
WHERE balance < 0;


-- =========================================================
-- 16. BUSINESS RULE VALIDATION
-- Transaction amounts must be positive.
-- =========================================================

SELECT
    COUNT(*) AS invalid_transaction_amounts
FROM production.transactions
WHERE amount <= 0;


-- =========================================================
-- 17. BUSINESS RULE VALIDATION
-- Transfer amounts must be positive.
-- =========================================================

SELECT
    COUNT(*) AS invalid_transfer_amounts
FROM production.transfers
WHERE amount <= 0;


-- =========================================================
-- 18. BUSINESS RULE VALIDATION
-- Fraud risk score must be between 0 and 100.
-- =========================================================

SELECT
    COUNT(*) AS invalid_risk_scores
FROM production.fraud_alerts
WHERE risk_score < 0
   OR risk_score > 100;


-- =========================================================
-- 19. BUSINESS RULE VALIDATION
-- Transfer source and destination accounts
-- must be different.
-- =========================================================

SELECT
    COUNT(*) AS invalid_transfer_accounts
FROM production.transfers
WHERE source_account_id = destination_account_id;


-- =========================================================
-- 20. DATE VALIDATION
-- Account opened date should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_account_dates
FROM production.accounts
WHERE opened_date > CURRENT_DATE;


-- =========================================================
-- 21. DATE VALIDATION
-- Customer registration date should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_customer_dates
FROM production.customers
WHERE customer_since > CURRENT_DATE;


-- =========================================================
-- 22. DATE VALIDATION
-- Date of birth should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_birth_dates
FROM production.customers
WHERE date_of_birth > CURRENT_DATE;


-- =========================================================
-- 23. DATE VALIDATION
-- Card expiry date should be after issue date.
-- =========================================================

SELECT
    COUNT(*) AS invalid_card_dates
FROM production.cards
WHERE expiry_date <= issue_date;


-- =========================================================
-- 24. DATE VALIDATION
-- Card issue date should not be before customer/account
-- related data is checked separately.
-- =========================================================

SELECT
    COUNT(*) AS future_card_issue_dates
FROM production.cards
WHERE issue_date > CURRENT_DATE;


-- =========================================================
-- 25. TRANSACTION DATA QUALITY
-- Transaction date should not be NULL.
-- =========================================================

SELECT
    COUNT(*) AS null_transaction_dates
FROM production.transactions
WHERE transaction_date IS NULL;


-- =========================================================
-- 26. TRANSACTION DATE VALIDATION
-- Transaction date should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_transaction_dates
FROM production.transactions
WHERE transaction_date > CURRENT_TIMESTAMP;


-- =========================================================
-- 27. TRANSFER DATE VALIDATION
-- Transfer date should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_transfer_dates
FROM production.transfers
WHERE transfer_date > CURRENT_TIMESTAMP;


-- =========================================================
-- 28. FRAUD DATA QUALITY
-- Fraud alert creation date should not be NULL.
-- =========================================================

SELECT
    COUNT(*) AS null_alert_dates
FROM production.fraud_alerts
WHERE created_at IS NULL;


-- =========================================================
-- 29. FRAUD DATE VALIDATION
-- Fraud alert creation date should not be in the future.
-- =========================================================

SELECT
    COUNT(*) AS future_alert_dates
FROM production.fraud_alerts
WHERE created_at > CURRENT_TIMESTAMP;


-- =========================================================
-- 30. CUSTOMER DATA QUALITY
-- Customer must be registered after date of birth.
-- =========================================================

SELECT
    COUNT(*) AS invalid_customer_dates
FROM production.customers
WHERE customer_since < date_of_birth;


-- =========================================================
-- 31. ACCOUNT DATE VALIDATION
-- Account opened date should not be before customer
-- registration date.
-- =========================================================

SELECT
    COUNT(*) AS invalid_account_customer_dates
FROM production.accounts a
JOIN production.customers c
    ON a.customer_id = c.customer_id
WHERE a.opened_date < c.customer_since;


-- =========================================================
-- 32. CARD DATE VALIDATION
-- Card issue date should not be before account opened date.
-- =========================================================

SELECT
    COUNT(*) AS invalid_card_account_dates
FROM production.cards c
JOIN production.accounts a
    ON c.account_id = a.account_id
WHERE c.issue_date < a.opened_date;


-- =========================================================
-- 33. TRANSACTION DATE VALIDATION
-- Transaction should not occur before account was opened.
-- =========================================================

SELECT
    COUNT(*) AS invalid_transaction_account_dates
FROM production.transactions t
JOIN production.accounts a
    ON t.account_id = a.account_id
WHERE t.transaction_date < a.opened_date;


-- =========================================================
-- 34. FRAUD ALERT DATE VALIDATION
-- Fraud alert should not be created before its transaction.
-- =========================================================

SELECT
    COUNT(*) AS invalid_fraud_transaction_dates
FROM production.fraud_alerts f
JOIN production.transactions t
    ON f.transaction_id = t.transaction_id
WHERE f.created_at < t.transaction_date;


-- =========================================================
-- 35. FINAL VALIDATION SUMMARY
-- Overall production health indicators.
-- =========================================================

SELECT
    (SELECT COUNT(*) FROM production.customers)
        AS customers,

    (SELECT COUNT(*) FROM production.accounts)
        AS accounts,

    (SELECT COUNT(*) FROM production.transactions)
        AS transactions,

    (SELECT COUNT(*) FROM production.transfers)
        AS transfers,

    (SELECT COUNT(*) FROM production.fraud_alerts)
        AS fraud_alerts,

    (SELECT COUNT(*)
     FROM production.accounts a
     LEFT JOIN production.customers c
        ON a.customer_id = c.customer_id
     WHERE c.customer_id IS NULL)
        AS invalid_account_customers,

    (SELECT COUNT(*)
     FROM production.accounts a
     LEFT JOIN production.branches b
        ON a.branch_id = b.branch_id
     WHERE b.branch_id IS NULL)
        AS invalid_account_branches,

    (SELECT COUNT(*)
     FROM production.transactions t
     LEFT JOIN production.accounts a
        ON t.account_id = a.account_id
     WHERE a.account_id IS NULL)
        AS invalid_transaction_accounts,

    (SELECT COUNT(*)
     FROM production.fraud_alerts f
     LEFT JOIN production.transactions t
        ON f.transaction_id = t.transaction_id
     WHERE t.transaction_id IS NULL)
        AS invalid_fraud_alerts,

    (SELECT COUNT(*)
     FROM production.accounts
     WHERE balance < 0)
        AS negative_balances,

    (SELECT COUNT(*)
     FROM production.transactions
     WHERE amount <= 0)
        AS invalid_transaction_amounts,

    (SELECT COUNT(*)
     FROM production.transfers
     WHERE amount <= 0)
        AS invalid_transfer_amounts,

    (SELECT COUNT(*)
     FROM production.fraud_alerts
     WHERE risk_score NOT BETWEEN 0 AND 100)
        AS invalid_risk_scores;