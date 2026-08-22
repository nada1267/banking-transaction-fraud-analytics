# =========================================================
# database_validation.py
# Banking Transaction & Fraud Analytics
# Database Validation Layer
# =========================================================

from db_connection import get_connection


# ---------------------------------------------------------
# Tables that must exist in the production schema
# ---------------------------------------------------------

REQUIRED_TABLES = [
    "customers",
    "branches",
    "accounts",
    "cards",
    "merchants",
    "transactions",
    "transfers",
    "fraud_alerts"
]


# ---------------------------------------------------------
# Validate database tables
# ---------------------------------------------------------

def validate_tables(connection):

    print("\nChecking production tables...\n")

    all_tables_exist = True

    with connection.cursor() as cursor:

        for table_name in REQUIRED_TABLES:

            cursor.execute(
                """
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = 'production'
                      AND table_name = %s
                );
                """,
                (table_name,)
            )

            exists = cursor.fetchone()[0]

            if exists:
                print(f"[PASS] production.{table_name}")
            else:
                print(f"[FAIL] production.{table_name}")
                all_tables_exist = False

    return all_tables_exist


# ---------------------------------------------------------
# Get row counts
# ---------------------------------------------------------

def validate_row_counts(connection):

    print("\nProduction table row counts:\n")

    with connection.cursor() as cursor:

        for table_name in REQUIRED_TABLES:

            cursor.execute(
                f"""
                SELECT COUNT(*)
                FROM production."{table_name}";
                """
            )

            row_count = cursor.fetchone()[0]

            print(
                f"{table_name:<15} {row_count:>10,} rows"
            )


# ---------------------------------------------------------
# Main validation process
# ---------------------------------------------------------

def main():

    connection = None

    try:

        connection = get_connection()

        print("=" * 60)
        print("BANKING FRAUD ANALYTICS")
        print("DATABASE VALIDATION")
        print("=" * 60)

        tables_valid = validate_tables(connection)

        if tables_valid:

            validate_row_counts(connection)

            print("\n" + "=" * 60)
            print("DATABASE VALIDATION PASSED")
            print("=" * 60)

        else:

            print("\n" + "=" * 60)
            print("DATABASE VALIDATION FAILED")
            print("=" * 60)

    except Exception as error:

        print("\nDatabase validation failed.")
        print(f"Error: {error}")

    finally:

        if connection is not None:
            connection.close()
            print("\nDatabase connection closed.")


# ---------------------------------------------------------
# Run validation
# ---------------------------------------------------------

if __name__ == "__main__":
    main()