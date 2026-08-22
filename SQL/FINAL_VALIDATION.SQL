-- =========================================================
-- 12_FINAL_VALIDATION.SQL
-- Banking Transaction & Fraud Analytics Database
--
-- Final Data Engineering Validation Layer
-- =========================================================


-- =========================================================
-- 1. PRODUCTION TABLE ROW COUNTS
-- =========================================================
-- Verify that production tables contain data.

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

ORDER BY
    table_name;


-- =========================================================
-- 2. CHECK NULL PRIMARY KEYS
-- =========================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS invalid_rows
FROM production.customers
WHERE customer_id IS NULL

UNION ALL

SELECT
    'branches',
    COUNT(*)
FROM production.branches
WHERE branch_id IS NULL

UNION ALL

SELECT
    'accounts',
    COUNT(*)
FROM production.accounts
WHERE account_id IS NULL

UNION ALL

SELECT
    'cards',
    COUNT(*)
FROM production.cards
WHERE card_id IS NULL

UNION ALL

SELECT
    'merchants',
    COUNT(*)
FROM production.merchants
WHERE merchant_id IS NULL

UNION ALL

SELECT
    'transactions',
    COUNT(*)
FROM production.transactions
WHERE transaction_id IS NULL

UNION ALL

SELECT
    'transfers',
    COUNT(*)
FROM production.transfers
WHERE transfer_id IS NULL

UNION ALL

SELECT
    'fraud_alerts',
    COUNT(*)
FROM production.fraud_alerts
WHERE alert_id IS NULL

ORDER BY
    table_name;


-- =========================================================
-- 3. CHECK FOREIGN KEY RELATIONSHIPS
-- =========================================================

-- ---------------------------------------------------------
-- Accounts -> Customers
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_account_customers
FROM production.accounts a
LEFT JOIN production.customers c
    ON a.customer_id = c.customer_id
WHERE a.customer_id IS NOT NULL
  AND c.customer_id IS NULL;


-- ---------------------------------------------------------
-- Accounts -> Branches
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_account_branches
FROM production.accounts a
LEFT JOIN production.branches b
    ON a.branch_id = b.branch_id
WHERE a.branch_id IS NOT NULL
  AND b.branch_id IS NULL;


-- ---------------------------------------------------------
-- Cards -> Accounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_cards_accounts
FROM production.cards c
LEFT JOIN production.accounts a
    ON c.account_id = a.account_id
WHERE c.account_id IS NOT NULL
  AND a.account_id IS NULL;


-- ---------------------------------------------------------
-- Transactions -> Accounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transaction_accounts
FROM production.transactions t
LEFT JOIN production.accounts a
    ON t.account_id = a.account_id
WHERE t.account_id IS NOT NULL
  AND a.account_id IS NULL;


-- ---------------------------------------------------------
-- Transactions -> Cards
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transaction_cards
FROM production.transactions t
LEFT JOIN production.cards c
    ON t.card_id = c.card_id
WHERE t.card_id IS NOT NULL
  AND c.card_id IS NULL;


-- ---------------------------------------------------------
-- Transactions -> Merchants
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transaction_merchants
FROM production.transactions t
LEFT JOIN production.merchants m
    ON t.merchant_id = m.merchant_id
WHERE t.merchant_id IS NOT NULL
  AND m.merchant_id IS NULL;


-- ---------------------------------------------------------
-- Transfers -> Source Accounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transfer_source_accounts
FROM production.transfers tr
LEFT JOIN production.accounts a
    ON tr.source_account_id = a.account_id
WHERE tr.source_account_id IS NOT NULL
  AND a.account_id IS NULL;


-- ---------------------------------------------------------
-- Transfers -> Destination Accounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transfer_destination_accounts
FROM production.transfers tr
LEFT JOIN production.accounts a
    ON tr.destination_account_id = a.account_id
WHERE tr.destination_account_id IS NOT NULL
  AND a.account_id IS NULL;


-- ---------------------------------------------------------
-- Fraud Alerts -> Transactions
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_fraud_alert_transactions
FROM production.fraud_alerts f
LEFT JOIN production.transactions t
    ON f.transaction_id = t.transaction_id
