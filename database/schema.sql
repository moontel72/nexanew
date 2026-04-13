-- NexaTrace System Database Schema
-- PostgreSQL 13+ Compatible
-- Created: 2024-01-01
-- Last Updated: 2024-01-01

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- SUPER ADMIN TABLES (Platform Management)
-- ============================================

-- Companies (Factories/Client Companies)
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    business_registration_number VARCHAR(100) UNIQUE NOT NULL,
    tax_id VARCHAR(100),
    company_type VARCHAR(50) NOT NULL DEFAULT 'manufacturing',
    industry_type VARCHAR(50) NOT NULL DEFAULT 'other',

    -- Contact Information
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    website VARCHAR(255),
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT,
    postal_code VARCHAR(50),

    -- Contact Person
    contact_person_name VARCHAR(255) NOT NULL,
    contact_person_email VARCHAR(255) NOT NULL,
    contact_person_phone VARCHAR(50) NOT NULL,
    contact_person_position VARCHAR(100),

    -- Status & Verification
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    verification_status VARCHAR(20) NOT NULL DEFAULT 'notSubmitted',
    verification_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID, -- References admin_users.id

    -- Settings
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    currency VARCHAR(3) DEFAULT 'USD',
    logo_url TEXT,

    -- Usage Tracking
    total_codes_generated INTEGER DEFAULT 0,
    active_users_count INTEGER DEFAULT 0,
    last_activity_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Indexes
    INDEX idx_companies_status (status),
    INDEX idx_companies_verification_status (verification_status),
    INDEX idx_companies_country (country),
    INDEX idx_companies_created_at (created_at DESC)
);

-- Company Documents
CREATE TABLE company_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_name VARCHAR(255) NOT NULL,
    document_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),

    -- Verification
    verification_status VARCHAR(20) DEFAULT 'pending',
    verification_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID, -- References admin_users.id

    -- Metadata
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_company_documents_company (company_id),
    INDEX idx_company_documents_type (document_type),
    INDEX idx_company_documents_status (verification_status)
);

-- Subscription Plans
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'basic', -- free, basic, standard, premium, custom
    description TEXT,

    -- Pricing
    monthly_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    yearly_price DECIMAL(10,2),
    setup_fee DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',

    -- Code Generation Limits (Monthly)
    monthly_unit_codes INTEGER NOT NULL DEFAULT 0,
    monthly_packet_codes INTEGER NOT NULL DEFAULT 0,
    monthly_carton_codes INTEGER NOT NULL DEFAULT 0,
    monthly_bundle_codes INTEGER NOT NULL DEFAULT 0,

    -- User Limits
    max_users INTEGER NOT NULL DEFAULT 1,
    max_stores INTEGER NOT NULL DEFAULT 1,
    max_drivers INTEGER NOT NULL DEFAULT 1,

    -- Features
    features JSONB DEFAULT '[]',
    is_custom BOOLEAN DEFAULT FALSE,
    is_recommended BOOLEAN DEFAULT FALSE,

    -- Status
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, archived
    company_count INTEGER DEFAULT 0,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE,

    -- Indexes
    INDEX idx_subscription_plans_type (type),
    INDEX idx_subscription_plans_status (status),
    INDEX idx_subscription_plans_price (monthly_price)
);

-- Company Subscriptions
CREATE TABLE company_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    -- Subscription Details
    billing_cycle VARCHAR(20) NOT NULL DEFAULT 'monthly', -- monthly, quarterly, yearly
    start_date DATE NOT NULL,
    end_date DATE,
    renewal_date DATE,
    auto_renew BOOLEAN DEFAULT TRUE,

    -- Payment Information
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending', -- pending, paid, failed, refunded
    last_payment_date DATE,
    next_payment_date DATE,

    -- Usage Tracking (Current Period)
    current_unit_codes_used INTEGER DEFAULT 0,
    current_packet_codes_used INTEGER DEFAULT 0,
    current_carton_codes_used INTEGER DEFAULT 0,
    current_bundle_codes_used INTEGER DEFAULT 0,

    -- Status
    status VARCHAR(20) DEFAULT 'active', -- active, suspended, cancelled, expired
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    UNIQUE(company_id, plan_id, status) WHERE status = 'active',

    -- Indexes
    INDEX idx_company_subscriptions_company (company_id),
    INDEX idx_company_subscriptions_plan (plan_id),
    INDEX idx_company_subscriptions_status (status),
    INDEX idx_company_subscriptions_dates (start_date, end_date)
);

-- Invoices
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES company_subscriptions(id) ON DELETE SET NULL,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,

    -- Invoice Details
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,

    -- Amounts
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',

    -- Items
    items JSONB DEFAULT '[]',

    -- Payment Status
    status VARCHAR(20) DEFAULT 'pending', -- pending, paid, overdue, cancelled
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),

    -- Metadata
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_invoices_company (company_id),
    INDEX idx_invoices_status (status),
    INDEX idx_invoices_due_date (due_date),
    INDEX idx_invoices_period (period_start, period_end)
);

-- ============================================
-- FACTORY ADMIN TABLES (Code Management)
-- ============================================

