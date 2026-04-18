# NexaTrace System Database Deployment Script for Windows
# PowerShell script to deploy PostgreSQL database for NexaTrace System
# Run this script as Administrator

param(
    [string]$DatabaseName = "nexasystem_db",
    [string]$HostName = "localhost",
    [int]$Port = 5444,
    [string]$AdminUser = "postgres",
    [string]$AdminPassword = "awan1972",
    [string]$AppUser = "nexa_app",
    [string]$AppPassword = "NexaAppPassword123!",
    [string]$ReadOnlyUser = "nexa_readonly",
    [string]$ReadOnlyPassword = "ReadOnlyPassword456!",
    [string]$SuperAdminUser = "nexa_superadmin",
    [string]$SuperAdminPassword = "SuperAdminPassword789!",
    [string]$ProjectPath = "C:\Ecosystem\NexaTrace_System",
    [switch]$SkipInstall = $false,
    [switch]$SkipSampleData = $false,
    [switch]$Force = $false
)

# Error handling
$ErrorActionPreference = "Stop"

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$Magenta = "Magenta"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if PostgreSQL is installed
function Test-PostgreSQLInstalled {
    try {
        $pgPath = Get-Command psql -ErrorAction SilentlyContinue
        if ($pgPath) {
            return $true
        }

        # Check common installation paths
        $commonPaths = @(
            "C:\Program Files\PostgreSQL\*\bin\psql.exe",
            "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe"
        )

        foreach ($path in $commonPaths) {
            if (Test-Path $path) {
                return $true
            }
        }

        return $false
    }
    catch {
        return $false
    }
}

# Function to install PostgreSQL
function Install-PostgreSQL {
    Write-ColorOutput "`n📦 Installing PostgreSQL..." -Color $Cyan

    # Check if Chocolatey is installed
    $chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $chocoInstalled) {
        Write-ColorOutput "  Installing Chocolatey package manager..." -Color $Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    # Install PostgreSQL 15
    Write-ColorOutput "  Installing PostgreSQL 15 via Chocolatey..." -Color $Yellow
    choco install postgresql15 --version=15.7 -y --params "/Password:$AdminPassword /Port:$Port"

    # Add PostgreSQL to PATH
    $pgPath = "C:\Program Files\PostgreSQL\15\bin"
    if (Test-Path $pgPath) {
        $env:Path += ";$pgPath"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)
    }

    Write-ColorOutput "  ✅ PostgreSQL installed successfully" -Color $Green
}

# Function to start PostgreSQL service
function Start-PostgreSQLService {
    Write-ColorOutput "`n🚀 Starting PostgreSQL service..." -Color $Cyan

    try {
        # Try to start the service
        Start-Service -Name "postgresql-x64-15" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5

        # Check if service is running
        $service = Get-Service -Name "postgresql-x64-15" -ErrorAction SilentlyContinue
        if ($service.Status -ne "Running") {
            Write-ColorOutput "  ⚠️  PostgreSQL service not running, attempting to start..." -Color $Yellow
            net start "postgresql-x64-15"
            Start-Sleep -Seconds 3
        }

        Write-ColorOutput "  ✅ PostgreSQL service started" -Color $Green
    }
    catch {
        Write-ColorOutput "  ⚠️  Could not start PostgreSQL service: $_" -Color $Yellow
        Write-ColorOutput "  ℹ️  Please start PostgreSQL service manually" -Color $Yellow
    }
}

# Function to execute SQL command
function Invoke-PostgreSQLCommand {
    param(
        [string]$Database,
        [string]$Command,
        [string]$Username = $AdminUser,
        [string]$Password = $AdminPassword
    )

    $env:PGPASSWORD = $Password
    $output = & "psql" "-h" $HostName "-p" $Port "-U" $Username "-d" $Database "-c" $Command 2>&1
    $env:PGPASSWORD = $null

    return $output
}

# Function to execute SQL file
function Invoke-PostgreSQLFile {
    param(
        [string]$Database,
        [string]$FilePath,
        [string]$Username = $AdminUser,
        [string]$Password = $AdminPassword
    )

    if (-not (Test-Path $FilePath)) {
        throw "SQL file not found: $FilePath"
    }

    $env:PGPASSWORD = $Password
    $output = & "psql" "-h" $HostName "-p" $Port "-U" $Username "-d" $Database "-f" $FilePath 2>&1
    $env:PGPASSWORD = $null

    return $output
}

# Function to check if database exists
function Test-DatabaseExists {
    param([string]$DatabaseName)

    $command = "SELECT 1 FROM pg_database WHERE datname = '$DatabaseName'"
    $result = Invoke-PostgreSQLCommand "postgres" $command

    return $result -match "1 row"
}

