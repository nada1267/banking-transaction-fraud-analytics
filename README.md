# Banking Transaction & Fraud Analytics

A production-like SQL and Data Engineering project that simulates a banking system and provides transaction analytics, fraud detection, data validation, and database performance optimization.

## 📌 Project Overview

This project simulates a banking transaction system containing:

- Customers
- Branches
- Bank Accounts
- Cards
- Merchants
- Transactions
- Transfers
- Fraud Alerts

The project follows a layered database approach:

```text
CSV Data
   ↓
Staging Layer
   ↓
Data Cleaning & Transformation
   ↓
Production Layer
   ↓
Analytics & Fraud Detection
                    ┌──────────────┐
                    │  CSV Files   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Staging    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ ETL / Clean  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Production  │
                    │  PostgreSQL  │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       Fraud Detection          Analytical Layer
              │                         │
              └────────────┬────────────┘
                           ▼
                    Validation

````md
# Banking Transaction & Fraud Analytics

A production-like SQL and Data Engineering project that simulates a banking system and provides transaction analytics, fraud detection, data validation, and database performance optimization.

## 📌 Project Overview

This project simulates a banking transaction system containing:

- Customers
- Branches
- Bank Accounts
- Cards
- Merchants
- Transactions
- Transfers
- Fraud Alerts

The project follows a layered database approach:

```text
CSV Data
   ↓
Staging Layer
   ↓
Data Cleaning & Transformation
   ↓
Production Layer
   ↓
Analytics & Fraud Detection
````

## 🏗️ Architecture

```text
                    ┌──────────────┐
                    │  CSV Files   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Staging    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ ETL / Clean  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Production  │
                    │  PostgreSQL  │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       Fraud Detection          Analytical Layer
              │                         │
              └────────────┬────────────┘
                           ▼
                    Validation
```

## 🗂️ Database Tables

| Table        | Description                |
| ------------ | -------------------------- |
| customers    | Customer information       |
| branches     | Bank branch information    |
| accounts     | Customer bank accounts     |
| cards        | Cards linked to accounts   |
| merchants    | Merchant information       |
| transactions | Banking transactions       |
| transfers    | Transfers between accounts |
| fraud_alerts | Fraud detection alerts     |

## 📊 Dataset

The project contains:

* 10,000 Customers
* 50 Branches
* 15,000 Accounts
* 20,000 Cards
* 2,000 Merchants
* 200,000 Transactions
* 30,000 Transfers
* 5,000 Fraud Alerts

## ⚙️ Project Features

### Database Design

* Primary Keys
* Foreign Keys
* Constraints
* Normalized relational design
* Production-oriented database structure

### ETL Pipeline

The project includes:

* Staging layer
* Data cleaning
* Data transformation
* Production data loading
* Data validation

### Advanced SQL

The project demonstrates:

* Complex JOINs
* CTEs
* Recursive CTEs
* Window Functions
* LAG() and LEAD()
* RANK() and DENSE_RANK()
* CASE statements
* Correlated subqueries
* Date and time analysis

### Fraud Detection

The fraud analytics layer includes SQL-based fraud detection and risk analysis.

### Performance Optimization

* Database indexes
* Query performance analysis
* Performance testing

### Database Programming

* Stored procedures
* Transactions
* Error handling
* Views and analytical queries

## 🐍 Python Integration

Python is used to:

* Connect to PostgreSQL
* Load transaction data
* Load transfer data
* Load fraud alert data
* Validate production tables
* Validate row counts

Python files:

```text
python/
├── db_connection.py
├── load_data.py
└── database_validation.py
```

## 🐳 Docker

The project includes Docker support for running database validation inside a container.

Run:

```bash
docker compose up
```

The Docker container connects to PostgreSQL and runs:

```text
DATABASE VALIDATION
```

Expected result:

```text
DATABASE VALIDATION PASSED
```

## 📁 Project Structure

```text
banking-transaction-fraud-analytics/
│
├── data/
│   ├── accounts.csv
│   ├── branches.csv
│   ├── cards.csv
│   ├── customers.csv
│   ├── fraud_alerts.csv
│   ├── merchants.csv
│   ├── transactions.csv
│   └── transfers.csv
│
├── SQL/
│   ├── statging.sql
│   ├── staging_validation.sql
│   ├── etl_cleaning.sql
│   ├── PRODUCTION.sql
│   ├── production_validation.sql
│   ├── index.sql
│   ├── performance.sql
│   ├── TRANSACTIONS_PROCEDURES.sql
│   ├── fraud_detection.sql
│   ├── ANALYTICAL_LAYER.sql
│   └── FINAL_VALIDATION.sql
│
├── python/
│   ├── db_connection.py
│   ├── load_data.py
│   └── database_validation.py
│
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .gitignore
└── README.md
```

## 🚀 Technologies Used

* PostgreSQL
* SQL
* Python
* Pandas
* Psycopg
* Docker
* Docker Compose
* Git
* GitHub

## ▶️ Running the Project

### 1. Clone the repository

```bash
git clone https://github.com/nada1267/banking-transaction-fraud-analytics.git
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment variables

Create a `.env` file:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=banking_Transaction
DB_USER=postgres
DB_PASSWORD=your_password
```

### 4. Run database validation

```bash
python python/database_validation.py
```

### 5. Run using Docker

```bash
docker compose up
```

## ✅ Validation Results

The production database was successfully validated with:

```text
customers       10,000
branches            50
accounts        15,000
cards           20,000
merchants        2,000
transactions   200,000
transfers       30,000
fraud_alerts     5,000
```

Result:

```text
DATABASE VALIDATION PASSED
```

## 🎯 Key Skills Demonstrated

* Relational Database Design
* SQL Development
* ETL Pipelines
* Data Cleaning
* Data Validation
* Advanced SQL
* Window Functions
* Stored Procedures
* Transaction Management
* Fraud Detection Analytics
* Database Performance Optimization
* PostgreSQL
* Python Database Integration
* Docker
* Git & GitHub

## 👩‍💻 Author

Nada Ayman

GitHub: [https://github.com/nada1267](https://github.com/nada1267)

```
```