-- Factory Users (Admins, Store Keepers, Drivers)
CREATE TABLE factory_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

    -- User Information
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL, -- admin, store_keeper, driver

    -- Authentication
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,

    -- Permissions
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    -- Constraints
    UNIQUE(company_id, email),

    -- Indexes
    INDEX idx_factory_users_company (company_id),
    INDEX idx_factory_users_position (position),
    INDEX idx_factory_users_email (email)
);

-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

    -- Product Information
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100),

    -- Product Type Specific Fields
    product_type VARCHAR(50) NOT NULL DEFAULT 'other', -- food, medical, other
    requires_manufacturing_date BOOLEAN DEFAULT FALSE,
    requires_expiry_date BOOLEAN DEFAULT FALSE,
    requires_warranty BOOLEAN DEFAULT FALSE,

    -- Default Values
    default_warranty_months INTEGER,
    default_storage_conditions TEXT,
    default_handling_instructions TEXT,

    -- Images
    image_urls TEXT[] DEFAULT '{}',

    status VARCHAR(20) NOT NULL DEFAULT 'active',

    -- Metadata
    metadata JSONB DEFAULT '{}',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_products_company (company_id),
    INDEX idx_products_sku (sku),
    INDEX idx_products_category (category),
    INDEX idx_products_type (product_type)
);

-- Base Codes Table (Common fields for all code types)
CREATE TABLE base_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    subscription_plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    -- Code Information
    code VARCHAR(100) UNIQUE NOT NULL,
    code_type VARCHAR(20) NOT NULL, -- bundle, carton, packet, unit
    status VARCHAR(20) NOT NULL DEFAULT 'generated', -- generated, linked, published, deactivated

    -- Internal Tracking
    store_keeper_code VARCHAR(100) NOT NULL,
    international_code VARCHAR(255),
    batch_id VARCHAR(100) NOT NULL,

    -- Timestamps
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    linked_at TIMESTAMP WITH TIME ZONE,
    published_at TIMESTAMP WITH TIME ZONE,
    deactivated_at TIMESTAMP WITH TIME ZONE,

    -- Product Linking
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_batch_number VARCHAR(100),
    manufacturing_date DATE,
    expiry_date DATE,
    warranty_months INTEGER,

    -- Code Data
    qr_code_data TEXT,
    barcode_data TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    version INTEGER DEFAULT 1,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_base_codes_company (company_id),
    INDEX idx_base_codes_type (code_type),
    INDEX idx_base_codes_status (status),
    INDEX idx_base_codes_batch (batch_id),
    INDEX idx_base_codes_created (created_at DESC),
    INDEX idx_base_codes_product (product_id)
);

-- Bundle Codes (Extends base_codes)
CREATE TABLE bundle_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Bundle Specific Fields
    cartons_per_bundle INTEGER NOT NULL,
    bundle_weight_kg DECIMAL(10,2),
    bundle_dimensions VARCHAR(100), -- format: "LxWxH"

    -- Shipping Information
    storage_location VARCHAR(255),
    shipping_method VARCHAR(100),
    expected_delivery_date DATE,

    -- Additional Information
    category VARCHAR(100),
    handling_instructions TEXT,
    customs_declaration_number VARCHAR(100),
    insurance_value DECIMAL(10,2),
    priority INTEGER DEFAULT 2, -- 1=High, 2=Medium, 3=Low

    -- Indexes
    INDEX idx_bundle_codes_delivery (expected_delivery_date)
);

-- Carton Codes (Extends base_codes)
CREATE TABLE carton_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Hierarchy
    bundle_code_id UUID REFERENCES bundle_codes(id) ON DELETE CASCADE,

    -- Carton Specific Fields
    packet_count INTEGER NOT NULL,
    packet_codes UUID[] DEFAULT '{}', -- References to packet_codes.id
    sequence_number INTEGER NOT NULL,
    total_units INTEGER NOT NULL,

    -- Physical Properties
    weight_kg DECIMAL(10,2),
    dimensions VARCHAR(100), -- format: "LxWxH"
    carton_type VARCHAR(50), -- Corrugated, Cardboard, Plastic
    grade VARCHAR(20), -- A, B, Premium
    max_weight_capacity_kg DECIMAL(10,2),

    -- Sealing Information
    is_sealed BOOLEAN DEFAULT FALSE,
    sealed_at TIMESTAMP WITH TIME ZONE,
    sealed_by UUID REFERENCES factory_users(id),

    -- Handling Requirements
    temperature_requirements VARCHAR(100),
    handling_instructions TEXT,

    -- Additional Codes
    carton_barcode VARCHAR(255),
    carton_qr_code VARCHAR(255),

    -- Condition & Inspection
    condition VARCHAR(50) DEFAULT 'New', -- New, Good, Damaged, Repair needed
    last_inspection_date DATE,
    inspection_notes TEXT,

    -- Indexes
    INDEX idx_carton_codes_bundle (bundle_code_id),
    INDEX idx_carton_codes_condition (condition),
    INDEX idx_carton_codes_sealed (is_sealed)
);

