-- =========================================================
-- 08_FRAUD_DETECTION.SQL
-- Banking Transaction & Fraud Analytics Database
-- Fraud Detection & Risk Analytics Layer
-- =========================================================


-- =========================================================
-- 1. FRAUD RATE
-- Overall fraud transaction rate.
--
-- Each transaction is counted once even if it has
-- multiple fraud alerts.
-- =========================================================

WITH fraud_transactions AS (

    SELECT DISTINCT transaction_id
    FROM production.fraud_alerts

)

SELECT
    COUNT(ft.transaction_id) AS fraud_transactions,

    COUNT(t.transaction_id) AS total_transactions,

    ROUND(
        (
            COUNT(ft.transaction_id) * 100.0
            / NULLIF(COUNT(t.transaction_id), 0)
        )::NUMERIC,
        2
    ) AS fraud_rate_percentage

FROM production.transactions t

LEFT JOIN fraud_transactions ft
    ON t.transaction_id = ft.transaction_id;


-- =========================================================
-- 2. FRAUD ALERT SUMMARY
-- High-level fraud monitoring snapshot.
-- =========================================================

SELECT
    COUNT(*) AS total_alerts,

    COUNT(*) FILTER (
        WHERE risk_score >= 80
    ) AS high_risk_alerts,

    COUNT(*) FILTER (
        WHERE risk_score >= 50
          AND risk_score < 80
    ) AS medium_risk_alerts,

    COUNT(*) FILTER (
        WHERE risk_score >= 0
          AND risk_score < 50
    ) AS low_risk_alerts,

    COALESCE(
        ROUND(AVG(risk_score), 2),
        0
    ) AS average_risk_score,

    COALESCE(
        MAX(risk_score),
        0
    ) AS maximum_risk_score

FROM production.fraud_alerts;


-- =========================================================
-- 3. HIGH-RISK TRANSACTIONS
-- Transactions with risk score >= 80.
--
-- MAX risk score is used so each transaction appears once.
-- =========================================================

WITH transaction_risk AS (

    SELECT
        transaction_id,
        MAX(risk_score) AS maximum_risk_score

    FROM production.fraud_alerts

    GROUP BY transaction_id
)

SELECT
    t.transaction_id,
    t.account_id,
    t.amount,
    t.transaction_date,
    t.channel,

    tr.maximum_risk_score

FROM production.transactions t

JOIN transaction_risk tr
    ON t.transaction_id = tr.transaction_id

WHERE tr.maximum_risk_score >= 80

ORDER BY
    tr.maximum_risk_score DESC,
    t.amount DESC;


-- =========================================================
-- 4. FRAUD BY MERCHANT
-- Identifies merchants associated with fraud activity.
-- =========================================================

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.risk_level,

    COUNT(DISTINCT f.transaction_id)
        AS fraud_transaction_count,

    COALESCE(
        ROUND(AVG(f.risk_score), 2),
        0
    ) AS average_risk_score,

    COALESCE(
        MAX(f.risk_score),
        0
    ) AS maximum_risk_score

FROM production.merchants m

JOIN production.transactions t
    ON m.merchant_id = t.merchant_id

JOIN production.fraud_alerts f
    ON t.transaction_id = f.transaction_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.risk_level

ORDER BY
    fraud_transaction_count DESC,
    average_risk_score DESC

LIMIT 10;


-- =========================================================
-- 5. FRAUD RISK CLASSIFICATION
-- Combines transaction amount and fraud risk score.
--
-- MAX risk score ensures one row per transaction.
-- =========================================================

WITH transaction_risk AS (

    SELECT
        t.transaction_id,
        t.account_id,
        t.amount,
        t.transaction_date,
        t.channel,
        t.status,

        COALESCE(
            MAX(f.risk_score),
            0
        ) AS fraud_risk_score

    FROM production.transactions t

    LEFT JOIN production.fraud_alerts f
        ON t.transaction_id = f.transaction_id

    GROUP BY
        t.transaction_id,
        t.account_id,
        t.amount,
        t.transaction_date,
        t.channel,
        t.status
)

