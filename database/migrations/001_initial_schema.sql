-- NexaTrace System - Initial Database Migration
-- Migration ID: 001_initial_schema
-- Created: 2024-01-01
-- Description: Creates initial database schema for NexaTrace System

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
    verified_by UUID,

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
    deleted_at TIMESTAMP WITH TIME ZONE
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
    verified_by UUID,

    -- Metadata
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscription Plans
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'basic',
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
    status VARCHAR(20) DEFAULT 'active',
    company_count INTEGER DEFAULT 0,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE
);

-- Company Subscriptions
CREATE TABLE company_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    -- Subscription Details
    billing_cycle VARCHAR(20) NOT NULL DEFAULT 'monthly',
    start_date DATE NOT NULL,
    end_date DATE,
    renewal_date DATE,
    auto_renew BOOLEAN DEFAULT TRUE,

    -- Payment Information
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending',
    last_payment_date DATE,
    next_payment_date DATE,

    -- Usage Tracking (Current Period)
    current_unit_codes_used INTEGER DEFAULT 0,
    current_packet_codes_used INTEGER DEFAULT 0,
    current_carton_codes_used INTEGER DEFAULT 0,
    current_bundle_codes_used INTEGER DEFAULT 0,

    -- Status
    status VARCHAR(20) DEFAULT 'active',
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_company_subscriptions_active_unique
    ON company_subscriptions(company_id, plan_id)
    WHERE status = 'active';

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
    status VARCHAR(20) DEFAULT 'pending',
    payment_date DATE,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),

    -- Metadata
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
    position VARCHAR(100) NOT NULL,

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
    UNIQUE(company_id, email)
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
    product_type VARCHAR(50) NOT NULL DEFAULT 'other',
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Base Codes Table (Common fields for all code types)
CREATE TABLE base_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    subscription_plan_id UUID NOT NULL REFERENCES subscription_plans(id),

    -- Code Information
    code VARCHAR(100) UNIQUE NOT NULL,
    code_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'generated',

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bundle Codes (Extends base_codes)
CREATE TABLE bundle_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Bundle Specific Fields
    cartons_per_bundle INTEGER NOT NULL,
    bundle_weight_kg DECIMAL(10,2),
    bundle_dimensions VARCHAR(100),

    -- Shipping Information
    storage_location VARCHAR(255),
    shipping_method VARCHAR(100),
    expected_delivery_date DATE,

    -- Additional Information
    category VARCHAR(100),
    handling_instructions TEXT,
    customs_declaration_number VARCHAR(100),
    insurance_value DECIMAL(10,2),
    priority INTEGER DEFAULT 2
);

-- Carton Codes (Extends base_codes)
CREATE TABLE carton_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Hierarchy
    bundle_code_id UUID REFERENCES bundle_codes(id) ON DELETE CASCADE,

    -- Carton Specific Fields
    packet_count INTEGER NOT NULL,
    packet_codes UUID[] DEFAULT '{}',
    sequence_number INTEGER NOT NULL,
    total_units INTEGER NOT NULL,

    -- Physical Properties
    weight_kg DECIMAL(10,2),
    dimensions VARCHAR(100),
    carton_type VARCHAR(50),
    grade VARCHAR(20),
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
    condition VARCHAR(50) DEFAULT 'New',
    last_inspection_date DATE,
    inspection_notes TEXT
);

-- Packet Codes (Extends base_codes)
CREATE TABLE packet_codes (
    id UUID PRIMARY KEY REFERENCES base_codes(id) ON DELETE CASCADE,

    -- Hierarchy
    carton_code_id UUID REFERENCES carton_codes(id) ON DELETE CASCADE,

    -- Packet Specific Fields
    unit_count INTEGER NOT NULL,
    unit_codes UUID[] DEFAULT '{}',
    sequence_number INTEGER NOT NULL,

    -- Physical Properties
    weight_grams DECIMAL(10,2),
    dimensions VARCHAR(100),
    packet_type VARCHAR(50),
    material VARCHAR(50),

    -- Sealing Information
    is_sealed BOOLEAN DEFAULT FALSE,
    sealed_at TIMESTAMP WITH TIME ZONE,
    sealed_by UUID REFERENCES factory_users(id),
    sealing_method VARCHAR(50),

    -- Additional Codes
    packet_barcode VARCHAR(255),
    packet_qr_code VARCHAR(255),

    -- Safety Features
    condition VARCHAR(50) DEFAULT 'Intact',
    has_tamper_evidence BOOLEAN DEFAULT FALSE,
    has_child_safety BOOLEAN DEFAULT FALSE,
    has_instructions BOOLEAN DEFAULT FALSE,

    -- Identification
    packet_batch_number VARCHAR(100),
    serial_number VARCHAR(100)
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
    verified_by UUID,

    -- Fake Reporting
    is_reported_fake BOOLEAN DEFAULT FALSE,
    fake_reported_at TIMESTAMP WITH TIME ZONE,
    fake_reported_by UUID,
    fake_report_reason TEXT,

    -- Blocking
    is_blocked BOOLEAN DEFAULT FALSE,
    blocked_at TIMESTAMP WITH TIME ZONE,
    blocked_by UUID REFERENCES factory_users(id),
    block_reason TEXT,

    -- Identification
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    model VARCHAR(100)
);

-- Code Verification History
CREATE TABLE code_verification_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_code_id UUID NOT NULL REFERENCES unit_codes(id) ON DELETE CASCADE,

    -- Verification Details
    verification_type VARCHAR(50) NOT NULL,
    verification_method VARCHAR(50),
    verification_result VARCHAR(50) NOT NULL,

    -- Location & Device
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_address TEXT,
    device_id VARCHAR(255),
    device_type VARCHAR(50),

    -- User Information
    user_id UUID,
    user_type VARCHAR(50),

    -- Timestamps
    verified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Additional Data
    notes TEXT,
    metadata JSONB DEFAULT '{}'
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- AUDIT & LOGGING TABLES
-- ============================================

-- Audit Logs (Track all important actions)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Action Details
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,

    -- User Information
    user_id UUID,
    user_type VARCHAR(50),
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
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- System Logs (For debugging and monitoring)
CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Log Details
    log_level VARCHAR(20) NOT NULL,
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
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- CREATE INDEXES
-- ============================================

-- Companies indexes
CREATE INDEX idx_companies_status ON companies(status);
CREATE INDEX idx_companies_verification_status ON companies(verification_status);
CREATE INDEX idx_companies_country ON companies(country);
CREATE INDEX idx_companies_created_at ON companies(created_at DESC);

-- Company documents indexes
CREATE INDEX idx_company_documents_company ON company_documents(company_id);
CREATE INDEX idx_company_documents_type ON company_documents(document_type);
CREATE INDEX idx_company_documents_status ON company_documents(verification_status);

-- Subscription plans indexes
CREATE INDEX idx_subscription_plans_type ON subscription_plans(type);
CREATE INDEX idx_subscription_plans_status ON subscription_plans(status);
CREATE INDEX idx_subscription_plans_price ON subscription_plans(monthly_price);

-- Company subscriptions indexes
CREATE INDEX idx_company_subscriptions_company ON company_subscriptions(company_id);
CREATE INDEX idx_company_subscriptions_plan ON company_subscriptions(plan_id);
CREATE INDEX idx_company_subscriptions_status ON company_subscriptions(status);
CREATE INDEX idx_company_subscriptions_dates ON company_subscriptions(start_date, end_date);

-- Invoices indexes
CREATE INDEX idx_invoices_company ON invoices(company_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_issue_date ON invoices(issue_date DESC);
