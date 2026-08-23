@echo off
setlocal

echo ============================================================
echo BANKING TRANSACTION ^& FRAUD ANALYTICS
echo AUTOMATIC SETUP
echo ============================================================
echo.

REM ============================================================
REM 1. Check Docker
REM ============================================================

echo [1/4] Checking Docker...

docker --version >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Docker is not installed or not available.
    echo Please install Docker Desktop and try again.
    exit /b 1
)

echo [PASS] Docker is available.
echo.

REM ============================================================
REM 2. Start Docker services
REM ============================================================

echo [2/4] Starting Docker services...

docker compose up -d

if errorlevel 1 (
    echo [ERROR] Failed to start Docker services.
    exit /b 1
)

echo [PASS] Docker services started.
echo.

REM ============================================================
REM 3. Run database validation
REM ============================================================

echo [3/4] Validating database...

docker compose run --rm banking-fraud-analytics

if errorlevel 1 (
    echo [ERROR] Database validation failed.
    exit /b 1
)

echo [PASS] Database validation completed successfully.
echo.

REM ============================================================
REM 4. Setup completed
REM ============================================================

echo [4/4] Setup completed successfully.
echo.
echo ============================================================
echo BANKING FRAUD ANALYTICS
echo SETUP COMPLETED SUCCESSFULLY
echo ============================================================

exit /b 0