-- Packet Codes (Extends base_codes)
CREATE TABLE packet_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Hierarchy
    carton_code_id UUID REFERENCES carton_codes(id) ON DELETE CASCADE,

    -- Packet Specific Fields
    unit_count INTEGER NOT NULL,
    unit_codes UUID[] DEFAULT '{}', -- References to unit_codes.id
    sequence_number INTEGER NOT NULL,

    -- Physical Properties
    weight_grams DECIMAL(10,2),
    dimensions VARCHAR(100), -- format: "LxWxH"
    packet_type VARCHAR(50), -- Blister, Box, Pouch, Bottle
    material VARCHAR(50), -- Plastic, Paper, Aluminum

    -- Sealing Information
    is_sealed BOOLEAN DEFAULT FALSE,
    sealed_at TIMESTAMP WITH TIME ZONE,
    sealed_by UUID REFERENCES factory_users(id),
    sealing_method VARCHAR(50), -- Heat Seal, Adhesive, Clip

    -- Additional Codes
    packet_barcode VARCHAR(255),
    packet_qr_code VARCHAR(255),

    -- Safety Features
    condition VARCHAR(50) DEFAULT 'Intact', -- Intact, Damaged, Torn
    has_tamper_evidence BOOLEAN DEFAULT FALSE,
    has_child_safety BOOLEAN DEFAULT FALSE,
    has_instructions BOOLEAN DEFAULT FALSE,

    -- Identification
    packet_batch_number VARCHAR(100),
    serial_number VARCHAR(100),

    -- Indexes
    INDEX idx_packet_codes_carton (carton_code_id),
    INDEX idx_packet_codes_condition (condition),
    INDEX idx_packet_codes_serial (serial_number)
);

-- Unit Codes (Authentication Codes - Extends base_codes)
CREATE TABLE unit_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Hierarchy
    packet_code_id UUID REFERENCES packet_codes(id) ON DELETE CASCADE,

    -- Unit Specific Fields
    sequence_number INTEGER NOT NULL,
    authentication_code VARCHAR(255) NOT NULL UNIQUE,

    -- Authentication Hierarchy
    is_master_code BOOLEAN DEFAULT FALSE,
    master_code_id UUID REFERENCES unit_codes(id),

    -- Verification Tracking
    verification_count INTEGER DEFAULT 0,
    first_verified_at TIMESTAMP WITH TIME ZONE,
    last_verified_at TIMESTAMP WITH TIME ZONE,
    verification_location VARCHAR(255),
    verified_by UUID, -- Could be customer user ID or device ID

    -- Fake Reporting
    is_reported_fake BOOLEAN DEFAULT FALSE,
    fake_reported_at TIMESTAMP WITH TIME ZONE,
    fake_reported_by UUID, -- References customer_users.id
    fake_report_reason TEXT,

    -- Blocking
    is_blocked BOOLEAN DEFAULT FALSE,
    blocked_at TIMESTAMP WITH TIME ZONE,
    blocked_by UUID REFERENCES factory_users(id),
    block_reason TEXT,

    -- Identification
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    model VARCHAR(100),

    -- Indexes
    INDEX idx_unit_codes_packet (packet_code_id),
    INDEX idx_unit_codes_auth (authentication_code),
    INDEX idx_unit_codes_serial (serial_number),
    INDEX idx_unit_codes_verified (verification_count),
    INDEX idx_unit_codes_fake (is_reported_fake),
    INDEX idx_unit_codes_blocked (is_blocked)
);

-- Code Verification History
CREATE TABLE code_verification_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_code_id UUID NOT NULL REFERENCES unit_codes(id) ON DELETE CASCADE,

    -- Verification Details
    verification_type VARCHAR(50) NOT NULL, -- customer_scan, store_verification, admin_check
    verification_method VARCHAR(50), -- qr_scan, barcode_scan, manual_entry
    verification_result VARCHAR(50) NOT NULL, -- genuine, fake, suspicious

    -- Location & Device
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_address TEXT,
    device_id VARCHAR(255),
    device_type VARCHAR(50), -- mobile, tablet, desktop, scanner

    -- User Information
    user_id UUID, -- References customer_users.id or factory_users.id
    user_type VARCHAR(50), -- customer, store_keeper, admin, driver

    -- Timestamps
    verified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Additional Data
    notes TEXT,
    metadata JSONB DEFAULT '{}',

    -- Indexes
    INDEX idx_verification_history_unit_code (unit_code_id),
    INDEX idx_verification_history_verified_at (verified_at DESC),
    INDEX idx_verification_history_result (verification_result),
    INDEX idx_verification_history_user (user_id, user_type)
);

-- Customer Users (for verification tracking)
CREATE TABLE customer_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- User Information
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50) UNIQUE,
    full_name VARCHAR(255),

    -- Authentication (optional for registered customers)
    password_hash VARCHAR(255),
    password_salt VARCHAR(255),

    -- Preferences
    language VARCHAR(10) DEFAULT 'en',
    notification_preferences JSONB DEFAULT '{"email": true, "push": true}',

    -- Statistics
    total_verifications INTEGER DEFAULT 0,
    fake_reports_count INTEGER DEFAULT 0,
    last_verification_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_customer_users_email (email),
    INDEX idx_customer_users_phone (phone),
    INDEX idx_customer_users_created (created_at DESC)
);