WHERE f.transaction_id IS NOT NULL
  AND t.transaction_id IS NULL;


-- =========================================================
-- 4. BUSINESS RULE VALIDATION
-- =========================================================

-- ---------------------------------------------------------
-- Negative account balances
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS negative_balance_accounts
FROM production.accounts
WHERE balance < 0;


-- ---------------------------------------------------------
-- Invalid transaction amounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transaction_amounts
FROM production.transactions
WHERE amount <= 0;


-- ---------------------------------------------------------
-- Invalid transfer amounts
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transfer_amounts
FROM production.transfers
WHERE amount <= 0;


-- ---------------------------------------------------------
-- Invalid fraud risk scores
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_risk_scores
FROM production.fraud_alerts
WHERE risk_score < 0
   OR risk_score > 100;


-- ---------------------------------------------------------
-- Transfers between the same account
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS same_account_transfers
FROM production.transfers
WHERE source_account_id = destination_account_id;


-- ---------------------------------------------------------
-- Invalid card dates
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_card_dates
FROM production.cards
WHERE expiry_date < issue_date;


-- ---------------------------------------------------------
-- Transactions without valid dates
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS invalid_transaction_dates
FROM production.transactions
WHERE transaction_date IS NULL;


-- ---------------------------------------------------------
-- Transactions without status
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS transactions_without_status
FROM production.transactions
WHERE status IS NULL;


-- ---------------------------------------------------------
-- Fraud alerts without status
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS fraud_alerts_without_status
FROM production.fraud_alerts
WHERE alert_status IS NULL;


-- =========================================================
-- 5. STATUS VALIDATION
-- =========================================================

-- ---------------------------------------------------------
-- Transaction statuses
-- ---------------------------------------------------------

SELECT
    status,
    COUNT(*) AS status_count
FROM production.transactions
GROUP BY status
ORDER BY status;


-- ---------------------------------------------------------
-- Fraud alert statuses
-- ---------------------------------------------------------

SELECT
    alert_status,
    COUNT(*) AS status_count
FROM production.fraud_alerts
GROUP BY alert_status
ORDER BY alert_status;


-- =========================================================
-- 6. DUPLICATE BUSINESS KEYS
-- =========================================================

-- ---------------------------------------------------------
-- Duplicate customer IDs
-- ---------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM production.customers
WHERE customer_id IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------
-- Duplicate account numbers
-- ---------------------------------------------------------

SELECT
    account_number,
    COUNT(*) AS duplicate_count
FROM production.accounts
WHERE account_number IS NOT NULL
GROUP BY account_number
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------
-- Duplicate card hashes
-- NULL values are excluded from duplicate detection.
-- ---------------------------------------------------------

SELECT
    card_number_hash,
    COUNT(*) AS duplicate_count
FROM production.cards
WHERE card_number_hash IS NOT NULL
GROUP BY card_number_hash
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------
-- Duplicate transaction IDs
-- ---------------------------------------------------------

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM production.transactions
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------
-- Duplicate transfer IDs
-- ---------------------------------------------------------

SELECT
    transfer_id,
    COUNT(*) AS duplicate_count
FROM production.transfers
WHERE transfer_id IS NOT NULL
GROUP BY transfer_id
HAVING COUNT(*) > 1;


-- =========================================================
-- 7. ETL ROW COUNT COMPARISON
-- =========================================================
-- Compare cleaning layer with production layer.
--
-- A difference does NOT automatically mean an error.
-- Production may contain fewer rows because invalid/rejected
-- records were removed during ETL.
-- =========================================================

SELECT
    'customers' AS table_name,

    (SELECT COUNT(*)
     FROM cleaning.clean_customers)
        AS cleaning_count,

    (SELECT COUNT(*)
     FROM production.customers)
        AS production_count,

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_customers)
        -
        (SELECT COUNT(*)
         FROM production.customers)
    ) AS row_difference

UNION ALL