SELECT
    transaction_id,
    account_id,
    amount,
    transaction_date,
    channel,
    status,
    fraud_risk_score,

    CASE
        WHEN fraud_risk_score >= 80
             OR amount >= 10000
            THEN 'Potential Fraud'

        WHEN fraud_risk_score >= 50
             OR amount >= 5000
            THEN 'Review'

        ELSE 'Normal'
    END AS fraud_classification

FROM transaction_risk

ORDER BY
    fraud_risk_score DESC,
    amount DESC;


-- =========================================================
-- 6. SUSPICIOUS HIGH-VALUE TRANSACTIONS
-- Detects transactions above a fixed threshold.
-- =========================================================

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    currency,
    channel,
    status

FROM production.transactions

WHERE amount >= 10000

ORDER BY
    amount DESC;


-- =========================================================
-- 7. TRANSACTIONS ABOVE ACCOUNT AVERAGE
-- Detects unusual spending relative to account behavior.
-- =========================================================

WITH account_averages AS (

    SELECT
        account_id,
        AVG(amount) AS average_amount

    FROM production.transactions

    GROUP BY account_id
)

SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    ROUND(
        aa.average_amount,
        2
    ) AS average_account_amount,

    ROUND(
        (t.amount - aa.average_amount),
        2
    ) AS amount_above_average

FROM production.transactions t

JOIN account_averages aa
    ON t.account_id = aa.account_id

WHERE t.amount > aa.average_amount

ORDER BY
    t.account_id,
    t.amount DESC;


-- =========================================================
-- 8. RAPID SUCCESSIVE TRANSACTIONS
-- Transactions occurring within 5 minutes.
-- Uses LAG() Window Function.
-- =========================================================

WITH transaction_gaps AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date,
        amount,

        LAG(transaction_date) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_transaction

    FROM production.transactions

    WHERE transaction_date IS NOT NULL
)

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    previous_transaction,

    transaction_date - previous_transaction
        AS time_gap

FROM transaction_gaps

WHERE previous_transaction IS NOT NULL

  AND transaction_date - previous_transaction
      <= INTERVAL '5 minutes'

ORDER BY
    account_id,
    transaction_date;


-- =========================================================
-- 9. TOP 3 TRANSACTIONS PER ACCOUNT
-- Uses ROW_NUMBER() Window Function.
-- =========================================================

WITH ranked_transactions AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date,
        amount,

        ROW_NUMBER() OVER (
            PARTITION BY account_id
            ORDER BY
                amount DESC,
                transaction_date DESC,
                transaction_id DESC
        ) AS transaction_rank

    FROM production.transactions
)

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_rank

FROM ranked_transactions

WHERE transaction_rank <= 3

ORDER BY
    account_id,
    transaction_rank;


-- =========================================================
-- 10. TRANSACTION AMOUNT CHANGE
-- Compares each transaction with the previous transaction.
-- =========================================================

WITH transaction_comparison AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date,
        amount,

        LAG(amount) OVER (
            PARTITION BY account_id
            ORDER BY
                transaction_date,
                transaction_id
        ) AS previous_amount

    FROM production.transactions
)

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    previous_amount,

    amount - previous_amount
        AS amount_difference,

    ROUND(
        (
            (
                (amount - previous_amount)
                / NULLIF(previous_amount, 0)
            ) * 100
        )::NUMERIC,
        2
    ) AS percentage_change

FROM transaction_comparison

WHERE previous_amount IS NOT NULL

ORDER BY
    account_id,
    transaction_date;


-- =========================================================
-- 11. TRANSACTIONS ABOVE 90TH PERCENTILE
-- Detects unusually large transactions per account.
-- =========================================================

-- =========================================================
-- 11. TRANSACTIONS ABOVE 90TH PERCENTILE
-- Detects unusually large transactions per account.
-- =========================================================

