# NexaTrace System Database Deployment Guide

## Overview
This document provides comprehensive instructions for deploying the NexaTrace System database. The database uses PostgreSQL 13+ and follows a multi-tenant architecture with separate schemas for super admin (platform management) and factory admin (code management).

## Prerequisites

### System Requirements
- **PostgreSQL**: Version 13 or higher
- **Database**: `nexasystem_db` (will be created)
- **Extensions**: `uuid-ossp`, `pgcrypto`, `pg_stat_statements`
- **Storage**: Minimum 10GB (adjust based on expected data volume)
- **Memory**: Minimum 2GB RAM for development, 8GB+ for production

### Required Permissions
- Superuser access to create database and extensions
- Ability to create roles and grant permissions
- Network access to PostgreSQL port (default: 5432)

## Deployment Steps

### Step 1: Environment Setup

#### 1.1 Install PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS (Homebrew)
brew install postgresql@13

# Windows
# Download from https://www.postgresql.org/download/windows/
```

#### 1.2 Configure PostgreSQL
```bash
# Start PostgreSQL service
sudo service postgresql start  # Linux
brew services start postgresql@13  # macOS

# Access PostgreSQL shell
sudo -u postgres psql
```

### Step 2: Database Creation

#### 2.1 Create Database and User
```sql
-- Connect to PostgreSQL as superuser
psql -U postgres

-- Create database
CREATE DATABASE nexasystem_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the new database
\c nexasystem_db
```

#### 2.2 Enable Required Extensions
```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable cryptographic functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enable query statistics
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

### Step 3: Schema Deployment

#### 3.1 Run Initial Migration
```bash
# Navigate to database directory
cd C:\Ecosystem\NexaTrace_System\database

# Run the initial schema
psql -U postgres -d nexasystem_db -f schema.sql
```

#### 3.2 Alternative: Run Migration Scripts Sequentially
```bash
# Run migrations in order
psql -U postgres -d nexasystem_db -f migrations/001_initial_schema.sql
# psql -U postgres -d nexasystem_db -f migrations/002_add_indexes.sql
# psql -U postgres -d nexasystem_db -f migrations/003_add_partitioning.sql
```

### Step 4: Create Application Roles

#### 4.1 Create Roles and Set Passwords
```sql
-- Create application role with full access
CREATE ROLE nexa_app WITH LOGIN PASSWORD 'ChangeThisPassword123!';

-- Create read-only role for reporting
CREATE ROLE nexa_readonly WITH LOGIN PASSWORD 'ReadOnlyPassword456!';

-- Create admin role for super admin panel
CREATE ROLE nexa_superadmin WITH LOGIN PASSWORD 'SuperAdminPassword789!';
```

#### 4.2 Grant Permissions
```sql
-- Grant connect permission
GRANT CONNECT ON DATABASE nexasystem_db TO nexa_app, nexa_readonly, nexa_superadmin;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO nexa_app, nexa_readonly, nexa_superadmin;

-- Full access for application role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO nexa_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO nexa_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO nexa_app;

-- Read-only access for reporting
GRANT SELECT ON ALL TABLES IN SCHEMA public TO nexa_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO nexa_readonly;

-- Super admin access (full control)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nexa_superadmin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nexa_superadmin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO nexa_superadmin;
```

### Step 5: Insert Sample Data

#### 5.1 Insert Default Subscription Plans
```sql
-- Insert predefined subscription plans
INSERT INTO subscription_plans (id, name, type, description, monthly_price, yearly_price,
    monthly_unit_codes, monthly_packet_codes, monthly_carton_codes, monthly_bundle_codes,
    max_users, max_stores, max_drivers, is_recommended) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'Free Plan',
    'free',
    'Perfect for small businesses getting started with product authentication',
    0.00,
    0.00,
    5000, 1000, 200, 50,
    1, 1, 1,
    FALSE
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
    TRUE
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
    FALSE
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
    FALSE
);
```

#### 5.2 Create Initial Super Admin User
```sql
-- First, create a sample company
INSERT INTO companies (id, name, business_registration_number, email, country, city,
    contact_person_name, contact_person_email, contact_person_phone, status) VALUES
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
    'active'
);

-- Create super admin user
INSERT INTO factory_users (id, company_id, email, full_name, position,
    password_hash, password_salt, is_active) VALUES
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'superadmin@nexatrace.com',
    'Super Administrator',
    'admin',
    -- Password: Admin123! (bcrypt hash)
    '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u8i7o6p5q4w3e2r1t0y9u8i7o6p5q4w3e2r1',
    '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u',
    TRUE
);
```

### Step 6: Configuration and Optimization

#### 6.1 Database Configuration
```sql
-- Set timezone to UTC
SET TIME ZONE 'UTC';

-- Configure performance settings (adjust based on server resources)
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
```

#### 6.2 Create Initial Indexes
```sql
-- Additional performance indexes
CREATE INDEX idx_base_codes_code_lower ON base_codes(LOWER(code));
CREATE INDEX idx_unit_codes_auth_lower ON unit_codes(LOWER(authentication_code));
CREATE INDEX idx_products_sku_lower ON products(LOWER(sku));

-- Full-text search for products
ALTER TABLE products ADD COLUMN search_vector tsvector;
CREATE INDEX idx_products_search ON products USING GIN(search_vector);
```

### Step 7: Verification and Testing

#### 7.1 Verify Database Structure
```sql
-- Check table counts
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Check system health
SELECT * FROM system_health_view;

-- Verify sample data
SELECT name, type, monthly_price FROM subscription_plans;
SELECT name, status FROM companies;
```

#### 7.2 Test Database Functions
```sql
-- Test code generation validation
SELECT * FROM validate_code_generation(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'unit',
    100
);

-- Test data integrity checks
SELECT * FROM check_data_integrity();
```

### Step 8: Connection Configuration

#### 8.1 Update Application Configuration
Create `config/database.yaml`:
```yaml
database:
  host: localhost
  port: 5432
  name: nexasystem_db
  username: nexa_app
  password: ChangeThisPassword123!
  pool:
    min: 2
    max: 10
    idle_timeout: 30000
```

#### 8.2 Update Laravel Backend (.env)
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=nexasystem_db
DB_USERNAME=nexa_app
DB_PASSWORD=ChangeThisPassword123!
```

#### 8.3 Update Flutter Configuration
Create `lib/core/config/database_config.dart`:
```dart
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'nexasystem_db';
  static const String username = 'nexa_app';
  static const String password = 'ChangeThisPassword123!';
}
```

### Step 9: Backup and Recovery Setup

#### 9.1 Create Backup Script
Create `scripts/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/nexatrace"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/nexasystem_db_$DATE.sql"

mkdir -p $BACKUP_DIR
pg_dump -U postgres nexasystem_db > $BACKUP_FILE
gzip $BACKUP_FILE

# Keep only last 30 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
```

#### 9.