SELECT
    'branches',

    (SELECT COUNT(*)
     FROM cleaning.clean_branches),

    (SELECT COUNT(*)
     FROM production.branches),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_branches)
        -
        (SELECT COUNT(*)
         FROM production.branches)
    )

UNION ALL

SELECT
    'accounts',

    (SELECT COUNT(*)
     FROM cleaning.clean_accounts),

    (SELECT COUNT(*)
     FROM production.accounts),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_accounts)
        -
        (SELECT COUNT(*)
         FROM production.accounts)
    )

UNION ALL

SELECT
    'cards',

    (SELECT COUNT(*)
     FROM cleaning.clean_cards),

    (SELECT COUNT(*)
     FROM production.cards),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_cards)
        -
        (SELECT COUNT(*)
         FROM production.cards)
    )

UNION ALL

SELECT
    'merchants',

    (SELECT COUNT(*)
     FROM cleaning.clean_merchants),

    (SELECT COUNT(*)
     FROM production.merchants),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_merchants)
        -
        (SELECT COUNT(*)
         FROM production.merchants)
    )

UNION ALL

SELECT
    'transactions',

    (SELECT COUNT(*)
     FROM cleaning.clean_transactions),

    (SELECT COUNT(*)
     FROM production.transactions),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_transactions)
        -
        (SELECT COUNT(*)
         FROM production.transactions)
    )

UNION ALL

SELECT
    'transfers',

    (SELECT COUNT(*)
     FROM cleaning.clean_transfers),

    (SELECT COUNT(*)
     FROM production.transfers),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_transfers)
        -
        (SELECT COUNT(*)
         FROM production.transfers)
    )

UNION ALL

SELECT
    'fraud_alerts',

    (SELECT COUNT(*)
     FROM cleaning.clean_fraud_alerts),

    (SELECT COUNT(*)
     FROM production.fraud_alerts),

    (
        (SELECT COUNT(*)
         FROM cleaning.clean_fraud_alerts)
        -
        (SELECT COUNT(*)
         FROM production.fraud_alerts)
    )

ORDER BY
    table_name;


-- =========================================================
-- 8. REJECTED RECORDS SUMMARY
-- =========================================================
-- Shows whether ETL rejected invalid records.

SELECT
    COUNT(*) AS rejected_records
FROM cleaning.rejected_records;


-- =========================================================
-- 9. TRANSACTION DATA QUALITY
-- =========================================================

SELECT
    COUNT(*) AS transactions_with_invalid_amount
FROM production.transactions
WHERE amount <= 0;


SELECT
    COUNT(*) AS transactions_without_account
FROM production.transactions
WHERE account_id IS NULL;


SELECT
    COUNT(*) AS transactions_without_date
FROM production.transactions
WHERE transaction_date IS NULL;


SELECT
    COUNT(*) AS transactions_without_status
FROM production.transactions
WHERE status IS NULL;


-- =========================================================
-- 10. FRAUD DATA QUALITY
-- =========================================================

SELECT
    COUNT(*) AS fraud_alerts_without_transaction
FROM production.fraud_alerts
WHERE transaction_id IS NULL;


SELECT
    COUNT(*) AS fraud_alerts_invalid_risk
FROM production.fraud_alerts
WHERE risk_score < 0
   OR risk_score > 100;


SELECT
    COUNT(*) AS fraud_alerts_without_status
FROM production.fraud_alerts
WHERE alert_status IS NULL;


-- =========================================================
-- 11. REFRESH CUSTOMER RISK MATERIALIZED VIEW
-- =========================================================
-- Refresh after fraud alerts/procedure tests so the analytical
-- result reflects the latest production data.

REFRESH MATERIALIZED VIEW production.customer_risk_summary;


-- =========================================================
-- 12. TEST ANALYTICAL VIEW: CUSTOMER ACCOUNTS
-- =========================================================

SELECT *
FROM public.customer_accounts_overview
LIMIT 5;


-- =========================================================
-- 13. TEST ANALYTICAL VIEW: TRANSACTION FRAUD
-- =========================================================

SELECT *
FROM public.transaction_fraud_analysis
LIMIT 5;