WITH account_percentiles AS (

    SELECT
        account_id,

        -- PERCENTILE_CONT returns DOUBLE PRECISION.
        -- Cast the result to NUMERIC.
        (
            PERCENTILE_CONT(0.90)
            WITHIN GROUP (ORDER BY amount)
        )::NUMERIC AS p90_amount

    FROM production.transactions

    GROUP BY account_id
)

SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    ROUND(
        ap.p90_amount,
        2
    ) AS p90_amount

FROM production.transactions t

JOIN account_percentiles ap
    ON t.account_id = ap.account_id

WHERE t.amount > ap.p90_amount

ORDER BY
    t.account_id,
    t.amount DESC;

-- =========================================================
-- 12. MONTHLY FRAUD TREND
-- Fraud transactions are counted once per transaction.
-- =========================================================

WITH transaction_risk AS (

    SELECT
        t.transaction_id,
        t.transaction_date,
        MAX(f.risk_score) AS maximum_risk_score

    FROM production.transactions t

    LEFT JOIN production.fraud_alerts f
        ON t.transaction_id = f.transaction_id

    GROUP BY
        t.transaction_id,
        t.transaction_date
)

SELECT
    DATE_TRUNC(
        'month',
        transaction_date
    ) AS transaction_month,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE maximum_risk_score IS NOT NULL
    ) AS fraud_transactions,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE maximum_risk_score IS NOT NULL
            ) * 100.0
            / NULLIF(COUNT(*), 0)
        )::NUMERIC,
        2
    ) AS fraud_rate_percentage,

    COALESCE(
        ROUND(
            AVG(maximum_risk_score)
            FILTER (
                WHERE maximum_risk_score IS NOT NULL
            ),
            2
        ),
        0
    ) AS average_risk_score

FROM transaction_risk

WHERE transaction_date IS NOT NULL

GROUP BY
    DATE_TRUNC(
        'month',
        transaction_date
    )

ORDER BY
    transaction_month;


-- =========================================================
-- 13. CUSTOMER RISK ANALYTICS
-- Uses the Materialized View created in
-- the Analytical Layer.
-- =========================================================

SELECT
    customer_id,
    first_name,
    last_name,
    total_transactions,
    fraud_transactions,
    average_risk_score,
    maximum_risk_score,
    customer_risk_level

FROM production.customer_risk_summary

ORDER BY
    maximum_risk_score DESC,
    fraud_transactions DESC

LIMIT 20;


-- =========================================================
-- 14. HIGH-RISK CUSTOMERS
-- Identifies customers requiring additional investigation.
-- =========================================================

SELECT
    customer_id,
    first_name,
    last_name,
    total_transactions,
    fraud_transactions,
    average_risk_score,
    maximum_risk_score,
    customer_risk_level

FROM production.customer_risk_summary

WHERE customer_risk_level = 'High Risk'

ORDER BY
    maximum_risk_score DESC,
    fraud_transactions DESC;


-- =========================================================
-- 15. FRAUD DETECTION SUMMARY
-- Overall final monitoring indicators.
-- =========================================================

WITH transaction_risk AS (

    SELECT
        t.transaction_id,
        t.amount,
        MAX(f.risk_score) AS risk_score

    FROM production.transactions t

    LEFT JOIN production.fraud_alerts f
        ON t.transaction_id = f.transaction_id

    GROUP BY
        t.transaction_id,
        t.amount
)

SELECT
    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE risk_score IS NOT NULL
    ) AS transactions_with_alerts,

    COUNT(*) FILTER (
        WHERE risk_score >= 80
    ) AS high_risk_transactions,

    COUNT(*) FILTER (
        WHERE risk_score >= 50
          AND risk_score < 80
    ) AS medium_risk_transactions,

    COUNT(*) FILTER (
        WHERE amount >= 10000
    ) AS high_value_transactions

FROM transaction_risk;


-- =========================================================
-- END OF FRAUD DETECTION
-- =========================================================