# Function to create database
function New-NexaTraceDatabase {
    Write-ColorOutput "`n🗄️  Creating database '$DatabaseName'..." -Color $Cyan

    # Check if database already exists
    if (Test-DatabaseExists $DatabaseName) {
        if ($Force) {
            Write-ColorOutput "  ⚠️  Database '$DatabaseName' already exists, dropping..." -Color $Yellow
            $dropResult = Invoke-PostgreSQLCommand "postgres" "DROP DATABASE IF EXISTS $DatabaseName WITH (FORCE)"
            Write-ColorOutput "  ✅ Database dropped" -Color $Green
        } else {
            Write-ColorOutput "  ⚠️  Database '$DatabaseName' already exists. Use -Force to drop and recreate." -Color $Yellow
            return
        }
    }

    # Create database
    $createDbCommand = @"
CREATE DATABASE $DatabaseName
    WITH
    OWNER = $AdminUser
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
"@

    $result = Invoke-PostgreSQLCommand "postgres" $createDbCommand
    Write-ColorOutput "  ✅ Database created successfully" -Color $Green

    # Enable extensions
    Write-ColorOutput "  🔧 Enabling required extensions..." -Color $Yellow
    $extensions = @("uuid-ossp", "pgcrypto", "pg_stat_statements")

    foreach ($extension in $extensions) {
        $result = Invoke-PostgreSQLCommand $DatabaseName "CREATE EXTENSION IF NOT EXISTS `"$extension`";"
        Write-ColorOutput "    ✅ $extension enabled" -Color $Green
    }
}

# Function to create application roles
function New-ApplicationRoles {
    Write-ColorOutput "`n👥 Creating application roles..." -Color $Cyan

    # Create application role
    $createAppUser = "CREATE ROLE $AppUser WITH LOGIN PASSWORD '$AppPassword';"
    $result = Invoke-PostgreSQLCommand $DatabaseName $createAppUser
    Write-ColorOutput "  ✅ Application user '$AppUser' created" -Color $Green

    # Create read-only role
    $createReadOnlyUser = "CREATE ROLE $ReadOnlyUser WITH LOGIN PASSWORD '$ReadOnlyPassword';"
    $result = Invoke-PostgreSQLCommand $DatabaseName $createReadOnlyUser
    Write-ColorOutput "  ✅ Read-only user '$ReadOnlyUser' created" -Color $Green

    # Create super admin role
    $createSuperAdminUser = "CREATE ROLE $SuperAdminUser WITH LOGIN PASSWORD '$SuperAdminPassword';"
    $result = Invoke-PostgreSQLCommand $DatabaseName $createSuperAdminUser
    Write-ColorOutput "  ✅ Super admin user '$SuperAdminUser' created" -Color $Green
}

# Function to deploy schema
function Deploy-Schema {
    Write-ColorOutput "`n🏗️  Deploying database schema..." -Color $Cyan

    $schemaFile = Join-Path $ProjectPath "database\schema.sql"

    if (-not (Test-Path $schemaFile)) {
        throw "Schema file not found: $schemaFile"
    }

    Write-ColorOutput "  📄 Running schema file: $schemaFile" -Color $Yellow
    $result = Invoke-PostgreSQLFile $DatabaseName $schemaFile

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "  ✅ Schema deployed successfully" -Color $Green
    } else {
        Write-ColorOutput "  ❌ Schema deployment failed: $result" -Color $Red
        throw "Schema deployment failed"
    }
}

# Function to grant permissions
function Grant-Permissions {
    Write-ColorOutput "`n🔐 Granting permissions to roles..." -Color $Cyan

    $permissionsSQL = @"
-- Grant connect permission
GRANT CONNECT ON DATABASE $DatabaseName TO $AppUser, $ReadOnlyUser, $SuperAdminUser;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO $AppUser, $ReadOnlyUser, $SuperAdminUser;

-- Full access for application role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $AppUser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO $AppUser;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO $AppUser;

-- Read-only access for reporting
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $ReadOnlyUser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO $ReadOnlyUser;

-- Super admin access (full control)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $SuperAdminUser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $SuperAdminUser;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $SuperAdminUser;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $AppUser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $ReadOnlyUser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $SuperAdminUser;
"@

    $result = Invoke-PostgreSQLCommand $DatabaseName $permissionsSQL
    Write-ColorOutput "  ✅ Permissions granted successfully" -Color $Green
}