-- =========================================================
-- 14. TEST ANALYTICAL VIEW: MONTHLY SUMMARY
-- =========================================================

SELECT *
FROM public.monthly_transaction_summary
ORDER BY transaction_month;


-- =========================================================
-- 15. TEST ANALYTICAL VIEW: CUSTOMER SUMMARY
-- =========================================================

SELECT *
FROM public.customer_transaction_summary
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- =========================================================
-- 16. TEST MATERIALIZED VIEW: CUSTOMER RISK
-- =========================================================

SELECT *
FROM production.customer_risk_summary
ORDER BY maximum_risk_score DESC
LIMIT 10;


-- =========================================================
-- 17. FRAUD RATE VALIDATION
-- =========================================================

SELECT
    COUNT(DISTINCT f.transaction_id)
        AS fraud_transactions,

    COUNT(DISTINCT t.transaction_id)
        AS total_transactions,

    ROUND(
        (
            COUNT(DISTINCT f.transaction_id) * 100.0
            /
            NULLIF(
                COUNT(DISTINCT t.transaction_id),
                0
            )
        )::NUMERIC,
        2
    ) AS fraud_rate_percentage

FROM production.transactions t

LEFT JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id;


-- =========================================================
-- 18. HIGH-RISK TRANSACTIONS
-- =========================================================

SELECT
    t.transaction_id,
    t.account_id,
    t.amount,
    t.transaction_date,
    f.risk_score,
    f.alert_status

FROM production.transactions t

JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id

WHERE f.risk_score >= 80

ORDER BY
    f.risk_score DESC,
    t.amount DESC

LIMIT 10;


-- =========================================================
-- 19. TOP CUSTOMERS
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id)
        AS transaction_count,

    COALESCE(
        SUM(t.amount),
        0
    ) AS total_transaction_amount

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
    total_transaction_amount DESC

LIMIT 10;


-- =========================================================
-- 20. TOP MERCHANTS
-- =========================================================

SELECT
    m.merchant_id,
    m.merchant_name,

    COUNT(t.transaction_id)
        AS transaction_count,

    COALESCE(
        SUM(t.amount),
        0
    ) AS total_transaction_amount

FROM production.merchants m

JOIN production.transactions t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name

ORDER BY
    total_transaction_amount DESC

LIMIT 10;


-- =========================================================
-- 21. CHECK INDEXES
-- =========================================================

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef

FROM pg_indexes

WHERE schemaname = 'production'

ORDER BY
    tablename,
    indexname;


-- =========================================================
-- 22. CHECK STORED PROCEDURES
-- =========================================================

SELECT
    routine_schema,
    routine_name,
    routine_type

FROM information_schema.routines

WHERE routine_schema = 'production'
  AND routine_type = 'PROCEDURE'

ORDER BY
    routine_name;


-- =========================================================
-- 23. CHECK ANALYTICAL VIEWS
-- =========================================================

SELECT
    schemaname,
    viewname

FROM pg_views

WHERE schemaname = 'public'
  AND viewname IN (
      'customer_accounts_overview',
      'transaction_fraud_analysis',
      'monthly_transaction_summary',
      'customer_transaction_summary'
  )

ORDER BY
    schemaname,
    viewname;


-- =========================================================
-- 24. CHECK MATERIALIZED VIEWS
-- =========================================================

SELECT
    schemaname,
    matviewname

FROM pg_matviews

WHERE schemaname = 'production'

ORDER BY
    matviewname;


-- =========================================================
-- 25. CHECK PRODUCTION CONSTRAINTS
-- =========================================================

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type

FROM information_schema.table_constraints tc

WHERE tc.table_schema = 'production'

ORDER BY
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name;


-- =========================================================
-- 26. CHECK FOREIGN KEY CONSTRAINTS
-- =========================================================
-- Specifically verify that referential integrity constraints
-- exist in the production schema.

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type

FROM information_schema.table_constraints tc

WHERE tc.table_schema = 'production'
  AND tc.constraint_type = 'FOREIGN KEY'

ORDER BY
    tc.table_name,
    tc.constraint_name;