-- ============================================
-- AUDIT & LOGGING TABLES
-- ============================================

-- Audit Logs (Track all important actions)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Action Details
    action_type VARCHAR(100) NOT NULL, -- create, update, delete, publish, deactivate
    entity_type VARCHAR(100) NOT NULL, -- company, code, product, user, subscription
    entity_id UUID NOT NULL,

    -- User Information
    user_id UUID,
    user_type VARCHAR(50), -- super_admin, factory_admin, store_keeper, customer
    user_ip INET,
    user_agent TEXT,

    -- Changes
    old_values JSONB,
    new_values JSONB,
    changes JSONB,

    -- Result
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,

    -- Timestamps
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_audit_logs_entity (entity_type, entity_id),
    INDEX idx_audit_logs_user (user_id, user_type),
    INDEX idx_audit_logs_action (action_type),
    INDEX idx_audit_logs_timestamp (performed_at DESC)
);

-- System Logs (For debugging and monitoring)
CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Log Details
    log_level VARCHAR(20) NOT NULL, -- debug, info, warning, error, critical
    logger_name VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,

    -- Context
    context JSONB DEFAULT '{}',
    stack_trace TEXT,

    -- Source
    source_file VARCHAR(255),
    source_line INTEGER,
    source_function VARCHAR(255),

    -- Environment
    environment VARCHAR(50) DEFAULT 'production',
    version VARCHAR(50),

    -- Timestamps
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes
    INDEX idx_system_logs_level (log_level),
    INDEX idx_system_logs_logger (logger_name),
    INDEX idx_system_logs_timestamp (logged_at DESC),
    INDEX idx_system_logs_env (environment)
);

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- Company Dashboard View
CREATE VIEW company_dashboard_view AS
SELECT
    c.id,
    c.name,
    c.status,
    c.verification_status,
    c.total_codes_generated,
    c.active_users_count,
    c.last_activity_at,

    -- Subscription Information
    cs.status as subscription_status,
    sp.name as plan_name,
    sp.type as plan_type,
    cs.start_date,
    cs.end_date,
    cs.renewal_date,

    -- Usage Statistics
    cs.current_unit_codes_used,
    cs.current_packet_codes_used,
    cs.current_carton_codes_used,
    cs.current_bundle_codes_used,

    -- Plan Limits
    sp.monthly_unit_codes,
    sp.monthly_packet_codes,
    sp.monthly_carton_codes,
    sp.monthly_bundle_codes,

    -- Usage Percentages
    ROUND((cs.current_unit_codes_used::DECIMAL / NULLIF(sp.monthly_unit_codes, 0) * 100), 2) as unit_usage_percentage,
    ROUND((cs.current_packet_codes_used::DECIMAL / NULLIF(sp.monthly_packet_codes, 0) * 100), 2) as packet_usage_percentage,
    ROUND((cs.current_carton_codes_used::DECIMAL / NULLIF(sp.monthly_carton_codes, 0) * 100), 2) as carton_usage_percentage,
    ROUND((cs.current_bundle_codes_used::DECIMAL / NULLIF(sp.monthly_bundle_codes, 0) * 100), 2) as bundle_usage_percentage

FROM companies c
LEFT JOIN company_subscriptions cs ON c.id = cs.company_id AND cs.status = 'active'
LEFT JOIN subscription_plans sp ON cs.plan_id = sp.id
WHERE c.is_deleted = FALSE;

-- Code Statistics View
CREATE VIEW code_statistics_view AS
SELECT
    bc.company_id,
    bc.code_type,
    bc.status,
    DATE(bc.created_at) as creation_date,
    COUNT(*) as code_count,

    -- Product Types
    COUNT(DISTINCT bc.product_id) as unique_products,

    -- Verification Stats (for unit codes)
    SUM(CASE WHEN uc.verification_count > 0 THEN 1 ELSE 0 END) as verified_units,
    SUM(CASE WHEN uc.is_reported_fake THEN 1 ELSE 0 END) as fake_reported_units,
    SUM(CASE WHEN uc.is_blocked THEN 1 ELSE 0 END) as blocked_units

FROM base_codes bc
LEFT JOIN unit_codes uc ON bc.id = uc.id AND bc.code_type = 'unit'
WHERE bc.is_deleted = FALSE
GROUP BY bc.company_id, bc.code_type, bc.status, DATE(bc.created_at);

-- ============================================
-- SAMPLE DATA FOR DEVELOPMENT
-- ============================================