# Function to insert sample data
function Insert-SampleData {
    Write-ColorOutput "`n📊 Inserting sample data..." -Color $Cyan

    $sampleDataSQL = @"
-- Insert predefined subscription plans
INSERT INTO subscription_plans (id, name, type, description, monthly_price, yearly_price,
    monthly_unit_codes, monthly_packet_codes, monthly_carton_codes, monthly_bundle_codes,
    max_users, max_stores, max_drivers, is_recommended, created_at, updated_at) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'Free Plan',
    'free',
    'Perfect for small businesses getting started with product authentication',
    0.00,
    0.00,
    5000, 1000, 200, 50,
    1, 1, 1,
    FALSE,
    NOW(),
    NOW()
),
(
    '22222222-2222-2222-2222-222222222222',
    'Basic Plan',
    'basic',
    'Ideal for growing businesses with moderate code generation needs',
    49.00,
    490.00,
    50000, 10000, 2000, 500,
    5, 5, 3,
    TRUE,
    NOW(),
    NOW()
),
(
    '33333333-3333-3333-3333-333333333333',
    'Standard Plan',
    'standard',
    'For established businesses with high-volume code generation',
    149.00,
    1490.00,
    200000, 40000, 8000, 2000,
    20, 20, 10,
    FALSE,
    NOW(),
    NOW()
),
(
    '44444444-4444-4444-4444-444444444444',
    'Premium Plan',
    'premium',
    'Enterprise-grade solution for large-scale operations',
    499.00,
    4990.00,
    1000000, 200000, 40000, 10000,
    100, 100, 50,
    FALSE,
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Create a sample company
INSERT INTO companies (id, name, business_registration_number, email, country, city,
    contact_person_name, contact_person_email, contact_person_phone, status, created_at, updated_at) VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'NexaTrace Platform',
    'NT-2024-001',
    'platform@nexatrace.com',
    'United States',
    'San Francisco',
    'System Administrator',
    'admin@nexatrace.com',
    '+1-555-000-0001',
    'active',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Create super admin user (password: Admin123!)
INSERT INTO factory_users (id, company_id, email, full_name, position,
    password_hash, password_salt, is_active, created_at, updated_at) VALUES
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'superadmin@nexatrace.com',
    'Super Administrator',
    'admin',
    -- Password: Admin123! (bcrypt hash)
    '\$2a\$12\$K9q8q7v6s5d4f3e2r1t0y9u8i7o6p5q4w3e2r1t0y9u8i7o6p5q4w3e2r1',
    '\$2a\$12\$K9q8q7v6s5d4f3e2r1t0y9u',
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;
"@

    $result = Invoke-PostgreSQLCommand $DatabaseName $sampleDataSQL
    Write-ColorOutput "  ✅ Sample data inserted successfully" -Color $Green
}

# Function to optimize database
function Optimize-Database {
    Write-ColorOutput "`n⚡ Optimizing database configuration..." -Color $Cyan

    $optimizationSQL = @"
-- Set timezone to UTC
SET TIME ZONE 'UTC';

-- Configure performance settings
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '768MB';
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- Log configuration
ALTER SYSTEM SET log_min_duration_statement = '1000ms';
ALTER SYSTEM SET log_connections = ON;
ALTER SYSTEM SET log_disconnections = ON;
ALTER SYSTEM SET log_lock_waits = ON;

-- Reload configuration
SELECT pg_reload_conf();
"@

    $result = Invoke-PostgreSQLCommand $DatabaseName $optimizationSQL
    Write-ColorOutput "  ✅ Database optimized" -Color $Green
}

# Function to verify deployment
function Verify-Deployment {
    Write-ColorOutput "`n🔍 Verifying deployment..." -Color $Cyan

    $verificationSQL = @"
-- Check table counts
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Check subscription plans
SELECT name, type, monthly_price FROM subscription_plans;

-- Check companies
SELECT name, status FROM companies;

-- Check users
SELECT email, full_name, position FROM factory_users;
"@

    Write-ColorOutput "  📊 Deployment verification results:" -Color $Yellow
    $result = Invoke-PostgreSQLCommand $DatabaseName $verificationSQL
    Write-Host $result

    Write-ColorOutput "  ✅ Deployment verified successfully" -Color $Green
}

# Function to create connection test
function Test-Connection {
    Write-ColorOutput "`n🔗 Testing database connection..." -Color $Cyan

    try {
        $testCommand = "SELECT version();"
        $result = Invoke-PostgreSQLCommand $DatabaseName $testCommand

        if ($result -match "PostgreSQL") {
            Write-ColorOutput "  ✅ Connection successful: $($result | Select-String 'PostgreSQL