-- =========================================================
-- 27. FINAL DATABASE OBJECT SUMMARY
-- =========================================================

SELECT
    'Production Tables' AS object_type,
    COUNT(*) AS object_count

FROM information_schema.tables

WHERE table_schema = 'production'
  AND table_type = 'BASE TABLE'

UNION ALL

SELECT
    'Views',
    COUNT(*)

FROM pg_views

WHERE schemaname = 'public'

UNION ALL

SELECT
    'Materialized Views',
    COUNT(*)

FROM pg_matviews

WHERE schemaname = 'production'

UNION ALL

SELECT
    'Indexes',
    COUNT(*)

FROM pg_indexes

WHERE schemaname = 'production'

UNION ALL

SELECT
    'Procedures',
    COUNT(*)

FROM information_schema.routines

WHERE routine_schema = 'production'
  AND routine_type = 'PROCEDURE';


-- =========================================================
-- 28. FINAL DATABASE STATUS
-- =========================================================

SELECT
    current_database() AS database_name,
    CURRENT_TIMESTAMP AS validation_time,
    version() AS postgres_version;


-- =========================================================
-- 29. FINAL HEALTH CHECK
-- =========================================================
-- Overall validation summary.
--
-- issue_count = 0
--     PASS
--
-- issue_count > 0
--     ISSUES DETECTED
-- =========================================================

SELECT
    'Negative account balances' AS validation_check,
    COUNT(*) AS issue_count

FROM production.accounts

WHERE balance < 0


UNION ALL


SELECT
    'Invalid transaction amounts',
    COUNT(*)

FROM production.transactions

WHERE amount <= 0


UNION ALL


SELECT
    'Invalid transfer amounts',
    COUNT(*)

FROM production.transfers

WHERE amount <= 0


UNION ALL


SELECT
    'Invalid fraud risk scores',
    COUNT(*)

FROM production.fraud_alerts

WHERE risk_score < 0
   OR risk_score > 100


UNION ALL


SELECT
    'Orphan accounts - customers',
    COUNT(*)

FROM production.accounts a

LEFT JOIN production.customers c
    ON a.customer_id = c.customer_id

WHERE a.customer_id IS NOT NULL
  AND c.customer_id IS NULL


UNION ALL


SELECT
    'Orphan accounts - branches',
    COUNT(*)

FROM production.accounts a

LEFT JOIN production.branches b
    ON a.branch_id = b.branch_id

WHERE a.branch_id IS NOT NULL
  AND b.branch_id IS NULL


UNION ALL


SELECT
    'Orphan cards - accounts',
    COUNT(*)

FROM production.cards c

LEFT JOIN production.accounts a
    ON c.account_id = a.account_id

WHERE c.account_id IS NOT NULL
  AND a.account_id IS NULL


UNION ALL


SELECT
    'Orphan transactions - accounts',
    COUNT(*)

FROM production.transactions t

LEFT JOIN production.accounts a
    ON t.account_id = a.account_id

WHERE t.account_id IS NOT NULL
  AND a.account_id IS NULL


UNION ALL


SELECT
    'Orphan transactions - cards',
    COUNT(*)

FROM production.transactions t

LEFT JOIN production.cards c
    ON t.card_id = c.card_id

WHERE t.card_id IS NOT NULL
  AND c.card_id IS NULL


UNION ALL


SELECT
    'Orphan transactions - merchants',
    COUNT(*)

FROM production.transactions t

LEFT JOIN production.merchants m
    ON t.merchant_id = m.merchant_id

WHERE t.merchant_id IS NOT NULL
  AND m.merchant_id IS NULL


UNION ALL


SELECT
    'Orphan transfers - source accounts',
    COUNT(*)

FROM production.transfers tr

LEFT JOIN production.accounts a
    ON tr.source_account_id = a.account_id

WHERE tr.source_account_id IS NOT NULL
  AND a.account_id IS NULL


UNION ALL


SELECT
    'Orphan transfers - destination accounts',
    COUNT(*)

FROM production.transfers tr