-- Insert Sample Subscription Plans
INSERT INTO subscription_plans (id, name, type, description, monthly_price, yearly_price,
    monthly_unit_codes, monthly_packet_codes, monthly_carton_codes, monthly_bundle_codes,
    max_users, max_stores, max_drivers, is_recommended, features) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'Free Plan',
    'free',
    'Perfect for small businesses getting started with product authentication',
    0.00,
    0.00,
    5000,  -- 5K unit codes
    1000,  -- 1K packet codes
    200,   -- 200 carton codes
    50,    -- 50 bundle codes
    1,     -- 1 user
    1,     -- 1 store
    1,     -- 1 driver
    FALSE,
    '["basic_qr_scanning", "manual_verification", "email_support", "mobile_app_access"]'
),
(
    '22222222-2222-2222-2222-222222222222',
    'Basic Plan',
    'basic',
    'Ideal for growing businesses with moderate code generation needs',
    49.00,
    490.00,  -- $490 yearly (2 months free)
    50000,   -- 50K unit codes
    10000,   -- 10K packet codes
    2000,    -- 2K carton codes
    500,     -- 500 bundle codes
    5,       -- 5 users
    5,       -- 5 stores
    3,       -- 3 drivers
    TRUE,
    '["basic_qr_scanning", "manual_verification", "email_support", "mobile_app_access",
      "batch_code_generation", "product_management", "basic_analytics", "api_access"]'
),
(
    '33333333-3333-3333-3333-333333333333',
    'Standard Plan',
    'standard',
    'For established businesses with high-volume code generation',
    149.00,
    1490.00,  -- $1490 yearly (2 months free)
    200000,   -- 200K unit codes
    40000,    -- 40K packet codes
    8000,     -- 8K carton codes
    2000,     -- 2K bundle codes
    20,       -- 20 users
    20,       -- 20 stores
    10,       -- 10 drivers
    FALSE,
    '["basic_qr_scanning", "manual_verification", "email_support", "mobile_app_access",
      "batch_code_generation", "product_management", "basic_analytics", "api_access",
      "gps_attendance", "salary_management", "advanced_analytics", "priority_support"]'
),
(
    '44444444-4444-4444-4444-444444444444',
    'Premium Plan',
    'premium',
    'Enterprise-grade solution for large-scale operations',
    499.00,
    4990.00,  -- $4990 yearly (2 months free)
    1000000,  -- 1M unit codes
    200000,   -- 200K packet codes
    40000,    -- 40K carton codes
    10000,    -- 10K bundle codes
    100,      -- 100 users
    100,      -- 100 stores
    50,       -- 50 drivers
    FALSE,
    '["basic_qr_scanning", "manual_verification", "email_support", "mobile_app_access",
      "batch_code_generation", "product_management", "basic_analytics", "api_access",
      "gps_attendance", "salary_management", "advanced_analytics", "priority_support",
      "multi_company_control", "custom_integrations", "dedicated_support", "white_labeling"]'
);

-- Insert Sample Company
INSERT INTO companies (id, name, business_registration_number, email, country, city,
    contact_person_name, contact_person_email, contact_person_phone, status) VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'MediPharm Pharmaceuticals',
    'MP-2024-001',
    'contact@medipharm.com',
    'United States',
    'New York',
    'John Smith',
    'john.smith@medipharm.com',
    '+1-555-123-4567',
    'active'
);

-- Insert Sample Company Subscription
INSERT INTO company_subscriptions (id, company_id, plan_id, billing_cycle, start_date,
    end_date, renewal_date, status) VALUES
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '22222222-2222-2222-2222-222222222222',  -- Basic Plan
    'monthly',
    CURRENT_DATE - INTERVAL '3 months',
    CURRENT_DATE + INTERVAL '9 months',
    CURRENT_DATE + INTERVAL '1 month',
    'active'
);

-- Insert Sample Factory Admin User
INSERT INTO factory_users (id, company_id, email, full_name, position,
    password_hash, password_salt) VALUES
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'admin@medipharm.com',
    'Sarah Johnson',
    'admin',
    -- Password: Admin123! (hashed with bcrypt)
    '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u8i7o6p5q4w3e2r1t0y9u8i7o6p5q4w3e2r1',
    '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u'
);

-- Insert Sample Product
INSERT INTO products (id, company_id, name, sku, description, category,
    product_type, requires_manufacturing_date, requires_expiry_date) VALUES
(
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Pain Relief Tablets',
    'MED-PRT-001',
    'Fast-acting pain relief tablets, 500mg each',
    'Pharmaceuticals',
    'medical',
    TRUE,
    TRUE
);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_documents_updated_at
    BEFORE UPDATE ON company_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at
    BEFORE UPDATE ON subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_subscriptions_updated_at
    BEFORE UPDATE ON company_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at
    BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_factory_users_updated_at
    BEFORE UPDATE ON factory_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_base_codes_updated_at
    BEFORE UPDATE ON base_codes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customer_users_updated_at
    BEFORE UPDATE ON customer_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to validate code generation against subscription limits
CREATE OR REPLACE FUNCTION validate_code_generation(
    p_company_id UUID,
    p_code_type VARCHAR(20),
    p_requested_count INTEGER
)
RETURNS TABLE (
    can_generate BOOLEAN,
    current_usage INTEGER,
    plan_limit INTEGER,
    remaining INTEGER,
    message TEXT
) AS $$
DECLARE
    v_subscription RECORD;
    v_current_usage INTEGER;
    v_plan_limit INTEGER;
