-- =========================================================
-- 09_INDEXES.SQL
-- Banking Transaction & Fraud Analytics Database
-- Performance Optimization Layer
-- =========================================================


-- =========================================================
-- TRANSACTIONS INDEXES
-- =========================================================

-- Used for account-based transaction queries
CREATE INDEX IF NOT EXISTS idx_production_transactions_account_id
ON production.transactions(account_id);


-- Used for date-range filtering and time-based analytics
CREATE INDEX IF NOT EXISTS idx_production_transactions_date
ON production.transactions(transaction_date);


-- Used for merchant-based fraud and transaction analysis
CREATE INDEX IF NOT EXISTS idx_production_transactions_merchant_id
ON production.transactions(merchant_id);


-- Used for card-based transaction analysis and joins
CREATE INDEX IF NOT EXISTS idx_production_transactions_card_id
ON production.transactions(card_id);


-- Used for high-value transaction detection
CREATE INDEX IF NOT EXISTS idx_production_transactions_amount
ON production.transactions(amount);


-- Composite index for account transaction history
-- Useful for LAG(), rapid transaction detection,
-- ordering transactions by account and date.
CREATE INDEX IF NOT EXISTS idx_production_transactions_account_date
ON production.transactions(account_id, transaction_date);


-- =========================================================
-- ACCOUNTS INDEXES
-- =========================================================

-- Used when joining accounts with customers
CREATE INDEX IF NOT EXISTS idx_production_accounts_customer_id
ON production.accounts(customer_id);


-- Used when joining accounts with branches
CREATE INDEX IF NOT EXISTS idx_production_accounts_branch_id
ON production.accounts(branch_id);


-- =========================================================
-- CARDS INDEXES
-- =========================================================

-- Used when joining cards with accounts
CREATE INDEX IF NOT EXISTS idx_production_cards_account_id
ON production.cards(account_id);


-- =========================================================
-- MERCHANTS INDEXES
-- =========================================================

-- Used for merchant-based analytical queries
CREATE INDEX IF NOT EXISTS idx_production_merchants_risk_level
ON production.merchants(risk_level);


-- =========================================================
-- FRAUD ALERTS INDEXES
-- =========================================================

-- Used when joining fraud alerts with transactions
CREATE INDEX IF NOT EXISTS idx_production_fraud_alerts_transaction_id
ON production.fraud_alerts(transaction_id);


-- Used for high-risk fraud detection queries
CREATE INDEX IF NOT EXISTS idx_production_fraud_alerts_risk_score
ON production.fraud_alerts(risk_score);


-- Used for fraud monitoring by alert status
CREATE INDEX IF NOT EXISTS idx_production_fraud_alerts_status
ON production.fraud_alerts(alert_status);


-- Composite index for fraud monitoring
-- Useful when filtering by alert status and risk score.
CREATE INDEX IF NOT EXISTS idx_production_fraud_alerts_status_risk
ON production.fraud_alerts(alert_status, risk_score);


-- =========================================================
-- TRANSFERS INDEXES
-- =========================================================

-- Used for source-account transfer analysis
CREATE INDEX IF NOT EXISTS idx_production_transfers_source_account
ON production.transfers(source_account_id);


-- Used for destination-account transfer analysis
CREATE INDEX IF NOT EXISTS idx_production_transfers_destination_account
ON production.transfers(destination_account_id);


-- Used for time-based transfer analysis
CREATE INDEX IF NOT EXISTS idx_production_transfers_date
ON production.transfers(transfer_date);


-- Composite index for time-based transfer monitoring
CREATE INDEX IF NOT EXISTS idx_production_transfers_date_status
ON production.transfers(transfer_date, status);


-- =========================================================
-- INDEX SUMMARY
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