LEFT JOIN production.accounts a
    ON tr.destination_account_id = a.account_id

WHERE tr.destination_account_id IS NOT NULL
  AND a.account_id IS NULL


UNION ALL


SELECT
    'Orphan fraud alerts',
    COUNT(*)

FROM production.fraud_alerts f

LEFT JOIN production.transactions t
    ON f.transaction_id = t.transaction_id

WHERE f.transaction_id IS NOT NULL
  AND t.transaction_id IS NULL


UNION ALL


SELECT
    'Same-account transfers',
    COUNT(*)

FROM production.transfers

WHERE source_account_id = destination_account_id


UNION ALL


SELECT
    'Invalid card dates',
    COUNT(*)

FROM production.cards

WHERE expiry_date < issue_date


UNION ALL


SELECT
    'Transactions without status',
    COUNT(*)

FROM production.transactions

WHERE status IS NULL


UNION ALL


SELECT
    'Fraud alerts without status',
    COUNT(*)

FROM production.fraud_alerts

WHERE alert_status IS NULL


ORDER BY
    issue_count DESC,
    validation_check;


-- =========================================================
-- 30. FINAL PASS / FAIL STATUS
-- =========================================================
-- Returns one overall database health result.
-- =========================================================

WITH validation_results AS (

    SELECT COUNT(*) AS issue_count
    FROM production.accounts
    WHERE balance < 0

    UNION ALL

    SELECT COUNT(*)
    FROM production.transactions
    WHERE amount <= 0

    UNION ALL

    SELECT COUNT(*)
    FROM production.transfers
    WHERE amount <= 0

    UNION ALL

    SELECT COUNT(*)
    FROM production.fraud_alerts
    WHERE risk_score < 0
       OR risk_score > 100

    UNION ALL

    SELECT COUNT(*)
    FROM production.accounts a
    LEFT JOIN production.customers c
        ON a.customer_id = c.customer_id
    WHERE a.customer_id IS NOT NULL
      AND c.customer_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.accounts a
    LEFT JOIN production.branches b
        ON a.branch_id = b.branch_id
    WHERE a.branch_id IS NOT NULL
      AND b.branch_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.cards c
    LEFT JOIN production.accounts a
        ON c.account_id = a.account_id
    WHERE c.account_id IS NOT NULL
      AND a.account_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transactions t
    LEFT JOIN production.accounts a
        ON t.account_id = a.account_id
    WHERE t.account_id IS NOT NULL
      AND a.account_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transactions t
    LEFT JOIN production.cards c
        ON t.card_id = c.card_id
    WHERE t.card_id IS NOT NULL
      AND c.card_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transactions t
    LEFT JOIN production.merchants m
        ON t.merchant_id = m.merchant_id
    WHERE t.merchant_id IS NOT NULL
      AND m.merchant_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transfers tr
    LEFT JOIN production.accounts a
        ON tr.source_account_id = a.account_id
    WHERE tr.source_account_id IS NOT NULL
      AND a.account_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transfers tr
    LEFT JOIN production.accounts a
        ON tr.destination_account_id = a.account_id
    WHERE tr.destination_account_id IS NOT NULL
      AND a.account_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.fraud_alerts f
    LEFT JOIN production.transactions t
        ON f.transaction_id = t.transaction_id
    WHERE f.transaction_id IS NOT NULL
      AND t.transaction_id IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.transfers
    WHERE source_account_id = destination_account_id

    UNION ALL

    SELECT COUNT(*)
    FROM production.cards
    WHERE expiry_date < issue_date

    UNION ALL

    SELECT COUNT(*)
    FROM production.transactions
    WHERE status IS NULL

    UNION ALL

    SELECT COUNT(*)
    FROM production.fraud_alerts
    WHERE alert_status IS NULL
)

SELECT
    CASE
        WHEN SUM(issue_count) = 0
        THEN 'PASS'
        ELSE 'ISSUES DETECTED'
    END AS final_database_status,

    SUM(issue_count) AS total_issues

FROM validation_results;


-- =========================================================
-- END OF FINAL VALIDATION
-- =========================================================