BEGIN
    -- Get active subscription for company
    SELECT
        cs.current_unit_codes_used,
        cs.current_packet_codes_used,
        cs.current_carton_codes_used,
        cs.current_bundle_codes_used,
        sp.monthly_unit_codes,
        sp.monthly_packet_codes,
        sp.monthly_carton_codes,
        sp.monthly_bundle_codes
    INTO v_subscription
    FROM company_subscriptions cs
    JOIN subscription_plans sp ON cs.plan_id = sp.id
    WHERE cs.company_id = p_company_id
        AND cs.status = 'active'
        AND cs.end_date >= CURRENT_DATE;

    IF v_subscription IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            0,
            0,
            0,
            'No active subscription found for company';
        RETURN;
    END IF;

    -- Get current usage based on code type
    CASE p_code_type
        WHEN 'unit' THEN
            v_current_usage := v_subscription.current_unit_codes_used;
            v_plan_limit := v_subscription.monthly_unit_codes;
        WHEN 'packet' THEN
            v_current_usage := v_subscription.current_packet_codes_used;
            v_plan_limit := v_subscription.monthly_packet_codes;
        WHEN 'carton' THEN
            v_current_usage := v_subscription.current_carton_codes_used;
            v_plan_limit := v_subscription.monthly_carton_codes;
        WHEN 'bundle' THEN
            v_current_usage := v_subscription.current_bundle_codes_used;
            v_plan_limit := v_subscription.monthly_bundle_codes;
        ELSE
            RETURN QUERY SELECT
                FALSE,
                0,
                0,
                0,
                'Invalid code type: ' || p_code_type;
            RETURN;
    END CASE;

    -- Check if can generate requested count
    IF v_current_usage + p_requested_count <= v_plan_limit THEN
        RETURN QUERY SELECT
            TRUE,
            v_current_usage,
            v_plan_limit,
            v_plan_limit - v_current_usage - p_requested_count,
            'Code generation allowed';
    ELSE
        RETURN QUERY SELECT
            FALSE,
            v_current_usage,
            v_plan_limit,
            v_plan_limit - v_current_usage,
            'Code limit exceeded. Requested: ' || p_requested_count ||
            ', Available: ' || (v_plan_limit - v_current_usage);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update code usage after generation
CREATE OR REPLACE FUNCTION update_code_usage(
    p_company_id UUID,
    p_code_type VARCHAR(20),
    p_generated_count INTEGER
)
RETURNS VOID AS $$
BEGIN
    UPDATE company_subscriptions cs
    SET
        current_unit_codes_used = CASE
            WHEN p_code_type = 'unit' THEN current_unit_codes_used + p_generated_count
            ELSE current_unit_codes_used
        END,
        current_packet_codes_used = CASE
            WHEN p_code_type = 'packet' THEN current_packet_codes_used + p_generated_count
            ELSE current_packet_codes_used
        END,
        current_carton_codes_used = CASE
            WHEN p_code_type = 'carton' THEN current_carton_codes_used + p_generated_count
            ELSE current_carton_codes_used
        END,
        current_bundle_codes_used = CASE
            WHEN p_code_type = 'bundle' THEN current_bundle_codes_used + p_generated_count
            ELSE current_bundle_codes_used
        END,
        updated_at = NOW()
    WHERE cs.company_id = p_company_id
        AND cs.status = 'active';
END;
$$ LANGUAGE plpgsql;

-- Function to update company total codes generated
CREATE OR REPLACE FUNCTION update_company_code_stats(
    p_company_id UUID,
    p_code_count INTEGER
)
RETURNS VOID AS $$
BEGIN
    UPDATE companies
    SET
        total_codes_generated = total_codes_generated + p_code_count,
        last_activity_at = NOW(),
        updated_at = NOW()
    WHERE id = p_company_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for code generation validation
CREATE OR REPLACE FUNCTION validate_code_generation_trigger()
RETURNS TRIGGER AS $$
DECLARE
    v_validation RECORD;
BEGIN
    -- Validate code generation against subscription limits
    SELECT * INTO v_validation
    FROM validate_code_generation(
        NEW.company_id,
        NEW.code_type,
        1  -- Each insert is 1 code
    );

    IF NOT v_validation.can_generate THEN
        RAISE EXCEPTION '%', v_validation.message;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply validation trigger to base_codes
CREATE TRIGGER validate_code_generation_before_insert
    BEFORE INSERT ON base_codes
    FOR EACH ROW EXECUTE FUNCTION validate_code_generation_trigger();

