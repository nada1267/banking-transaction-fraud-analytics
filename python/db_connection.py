# =========================================================
# db_connection.py
# Banking Transaction & Fraud Analytics
# PostgreSQL Database Connection
# =========================================================

import os
import psycopg
from dotenv import load_dotenv


# ---------------------------------------------------------
# Load environment variables
# ---------------------------------------------------------

load_dotenv()


# ---------------------------------------------------------
# Database configuration
# ---------------------------------------------------------

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "banking_Transaction")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")


# ---------------------------------------------------------
# Docker / Windows host configuration
# ---------------------------------------------------------

# When running inside Docker on Windows,
# "host.docker.internal" points to the Windows host.
#
# We keep "localhost" as the default so the Python scripts
# continue working normally outside Docker.

if os.getenv("DOCKER_ENV") == "true":
    DB_HOST = "host.docker.internal"


# ---------------------------------------------------------
# Create database connection
# ---------------------------------------------------------

def get_connection():

    connection = psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

    return connection


# ---------------------------------------------------------
# Test database connection
# ---------------------------------------------------------

if __name__ == "__main__":

    try:

        connection = get_connection()

        print("Database connection successful!")

        connection.close()

        print("Database connection closed.")

    except Exception as error:

        print("Database connection failed.")
        print(f"Error: {error}")