-- Trigger function to update usage after code generation
CREATE OR REPLACE FUNCTION update_usage_after_code_generation()
RETURNS TRIGGER AS $$
BEGIN
    -- Update subscription usage
    PERFORM update_code_usage(
        NEW.company_id,
        NEW.code_type,
        1  -- Each insert is 1 code
    );

    -- Update company statistics
    PERFORM update_company_code_stats(
        NEW.company_id,
        1  -- Each insert is 1 code
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply usage update trigger to base_codes
CREATE TRIGGER update_usage_after_code_insert
    AFTER INSERT ON base_codes
    FOR EACH ROW EXECUTE FUNCTION update_usage_after_code_generation();

-- Function to reset monthly usage (to be run by cron job)
CREATE OR REPLACE FUNCTION reset_monthly_usage()
RETURNS VOID AS $$
BEGIN
    UPDATE company_subscriptions
    SET
        current_unit_codes_used = 0,
        current_packet_codes_used = 0,
        current_carton_codes_used = 0,
        current_bundle_codes_used = 0,
        updated_at = NOW()
    WHERE status = 'active'
        AND EXTRACT(MONTH FROM start_date) != EXTRACT(MONTH FROM CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- MIGRATION SCRIPTS
-- ============================================

-- Migration 001: Initial Schema
-- This is the initial schema creation script
-- Run this first to create all tables, views, and functions

-- Migration 002: Add Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_base_codes_code_lower ON base_codes(LOWER(code));
CREATE INDEX IF NOT EXISTS idx_unit_codes_auth_lower ON unit_codes(LOWER(authentication_code));
CREATE INDEX IF NOT EXISTS idx_products_sku_lower ON products(LOWER(sku));

-- Migration 003: Add Partitioning for Large Tables
-- Note: Partitioning should be implemented based on actual usage patterns
-- Example for base_codes by month:
-- CREATE TABLE base_codes_2024_01 PARTITION OF base_codes
-- FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Migration 004: Add Full-Text Search
ALTER TABLE products ADD COLUMN IF NOT EXISTS search_vector tsvector;
CREATE INDEX IF NOT EXISTS idx_products_search ON products USING GIN(search_vector);

CREATE OR REPLACE FUNCTION products_search_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector =
        setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.sku, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_search_vector_update
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION products_search_update();

-- Migration 005: Add Audit Trail for Critical Operations
CREATE TABLE IF NOT EXISTS critical_operations_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operation_type VARCHAR(100) NOT NULL,
    performed_by UUID NOT NULL,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    details JSONB NOT NULL,
    ip_address INET,
    user_agent TEXT
);

-- ============================================
-- DATA INTEGRITY CHECKS
-- ============================================

-- Check for orphaned records
CREATE OR REPLACE FUNCTION check_data_integrity()
RETURNS TABLE (
    check_name VARCHAR(100),
    issue_count INTEGER,
    details TEXT
) AS $$
BEGIN
    -- Orphaned base_codes (no company)
    RETURN QUERY SELECT
        'Orphaned base_codes'::VARCHAR,
        COUNT(*)::INTEGER,
        'Base codes without valid company reference'::TEXT
    FROM base_codes bc
    LEFT JOIN companies c ON bc.company_id = c.id
    WHERE c.id IS NULL OR c.is_deleted = TRUE;

    -- Codes with invalid subscription plan
    RETURN QUERY SELECT
        'Invalid subscription plan references'::VARCHAR,
        COUNT(*)::INTEGER,
        'Base codes referencing non-existent subscription plans'::TEXT
    FROM base_codes bc
    LEFT JOIN subscription_plans sp ON bc.subscription_plan_id = sp.id
    WHERE sp.id IS NULL;

    -- Duplicate codes
    RETURN QUERY SELECT
        'Duplicate codes'::VARCHAR,
        COUNT(*)::INTEGER,
        'Multiple codes with same value'::TEXT
    FROM (
        SELECT code, COUNT(*) as cnt
        FROM base_codes
        WHERE is_deleted = FALSE
        GROUP BY code
        HAVING COUNT(*) > 1
    ) duplicates;

    -- Subscription usage exceeding limits
    RETURN QUERY SELECT
        'Subscription limits exceeded'::VARCHAR,
        COUNT(*)::INTEGER,
        'Companies exceeding their subscription limits'::TEXT
    FROM company_subscriptions cs
    JOIN subscription_plans sp ON cs.plan_id = sp.id
    WHERE cs.status = 'active'
        AND (
            cs.current_unit_codes_used > sp.monthly_unit_codes
            OR cs.current_packet_codes_used > sp.monthly_packet_codes
            OR cs.current_carton_codes_used > sp.monthly_carton_codes
            OR cs.current_bundle_codes_used > sp.monthly_bundle_codes
        );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- BACKUP AND RESTORE FUNCTIONS
-- ============================================

-- Function to create backup snapshot
CREATE OR REPLACE FUNCTION create_backup_snapshot(p_snapshot_name VARCHAR(255))
RETURNS UUID AS $$
DECLARE
    v_snapshot_id UUID;
BEGIN
    v_snapshot_id := uuid_generate_v4();

    -- Create backup of critical tables
    EXECUTE format('
        CREATE TABLE backup_%s_companies AS SELECT * FROM companies;
        CREATE TABLE backup_%s_base_codes AS SELECT * FROM base_codes;
        CREATE TABLE backup_%s_subscriptions AS SELECT * FROM company_subscriptions;
    ', p_snapshot_name, p_snapshot_name, p_snapshot_name);

    -- Record backup metadata
    INSERT INTO system_logs (log_level, logger_name, message, context)
    VALUES (
        'info',
        'backup',
        'Backup snapshot created',
        jsonb_build_object(
            'snapshot_id', v_snapshot_id,
            'snapshot_name', p_snapshot_name,
            'timestamp', NOW()
        )
    );

    RETURN v_snapshot_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SYSTEM HEALTH CHECKS
-- ============================================

-- View for system health monitoring
CREATE VIEW system_health_view AS
SELECT
    'database' as component,
    COUNT(*) as total_tables,
    SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))) as total_size_bytes
FROM pg_tables
WHERE schemaname = 'public'
UNION ALL
SELECT
    'companies' as component,
    COUNT(*) as total_companies,
    SUM(total_codes_generated) as total_codes_generated
FROM companies
WHERE is_deleted = FALSE
UNION ALL
SELECT
    'codes' as component,
    COUNT(*) as total_codes,
    COUNT(DISTINCT company_id) as companies_with_codes
FROM base_codes
WHERE is_deleted = FALSE;

-- ============================================
-- CLEANUP AND MAINTENANCE
-- ============================================

-- Function to archive old data
CREATE OR REPLACE FUNCTION archive_old_data(p_months_to_keep INTEGER DEFAULT 12)
RETURNS INTEGER AS $$
DECLARE
    v_archived_count INTEGER := 0;
BEGIN
    -- Archive old verification history
    WITH archived AS (
        DELETE FROM code_verification_history
        WHERE verified_at < NOW() - INTERVAL '1 month' * p_months_to_keep
        RETURNING *
    )
    SELECT COUNT(*) INTO v_archived_count FROM archived;

    -- Archive old system logs
    DELETE FROM system_logs
    WHERE logged_at < NOW() - INTERVAL '1 month' * p_months_to_keep
        AND log_level IN ('debug', 'info');

    -- Archive old audit logs
    DELETE FROM audit_logs
    WHERE performed_at < NOW() - INTERVAL '1 month' * p_months_to_keep;

    RETURN v_archived_count;
END;
$$ LANGUAGE plpgsql;

-- Function to vacuum and analyze tables
CREATE OR REPLACE FUNCTION perform_maintenance()
RETURNS VOID AS $$
BEGIN
    -- Analyze all tables for query planner
    ANALYZE;

    -- Vacuum tables that need it
    VACUUM ANALYZE base_codes;
    VACUUM ANALYZE code_verification_history;
    VACUUM ANALYZE audit_logs;
    VACUUM ANALYZE system_logs;

    -- Update statistics
    PERFORM update_plans_statistics();
END;
$$ LANGUAGE plpgsql;

-- Function to update plan statistics
CREATE OR REPLACE FUNCTION update_plans_statistics()
RETURNS VOID AS $$
BEGIN
    UPDATE subscription_plans sp
    SET company_count = (
        SELECT COUNT(*)
        FROM company_subscriptions cs
        WHERE cs.plan_id = sp.id
            AND cs.status = 'active'
    ),
    updated_at = NOW()
    WHERE status = 'active';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FINAL SETUP AND CONFIGURATION
-- ============================================

-- Set default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO nexa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO nexa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO nexa_admin;

-- Create application roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'nexa_app') THEN
        CREATE ROLE nexa_app WITH LOGIN PASSWORD 'secure_password_123';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'nexa_readonly') THEN
        CREATE ROLE nexa_readonly WITH LOGIN PASSWORD 'readonly_password_123';
    END IF;
END $$;

-- Grant permissions
GRANT CONNECT ON DATABASE nexasystem_db TO nexa_app, nexa_readonly;
GRANT USAGE ON SCHEMA public TO nexa_app, nexa_readonly;

-- Full access for application role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO nexa_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO nexa_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO nexa_app;

-- Read-only access for reporting role
GRANT SELECT ON ALL TABLES IN SCHEMA public TO nexa_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO nexa_readonly;

-- Grant access to views
GRANT SELECT ON company_dashboard_view TO nexa_app, nexa_readonly;
GRANT SELECT ON code_statistics_view TO nexa_app, nexa_readonly;
GRANT SELECT ON system_health_view TO nexa_app, nexa_readonly;

-- ============================================
-- DATABASE CONFIGURATION
-- ============================================

-- Set timezone
SET TIME ZONE 'UTC';

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

-- ============================================
-- FINAL NOTES
-- ============================================

/*
DATABASE SCHEMA DEPLOYMENT INSTRUCTIONS:

1. Create database:
   CREATE DATABASE nexasystem_db;

2. Connect to database:
   \c nexasystem_db

3. Run this schema file:
   \i /path/to/schema.sql

4. Verify deployment:
   SELECT * FROM system_health_view;

5. Create initial admin user (run separately):
   INSERT INTO factory_users (company_id, email, full_name, position, password_hash, password_salt)
   VALUES (
       'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Sample company ID
       'superadmin@nexatrace.com',
       'Super Admin',
       'admin',
       -- Hash for password: Admin123!
       '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u8i7o6p5q4w3e2r1t0y9u8i7o6p5q4w3e2r1',
       '$2a$12$K9q8q7v6s5d4f3e2r1t0y9u'
   );

SECURITY NOTES:
1. Change default passwords for database roles
2. Enable SSL for database connections
3. Configure firewall rules
4. Regular backups
5. Monitor audit logs

PERFORMANCE TIPS:
1. Consider partitioning large tables (base_codes, audit_logs)
2. Implement connection pooling
3. Regular vacuum and analyze
4. Monitor query performance with pg_stat_statements

MAINTENANCE SCHEDULE:
- Daily: Check system health
- Weekly: Perform maintenance vacuum
- Monthly: Archive old data
- Quarterly: Review and update indexes
*/
