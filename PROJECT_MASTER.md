# NexaTrace System - Project Master Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack & Architecture](#technology-stack--architecture)
3. [Forbidden Technologies](#forbidden-technologies)
4. [Subscription Plans System](#subscription-plans-system)
5. [Core Features](#core-features)
6. [New Features to Implement](#new-features-to-implement)
7. [Database Schema](#database-schema)
8. [API Communication Standards](#api-communication-standards)
9. [State Management](#state-management)
10. [Deployment Guide](#deployment-guide)
11. [Coding Standards](#coding-standards)
12. [Project Structure](#project-structure)
13. [Development Workflow](#development-workflow)
14. [Testing Strategy](#testing-strategy)
15. [Security Considerations](#security-considerations)
16. [Support & Maintenance](#support--maintenance)

---

## 🎯 Project Overview

**NexaTrace** is a cloud-based SaaS platform for product tracking, authentication, and supply chain management. It provides a comprehensive solution for manufacturers, distributors, and retailers to track products through the entire supply chain with secure authentication codes.

### Business Purpose
- **Product Authentication**: Generate and verify unique codes for product authenticity
- **Supply Chain Tracking**: Monitor product movement from factory to consumer
- **Multi-Tenant SaaS**: Serve multiple factories/companies with data isolation
- **Subscription-Based**: Tiered pricing plans based on usage and features

### Target Users
1. **Factories/Manufacturers**: Generate authentication codes, track production
2. **Distributors/Wholesalers**: Track inventory movement, verify authenticity
3. **Retailers/Shops**: Scan and verify products, manage inventory
4. **End Consumers**: Verify product authenticity via mobile app
5. **Super Administrators**: Manage platform, companies, and subscriptions

### Core Value Proposition
- **Anti-Counterfeiting**: Secure QR-based authentication system
- **Supply Chain Visibility**: Real-time tracking of product movement
- **Multi-Tenant Architecture**: Secure data isolation between companies
- **Scalable Infrastructure**: Handles millions of codes and scans

---

## 🏗️ Technology Stack & Architecture

### Frontend (Flutter/Dart)
- **Framework**: Flutter 3.0+ with Dart 3.0+
- **State Management**: Flutter BLoC (Business Logic Component) pattern
- **Navigation**: GoRouter for declarative routing
- **UI Components**: Material Design with custom theming
- **Local Storage**: Hive for NoSQL, SharedPreferences for key-value
- **Networking**: Dio with interceptors and logging
- **Code Generation**: Freezed for immutable data classes

### Backend (Laravel/PHP)
- **Framework**: Laravel 10+ with PHP 8.1+
- **API**: RESTful JSON API with JWT authentication
- **Database**: PostgreSQL 13+ with UUID extension
- **Caching**: Redis for session and data caching
- **Queue**: Redis-based job queue for async processing
- **File Storage**: Local/S3 for document storage
- **Port**: 8090 (internal), proxied via Nginx on port 80

### Production Server Configuration
- **Server Provider**: Hetzner (Helsinki, Finland - hel1)
- **Server Name**: ubuntu-16gb-hel1-2
- **IPv4**: 135.181.46.27/32
- **IPv6**: 2a01:4f9:c014:2997::/64
- **Web Server**: Nginx (port 80)
- **API Server**: Laravel artisan serve (internal port 8090)
- **Flutter Web Path**: /var/www/nexatrace/admin-web/build/web
- **Laravel Path**: /var/www/nexatrace/admin-panel
- **CORS**: Configured with allowed_origins => ['*']

### Database (PostgreSQL)
- **Version**: PostgreSQL 13+
- **Port**: 5444 (development)
- **Extensions**: UUID-OSSP, pgcrypto, pg_stat_statements
- **Architecture**: Multi-tenant with schema/row-level isolation
- **Connection Pooling**: PgBouncer for production

### Performance Module (Rust)
- **Language**: Rust 1.70+
- **Purpose**: High-performance code generation and validation
- **Integration**: FFI (Foreign Function Interface) with Flutter
- **Features**: Cryptographic operations, batch processing, checksums

### Development Tools
- **Version Control**: Git with conventional commits
- **CI/CD**: GitHub Actions/GitLab CI
- **Containerization**: Docker for development and deployment
- **Monitoring**: Prometheus + Grafana for metrics
- **Logging**: Structured logging with ELK stack

---

## 🚫 Forbidden Technologies

### **DO NOT USE** these dependency injection/state management solutions:
1. **GetIt** - Removed and replaced with Flutter providers
2. **Riverpod** - Not compatible with our BLoC architecture
3. **Provider** (as DI) - Use only for widget tree providers, not dependency injection

### **REQUIRED** State Management:
- **Flutter BLoC** - Primary state management pattern
- **Repository Pattern** - Data access abstraction
- **Provider** - For widget tree dependency injection only
- **Freezed** - For immutable data classes and union types

### **DO NOT USE** these database solutions:
1. **SQLite** for production data (use PostgreSQL)
2. **Firebase/Firestore** as primary database
3. **MongoDB** (not compatible with relational data model)

### **REQUIRED** Database:
- **PostgreSQL 13+** - Primary relational database
- **Redis** - Caching and session storage
- **Hive** - Local NoSQL storage for Flutter

---

## 📊 Subscription Plans System

### Existing Subscription Plans

#### 1. **Free Plan** ($0/month)
- **Code Limits**: 5,000 unit codes per month
- **Stores**: 1 store location
- **Drivers**: 1 driver account
- **Transport Features**: ❌ No transport access
- **Features**:
  - Basic QR code scanning
  - Email support
  - Standard reports
  - Mobile app access

#### 2. **Basic Plan** ($49/month)
- **Code Limits**: 50,000 unit codes per month
- **Stores**: 5 store locations
- **Drivers**: 3 driver accounts
- **Transport Features**: Limited transport access
  - 10 transport connections per month
  - Can contact drivers directly
  - 5 loads posting per month
- **Features** (includes Free +):
  - Batch code generation
  - API access (limited)
  - Priority email support
  - Custom branding
  - Basic transport marketplace access

#### 3. **Standard Plan** ($149/month)
- **Code Limits**: 200,000 unit codes per month
- **Stores**: 20 store locations
- **Drivers**: Unlimited drivers
- **Transport Features**: Full transport access
  - 50 transport connections per month
  - Can contact drivers and owners directly
  - Can use goods companies
  - 20 loads posting per month
  - Live truck tracking
- **Features** (includes Basic +):
  - GPS attendance tracking
  - Salary management
  - Advanced analytics
  - Zoho Books integration
  - Phone support
  - Full transport marketplace access

#### 4. **Premium Plan** ($499/month)
- **Code Limits**: 1,000,000 unit codes per month
- **Stores**: Unlimited stores
- **Drivers**: Unlimited drivers
- **Transport Features**: Premium transport access
  - Unlimited transport connections
  - Can contact all transport users directly
  - Priority access to goods companies
  - Unlimited loads posting
  - Advanced route optimization
  - Escrow payment system
- **Features** (includes Standard +):
  - Multi-company control
  - Custom workflows
  - Dedicated account manager
  - SLA guarantee
  - 24/7 support
  - Premium transport features

#### 5. **Custom Plan** (Negotiated)
- **Code Limits**: Custom based on needs
- **Stores**: Unlimited
- **Drivers**: Unlimited
- **Transport Features**: Enterprise transport access
  - All Premium transport features
  - Custom commission structures
  - White-label transport app
  - Dedicated transport support
  - API integration with existing systems
- **Features**:
  - All Premium features
  - SAP integration
  - Dedicated infrastructure
  - Custom development
  - White-label solution
  - Enterprise transport ecosystem

### Goods Company Subscription Plans (Separate)

#### 1. **Basic Goods Company Plan** ($29/month)
- **Truck Connections**: 20 trucks
- **Factory Connections**: 10 factories
- **Monthly Trips**: 50 trips
- **Commission Range**: 5-15%
- **Features**:
  - Live tracking enabled
  - Basic bidding system
  - Email support
  - 1,000 API calls per day

#### 2. **Professional Goods Company Plan** ($79/month)
- **Truck Connections**: 50 trucks
- **Factory Connections**: 25 factories
- **Monthly Trips**: 150 trips
- **Commission Range**: 5-20%
- **Features** (includes Basic +):
  - Auto-commission calculation
  - Auto-bidding system
  - WhatsApp integration
  - Chat support
  - 5,000 API calls per day

#### 3. **Enterprise Goods Company Plan** ($199/month)
- **Truck Connections**: Unlimited trucks
- **Factory Connections**: Unlimited factories
- **Monthly Trips**: Unlimited trips
- **Commission Range**: 5-25%
- **Features** (includes Professional +):
  - Escrow payment system
  - White-label enabled
  - Dedicated phone support
  - 20,000 API calls per day
  - Custom branding

### Plan Features Matrix

| Feature | Free | Basic | Standard | Premium | Custom |
|---------|------|-------|----------|---------|---------|
| QR Code Scanning | ✅ | ✅ | ✅ | ✅ | ✅ |
| Email Support | ✅ | ✅ | ✅ | ✅ | ✅ |
| API Access | ❌ | Limited | Full | Full | Full |
| GPS Tracking | ❌ | ❌ | ✅ | ✅ | ✅ |
| Salary Management | ❌ | ❌ | ✅ | ✅ | ✅ |
| Zoho Integration | ❌ | ❌ | ✅ | ✅ | ✅ |
| Multi-Company | ❌ | ❌ | ❌ | ✅ | ✅ |
| SAP Integration | ❌ | ❌ | ❌ | ❌ | ✅ |
| Dedicated Support | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Transport Features** | | | | | |
| Transport Connections | ❌ | 10/month | 50/month | Unlimited | Unlimited |
| Contact Drivers | ❌ | ✅ | ✅ | ✅ | ✅ |
| Contact Owners | ❌ | ❌ | ✅ | ✅ | ✅ |
| Use Goods Companies | ❌ | ❌ | ✅ | ✅ | ✅ |
| Load Posting | ❌ | 5/month | 20/month | Unlimited | Unlimited |
| Live Truck Tracking | ❌ | ❌ | ✅ | ✅ | ✅ |
| Route Optimization | ❌ | ❌ | ❌ | ✅ | ✅ |
| Escrow Payments | ❌ | ❌ | ❌ | ✅ | ✅ |

### Goods Company Plan Matrix

| Feature | Basic ($29) | Professional ($79) | Enterprise ($199) |
|---------|-------------|-------------------|-------------------|
| Truck Connections | 20 | 50 | Unlimited |
| Factory Connections | 10 | 25 | Unlimited |
| Monthly Trips | 50 | 150 | Unlimited |
| Commission Range | 5-15% | 5-20% | 5-25% |
| Live Tracking | ✅ | ✅ | ✅ |
| Bidding System | Basic | Advanced | Advanced |
| Auto-Commission | ❌ | ✅ | ✅ |
| Auto-Bidding | ❌ | ✅ | ✅ |
| WhatsApp Integration | ❌ | ✅ | ✅ |
| Escrow Payments | ❌ | ❌ | ✅ |
| White-label | ❌ | ❌ | ✅ |
| API Calls/Day | 1,000 | 5,000 | 20,000 |
| Support | Email | Chat | Phone |

---

## Super Admin Billing & Invoice System

### Platform Revenue Model

The NexaTrace platform generates revenue through a hybrid billing model combining fixed subscription fees with variable usage-based charges.

**Fixed Monthly Subscription + Per-Code Overage Pricing:**

| Plan | Monthly Fee | Included Unit Codes/Month | Overage Rate (per unit code) |
|------|------------|--------------------------|----------------------------|
| Free | $0 | 5,000 | N/A (hard limit) |
| Basic | $49 | 50,000 | $0.002 |
| Standard | $149 | 200,000 | $0.0015 |
| Premium | $499 | 1,000,000 | $0.001 |
| Custom | Negotiated | Negotiated | Negotiated |

**Code Type Multipliers (relative to unit code rate):**

| Code Type | Multiplier | Example (Basic Overage) |
|-----------|-----------|------------------------|
| Unit Code | 1x | $0.002 per code |
| Packet Code | 3x | $0.006 per code |
| Carton Code | 5x | $0.010 per code |
| Bundle Code | 10x | $0.020 per code |

**Additional Revenue Streams:**
- Transport Connection Fees: ₹10 per new contact connection (wallet-based)
- Commission on Transport Trips: 3-7% per completed trip (tier-based)
- Factory Pay-per-Publish: Charged at tier rate when Factory publishes code batches (3AF)

### Invoice Database Schema

```sql
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('subscription', 'usage', 'commission', 'manual')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_rate DECIMAL(5,4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'paid', 'overdue', 'cancelled', 'refunded')),
    due_date DATE NOT NULL,
    paid_at TIMESTAMP NULL,
    payment_method VARCHAR(50) NULL,
    payment_reference VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(255) NOT NULL,
    item_type VARCHAR(30) NOT NULL CHECK (item_type IN ('subscription_fee', 'unit_codes', 'bundle_codes', 'carton_codes', 'packet_codes', 'connection_fee', 'commission', 'overage')),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,4) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    metadata JSONB NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE credit_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id),
    amount DECIMAL(12,2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'applied')),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Super Admin Billing Screens

1. **Platform Revenue Dashboard** - MRR/ARR overview, revenue by plan tier/region/company, trend charts
2. **Company Invoices List** - All invoices, filter by status (paid/pending/overdue), search, bulk export
3. **Invoice Detail** - Full invoice with line items, payment history, PDF download, resend
4. **Invoice Generator** - Create manual invoices, add line items, preview, generate PDF
5. **Payment Reconciliation** - Match gateway records with internal records, flag discrepancies
6. **Refund Management** - Process refund requests, approval workflow, partial refunds
7. **Financial Reports** - P&L statements, revenue forecasts, tax summaries, CSV/PDF export
8. **Credit Limit Management** - Set/adjust credit limits per company, view utilization

### Super Admin Billing Folder Structure

```
lib/features/nexa_admin/
├── data/
│   ├── datasources/billing_datasource.dart
│   ├── models/
│   │   ├── invoice_model.dart
│   │   ├── invoice_item_model.dart
│   │   ├── credit_note_model.dart
│   │   ├── payment_reconciliation_model.dart
│   │   └── revenue_report_model.dart
│   └── repositories/billing_repository.dart
├── domain/
│   ├── entities/billing_entity.dart
│   └── usecases/
│       ├── generate_invoice_usecase.dart
│       ├── process_payment_usecase.dart
│       └── reconcile_payments_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── billing/
    │   │   ├── billing_bloc.dart
    │   │   ├── billing_event.dart
    │   │   └── billing_state.dart
    │   └── invoices/
    │       ├── invoice_bloc.dart
    │       ├── invoice_event.dart
    │       └── invoice_state.dart
    ├── screens/super_admin/billing/
    │   ├── platform_revenue_dashboard.dart
    │   ├── company_invoices_screen.dart
    │   ├── invoice_detail_screen.dart
    │   ├── invoice_generator_screen.dart
    │   ├── payment_reconciliation_screen.dart
    │   ├── refund_management_screen.dart
    │   ├── financial_reports_screen.dart
    │   └── credit_limit_management_screen.dart
    └── widgets/billing/
        ├── revenue_chart_widget.dart
        ├── invoice_status_badge.dart
        ├── payment_timeline_widget.dart
        └── dunning_alert_widget.dart
```

### Billing API Endpoints

```
POST   /api/v1/admin/invoices                  - Create invoice
GET    /api/v1/admin/invoices                  - List invoices (with filters)
GET    /api/v1/admin/invoices/{id}             - Get invoice detail
PUT    /api/v1/admin/invoices/{id}             - Update invoice
POST   /api/v1/admin/invoices/{id}/send        - Send invoice to company
POST   /api/v1/admin/invoices/{id}/mark-paid   - Mark as paid
GET    /api/v1/admin/invoices/{id}/pdf         - Download invoice PDF
POST   /api/v1/admin/credit-notes              - Create credit note
GET    /api/v1/admin/revenue/dashboard         - Revenue dashboard data
GET    /api/v1/admin/revenue/reports            - Financial reports
GET    /api/v1/admin/reconciliation            - Payment reconciliation
POST   /api/v1/admin/refunds                   - Process refund
GET    /api/v1/companies/{id}/credit-limit     - Get credit limit
PUT    /api/v1/companies/{id}/credit-limit     - Update credit limit
```

---

## 🎯 Core Features

### 1. **Code Hierarchy System**
- **Bundle**: Highest level (contains cartons)
- **Carton**: Contains packets
- **Packet**: Contains units
- **Unit**: Individual product authentication code

### 2. **Product Management**
- Product catalog with categories (Food, Medical, Other)
- Batch management with expiry dates
- Product specifications and documentation
- Image gallery for products

### 3. **Authentication & Verification**
- QR code generation with unique identifiers
- Mobile scanning via Flutter app
- Web-based verification portal
- Fake/counterfeit reporting system
- Audit trail for all scans

### 4. **Supply Chain Tracking**
- Product movement tracking
- Inventory management across locations
- Stock transfer between stores
- Real-time inventory updates

### 5. **Transport Ecosystem** 🚚 **NEW**
- **Goods Companies**: Professional transport services with monthly subscriptions
- **Truck Owners**: Fleet management and bidding system
- **Truck Drivers**: Trip management and earnings tracking
- **Wallet System**: Pre-paid wallet with connection fees (₹10 per contact)
- **Fraud Prevention**: Secure in-app chat with phone number blocking
- **Commission Structure**: 3-7% commission on successful trips
- **Google Maps Integration**: Live tracking and route optimization
- **Bidding System**: Load posting and competitive bidding

#### 5A. **Factory Billing & Payment System** ✅ **IMPLEMENTED**

The Factory Billing system is fully implemented and operational:

| Feature ID | Feature | Status | Description |
|------------|---------|--------|-------------|
| **3AE** | Factory Billing Dashboard | ✅ Implemented | Owed balance display, outstanding invoices, payment due dates, credit limit status, payment method on file |
| **3AF** | Pay-per-Publish Billing | ✅ Implemented | Auto-generates invoice on publish for Unit/Packet/Carton/Bundle codes with tier-based rates |
| **3AG** | Download Lock | ✅ Implemented | Codes CSV/PDF download blocked until publish invoice is paid; locked download icon with outstanding amount |
| **3AH** | Payment History Ledger | ✅ Implemented | Complete payment history with invoice PDF download, transaction records, and receipt generation |

**Factory Billing Dashboard Features:**
- Current owed balance to NexaTrace (Super Admin)
- Outstanding invoices with payment due dates
- Credit limit status and warnings
- Payment method management
- Quick payment actions

**Pay-per-Publish Workflow:**
1. Factory Admin generates codes (Bundle/Carton/Packet/Unit)
2. On clicking "Publish", system calculates cost based on subscription tier
3. Invoice auto-created with tier-based rate
4. Download locked until payment is processed
5. Payment can be made via wallet, card, or bank transfer
6. Download unlocked automatically after successful payment

**Factory Billing Folder Structure (Implemented):**
```
lib/features/factory/
├── billing/
│   ├── data/
│   │   ├── models/
│   │   │   ├── factory_invoice_model.dart
│   │   │   ├── payment_model.dart
│   │   │   └── billing_summary_model.dart
│   │   └── repositories/
│   │       └── factory_billing_repository.dart
│   ├── domain/
│   │   └── usecases/
│   │       ├── get_billing_summary_usecase.dart
│   │       ├── pay_invoice_usecase.dart
│   │       └── download_invoice_pdf_usecase.dart
│   └── presentation/
│       ├── bloc/
│       │   └── factory_billing_bloc.dart
│       ├── screens/
│       │   ├── billing_dashboard_screen.dart
│       │   ├── invoice_list_screen.dart
│       │   ├── invoice_detail_screen.dart
│       │   ├── payment_history_screen.dart
│       │   └── payment_method_screen.dart
│       └── widgets/
│           ├── owed_balance_card.dart
│           ├── invoice_card.dart
│           ├── payment_status_badge.dart
│           └── download_lock_overlay.dart
```

### 6. **Super Admin Panel**
- Company/factory management
- Subscription plan management
- Billing and invoicing
- Usage monitoring and analytics
- System configuration
- Transport ecosystem management

#### 6A. **Super Admin Billing & Invoicing** 💰 **COMPREHENSIVE**

##### A. Platform Revenue Model

The NexaTrace platform generates revenue through multiple streams:

**1. Fixed Monthly Subscription**
| Plan | Monthly Fee | Code Quota | Transport Features |
|------|------------|------------|-------------------|
| Free | $0 | 5,000 units | ❌ None |
| Basic | $49 | 50,000 units | Limited (10 connections/month) |
| Standard | $149 | 200,000 units | Full (50 connections/month) |
| Premium | $499 | 1,000,000 units | Unlimited |
| Custom | Negotiated | Custom | Enterprise |

**2. Per-Code Publish Rate (Variable Charges)**
| Plan | Included Quota | Overage Rate |
|------|---------------|--------------|
| Free | No publishing allowed | N/A |
| Basic | 50,000 unit codes/month | $0.002 per additional unit code |
| Standard | 200,000 unit codes/month | $0.0015 per additional unit code |
| Premium | 1,000,000 unit codes/month | $0.001 per additional unit code |
| Custom | Negotiated | Negotiated |

**Code Type Multipliers (relative to unit code rate):**
| Code Type | Multiplier | Example (Basic Plan Overage) |
|-----------|-----------|---------------------------|
| Unit Code | 1x | $0.002 per code |
| Packet Code | 3x | $0.006 per code |
| Carton Code | 5x | $0.010 per code |
| Bundle Code | 10x | $0.020 per code |

**3. Transport Connection Fees**
- ₹10 per new contact connection (wallet-based)
- Deducted when users initiate contact through the platform

**4. Commission on Transport Trips**
- 3-7% per completed trip (tier-based)
- Basic Plan: 7% commission
- Standard Plan: 5% commission
- Premium Plan: 3% commission

##### B. Super Admin Billing Dashboard Features

| Feature | Description |
|---------|-------------|
| **Platform Revenue Overview** | MRR, ARR, churn rate, growth trends |
| **Revenue Breakdown** | By plan tier, region, company, revenue type (subscription vs usage vs commission) |
| **Invoice Management** | List all company invoices, filter by status (paid/pending/overdue), search, export |
| **Invoice Generator** | Create manual invoices, preview, PDF generation, email delivery |
| **Payment Reconciliation** | Match payment gateway records with internal records, flag discrepancies |
| **Refund Management** | Process refund requests, approval workflow, partial refunds |
| **Financial Reports** | P&L statements, revenue forecasts, tax summaries |
| **Dunning Management** | Automated payment retry logic, escalation emails for failed payments |
| **Credit Limit Management** | Set/adjust credit limits per company |

##### C. Invoice Database Schema

```sql
-- =====================================================
-- SUPER ADMIN BILLING TABLES
-- =====================================================

-- 1. INVOICES TABLE
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE, -- Auto-generated: INV-2026-0001
    type VARCHAR(50) NOT NULL, -- subscription | usage | commission | manual
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_rate DECIMAL(5,4) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(50) NOT NULL DEFAULT 'draft', -- draft | pending | paid | overdue | cancelled | refunded
    due_date DATE NOT NULL,
    paid_at TIMESTAMP,
    payment_method VARCHAR(50), -- card | bank_transfer | wallet | other
    payment_reference VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT chk_invoice_total CHECK (total_amount >= 0),
    CONSTRAINT chk_invoice_dates CHECK (period_end >= period_start)
);

CREATE INDEX idx_invoices_company ON invoices(company_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_period ON invoices(period_start, period_end);

-- 2. INVOICE ITEMS TABLE
CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(500) NOT NULL,
    item_type VARCHAR(50) NOT NULL, -- subscription_fee | unit_codes | bundle_codes | carton_codes | packet_codes | connection_fee | commission | overage
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,4) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    metadata JSONB, -- For storing code batch IDs, trip IDs, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_total CHECK (total_price >= 0)
);

CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_type ON invoice_items(item_type);

-- 3. CREDIT NOTES TABLE
CREATE TABLE credit_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending | approved | applied
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT chk_credit_amount CHECK (amount > 0)
);

CREATE INDEX idx_credit_notes_company ON credit_notes(company_id);
CREATE INDEX idx_credit_notes_status ON credit_notes(status);

-- 4. PAYMENT RECONCILIATION TABLE
CREATE TABLE payment_reconciliations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    gateway_transaction_id VARCHAR(255),
    gateway_name VARCHAR(50), -- stripe | paypal | razorpay | bank
    expected_amount DECIMAL(12,2) NOT NULL,
    received_amount DECIMAL(12,2),
    discrepancy_amount DECIMAL(12,2),
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending | matched | discrepancy | resolved
    notes TEXT,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reconciliations_invoice ON payment_reconciliations(invoice_id);
CREATE INDEX idx_reconciliations_status ON payment_reconciliations(status);
```

##### D. Super Admin Billing Folder Structure

```
lib/features/nexa_admin/
├── data/
│   ├── datasources/
│   │   └── billing_datasource.dart
│   ├── models/
│   │   ├── invoice_model.dart
│   │   ├── invoice_item_model.dart
│   │   ├── credit_note_model.dart
│   │   ├── payment_reconciliation_model.dart
│   │   └── revenue_report_model.dart
│   └── repositories/
│       └── billing_repository.dart
├── domain/
│   ├── entities/
│   │   └── billing_entity.dart
│   └── usecases/
│       ├── generate_invoice_usecase.dart
│       ├── process_payment_usecase.dart
│       └── reconcile_payments_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── billing/
    │   │   ├── billing_bloc.dart
    │   │   ├── billing_event.dart
    │   │   └── billing_state.dart
    │   └── invoices/
    │       ├── invoice_bloc.dart
    │       ├── invoice_event.dart
    │       └── invoice_state.dart
    ├── screens/
    │   └── super_admin/
    │       └── billing/
    │           ├── platform_revenue_dashboard.dart
    │           ├── company_invoices_screen.dart
    │           ├── invoice_detail_screen.dart
    │           ├── invoice_generator_screen.dart
    │           ├── payment_reconciliation_screen.dart
    │           ├── refund_management_screen.dart
    │           ├── financial_reports_screen.dart
    │           └── credit_limit_management_screen.dart
    └── widgets/
        └── billing/
            ├── revenue_chart_widget.dart
            ├── invoice_status_badge.dart
            ├── payment_timeline_widget.dart
            └── dunning_alert_widget.dart
```

### 7. **Multi-Tenant Architecture**
- Complete data isolation between companies
- Custom branding per company
- Role-based access control
- Usage limits enforcement

### 8. **Reporting & Analytics**
- Code generation reports
- Scan activity reports
- Inventory movement reports
- Revenue and usage analytics
- Transport earnings and commission reports
- Custom report builder

---

## 🚀 New Features to Implement

### 1. **Transport Ecosystem Complete Implementation** 🚚 **ENHANCED**

#### Overview
Complete transport ecosystem with wallet system, fraud prevention, and multi-user type support for Pakistan market.

#### New User Types
1. **Goods Companies** (گڈز کمپنیاں): Professional transport services with monthly subscriptions
2. **Truck Owners** (ٹرک مالکان): Fleet owners with bidding system
3. **Truck Drivers** (ڈرائیور): Drivers with trip management
4. **Resellers/Shopkeepers** (موجودہ): Existing users with transport access

#### Key Features
- **Wallet System**: Pre-paid wallet mandatory for all users (₹100-500 minimum)
- **Connection Fee**: ₹10 deducted for ANY contact between users
- **Fraud Prevention**: Secure in-app chat with phone number blocking
- **Commission Structure**: 3-7% commission on successful trips
- **Google Maps Integration**: Live tracking and route optimization
- **Bidding System**: Load posting and competitive bidding
- **Secure Communication**: All communication must stay within app

#### Database Schema for Transport Ecosystem
```sql
-- =====================================================
-- WALLET SYSTEM TABLES
-- =====================================================

-- 1. WALLETS TABLE
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    user_type VARCHAR(50) NOT NULL, -- factory/goods_company/truck_owner/driver/reseller/shop/customer
    balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    minimum_balance DECIMAL(12,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_transaction_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_balance_non_negative CHECK (balance >= 0)
);

-- 2. WALLET TRANSACTIONS TABLE
CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL,
    from_user_id UUID NOT NULL,
    to_user_id UUID,
    amount DECIMAL(12,2) NOT NULL,
    type VARCHAR(50) NOT NULL, -- top_up/connection_fee/commission/penalty/reward/trip_payment/withdrawal
    status VARCHAR(50) NOT NULL, -- pending/completed/failed/cancelled
    reference_id UUID, -- trip_id or load_id or bid_id
    description TEXT,
    metadata JSONB, -- additional data
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    
    CONSTRAINT fk_transaction_wallet FOREIGN KEY (wallet_id) 
        REFERENCES wallets(id) ON DELETE CASCADE
);

-- =====================================================
-- TRANSPORT USER TABLES
-- =====================================================

-- 3. GOODS COMPANIES TABLE (extends users)
CREATE TABLE goods_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    company_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255),
    cnic VARCHAR(50) NOT NULL UNIQUE,
    address TEXT,
    plan_type VARCHAR(50) NOT NULL, -- basic/professional/enterprise
    subscription_status VARCHAR(50) DEFAULT 'active',
    commission_min DECIMAL(5,2) DEFAULT 5.0,
    commission_max DECIMAL(5,2) DEFAULT 15.0,
    auto_commission_enabled BOOLEAN DEFAULT false,
    live_tracking_enabled BOOLEAN DEFAULT true,
    bidding_enabled BOOLEAN DEFAULT true,
    auto_bidding_enabled BOOLEAN DEFAULT false,
    escrow_enabled BOOLEAN DEFAULT false,
    whatsapp_integration BOOLEAN DEFAULT false,
    white_label_enabled BOOLEAN DEFAULT false,
    api_calls_today INTEGER DEFAULT 0,
    api_calls_limit INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_goods_company_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- 4. TRUCK OWNERS TABLE (extends users)
CREATE TABLE truck_owners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    owner_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL UNIQUE,
    cnic VARCHAR(50) NOT NULL UNIQUE,
    address TEXT,
    total_trucks INTEGER DEFAULT 0,
    verification_status VARCHAR(50) DEFAULT 'pending', -- pending/verified/rejected
    rating DECIMAL(3,2) DEFAULT 0,
    total_trips INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_truck_owner_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- 5. TRUCKS TABLE (owned by owners or goods companies)
CREATE TABLE trucks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_number VARCHAR(100) NOT NULL UNIQUE,
    owner_id UUID, -- if owned by individual
    goods_company_id UUID, -- if owned by company
    driver_id UUID, -- current assigned driver
    truck_type VARCHAR(100), -- Mazda/Trailer/Container
    capacity_tons DECIMAL(10,2),
    length_feet INTEGER,
    status VARCHAR(50) DEFAULT 'available', -- available/busy/maintenance
    current_latitude DECIMAL(10,8),
    current_longitude DECIMAL(11,8),
    last_location_update TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_truck_owner FOREIGN KEY (owner_id) 
        REFERENCES truck_owners(id) ON DELETE SET NULL,
    CONSTRAINT fk_truck_company FOREIGN KEY (goods_company_id) 
        REFERENCES goods_companies(id) ON DELETE SET NULL,
    CONSTRAINT fk_truck_driver FOREIGN KEY (driver_id) 
        REFERENCES drivers(id) ON DELETE SET NULL,
    CONSTRAINT chk_truck_owner_xor_company CHECK (
        (owner_id IS NOT NULL AND goods_company_id IS NULL) OR
        (owner_id IS NULL AND goods_company_id IS NOT NULL)
    )
);

-- 6. DRIVERS TABLE (extends users)
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    driver_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL UNIQUE,
    cnic VARCHAR(50) NOT NULL UNIQUE,
    license_number VARCHAR(100),
    current_truck_id UUID,
    verification_status VARCHAR(50) DEFAULT 'pending',
    rating DECIMAL(3,2) DEFAULT 0,
    total_trips INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_driver_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_driver_truck FOREIGN KEY (current_truck_id) 
        REFERENCES trucks(id) ON DELETE SET NULL
);

-- =====================================================
-- TRANSPORT OPERATIONS TABLES
-- =====================================================

-- 7. LOADS TABLE (posted by factories or goods companies)
CREATE TABLE loads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    posted_by_id UUID NOT NULL,
    posted_by_type VARCHAR(50) NOT NULL, -- factory/goods_company
    origin_city VARCHAR(100) NOT NULL,
    origin_address TEXT,
    destination_city VARCHAR(100) NOT NULL,
    destination_address TEXT,
    cargo_type VARCHAR(100), -- general/food/medical/construction
    weight_tons DECIMAL(10,2),
    required_truck_type VARCHAR(100),
    expected_price DECIMAL(12,2),
    preferred_date DATE,
    status VARCHAR(50) DEFAULT 'open', -- open/bidding/assigned/completed/cancelled
    accepted_bid_id UUID,
    accepted_truck_id UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    
    CONSTRAINT fk_load_poster FOREIGN KEY (posted_by_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- 8. BIDS TABLE
CREATE TABLE bids (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    load_id UUID NOT NULL,
    bidder_id UUID NOT NULL,
    bidder_type VARCHAR(50) NOT NULL, -- goods_company/truck_owner/driver
    truck_id UUID NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    commission_percentage DECIMAL(5,2), -- if goods company is involved
    estimated_delivery_date DATE,
    status VARCHAR(50) DEFAULT 'pending', -- pending/accepted/rejected/cancelled
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_bid_load FOREIGN KEY (load_id) 
        REFERENCES loads(id) ON DELETE CASCADE,
    CONSTRAINT fk_bid_truck FOREIGN KEY (truck_id) 
        REFERENCES trucks(id) ON DELETE CASCADE
);

-- 9. TRIPS TABLE (after bid acceptance)
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    load_id UUID NOT NULL UNIQUE,
    bid_id UUID NOT NULL UNIQUE,
    truck_id UUID NOT NULL,
    driver_id UUID NOT NULL,
    assigned_by_id UUID, -- who assigned (factory/goods_company)
    assigned_by_type VARCHAR(50),
    total_amount DECIMAL(12,2) NOT NULL,
    nexa_commission DECIMAL(12,2) NOT NULL, -- NexaTrace's cut
    connection_fee DECIMAL(10,2) DEFAULT 10.0,
    status VARCHAR(50) DEFAULT 'assigned', -- assigned/started/in_transit/completed/cancelled
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    start_latitude DECIMAL(10,8),
    start_longitude DECIMAL(11,8),
    end_latitude DECIMAL(10,8),
    end_longitude DECIMAL(11,8),
    delivery_proof_url TEXT,
    customer_signature_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_trip_load FOREIGN KEY (load_id) 
        REFERENCES loads(id) ON DELETE CASCADE,
    CONSTRAINT fk_trip_bid FOREIGN KEY (bid_id) 
        REFERENCES bids(id) ON DELETE CASCADE,
    CONSTRAINT fk_trip_truck FOREIGN KEY (truck_id) 
        REFERENCES trucks(id) ON DELETE CASCADE,
    CONSTRAINT fk_trip_driver FOREIGN KEY (driver_id) 
        REFERENCES drivers(id) ON DELETE CASCADE
);

-- 10. TRIP_LOCATIONS TABLE (GPS tracking)
CREATE TABLE trip_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    speed DECIMAL(10,2),
    heading DECIMAL(10,2),
    timestamp TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT fk_location_trip FOREIGN KEY (trip_id) 
        REFERENCES trips(id) ON DELETE CASCADE
);

-- 11. FRAUD_REPORTS TABLE
CREATE TABLE fraud_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL,
    reported_user_id UUID NOT NULL,
    trip_id UUID,
    reason TEXT NOT NULL,
    evidence JSONB, -- screenshots, messages
    status VARCHAR(50) DEFAULT 'pending', -- pending/investigated/confirmed/rejected
    penalty_applied DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP,
    
    CONSTRAINT fk_fraud_reporter FOREIGN KEY (reporter_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_fraud_reported FOREIGN KEY (reported_user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_user_type ON wallets(user_type);
CREATE INDEX idx_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_transactions_type ON wallet_transactions(type);
CREATE INDEX idx_transactions_created_at ON wallet_transactions(created_at);

CREATE INDEX idx_trucks_status ON trucks(status);
CREATE INDEX idx_trucks_location ON trucks(current_latitude, current_longitude);
CREATE INDEX idx_trucks_owner ON trucks(owner_id);
CREATE INDEX idx_trucks_company ON trucks(goods_company_id);

CREATE INDEX idx_loads_status ON loads(status);
CREATE INDEX idx_loads_origin ON loads(origin_city);
CREATE INDEX idx_loads_destination ON loads(destination_city);
CREATE INDEX idx_loads_created_at ON loads(created_at);

CREATE INDEX idx_bids_load_id ON bids(load_id);
CREATE INDEX idx_bids_bidder ON bids(bidder_id);
CREATE INDEX idx_bids_status ON bids(status);

CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_truck ON trips(truck_id);
CREATE INDEX idx_trips_driver ON trips(driver_id);
CREATE INDEX idx_trips_created_at ON trips(created_at);

CREATE INDEX idx_trip_locations_trip_id ON trip_locations(trip_id);
CREATE INDEX idx_trip_locations_timestamp ON trip_locations(timestamp);

-- =====================================================
-- SCAN TRACKING & AUDIT (Existing - Keep)
-- =====================================================

-- Code Scans
CREATE TABLE code_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_code_id UUID REFERENCES unit_codes(id),
    scanned_by UUID, -- user_id or null for anonymous
    scan_type VARCHAR(50), -- verification, inventory, delivery
    location JSONB, -- GPS coordinates
    device_info JSONB,
    result VARCHAR(50), -- authentic, fake, duplicate
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES factory_users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 6. **Transport Ecosystem API Endpoints**

##### Wallet System APIs
- `POST /api/v1/wallet/topup`: Add money to wallet
- `GET /api/v1/wallet/balance`: Get current wallet balance
- `POST /api/v1/wallet/withdraw`: Withdraw funds to bank
- `GET /api/v1/wallet/transactions`: Get transaction history
- `POST /api/v1/wallet/deduct/connection-fee`: Deduct connection fee

##### Goods Company APIs
- `POST /api/v1/transport/goods-company/register`: Register goods company
- `GET /api/v1/transport/goods-company/{id}`: Get company details
- `POST /api/v1/transport/goods-company/{id}/commission`: Update commission structure
- `POST /api/v1/transport/goods-company/{id}/fleet`: Manage truck fleet
- `GET /api/v1/transport/goods-company/available`: List available companies

##### Truck Owner APIs
- `POST /api/v1/transport/truck-owner/register`: Register truck owner
- `POST /api/v1/transport/truck-owner/{id}/truck`: Add truck to fleet
- `GET /api/v1/transport/truck-owner/{id}/fleet`: Get owner's fleet
- `POST /api/v1/transport/truck-owner/{id}/bid`: Place bid on load
- `GET /api/v1/transport/truck-owner/{id}/available-loads`: View available loads
- `GET /api/v1/transport/truck-owner/{id}/active-trips`: View active trips
- `GET /api/v1/transport/truck-owner/{id}/earnings`: View earnings

##### Driver APIs
- `POST /api/v1/transport/driver/register`: Register driver
- `POST /api/v1/transport/driver/{id}/accept-trip`: Accept trip assignment
- `POST /api/v1/transport/driver/{id}/start-trip`: Start trip
- `POST /api/v1/transport/driver/{id}/update-location`: Update GPS location
- `POST /api/v1/transport/driver/{id}/complete-trip`: Complete trip with proof
- `GET /api/v1/transport/driver/{id}/available-trips`: View available trips
- `GET /api/v1/transport/driver/{id}/earnings`: View driver earnings

##### Load & Bidding APIs
- `POST /api/v1/transport/loads`: Post a new load
- `GET /api/v1/transport/loads/available`: Get available loads
- `GET /api/v1/transport/loads/{id}`: Get load details
- `POST /api/v1/transport/loads/{id}/bid`: Place bid on load
- `GET /api/v1/transport/loads/{id}/bids`: Get bids for load
- `POST /api/v1/transport/bids/{id}/accept`: Accept bid
- `POST /api/v1/transport/bids/{id}/reject`: Reject bid

##### Trip Management APIs
- `POST /api/v1/transport/trips`: Create trip from accepted bid
- `GET /api/v1/transport/trips/{id}`: Get trip details
- `POST /api/v1/transport/trips/{id}/start`: Start trip
- `POST /api/v1/transport/trips/{id}/update-location`: Update trip location
- `POST /api/v1/transport/trips/{id}/complete`: Complete trip
- `GET /api/v1/transport/trips/{id}/tracking`: Get live tracking data

##### Secure Chat APIs
- `POST /api/v1/transport/chat/initiate`: Initiate chat with connection fee
- `GET /api/v1/transport/chat/{chatId}/messages`: Get chat messages
- `POST /api/v1/transport/chat/{chatId}/send`: Send secure message
- `POST /api/v1/transport/chat/{chatId}/report-fraud`: Report fraud in chat

##### Fraud Prevention APIs
- `POST /api/v1/transport/fraud/check-pattern`: Check user patterns
- `POST /api/v1/transport/fraud/apply-penalty`: Apply fraud penalty
- `POST /api/v1/transport/fraud/report`: Submit fraud report
- `GET /api/v1/transport/fraud/stats`: Get fraud statistics

##### Google Maps Integration APIs
- `POST /api/v1/transport/maps/route`: Calculate optimal route
- `GET /api/v1/transport/maps/nearby-trucks`: Find nearby available trucks
- `POST /api/v1/transport/maps/geocode`: Geocode address to coordinates
- `GET /api/v1/transport/maps/distance-matrix`: Calculate distance matrix

---


### RESTful API Design

#### Base URL
```
Production: http://135.181.46.27/api/v1
Development: http://localhost:8090/api/v1

Note: In production, Nginx proxies /api requests to Laravel running on internal port 8090.
Client-side API base URL: http://135.181.46.27/api/v1
```

### API Endpoints Reference

#### Authentication Endpoints (`/api/v1/auth`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/login` | POST | User login |
| `/register` | POST | User registration |
| `/logout` | POST | User logout |
| `/refresh` | POST | Refresh JWT token |
| `/forgot-password` | POST | Request password reset |
| `/reset-password` | POST | Reset password with token |
| `/verify-email` | POST | Verify email address |
| `/profile` | GET/PUT | Get/update user profile |
| `/change-password` | POST | Change user password |

#### Admin Endpoints (`/api/v1/admin`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/dashboard` | GET | Admin dashboard statistics |
| `/companies` | GET/POST | List/create companies |
| `/plans` | GET/POST | List/create subscription plans |
| `/subscriptions` | GET | List all subscriptions |
| `/users` | GET | List all users |
| `/reports` | GET | System reports |
| `/settings` | GET/PUT | System settings |
| `/audit-logs` | GET | Audit log entries |

#### Company Endpoints (`/api/v1/companies`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List all companies |
| `/create` | POST | Create new company |
| `/update` | PUT | Update company |
| `/delete` | DELETE | Delete company |
| `/details` | GET | Get company details |
| `/statistics` | GET | Company statistics |
| `/subscription` | GET | Company subscription info |
| `/users` | GET | Company users |

#### Plan Endpoints (`/api/v1/plans`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List all plans |
| `/create` | POST | Create new plan |
| `/update` | PUT | Update plan |
| `/delete` | DELETE | Delete plan |
| `/details` | GET | Get plan details |
| `/features` | GET | List plan features |
| `/pricing` | GET | Get plan pricing |

#### Subscription Endpoints (`/api/v1/subscriptions`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List subscriptions |
| `/create` | POST | Create subscription |
| `/update` | PUT | Update subscription |
| `/cancel` | POST | Cancel subscription |
| `/renew` | POST | Renew subscription |
| `/history` | GET | Subscription history |
| `/invoices` | GET | Subscription invoices |

#### User Endpoints (`/api/v1/users`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List users |
| `/create` | POST | Create user |
| `/update` | PUT | Update user |
| `/delete` | DELETE | Delete user |
| `/profile` | GET | Get user profile |
| `/roles` | GET | Get user roles |
| `/permissions` | GET | Get user permissions |

#### Factory Endpoints (`/api/v1/factories`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List factories |
| `/create` | POST | Create factory |
| `/update` | PUT | Update factory |
| `/delete` | DELETE | Delete factory |
| `/details` | GET | Get factory details |
| `/employees` | GET | List factory employees |
| `/products` | GET | List factory products |
| `/dashboard` | GET | Factory dashboard |
| `/context` | GET | Get factory context |
| `/switch-context` | POST | Switch factory context |
| `/accessible` | GET | List accessible factories |
| `/{id}/subscription` | GET | Factory subscription |
| `/{id}/usage` | GET | Factory usage |
| `/store-keepers` | GET | List store keepers |
| `/drivers` | GET | List factory drivers |

#### Code Endpoints (`/api/v1/codes`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/bundles` | GET/POST | List/create bundle codes |
| `/generate` | POST | Generate codes |
| `/validate` | POST | Validate code |
| `/track` | GET | Track code |
| `/statistics` | GET | Code statistics |
| `/export` | GET | Export codes |
| `/import` | POST | Import codes |
| `/cartons` | GET/POST | List/create carton codes |
| `/packets` | GET/POST | List/create packet codes |
| `/units` | GET/POST | List/create unit codes |

#### Delivery Endpoints (`/api/v1/deliveries`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List deliveries |
| `/create` | POST | Create delivery |
| `/update` | PUT | Update delivery |
| `/track` | GET | Track delivery |
| `/scan` | POST | Scan delivery |
| `/verify` | POST | Verify delivery |
| `/reports` | GET | Delivery reports |

#### Notification Endpoints (`/api/v1/notifications`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List notifications |
| `/mark-read` | POST | Mark as read |
| `/mark-all-read` | POST | Mark all as read |
| `/delete` | DELETE | Delete notification |
| `/settings` | GET/PUT | Notification settings |

#### Report Endpoints (`/api/v1/reports`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/usage` | GET | Usage reports |
| `/revenue` | GET | Revenue reports |
| `/codes` | GET | Code reports |
| `/deliveries` | GET | Delivery reports |
| `/factories` | GET | Factory reports |
| `/export` | GET | Export reports |

#### Analytics Endpoints (`/api/v1/analytics`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/overview` | GET | Analytics overview |
| `/realtime` | GET | Real-time data |
| `/trends` | GET | Trend analysis |
| `/predictions` | GET | AI predictions |

#### File Endpoints (`/api/v1/files`)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/upload` | POST | Upload file |
| `/download` | GET | Download file |
| `/delete` | DELETE | Delete file |
| `/list` | GET | List files |

#### Authentication
- **JWT Tokens**: Bearer token authentication
- **Token Refresh**: Refresh tokens for long-lived sessions
- **API Keys**: For server-to-server communication
- **Rate Limiting**: Per API key/user basis

#### Request Headers
```http
Authorization: Bearer {jwt_token}
Content-Type: application/json
Accept: application/json
X-Company-ID: {company_uuid}  # For multi-tenant requests
X-Request-ID: {unique_id}     # For request tracing
```

#### Response Format
```json
{
  "success": true,
  "data": {
    // Response data here
  },
  "message": "Operation successful",
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### Wallet Transaction Response Example
```json
{
  "success": true,
  "data": {
    "transaction": {
      "id": "txn_123456",
      "from_user_id": "user_123",
      "to_user_id": "user_456",
      "amount": 10.00,
      "type": "connection_fee",
      "status": "completed",
      "description": "Connection fee: Contact with truck_owner",
      "timestamp": "2024-01-15T10:30:00Z"
    },
    "wallet_balance": 490.00
  },
  "message": "Connection fee deducted successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### Transport Load Response Example
```json
{
  "success": true,
  "data": {
    "load": {
      "id": "load_123456",
      "posted_by_id": "factory_123",
      "posted_by_type": "factory",
      "origin_city": "Karachi",
      "destination_city": "Lahore",
      "cargo_type": "general",
      "weight_tons": 10.5,
      "required_truck_type": "Mazda",
      "expected_price": 45000.00,
      "status": "open",
      "bid_count": 3,
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "message": "Load posted successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "phone",
        "message": "Phone number must be 11 digits"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### Transport-Specific Error Codes
- `INSUFFICIENT_WALLET_BALANCE`: Wallet balance below minimum required
- `CONNECTION_FEE_REQUIRED`: ₹10 connection fee required for contact
- `FRAUD_DETECTED`: Fraud pattern detected in user behavior
- `PHONE_NUMBER_BLOCKED`: Phone number sharing detected in chat
- `TRANSPORT_PLAN_LIMIT_REACHED`: Transport feature limit reached for plan
- `BIDDING_CLOSED`: Bidding closed for this load
- `TRUCK_NOT_AVAILABLE`: Truck is not available for trip
- `DRIVER_NOT_VERIFIED`: Driver verification pending
- `GOODS_COMPANY_INACTIVE`: Goods company subscription inactive
- `ESCROW_PAYMENT_REQUIRED`: Escrow payment required before trip start

#### Wallet Error Example
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_WALLET_BALANCE",
    "message": "Insufficient wallet balance. Minimum ₹10 required for contact.",
    "details": [
      {
        "field": "wallet_balance",
        "message": "Current balance: ₹5.00, Required: ₹10.00"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### Fraud Detection Error Example
```json
{
  "success": false,
  "error": {
    "code": "FRAUD_DETECTED",
    "message": "Fraud pattern detected. ₹500 penalty applied.",
    "details": [
      {
        "field": "user_behavior",
        "message": "Multiple cancellations without trips detected"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456"
}
```

#### HTTP Status Codes
- `200 OK`: Successful GET/PUT/PATCH requests
- `201 Created`: Successful POST requests
- `204 No Content`: Successful DELETE requests
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

#### Pagination
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 5,
    "per_page": 20,
    "to": 20,
    "total": 100
  },
  "links": {
    "first": "/api/v1/resource?page=1",
    "last": "/api/v1/resource?page=5",
    "prev": null,
    "next": "/api/v1/resource?page=2"
  }
}
```

#### Filtering & Sorting
```
GET /api/v1/products?status=active&sort=-created_at&include=categories
GET /api/v1/codes?type=unit&date_from=2024-01-01&date_to=2024-01-31
```

### WebSocket/Real-time Updates
- **Connection**: `ws://135.181.46.27/ws` (production), `ws://localhost:8090/ws` (development)
- **Authentication**: JWT token in connection header
- **Channels**:
  - `company.{company_id}.scans`: Real-time scan updates
  - `company.{company_id}.inventory`: Inventory changes
  - `user.{user_id}.notifications`: User notifications
  - `driver.{driver_id}.location`: Driver GPS updates

### File Upload
- **Max Size**: 10MB per file
- **Allowed Types**: PDF, JPG, PNG, DOC, XLS
- **Endpoint**: `POST /api/v1/uploads`
- **Response**: Returns CDN URL for uploaded file

### API Versioning
- **URL Versioning**: `/api/v1/`, `/api/v2/`
- **Header Versioning**: `Accept: application/vnd.nexatrace.v1+json`
- **Deprecation**: Announce 6 months before removal

---

## 🧠 State Management

### Architecture Pattern: BLoC (Business Logic Component)

#### Core Principles
1. **Separation of Concerns**: UI, Business Logic, Data layers separated
2. **Unidirectional Data Flow**: Events → BLoC → States → UI
3. **Reactive Programming**: Stream-based state management
4. **Testability**: Business logic independent of UI

#### BLoC Structure
```
lib/features/{feature_name}/
├── data/
│   ├── models/          # Data models (Freezed)
│   ├── repositories/    # Data access abstraction
│   └── datasources/     # Remote/Local data sources
├── domain/
│   ├── entities/        # Business entities
│   └── usecases/        # Business logic use cases
└── presentation/
    ├── bloc/            # BLoC files
    │   ├── {feature}_bloc.dart
    │   ├── {feature}_event.dart
    │   └── {feature}_state.dart
    ├── screens/         # UI screens
    └── widgets/         # Reusable widgets
```

#### BLoC Implementation Example
```dart
// Event
part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String email,
    required String password,
  }) = _Login;
  
  const factory AuthEvent.logout() = _Logout;
  
  const factory AuthEvent.checkSession() = _CheckSession;
}

// State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  
  AuthBloc(this._repository) : super(const AuthState.initial()) {
    on<_Login>(_onLogin);
    on<_Logout>(_onLogout);
    on<_CheckSession>(_onCheckSession);
  }
  
  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
```

#### Provider Configuration
```dart
// AppProviders.dart - Centralized provider configuration
class AppProviders extends StatelessWidget {
  final Widget child;
  
  const AppProviders({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<SharedPreferences>(create: (_) => SharedPreferences.getInstance()),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),
        Provider<Dio>(create: (_) => Dio()..options = BaseOptions(baseUrl: ApiConfig.baseUrl)),
        
        // Repositories
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            apiClient: context.read<Dio>(),
            secureStorage: context.read<FlutterSecureStorage>(),
          ),
        ),
        
        // BLoCs
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(context.read<AuthRepository>()),
        ),
        
        // Feature-specific providers
        RepositoryProvider<PlanRepository>(
          create: (context) => PlanRepository(context.read<Dio>()),
        ),
        BlocProvider<PlanBloc>(
          create: (context) => PlanBloc(context.read<PlanRepository>()),
        ),
      ],
      child: child,
    );
  }
}
```

#### Widget Usage
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is _Error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is _Authenticated) {
          context.go('/dashboard');
        }
      },
      builder: (context, state) {
        if (state is _Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          body: LoginForm(
            onLogin: (email, password) {
              context.read<AuthBloc>().add(
                AuthEvent.login(email: email, password: password),
              );
            },
          ),
        );
      },
    );
  }
}
```

#### Best Practices
1. **One BLoC per Feature**: Keep BLoCs focused on specific features
2. **Immutable States**: Use Freezed for state classes
3. **Event-Driven**: All state changes triggered by events
4. **Error Handling**: Handle errors in BLoC, show in UI
5. **Loading States**: Always show loading states for async operations
6. **Dispose Properly**: Close streams in BLoC dispose method
7. **Testing**: Write unit tests for BLoC logic

#### Forbidden Patterns
```dart
// ❌ DON'T: Use GetIt for dependency injection
final authBloc = getIt<AuthBloc>();

// ✅ DO: Use context.read for accessing BLoCs
final authBloc = context.read<AuthBloc>();

// ❌ DON'T: Manage state in widgets
setState(() { _isLoading = true; });

// ✅ DO: Use BLoC for state management
context.read<AuthBloc>().add(AuthEvent.login(...));

// ❌ DON'T: Mix business logic in UI
void _handleLogin() {
  // Business logic here
}

// ✅ DO: Keep business logic in BLoC
```

#### Testing BLoCs
```dart
void main() {
  late MockAuthRepository mockRepository;
  late AuthBloc authBloc;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(mockRepository);
  });
  
  test('initial state is AuthState.initial', () {
    expect(authBloc.state, equals(const AuthState.initial()));
  });
  
  test('login success emits authenticated state', () async {
    when(mockRepository.login(any, any))
      .thenAnswer((_) async => User(id: '1', email: 'test@example.com'));
    
    authBloc.add(const AuthEvent.login(
      email: 'test@example.com',
      password: 'password123',
    ));
    
    await expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthState.loading(),
        predicate<AuthState>((state) => state is _Authenticated),
      ]),
    );
  });
}
```

---

## 🚀 Deployment Guide

### Production Server Information

#### Hetzner Server Details
- **Server IP**: 135.181.46.27
- **IPv6**: 2a01:4f9:c014:2997::/64
- **Server Name**: ubuntu-16gb-hel1-2
- **User**: root
- **Password**: qUXXErRRghjE

#### SSH Access
```bash
ssh root@135.181.46.27
# Password: qUXXErRRghjE
```

### Quick Deployment (5 Minutes)

#### Prerequisites
- Windows 10/11 with PowerShell 5.1+
- PostgreSQL 13+ (will be installed automatically)
- Internet connection for package downloads

#### One-Command Deployment
```powershell
# Run as Administrator
cd C:\Ecosystem\NexaTrace_System
.\deploy.bat /all
```

#### Manual Quick Start
1. **Database Setup**:
   ```powershell
   cd C:\Ecosystem\NexaTrace_System\database
   .\deploy.ps1 -AdminPassword "awan1972"
   ```

2. **Start Backend**:
   ```powershell
   cd C:\nexatrace\nexa_backend
   php artisan serve --port=8090 --host=0.0.0.0
   ```

3. **Start Frontend**:
   ```powershell
   cd C:\Ecosystem\NexaTrace_System
   flutter pub get
   flutter run -d chrome
   ```

### Production Deployment to Hetzner Server

#### Flutter Web Build (Local)
```powershell
# Build Flutter web release
cd C:\Ecosystem\NexaTrace_System
flutter clean
flutter pub get
flutter build web --release --no-tree-shake-icons
```

#### Upload to Server
```bash
# Clean old files on server
rm -rf /var/www/nexatrace/admin-web/*

# Upload build/web folder contents to server
# Path: /var/www/nexatrace/admin-web/build/web/

# Reset permissions
chown -R www-data:www-data /var/www/nexatrace/admin-web
chmod -R 755 /var/www/nexatrace/admin-web

# Delete service worker (temporary fix)
rm -f /var/www/nexatrace/admin-web/flutter_service_worker.js

# Reload Nginx
systemctl reload nginx
```

#### Start/Restart Laravel API
```bash
# SSH into server
ssh root@135.181.46.27

# Navigate to Laravel directory
cd /var/www/nexatrace/admin-panel

# Start API in background
php artisan serve --host=0.0.0.0 --port=8090 > /dev/null 2>&1 &

# Or run in foreground for debugging
php artisan serve --host=0.0.0.0 --port=8090

# Clear cache (if needed)
php artisan optimize:clear
```

### Nginx Configuration (Production)

The production server uses Nginx to:
1. Serve Flutter Web static files on port 80
2. Proxy `/api` requests to Laravel on internal port 8090
3. Handle SPA routing with `try_files`

#### Nginx Configuration File
```nginx
# /etc/nginx/sites-available/nexatrace
server {
    listen 80;
    server_name 135.181.46.27;

    # Flutter Web static files
    root /var/www/nexatrace/admin-web/build/web;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # API proxy to Laravel
    location /api {
        proxy_pass http://127.0.0.1:8090;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # SPA routing - all routes go to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Nginx Commands
```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# View logs
sudo tail -f /var/log/nginx/error.log
```


### Backend Deployment (Laravel)

#### 1. Environment Configuration (Production)
```env
APP_NAME=NexaTrace
APP_ENV=production
APP_DEBUG=false
APP_URL=http://135.181.46.27

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5444
DB_DATABASE=nexasystem_db
DB_USERNAME=nexa_app
DB_PASSWORD=NexaAppPassword123!

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

# CORS Configuration
CORS_ALLOWED_ORIGINS=*

JWT_SECRET=<generate-with-php-artisan-jwt:secret>
```

#### 2. Installation Steps (Production Server)
```bash
# SSH into production server
ssh root@135.181.46.27

# Navigate to Laravel directory
cd /var/www/nexatrace/admin-panel

# Install dependencies
composer install

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Seed initial data
php artisan db:seed

# Generate JWT secret
php artisan jwt:secret

# Start server on port 8090 (proxied by Nginx)
php artisan serve --host=0.0.0.0 --port=8090
```

### Frontend Deployment (Flutter)

#### 1. Environment Setup
```bash
# Check Flutter installation
flutter doctor

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Build for platforms
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
flutter build windows --release      # Windows
```

#### 2. Configuration Files (Production)
```dart
// lib/core/config/api_config.dart
// Production configuration
class ApiConfig {
  static const String baseUrl = 'http://135.181.46.27';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}

// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'NexaTrace';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'http://135.181.46.27/api';
  static const int apiTimeout = 30000;
}

// lib/core/config/database_config.dart
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5444;
  static const String database = 'nexasystem_db';
  static const String username = 'nexa_app';
  static const String password = 'NexaAppPassword123!';
}
```

### Rust Module Integration

#### 1. Build Rust Module
```bash
cd C:\Ecosystem\NexaTrace_System\rust

# Build for development
cargo build

# Build for release
cargo build --release

# Run tests
cargo test

# Generate FFI bindings
cargo run --bin generate_bindings
```

#### 2. FFI Configuration
```dart
// rust_module/ffi_config.dart
class RustFFI {
  static final DynamicLibrary nativeLib = Platform.isWindows
      ? DynamicLibrary.open('rust_module.dll')
      : Platform.isLinux
          ? DynamicLibrary.open('librust_module.so')
          : DynamicLibrary.open('librust_module.dylib');

  final Pointer<Utf8> Function(Pointer<Utf8>) generateCodes =
      nativeLib.lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>('generate_codes');
}
```

### Production Deployment

#### 1. Database (Production)
```bash
# PostgreSQL configuration
sudo nano /etc/postgresql/13/main/postgresql.conf

# Optimize for production
max_connections = 200
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
```

#### 2. Laravel (Production)
```bash
# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set up supervisor for queue workers
sudo nano /etc/supervisor/conf.d/nexatrace.conf

# Nginx configuration
sudo nano /etc/nginx/sites-available/nexatrace
```

#### 3. Flutter (Production)
```bash
# Build with production configuration
flutter build apk --release --flavor production

# Code signing
keytool -genkey -v -keystore nexatrace.keystore \
  -alias nexatrace -keyalg RSA -keysize 2048 -validity 10000
```

### Verification

#### 1. Database Verification
```sql
-- Check database health
SELECT * FROM system_health_view;

-- Verify table counts
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;
```

#### 2. API Verification
```bash
# Test API endpoints (Production)
curl -X GET http://135.181.46.27/api/health
curl -X POST http://135.181.46.27/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@nexatrace.local","password":"admin12345"}'

# Test API endpoints (Development)
curl -X GET http://localhost:8090/api/health
curl -X POST http://localhost:8090/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@nexatrace.com","password":"admin12345"}'
```

#### 3. Flutter App Verification
```bash
# Run tests
flutter test

# Check code quality
flutter analyze

# Test on multiple devices
flutter run -d chrome
flutter run -d android
flutter run -d windows
```

### Default Credentials

#### Production Login
```
URL: http://135.181.46.27
(Note: Press Ctrl + F5 to hard refresh the browser)

Super Admin:
Email: admin@nexatrace.local
Password: admin12345

Factory Admin:
Email: factory-admin@nexatrace.local
Password: admin12345
```

#### Super Admin Access
```
Email: superadmin@nexatrace.com
Password: admin12345
```

#### Database Access
```
Host: localhost:5444
Database: nexasystem_db
Username: postgres
Password: awan1972
```

#### API Access
```
Base URL: http://135.181.46.27
API: http://135.181.46.27/api/v1
App User: nexa_app / NexaAppPassword123!
```

#### Hetzner Server Access
```
IPv4: 135.181.46.27
IPv6: 2a01:4f9:c014:2997::/64
User: root
Password: qUXXErRRghjE
```

### Troubleshooting

#### Common Issues & Solutions

##### 1. PostgreSQL Connection Failed
```powershell
# Check if service is running
Get-Service -Name "postgresql-x64-15"

# Start service
Start-Service -Name "postgresql-x64-15"

# Test connection
psql -U postgres -h localhost -p 5444 -c "SELECT 1;"
```

##### 2. Laravel Won't Start
```powershell
# Check port 8090
netstat -an | findstr :8090

# Clear Laravel cache
php artisan cache:clear
php artisan config:clear

# Check logs
Get-Content -Path "storage/logs/laravel.log" -Wait
```

##### 3. Flutter Build Errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Check Flutter installation
flutter doctor
```

##### 4. Database Migration Issues
```powershell
# Run migrations
php artisan migrate --force

# Reset database
php artisan migrate:fresh --seed

# Check database connection
php artisan db:show
```

### Backup & Recovery

#### Database Backup
```powershell
# Manual backup
pg_dump -U postgres -h localhost -p 5444 nexasystem_db > backup_%DATE%.sql

# Restore backup
psql -U postgres -h localhost -p 5444 nexasystem_db < backup.sql
```

#### Automated Backup Script
```powershell
# Run backup script
.\database\backup.ps1
```

### Monitoring

#### Log Locations
- **PostgreSQL**: Event Viewer → Applications → PostgreSQL
- **Laravel**: `storage/logs/laravel.log`
- **Flutter**: Run with `flutter run -v`

#### Health Checks
```powershell
# Database health
psql -U postgres -h localhost -p 5444 -d nexasystem_db -c "SELECT * FROM system_health_view;"

# API health
curl http://localhost:8090/api/health

# System status
python test_deployment.py
```

---

## 🚚 Transport Ecosystem Implementation Structure

### Complete Folder Structure for Transport Ecosystem

```
lib/features/
├── transport/ # NEW - Main Transport Module
│   ├── goods_company/ # Goods Companies (Private)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── goods_company_model.dart
│   │   │   │   ├── goods_company_settings.dart
│   │   │   │   ├── commission_structure_model.dart
│   │   │   │   └── goods_company_subscription.dart
│   │   │   ├── repositories/
│   │   │   │   ├── goods_company_repository.dart
│   │   │   │   └── goods_company_auth_repository.dart
│   │   │   └── datasources/
│   │   │       ├── goods_company_remote_datasource.dart
│   │   │       └── goods_company_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── goods_company_entity.dart
│   │   │   │   └── commission_entity.dart
│   │   │   └── usecases/
│   │   │       ├── register_goods_company.dart
│   │   │       ├── update_commission_structure.dart
│   │   │       ├── manage_fleet_connections.dart
│   │   │       └── view_company_earnings.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── goods_company_auth/
│   │       │   │   ├── goods_company_auth_bloc.dart
│   │       │   │   ├── goods_company_auth_event.dart
│   │       │   │   └── goods_company_auth_state.dart
│   │       │   ├── goods_company_dashboard/
│   │       │   │   ├── goods_company_dashboard_bloc.dart
│   │       │   │   ├── goods_company_dashboard_event.dart
│   │       │   │   └── goods_company_dashboard_state.dart
│   │       │   └── commission_management/
│   │       │       ├── commission_management_bloc.dart
│   │       │       ├── commission_management_event.dart
│   │       │       └── commission_management_state.dart
│   │       │
│   │       ├── screens/
│   │       │   ├── goods_company_login_screen.dart
│   │       │   ├── goods_company_dashboard_screen.dart
│   │       │   ├── goods_company_fleet_screen.dart
│   │       │   ├── goods_company_commission_screen.dart
│   │       │   ├── goods_company_loads_screen.dart
│   │       │   ├── goods_company_bids_screen.dart
│   │       │   └── goods_company_earnings_screen.dart
│   │       │
│   │       └── widgets/
│   │           ├── goods_company_drawer.dart
│   │           ├── commission_card.dart
│   │           └── fleet_truck_card.dart
│   │
│   ├── truck_owner/ # Truck Owners (Universal)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── truck_owner_model.dart
│   │   │   │   ├── owner_truck_model.dart
│   │   │   │   ├── owner_trip_model.dart
│   │   │   │   └── owner_earning_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── truck_owner_repository.dart
│   │   │   │   ├── owner_truck_repository.dart
│   │   │   │   └── owner_bid_repository.dart
│   │   │   └── datasources/
│   │   │       ├── truck_owner_remote_datasource.dart
│   │   │       └── truck_owner_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── truck_owner_entity.dart
│   │   │   │   └── owner_truck_entity.dart
│   │   │   └── usecases/
│   │   │       ├── register_truck_owner.dart
│   │   │       ├── add_truck_to_fleet.dart
│   │   │       ├── view_available_loads.dart
│   │   │       ├── place_bid_on_load.dart
│   │   │       ├── track_owner_trips.dart
│   │   │       └── view_owner_earnings.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── owner_auth/
│   │       │   │   ├── owner_auth_bloc.dart
│   │       │   │   ├── owner_auth_event.dart
│   │       │   │   └── owner_auth_state.dart
│   │       │   ├── owner_dashboard/
│   │       │   │   ├── owner_dashboard_bloc.dart
│   │       │   │   ├── owner_dashboard_event.dart
│   │       │   │   └── owner_dashboard_state.dart
│   │       │   ├── owner_bidding/
│   │       │   │   ├── owner_bidding_bloc.dart
│   │       │   │   ├── owner_bidding_event.dart
│   │       │   │   └── owner_bidding_state.dart
│   │       │   └── owner_trips/
│   │       │       ├── owner_trips_bloc.dart
│   │       │       ├── owner_trips_event.dart
│   │       │       └── owner_trips_state.dart
│   │       │
│   │       ├── screens/
│   │       │   ├── owner_login_screen.dart
│   │       │   ├── owner_register_screen.dart
│   │       │   ├── owner_dashboard_screen.dart
│   │       │   ├── owner_fleet_screen.dart
│   │       │   ├── owner_add_truck_screen.dart
│   │       │   ├── owner_available_loads_screen.dart
│   │       │   ├── owner_place_bid_screen.dart
│   │       │   ├── owner_active_trips_screen.dart
│   │       │   ├── owner_trip_detail_screen.dart
│   │       │   ├── owner_earnings_screen.dart
│   │       │   └── owner_wallet_screen.dart
│   │       │
│   │       └── widgets/
│   │           ├── owner_drawer.dart
│   │           ├── truck_card.dart
│   │           ├── load_card_for_owner.dart
│   │           └── bid_card.dart
│   │
│   ├── driver/ # Drivers (Universal) - NEW ENHANCED
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── driver_model.dart
│   │   │   │   ├── driver_trip_model.dart
│   │   │   │   ├── driver_earning_model.dart
│   │   │   │   └── driver_location_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── driver_repository.dart
│   │   │   │   ├── driver_trip_repository.dart
│   │   │   │   └── driver_location_repository.dart
│   │   │   └── datasources/
│   │   │       ├── driver_remote_datasource.dart
│   │   │       └── driver_local_datasource.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── driver_entity.dart
│   │   │   │   └── driver_trip_entity.dart
│   │   │   └── usecases/
│   │   │       ├── register_driver.dart
│   │   │       ├── accept_trip.dart
│   │   │       ├── start_trip.dart
│   │   │       ├── update_location.dart
│   │   │       ├── complete_trip.dart
│   │   │       ├── upload_delivery_proof.dart
│   │   │       └── view_driver_earnings.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── driver_auth/
│   │       │   │   ├── driver_auth_bloc.dart
│   │       │   │   ├── driver_auth_event.dart
│   │       │   │   └── driver_auth_state.dart
│   │       │   ├── driver_dashboard/
│   │       │   │   ├── driver_dashboard_bloc.dart
│   │       │   │   ├── driver_dashboard_event.dart
│   │       │   │   └── driver_dashboard_state.dart
│   │       │   ├── driver_trip/
│   │       │   │   ├── driver_trip_bloc.dart
│   │       │   │   ├── driver_trip_event.dart
│   │       │   │   └── driver_trip_state.dart
│   │       │   └── driver_location/
│   │       │       ├── driver_location_bloc.dart
│   │       │       ├── driver_location_event.dart
│   │       │       └── driver_location_state.dart
│   │       │
│   │       ├── screens/
│   │       │   ├── driver_login_screen.dart
│   │       │   ├── driver_register_screen.dart
│   │       │   ├── driver_dashboard_screen.dart
│   │       │   ├── driver_available_trips_screen.dart
│   │       │   ├── driver_trip_detail_screen.dart
│   │       │   ├── driver_navigation_screen.dart
│   │       │   ├── driver_upload_proof_screen.dart
│   │       │   ├── driver_earnings_screen.dart
│   │       │   └── driver_wallet_screen.dart
│   │       │
│   │       └── widgets/
│   │           ├── driver_drawer.dart
│   │           ├── trip_card.dart
│   │           └── earnings_chart.dart
│   │
│   ├── shared/ # Shared Transport Components
│   │   ├── models/
│   │   │   ├── load_model.dart # Load posting (by factories/goods companies)
│   │   │   ├── bid_model.dart # Bidding system
│   │   │   ├── trip_model.dart # Trip after bid acceptance
│   │   │   ├── route_model.dart # Route information
│   │   │   └── location_model.dart # GPS location
│   │   │
│   │   ├── repositories/
│   │   │   ├── load_repository.dart
│   │   │   ├── bid_repository.dart
│   │   │   └── trip_repository.dart
│   │   │
│   │   ├── usecases/
│   │   │   ├── create_load.dart
│   │   │   ├── get_available_loads.dart
│   │   │   ├── place_bid.dart
│   │   │   ├── accept_bid.dart
│   │   │   ├── create_trip_from_bid.dart
│   │   │   └── track_trip.dart
│   │   │
│   │   └── widgets/
│   │       ├── load_card.dart # Reusable load card
│   │       ├── bid_card.dart # Reusable bid card
│   │       └── trip_summary_card.dart # Reusable trip card
│   │
│   └── wallet/ # NEW - Wallet System (CORE)
│       ├── data/
│       │   ├── models/
│       │   │   ├── wallet_model.dart
│       │   │   ├── wallet_transaction_model.dart
│       │   │   ├── wallet_topup_model.dart
│       │   │   └── wallet_balance_model.dart
│       │   ├── repositories/
│       │   │   ├── wallet_repository.dart
│       │   │   └── transaction_repository.dart
│       │   └── datasources/
│       │       ├── wallet_remote_datasource.dart
│       │       └── wallet_local_datasource.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── wallet_entity.dart
│       │   │   └── transaction_entity.dart
│       │   └── usecases/
│       │       ├── get_wallet_balance.dart
│       │       ├── top_up_wallet.dart
│       │       ├── deduct_connection_fee.dart
│       │       ├── deduct_commission.dart
│       │       ├── apply_penalty.dart
│       │       ├── add_reward.dart
│       │       └── withdraw_funds.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── wallet_bloc.dart
│           │   ├── wallet_event.dart
│           │   └── wallet_state.dart
│           │
│           ├── screens/
│           │   ├── wallet_screen.dart
│           │   ├── wallet_topup_screen.dart
│           │   ├── wallet_transactions_screen.dart
│           │   └── wallet_withdraw_screen.dart
│           │
│           └── widgets/
│               ├── wallet_balance_card.dart
│               ├── transaction_tile.dart
│               └── topup_methods_widget.dart
│
├── features/factory/ # EXISTING - TO BE UPDATED
│   └── admin/
│       └── presentation/
│           └── screens/
│               └── factory_dashboard.dart # ADD transport options
│
├── features/universal/ # EXISTING - TO BE UPDATED
│   ├── reseller/ # Add transport access
│   └── shop/ # Add transport access
│
└── features/delivery/ # EXISTING - ENHANCE
    └── courier_integration/ # Already planned
```

### Transport BLoC Implementation Examples

#### Wallet BLoC Example
```dart
// lib/features/transport/wallet/presentation/bloc/wallet_bloc.dart
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  final FraudDetectionService fraudDetection;
  
  WalletBloc({
    required this.walletRepository,
    required this.fraudDetection,
  }) : super(WalletInitial()) {
    on<GetWalletBalance>(_onGetWalletBalance);
    on<TopUpWallet>(_onTopUpWallet);
    on<DeductConnectionFee>(_onDeductConnectionFee);
    on<WithdrawFunds>(_onWithdrawFunds);
    on<GetTransactionHistory>(_onGetTransactionHistory);
  }
  
  Future<void> _onDeductConnectionFee(
    DeductConnectionFee event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    
    try {
      // Check minimum balance
      final wallet = await walletRepository.getWallet(event.userId);
      if (wallet.balance < 10.0) {
        emit(WalletError('Insufficient balance. Minimum ₹10 required for contact.'));
        return;
      }
      
      // Deduct connection fee
      final transaction = await walletRepository.deductConnectionFee(
        fromUserId: event.fromUserId,
        toUserId: event.toUserId,
        amount: 10.0,
        description: 'Connection fee for contact',
      );
      
      emit(ConnectionFeeDeducted(transaction: transaction));
    } catch (e) {
      emit(WalletError('Failed to deduct connection fee: ${e.toString()}'));
    }
  }
}
```

#### Goods Company Auth BLoC Example
```dart
// lib/features/transport/goods_company/presentation/bloc/goods_company_auth/goods_company_auth_bloc.dart
class GoodsCompanyAuthBloc extends Bloc<GoodsCompanyAuthEvent, GoodsCompanyAuthState> {
  final GoodsCompanyRepository repository;
  final WalletService walletService;
  
  GoodsCompanyAuthBloc({
    required this.repository,
    required this.walletService,
  }) : super(GoodsCompanyAuthInitial()) {
    on<RegisterGoodsCompany>(_onRegisterGoodsCompany);
    on<LoginGoodsCompany>(_onLoginGoodsCompany);
    on<VerifyGoodsCompany>(_onVerifyGoodsCompany);
  }
  
  Future<void> _onRegisterGoodsCompany(
    RegisterGoodsCompany event,
    Emitter<GoodsCompanyAuthState> emit,
  ) async {
    emit(GoodsCompanyAuthLoading());
    
    try {
      // Check wallet minimum balance (₹500 for companies)
      final wallet = await walletService.getWalletByPhone(event.phone);
      if (wallet == null || wallet.balance < 500) {
        emit(GoodsCompanyWalletRequired(
          message: 'Minimum ₹500 wallet balance required',
          minBalance: 500,
        ));
        return;
      }
      
      // Register company
      final company = await repository.registerCompany(
        companyName: event.companyName,
        ownerName: event.ownerName,
        phone: event.phone,
        email: event.email,
        cnic: event.cnic,
        address: event.address,
        planType: event.planType,
      );
      
      emit(GoodsCompanyRegistered(company: company));
    } catch (e) {
      emit(GoodsCompanyAuthError('Registration failed: ${e.toString()}'));
    }
  }
}
```

#### Secure Chat BLoC Example
```dart
// lib/features/transport/shared/presentation/bloc/chat_bloc.dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final FraudDetectionService fraudDetection;
  final WalletRepository walletRepository;
  
  ChatBloc({
    required this.chatRepository,
    required this.fraudDetection,
    required this.walletRepository,
  }) : super(ChatInitial()) {
    on<InitiateChat>(_onInitiateChat);
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
    on<ReportFraud>(_onReportFraud);
  }
  
  Future<void> _onInitiateChat(
    InitiateChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    try {
      // Check wallet balance for connection fee
      final wallet = await walletRepository.getWallet(event.fromUserId);
      if (wallet.balance < 10.0) {
        emit(ChatError('Insufficient balance. ₹10 required for contact.'));
        return;
      }
      
      // Deduct connection fee
      await walletRepository.deductConnectionFee(
        fromUserId: event.fromUserId,
        toUserId: event.toUserId,
        amount: 10.0,
        description: 'Chat initiation fee',
      );
      
      // Create chat session
      final chat = await chatRepository.createChat(
        fromUserId: event.fromUserId,
        toUserId: event.toUserId,
        fromUserType: event.fromUserType,
        toUserType: event.toUserType,
      );
      
      emit(ChatInitiated(chat: chat));
    } catch (e) {
      emit(ChatError('Failed to initiate chat: ${e.toString()}'));
    }
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Check for phone numbers in message
    if (fraudDetection.containsPhoneNumber(event.message)) {
      // Apply penalty for phone number sharing
      await fraudDetection.applyFraudPenalty(
        event.senderId,
        event.receiverId,
      );
      
      emit(MessageBlocked(
        'Phone number sharing detected. ₹500 penalty applied.',
        warningCount: event.warningCount + 1,
      ));
      return;
    }
    
    // Send message normally
    final message = await chatRepository.sendMessage(
      chatId: event.chatId,
      senderId: event.senderId,
      message: event.message,
    );
    
    emit(MessageSent(message: message));
  }
}
```

#### Factory Dashboard Integration Example
```dart
// lib/features/factory/admin/presentation/screens/factory_dashboard.dart
class FactoryDashboard extends StatefulWidget {
  @override
  State<FactoryDashboard> createState() => _FactoryDashboardState();
}

class _FactoryDashboardState extends State<FactoryDashboard> {
  int _selectedTab = 0;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subscriptionState) {
        final plan = subscriptionState.currentPlan;
        
        return DefaultTabController(
          length: plan.limits.canContactDriversDirectly ? 3 : 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Factory Dashboard'),
              bottom: TabBar(
                tabs: _buildTabs(plan),
              ),
            ),
            body: TabBarView(
              children: _buildTabViews(plan),
            ),
          ),
        );
      },
    );
  }
  
  List<Tab> _buildTabs(PlanModel plan) {
    final tabs = [
      Tab(text: 'Overview'),
      Tab(text: 'Products'),
    ];
    
    if (plan.limits.canContactDriversDirectly) {
      tabs.add(Tab(text: 'Transport'));
    }
    
    return tabs;
  }
  
  List<Widget> _buildTabViews(PlanModel plan) {
    final views = [
      OverviewTab(),
      ProductsTab(),
    ];
    
    if (plan.limits.canContactDriversDirectly) {
      views.add(TransportTab());
    } else {
      views.add(Center(
        child: UpgradePromptWidget(
          message: 'Upgrade to Standard plan for transport features',
          requiredPlan: 'Standard',
        ),
      ));
    }
    
    return views;
  }
}
```

#### Transport Tab Widget Example
```dart
// lib/features/factory/admin/presentation/widgets/transport_tab.dart
class TransportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoadBloc(
            repository: context.read<LoadRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => WalletBloc(
            repository: context.read<WalletRepository>(),
            fraudDetection: context.read<FraudDetectionService>(),
          ),
        ),
      ],
      child: BlocBuilder<LoadBloc, LoadState>(
        builder: (context, loadState) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Wallet Balance Card
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    return WalletBalanceCard(
                      balance: walletState.balance,
                      onTopUp: () => _showTopUpDialog(context),
                    );
                  },
                ),
                
                SizedBox(height: 20),
                
                // Post Load Button
                ElevatedButton(
                  onPressed: () {
                    // Check wallet balance first
                    final walletBloc = context.read<WalletBloc>();
                    final walletState = walletBloc.state;
                    
                    if (walletState.balance < 10.0) {
                      _showInsufficientBalanceDialog(context);
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostLoadScreen(),
                      ),
                    );
                  },
                  child: Text('+ Post New Load'),
                ),
                
                SizedBox(height: 20),
                
                // Available Loads
                if (loadState is LoadsLoaded && loadState.loads.isNotEmpty)
                  ...loadState.loads.map((load) => LoadCard(load: load)),
                
                if (loadState is LoadsLoaded && loadState.loads.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.local_shipping,
                    message: 'No loads available',
                    actionText: 'Post First Load',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostLoadScreen()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### Critical Implementation Rules

#### RULE 1: NO GET_IT - Use BLoC Provider Only
```dart
// ❌ FORBIDDEN - Never use GetIt
final getIt = GetIt.instance;
getIt.registerSingleton<WalletRepository>(WalletRepository());

// ✅ ALLOWED - Use BLoC Provider
class MyWidget extends StatelessWidget {
  final WalletRepository walletRepository;
  
  const MyWidget({required this.walletRepository});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletBloc(repository: walletRepository),
      child: ChildWidget(),
    );
  }
}
```

#### RULE 2: Wallet Check Before Any Contact
```dart
// Before ANY contact between users:
Future<bool> canInitiateContact(String userId) async {
  final wallet = await walletRepository.getWallet(userId);
  if (wallet.balance < 10.0) {
    showDialog(context, '₹10 wallet balance required');
    return false;
  }
  return true;
}

// Deduct fee immediately on contact
await walletRepository.deductConnectionFee(
  fromUserId: fromUserId,
  toUserId: toUserId,
  amount: 10.0,
  description: 'Connection fee',
);
```

#### RULE 3: Secure Chat Implementation
```dart
// Every chat must:
// 1. Block phone numbers
// 2. Block WhatsApp links
// 3. Show warning banners
// 4. Apply penalties for violations
// 5. Never expose phone numbers

class SecureChatInput extends StatefulWidget {
  @override
  State<SecureChatInput> createState() => _SecureChatInputState();
}

class _SecureChatInputState extends State<SecureChatInput> {
  final FraudDetectionService _fraudDetection = FraudDetectionService();
  
  void _sendMessage(String text) {
    // Check for phone numbers
    if (_fraudDetection.containsPhoneNumber(text)) {
      _showWarning('Phone number sharing detected. ₹500 penalty applied.');
      _applyPenalty();
      return;
    }
    
    // Check for WhatsApp links
    if (text.contains('wa.me') || text.contains('whatsapp.com')) {
      _showWarning('WhatsApp links not allowed. Stay in app.');
      return;
    }
    
    // Send secure message
    _sendSecureMessage(text);
  }
}
```

#### RULE 4: Respect Subscription Plan Limits
```dart
// Always check plan limits before allowing features
bool canUseTransportFeature(PlanModel plan) {
  return plan.limits.canContactDriversDirectly || 
         plan.limits.canUseGoodsCompanies;
}

void _showTransportFeature() {
  final plan = context.read<SubscriptionBloc>().state.currentPlan;
  
  if (!canUseTransportFeature(plan)) {
    _showUpgradeDialog(
      'Upgrade to Standard plan for transport features',
      requiredPlan: 'Standard',
    );
    return;
  }
  
  // Show transport feature
  Navigator.push(context, MaterialPageRoute(builder: (_) => TransportScreen()));
}
```

#### RULE 5: Database Schema Compliance
```sql
-- All transport tables must follow this pattern:
-- 1. UUID primary keys
-- 2. Foreign key constraints
-- 3. JSONB for flexible data
-- 4. Created/updated timestamps
-- 5. Proper indexes

CREATE TABLE transport_entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_transport_user_id ON transport_entities(user_id);
CREATE INDEX idx_transport_created_at ON transport_entities(created_at);
```

### Implementation Checklist

#### ✅ PHASE 1: CORE INFRASTRUCTURE (WEEK 1)
- [ ] Create `lib/features/transport/` folder structure
- [ ] Implement Wallet models with Freezed
- [ ] Implement WalletRepository with Dio
- [ ] Implement WalletBloc (events: topUp, deduct, withdraw)
- [ ] Create FraudDetectionService in core/services
- [ ] Add wallet tables migration script
- [ ] Test wallet transactions locally

#### ✅ PHASE 2: GOODS COMPANY MODULE (WEEK 2)
- [ ] Create `lib/features/transport/goods_company/` folder
- [ ] Implement GoodsCompany models
- [ ] Implement GoodsCompanyRepository
- [ ] Implement GoodsCompanyAuthBloc
- [ ] Create GoodsCompanyDashboardBloc
- [ ] Build registration flow with wallet check
- [ ] Create commission management screens
- [ ] Test goods company flows

#### ✅ PHASE 3: TRUCK OWNER MODULE (WEEK 3)
- [ ] Create `lib/features/transport/truck_owner/` folder
- [ ] Implement TruckOwner and Truck models
- [ ] Implement OwnerRepository
- [ ] Implement OwnerAuthBloc
- [ ] Create OwnerDashboardBloc
- [ ] Build fleet management screens
- [ ] Implement bidding system
- [ ] Test owner flows

#### ✅ PHASE 4: DRIVER MODULE (WEEK 4)
- [ ] Create `lib/features/transport/driver/` folder
- [ ] Implement Driver models
- [ ] Implement DriverRepository
- [ ] Implement DriverAuthBloc
- [ ] Create DriverTripBloc
- [ ] Build navigation and location update
- [ ] Implement delivery proof upload
- [ ] Test driver flows

#### ✅ PHASE 5: SHARED COMPONENTS (WEEK 5)
- [ ] Create `lib/features/transport/shared/` folder
- [ ] Implement Load models and repository
- [ ] Implement Bid models and repository
- [ ] Create LoadCard widget (reusable)
- [ ] Create BidCard widget (reusable)
- [ ] Implement secure chat with fraud detection
- [ ] Build Google Maps integration
- [ ] Test all shared components

#### ✅ PHASE 6: EXISTING APP INTEGRATION (WEEK 6)
- [ ] Update FactoryPlanModel with transport fields
- [ ] Add Transport tab to Factory Dashboard
- [ ] Add transport options to Reseller app
- [ ] Add transport options to Shop app
- [ ] Add wallet section to all existing apps
- [ ] Test end-to-end flows
- [ ] Performance testing
- [ ] Security audit

### Integration Points with Existing Features

#### 1. Factory Plan Integration
```dart
// Update existing PlanLimitModel
class PlanLimitModel {
  // ... existing fields
  
  // Add transport fields
  final int transportConnectionsPerMonth;
  final bool canContactDriversDirectly;
  final bool canContactOwnersDirectly;
  final bool canUseGoodsCompanies;
  final int maxLoadsPerMonth;
  
  // Update constructor and fromJson/toJson methods
}
```

#### 2. Universal App Integration
```dart
// Add transport access to reseller and shop apps
class UniversalDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final userType = userState.user?.type;
        
        return Column(
          children: [
            // Existing features...
            
            // Transport access for resellers/shops
            if (userType == UserType.reseller || userType == UserType.shop)
              TransportAccessCard(
                minBalance: userType == UserType.reseller ? 200 : 100,
                onTap: () => _checkWalletAndNavigate(context, userType),
              ),
          ],
        );
      },
    );
  }
}
```

#### 3. Delivery System Enhancement
```dart
// Enhance existing delivery system with transport features
class EnhancedDeliverySystem {
  // Use existing driver_delivery structure
  // Add transport marketplace integration
  // Add wallet system for payments
  // Add secure chat for communication
}
```

### Security Considerations

#### 1. Fraud Prevention
- Phone number detection in chat messages
- WhatsApp link blocking
- Pattern detection for suspicious behavior
- Automatic penalties for violations
- Manual review system for reported fraud

#### 2. Wallet Security
- Minimum balance requirements per user type
- Immediate deduction of connection fees
- Escrow payments for large transactions
- Withdrawal limits and verification
- Transaction audit trail

#### 3. Data Protection
- Never expose phone numbers in UI
- Redact sensitive information in logs
- Secure chat message storage
- GDPR-compliant data handling
- Regular security audits

### Testing Strategy

#### 1. Unit Tests
- BLoC state transitions
- Repository methods
- Use case validation
- Model serialization

#### 2. Integration Tests
- Wallet transaction flows
- Chat initiation with fee deduction
- Load posting and bidding
- Trip management

#### 3. End-to-End Tests
- Complete transport workflow
- Fraud detection scenarios
- Plan limit enforcement
- Payment processing

### Deployment Notes

#### 1. Database Migration
```sql
-- Run transport schema migration
-- Add wallet tables
-- Add transport user tables
-- Add operation tables
-- Create indexes
-- Seed initial data
```

#### 2. Backend Updates
- Add transport API endpoints
- Implement fraud detection service
- Add wallet service
- Update subscription service

#### 3. Frontend Updates
- Add transport feature module
- Update existing dashboards
- Add wallet screens
- Implement secure chat

### Support & Maintenance

#### 1. Monitoring
- Wallet transaction monitoring
- Fraud detection alerts
- Transport usage analytics
- Performance metrics

#### 2. Support Channels
- Transport-specific support team
- Fraud investigation team
- Wallet support
- Technical support

#### 3. Regular Updates
- Monthly security updates
- Quarterly feature updates

#### Naming Conventions
- **Classes**: `PascalCase` - `UserRepository`, `ProductDetailScreen`
- **Variables**: `camelCase` - `userRepository`, `productList`
- **Constants**: `SCREAMING_SNAKE_CASE` - `API_BASE_URL`, `MAX_RETRY_COUNT`
- **Files**: `snake_case` - `user_repository.dart`, `product_detail_screen.dart`
- **Directories**: `snake_case` - `data/models/`, `presentation/screens/`

#### Code Organization
```dart
// File structure within a feature
// 1. Imports (dart, packages, local)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

// 2. Constants
const double kDefaultPadding = 16.0;
const Duration kAnimationDuration = Duration(milliseconds: 300);

// 3. Enums
enum UserRole { admin, manager, user, guest }

// 4. Typedefs
typedef OnSuccess<T> = void Function(T data);
typedef OnError = void Function(String message);

// 5. Classes
@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(User user) = _Loaded;
  const factory UserState.error(String message) = _Error;
}

// 6. Widgets
class UserProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  
  const UserProfileCard({
    super.key,
    required this.user,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(user.email),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### BLoC Standards
```dart
// Event naming: Noun + Verb
class LoadUserData extends UserEvent
class UpdateUserProfile extends UserEvent
class DeleteUserAccount extends UserEvent

// State naming: Adjective + Noun
class UserLoading extends UserState
class UserLoaded extends UserState
class UserError extends UserState

// Method naming in BLoC
Future<void> _onLoadUserData(LoadUserData event, Emitter<UserState> emit)
Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<UserState> emit)
```

#### Error Handling
```dart
// Use Either pattern for operations that can fail
Future<Either<Failure, User>> getUserById(String id) async {
  try {
    final response = await _apiClient.get('/users/$id');
    final user = User.fromJson(response.data);
    return Right(user);
  } on DioException catch (e) {
    return Left(NetworkFailure.fromDioError(e));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

// Handle errors in UI
BlocConsumer<UserBloc, UserState>(
  listener: (context, state) {
    if (state is UserError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    return switch (state) {
      UserInitial() => const Placeholder(),
      UserLoading() => const Center(child: CircularProgressIndicator()),
      UserLoaded(user: final user) => UserProfile(user: user),
      UserError(message: final message) => ErrorWidget(message: message),
    };
  },
);
```

#### Testing Standards
```dart
// Test file naming: {file_under_test}_test.dart
// user_repository.dart → user_repository_test.dart

// Test structure
void main() {
  late UserRepository repository;
  late MockApiClient mockApiClient;
  
  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserRepository(apiClient: mockApiClient);
  });
  
  group('UserRepository', () {
    test('getUserById returns User on success', () async {
      // Arrange
      when(mockApiClient.get('/users/1'))
        .thenAnswer((_) async => Response(
          data: {'id': '1', 'name': 'John'},
          statusCode: 200,
        ));
      
      // Act
      final result = await repository.getUserById('1');
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (user) => expect(user.name, 'John'),
      );
    });
  });
}
```

### PHP/Laravel Standards

#### Naming Conventions
- **Classes**: `PascalCase` - `UserController`, `ProductService`
- **Methods**: `camelCase` - `getUserById()`, `createProduct()`
- **Variables**: `camelCase` - `$userRepository`, `$productList`
- **Database Tables**: `snake_case` - `users`, `product_categories`
- **Database Columns**: `snake_case` - `created_at`, `is_active`

#### Controller Standards
```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\StoreUserRequest;
use App\Http\Requests\User\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(
        private readonly UserService $userService
    ) {}
    
    /**
     * Display a listing of users.
     */
    public function index(Request $request): JsonResponse
    {
        $users = $this->userService->getAllUsers($request->all());
        
        return response()->json([
            'success' => true,
            'data' => UserResource::collection($users),
            'message' => 'Users retrieved successfully.',
        ]);
    }
    
    /**
     * Store a newly created user.
     */
    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = $this->userService->createUser($request->validated());
        
        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
            'message' => 'User created successfully.',
        ], 201);
    }
}
```

#### Service Layer Standards
```php
<?php

namespace App\Services;

use App\Exceptions\BusinessException;
use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class UserService
{
    public function __construct(
        private readonly UserRepository $userRepository
    ) {}
    
    /**
     * Get all users with pagination and filters.
     */
    public function getAllUsers(array $filters = []): LengthAwarePaginator
    {
        return $this->userRepository->getAll($filters);
    }
    
    /**
     * Create a new user.
     * 
     * @throws BusinessException
     */
    public function createUser(array $data): User
    {
        // Business logic validation
        if ($this->userRepository->emailExists($data['email'])) {
            throw new BusinessException('Email already exists.');
        }
        
        return $this->userRepository->create($data);
    }
}
```

#### Repository Pattern
```php
<?php

namespace App\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class UserRepository
{
    public function __construct(
        private readonly User $model
    ) {}
    
    /**
     * Get all users with filters.
     */
    public function getAll(array $filters = [], int $perPage = 20): LengthAwarePaginator
    {
        $query = $this->model->newQuery();
        
        // Apply filters
        if (isset($filters['search'])) {
            $query->where(function (Builder $q) use ($filters) {
                $q->where('name', 'like', "%{$filters['search']}%")
                  ->orWhere('email', 'like', "%{$filters['search']}%");
            });
        }
        
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }
        
        return $query->paginate($perPage);
    }
    
    /**
     * Check if email exists.
     */
    public function emailExists(string $email, ?int $excludeId = null): bool
    {
        $query = $this->model->where('email', $email);
        
        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }
        
        return $query->exists();
    }
}
```

### Database Standards

#### SQL Standards
```sql
-- Use uppercase for SQL keywords
-- Use lowercase for table/column names
-- Always specify column list in INSERT
-- Use explicit JOIN syntax

-- ✅ Good
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
    AND u.created_at >= '2024-01-01'
GROUP BY u.id, u.name, u.email
ORDER BY order_count DESC
LIMIT 10;

-- ❌ Bad
select * from users u, orders o 
where u.id = o.user_id and u.status = 'active' 
limit 10;
```

#### Indexing Standards
```sql
-- Add indexes for foreign keys
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Composite indexes for common query patterns
CREATE INDEX idx_users_status_created ON users(status, created_at DESC);

-- Partial indexes for filtered queries
CREATE INDEX idx_active_users ON users(id) WHERE status = 'active';
```

### Git Standards

#### Commit Message Convention
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semi-colons, etc)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependencies updates

#### Examples
```
feat(auth): add two-factor authentication

- Add 2FA setup screen
- Implement TOTP generation
- Add backup code generation
- Update login flow to require 2FA

Closes #123
```

```
fix(products): fix product image upload

- Fix file size validation
- Handle unsupported image formats
- Improve error messages

Fixes #456
```

---

---
## 📁 Project Structure

### Flutter Project Structure
```
NexaTrace_System/
├── 📁 android/                    # Android-specific files
├── 📁 assets/                     # Static assets
│   ├── 📁 animations/             # Lottie animations
│   ├── 📁 fonts/                  # Custom fonts
│   ├── 📁 icons/                  # App icons
│   ├── 📁 images/                 # Images and illustrations
│   └── 📁 translations/           # Localization files
├── 📁 ios/                        # iOS-specific files
├── 📁 lib/                        # Dart source code
│   ├── 📁 core/                   # Core application code
│   │   ├── 📁 config/             # Configuration files
│   │   │   ├── api_config.dart    # API endpoints
│   │   │   ├── app_config.dart    # App configuration
│   │   │   ├── database_config.dart # Database config
│   │   │   └── theme_config.dart  # Theme configuration
│   │   ├── 📁 constants/          # App constants
│   │   │   ├── app_constants.dart # General constants
│   │   │   ├── api_constants.dart # API constants
│   │   │   └── route_constants.dart # Route names
│   │   ├── 📁 di/                 # Dependency injection (Providers)
│   │   │   ├── app_providers.dart # Main provider configuration
│   │   │   ├── service_providers.dart # Service providers
│   │   │   └── bloc_providers.dart # BLoC providers
│   │   ├── 📁 errors/             # Error handling
│   │   │   ├── exceptions.dart    # Custom exceptions
│   │   │   ├── failure.dart       # Failure classes
│   │   │   └── error_handler.dart # Global error handler
│   │   ├── 📁 network/            # Networking layer
│   │   │   ├── api_client.dart    # HTTP client
│   │   │   ├── interceptors/      # Dio interceptors
│   │   │   └── web_socket_client.dart # WebSocket client
│   │   ├── 📁 routes/             # Navigation
│   │   │   ├── app_router.dart    # Main router configuration
│   │   │   ├── route_guard.dart   # Route guards
│   │   │   └── route_observer.dart # Route observer
│   │   ├── 📁 theme/              # Theming
│   │   │   ├── app_theme.dart     # Theme data
│   │   │   ├── colors.dart        # Color palette
│   │   │   ├── text_styles.dart   # Typography
│   │   │   └── app_theme_mode.dart # Theme mode manager
│   │   ├── 📁 utils/              # Utility classes
│   │   │   ├── string_utils.dart  # String manipulation
│   │   │   ├── date_utils.dart    # Date/time utilities
│   │   │   ├── validation_utils.dart # Form validation
│   │   │   └── extension_utils.dart # Dart extensions
│   │   └── 📁 widgets/            # Reusable widgets
│   │       ├── buttons/           # Button widgets
│   │       ├── cards/             # Card widgets
│   │       ├── dialogs/           # Dialog widgets
│   │       ├── forms/             # Form widgets
│   │       ├── loaders/           # Loading indicators
│   │       └── shared/            # Shared widgets
│   ├── 📁 features/               # Feature modules
│   │   ├── 📁 auth/               # Authentication feature
│   │   │   ├── 📁 data/           # Data layer
│   │   │   │   ├── 📁 models/     # Auth models
│   │   │   │   ├── 📁 repositories/ # Auth repositories
│   │   │   │   └── 📁 datasources/ # Auth data sources
│   │   │   ├── 📁 domain/         # Domain layer
│   │   │   │   ├── 📁 entities/   # Auth entities
│   │   │   │   └── 📁 usecases/   # Auth use cases
│   │   │   └── 📁 presentation/   # Presentation layer
│   │   │       ├── 📁 bloc/       # Auth BLoC
│   │   │       ├── 📁 screens/    # Auth screens
│   │   │       └── 📁 widgets/    # Auth widgets
│   │   ├── 📁 dashboard/          # Dashboard feature
│   │   ├── 📁 products/           # Products feature
│   │   ├── 📁 codes/              # Code generation feature
│   │   ├── 📁 inventory/          # Inventory management
│   │   ├── 📁 reports/            # Reports feature
│   │   ├── 📁 settings/           # Settings feature
│   │   ├── 📁 nexa_admin/         # Super admin panel
│   │   │   ├── 📁 data/           # Admin data layer
│   │   │   ├── 📁 domain/         # Admin domain layer
│   │   │   └── 📁 presentation/   # Admin presentation layer
│   │   ├── 📁 driver_delivery/    # Driver delivery system (NEW)
│   │   ├── 📁 courier_integration/ # Courier integration (NEW)
│   │   └── 📁 transport_marketplace/ # Transport marketplace (NEW)
│   ├── 📁 rust_module/            # Rust FFI integration
│   │   ├── ffi_config.dart        # FFI configuration
│   │   ├── rust_bridge.dart       # Generated bridge
│   │   └── rust_service.dart      # Rust service wrapper
│   └── main.dart                  # Application entry point
├── 📁 rust/                       # Rust algorithms module
│   ├── 📁 src/                    # Rust source code
│   │   ├── lib.rs                 # Main library file
│   │   ├── code_generation.rs     # Code generation algorithms
│   │   ├── validation.rs          # Validation algorithms
│   │   └── cryptography.rs        # Cryptographic operations
│   ├── Cargo.toml                 # Rust dependencies
│   └── build.rs                   # Build script
├── 📁 database/                   # Database deployment
│   ├── deploy.ps1                 # PowerShell deployment script
│   ├── schema.sql                 # Database schema
│   ├── sample_data.sql            # Sample data
│   └── backup.ps1                 # Backup script
├── 📁 backend/                    # Laravel backend template
│   ├── 📁 app/                    # Application code
│   │   ├── 📁 Http/               # HTTP layer
│   │   │   ├── 📁 Controllers/    # Controllers
│   │   │   ├── 📁 Middleware/     # Middleware
│   │   │   └── 📁 Requests/       # Form requests
│   │   ├── 📁 Models/             # Eloquent models
│   │   ├── 📁 Services/           # Business services
│   │   ├── 📁 Repositories/       # Data repositories
│   │   └── 📁 Exceptions/         # Custom exceptions
│   ├── 📁 database/               # Database files
│   │   ├── 📁 migrations/         # Database migrations
│   │   ├── 📁 seeders/            # Database seeders
│   │   └── 📁 factories/          # Model factories
│   ├── 📁 routes/                 # Route definitions
│   ├── .env.example               # Environment template
│   └── composer.json              # PHP dependencies
├── 📁 test/                       # Test files
│   ├── 📁 unit/                   # Unit tests
│   ├── 📁 integration/            # Integration tests
│   └── 📁 widget/                 # Widget tests
├── pubspec.yaml                   # Flutter dependencies
├── pubspec.lock                   # Locked dependencies
├── analysis_options.yaml          # Linting rules
├── PROJECT_MASTER.md              # This master documentation file
├── deploy.bat                     # Windows deployment script
└── README.md                      # Basic project readme

---
## 🧪 Testing Strategy

### Testing Pyramid

```
        UI Tests (10%)
           /\
          /  \
         /    \
        /      \
Integration Tests (20%)
        \      /
         \    /
          \  /
           \/
   Unit Tests (70%)
```

### Unit Testing

#### Flutter Unit Tests
```dart
// Test BLoC events and states
test('login success emits authenticated state', () async {
  when(mockRepository.login(any, any))
    .thenAnswer((_) async => User(id: '1', email: 'test@example.com'));
  
  authBloc.add(const AuthEvent.login(
    email: 'test@example.com',
    password: 'password123',
  ));
  
  await expectLater(
    authBloc.stream,
    emitsInOrder([
      const AuthState.loading(),
      predicate<AuthState>((state) => state is _Authenticated),
    ]),
  );
});

// Test repository methods
test('getUserById returns User on success', () async {
  final user = await repository.getUserById('1');
  expect(user.id, '1');
  expect(user.name, 'John Doe');
});

// Test utility functions
test('StringUtils.isValidEmail validates email correctly', () {
  expect(StringUtils.isValidEmail('test@example.com'), true);
  expect(StringUtils.isValidEmail('invalid-email'), false);
});
```

#### Rust Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_generate_code() {
        let code = generate_code("FAC", 123);
        assert_eq!(code, "FAC-00123");
    }
    
    #[test]
    fn test_validate_code() {
        assert!(validate_code("FAC-00123"));
        assert!(!validate_code("INVALID"));
    }
}
```

### Integration Testing

#### API Integration Tests
```dart
// Test API endpoints
test('POST /auth/login returns token', () async {
  final response = await Dio().post(
    '${ApiConfig.baseUrl}/auth/login',
    data: {
      'email': 'test@example.com',
      'password': 'password123',
    },
  );
  
  expect(response.statusCode, 200);
  expect(response.data['success'], true);
  expect(response.data['data']['token'], isNotNull);
});

// Test database integration
test('User creation persists to database', () async {
  final user = User(name: 'Test', email: 'test@example.com');
  await user.save();
  
  final savedUser = await User.find(user.id);
  expect(savedUser.name, 'Test');
});
```

#### Widget Integration Tests
```dart
testWidgets('Login screen shows error on invalid credentials', (tester) async {
  // Build widget
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => AuthBloc(MockAuthRepository()),
        child: const LoginScreen(),
      ),
    ),
  );
  
  // Enter invalid credentials
  await tester.enterText(find.byType(TextField).first, 'invalid@email.com');
  await tester.enterText(find.byType(TextField).last, 'wrongpassword');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Verify error message
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

### End-to-End Testing

#### Flutter Driver Tests
```dart
void main() {
  group('Authentication Flow', () {
    late FlutterDriver driver;
    
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    
    tearDownAll(() async {
      driver.close();
    });
    
    test('Complete login flow', () async {
      // Navigate to login
      await driver.tap(find.byValueKey('login_button'));
      
      // Enter credentials
      await driver.enterText(find.byValueKey('email_field'), 'test@example.com');
      await driver.enterText(find.byValueKey('password_field'), 'password123');
      
      // Submit
      await driver.tap(find.byValueKey('submit_button'));
      
      // Verify dashboard appears
      await driver.waitFor(find.byValueKey('dashboard'));
    });
  });
}
```

### Test Data Management

#### Factory Pattern
```dart
// User factory
class UserFactory {
  static User create({
    String? id,
    String? name,
    String? email,
  }) {
    return User(
      id: id ?? 'user_${Uuid().v4()}',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
    );
  }
}

// Usage in tests
final user = UserFactory.create(name: 'John Doe');
```

#### Mock Services
```dart
// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    return UserFactory.create(email: email);
  }
}

// Mock API client
class MockApiClient extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return Response(
      data: {'id': '1', 'name': 'Test'} as T,
      statusCode: 200,
    );
  }
}
```

### Test Coverage

#### Coverage Requirements
- **Unit Tests**: 80% minimum coverage
- **Integration Tests**: Critical paths covered
- **E2E Tests**: Main user journeys covered

#### Coverage Reporting
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Check coverage
flutter test --coverage --test-randomize-ordering-seed=random
```

### Performance Testing

#### Load Testing
```bash
# API load testing with k6
k6 run --vus 100 --duration 30s api_load_test.js

# Database load testing
pgbench -c 100 -j 2 -T 300 nexasystem_db
```

#### Memory Testing
```dart
// Memory leak detection
testWidgets('No memory leaks in product list', (tester) async {
  await tester.pumpWidget(const ProductListScreen());
  
  // Navigate away and back
  await tester.tap(find.byKey(const ValueKey('back_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('products_tab')));
  await tester.pumpAndSettle();
  
  // Verify no memory leaks
  expect(find.byType(ProductListScreen), findsOneWidget);
});
```

### Security Testing

#### Authentication Tests
```dart
test('JWT token validation', () async {
  final token = await authRepository.login('test@example.com', 'password123');
  final isValid = JwtDecoder.isValid(token);
  expect(isValid, true);
});

test('Password hashing', () async {
  final password = 'secret123';
  final hash = await
## 🔄 Development Workflow

### Development Environment Setup

#### 1. Clone and Initialize
```bash
# Clone repository
git clone <repository-url> NexaTrace_System
cd NexaTrace_System

# Install Flutter dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Install Rust dependencies
cd rust
cargo fetch
```

#### 2. Database Setup
```powershell
# Run database deployment
cd database
.\deploy.ps1 -AdminPassword "awan1972"
```

#### 3. Start Development Servers
```bash
# Terminal 1: Laravel backend
cd backend
composer install
php artisan serve --port=8090 --host=0.0.0.0

# Terminal 2: Flutter frontend
cd ..
flutter run -d chrome
```

### Development Process

#### 1. Feature Development Workflow
```
1. Create feature branch: git checkout -b feat/new-feature
2. Implement feature following Clean Architecture
3. Write tests for new functionality
4. Run tests: flutter test && cargo test
5. Generate code: flutter pub run build_runner build
6. Commit with conventional commit message
7. Create pull request for review
```

#### 2. Code Generation Commands
```bash
# Generate Freezed classes
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch

# Generate Rust bindings
cd rust
cargo build --features flutter
```

#### 3. Testing Workflow
```bash
# Run all tests
flutter test
cd rust && cargo test

# Run specific test file
flutter test test/unit/auth_repository_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Git Workflow

#### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `release/*`: Release preparation

#### Pull Request Process
1. **Create PR** from feature branch to `develop`
2. **Code Review**: At least 2 approvals required
3. **CI/CD**: All tests must pass
4. **Merge**: Squash and merge with conventional commit
5. **Delete Branch**: After successful merge

### CI/CD Pipeline

#### GitHub Actions Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: cd rust && cargo test
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - run: flutter build web --release
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - run: ./deploy.sh production
```

### Code Review Checklist

#### General
- [ ] Code follows project standards
- [ ] No commented-out code
- [ ] Proper error handling
- [ ] Logging for important operations
- [ ] Security considerations addressed

#### Flutter Specific
- [ ] BLoC pattern followed correctly
- [ ] States are immutable (Freezed)
- [ ] Proper widget lifecycle management
- [ ] Responsive design considerations
- [ ] Accessibility support

#### Backend Specific
- [ ] Input validation implemented
- [ ] Proper exception handling
- [ ] Database queries optimized
- [ ] API response format consistent
- [ ] Authentication/authorization checks

### Performance Optimization

#### Frontend Optimization
```dart
// Use const constructors
const MyWidget();

// Use keys for list items
ListView.builder(
  itemBuilder: (context, index) => MyItem(key: ValueKey(index)),
);

// Implement lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// Use Selector for state updates
Selector<MyBloc, MyState>(
  selector: (_, bloc) => bloc.state.specificValue,
  builder: (context, value, child) => Text(value),
);
```

#### Backend Optimization
```php
// Use eager loading
User::with('orders.items')->get();

// Implement caching
Cache::remember('users.active', 3600, function () {
    return User::where('status', 'active')->get();
});

// Use database indexes
Schema::table('users', function (Blueprint $table) {
    $table->index(['status', 'created_at']);
});
```

### Monitoring and Debugging

#### Development Tools
- **Flutter DevTools**: For widget inspection, performance profiling
- **Postman**: API testing and documentation
- **pgAdmin**: PostgreSQL database management
- **Redis CLI**: Redis cache inspection

#### Logging Strategy
```dart
// Structured logging
logger.i('User login', {
  'userId': user.id,
  'timestamp': DateTime.now().toIso8601String(),
  'device': deviceInfo,
});

// Error logging with context
try {
  await repository.getData();
} catch (e, stack) {
  logger.e('Failed to fetch data', error: e, stackTrace: stack);
  // Report to error tracking service
  Sentry.captureException(e, stackTrace: stack);
}
```

#### Performance Monitoring
```bash
# Flutter performance overlay
flutter run --profile

# Memory profiling
flutter run --observatory-port=8080

# Database query logging
# In Laravel .env: DB_LOG_QUERIES=true
```

## 🔐 Security Considerations

### Authentication & Authorization

#### JWT Implementation
```dart
// Secure JWT storage
class AuthService {
  final FlutterSecureStorage _secureStorage;
  
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }
  
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
}

// Token refresh mechanism
Future<String> refreshToken(String refreshToken) async {
  final response = await _dio.post(
    '/auth/refresh',
    data: {'refresh_token': refreshToken},
  );
  return response.data['access_token'];
}
```

#### Role-Based Access Control (RBAC)
```php
// Laravel middleware
class CheckRole
{
    public function handle($request, Closure $next, ...$roles)
    {
        $user = $request->user();
        
        if (!$user || !in_array($user->role, $roles)) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access',
            ], 403);
        }
        
        return $next($request);
    }
}

// Route protection
Route::middleware(['auth:api', 'role:admin,superadmin'])
     ->group(function () {
         // Admin-only routes
     });
```

### Data Protection

#### Encryption at Rest
```php
// Encrypt sensitive data
class User extends Model
{
    protected $encrypted = [
        'ssn',
        'bank_account',
        'medical_records',
    ];
    
    public function setAttribute($key, $value)
    {
        if (in_array($key, $this->encrypted)) {
            $value = encrypt($value);
        }
        
        parent::setAttribute($key, $value);
    }
}
```

#### Secure File Uploads
```dart
// File validation
Future<void> uploadFile(File file) async {
  // Check file size (max 10MB)
  if (file.lengthSync() > 10 * 1024 * 1024) {
    throw ValidationException('File too large');
  }
  
  // Check file type
  final allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
  final mimeType = lookupMimeType(file.path);
  
  if (!allowedTypes.contains(mimeType)) {
    throw ValidationException('Invalid file type');
  }
  
  // Scan for malware (server-side)
  await _apiClient.uploadFile(file);
}
```

### Network Security

#### HTTPS Enforcement
```nginx
# Nginx configuration
server {
    listen 80;
    server_name nexatrace.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexatrace.com;
    
    ssl_certificate /etc/ssl/certs/nexatrace.crt;
    ssl_certificate_key /etc/ssl/private/nexatrace.key;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

#### API Rate Limiting
```php
// Laravel rate limiting
Route::middleware(['throttle:60,1']) // 60 requests per minute
     ->group(function () {
         Route::post('/auth/login', [AuthController::class, 'login']);
     });

// Custom rate limiting by IP
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(100)->by($request->ip());
});
```

### Database Security

#### SQL Injection Prevention
```php
// Use parameterized queries
$users = DB::select(
    'SELECT * FROM users WHERE email = ? AND status = ?',
    [$email, 'active']
);

// Use Eloquent ORM (automatically parameterized)
$users = User::where('email', $email)
             ->where('status', 'active')
             ->get();
```

#### Row-Level Security
```sql
-- PostgreSQL RLS policies
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY company_isolation ON companies
    USING (id IN (
        SELECT company_id FROM company_users 
        WHERE user_id = current_user_id()
    ));

-- Multi-tenant data isolation
CREATE FUNCTION current_company_id() RETURNS UUID AS $$
BEGIN
    RETURN current_setting('app.current_company_id')::UUID;
END;
$$ LANGUAGE plpgsql;
```

### Application Security

#### Input Validation
```dart
// Form validation with Formz
class Email extends FormzInput<String, String> {
  const Email.pure() : super.pure('');
  const Email.dirty([String value = '']) : super.dirty(value);
  
  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }
}

// Usage in BLoC
final email = Email.dirty(event.email);
if (!email.valid) {
  emit(state.copyWith(emailError: email.error));
  return;
}
```

#### XSS Prevention
```dart
// Sanitize user input
String sanitizeHtml(String input) {
  return input
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');
}

// Safe HTML rendering
Html(
  data: sanitizedContent,
  style: {
    'body': Style(margin: EdgeInsets.zero),
  },
);
```

### Security Monitoring

#### Audit Logging
```php
// Comprehensive audit trail
class AuditLogger
{
    public static function log(
        string $action,
        ?Model $model = null,
        array $changes = []
    ) {
        AuditLog::create([
            'user_id' => auth()->id(),
            'action' => $action,
            'model_type' => $model ? get_class($model) : null,
            'model_id' => $model?->id,
            'changes' => json_encode($changes),
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}
```

#### Security Incident Response
```php
// Incident reporting
class SecurityIncident
{
    public static function report(
        string $type,
        string $description,
        array $context = []
    ) {
        // Log to security database
        SecurityLog::create([
            'type' => $type,
            'description' => $description,
            'context' => json_encode($context),
            'severity' => self::determineSeverity($type),
        ]);
        
        // Notify security team
        if (self::requiresImmediateAttention($type)) {
            Notification::route('slack', config('security.slack_channel'))
                       ->notify(new SecurityAlert($type, $description));
        }
    }
}
```

### Regular Security Practices

#### Security Scanning
```bash
# Dependency vulnerability scanning
npm audit
composer audit
cargo audit

# Code security scanning
bandit -r .  # Python
gosec ./...  # Go
dart analyze --fatal-infos

# Container security scanning
trivy image nexatrace/app:latest
```

#### Penetration Testing
- **Frequency**: Quarterly penetration tests
- **Scope**: Full application stack
- **Tools**: OWASP ZAP, Burp Suite, Nmap
- **Reporting**: Detailed vulnerability reports with remediation plans

#### Security Training
- **Developers**: Secure coding practices, OWASP Top 10
- **Admins**: Security configuration, incident response
- **Users**: Phishing awareness, password hygiene
---

## 🔗 Cross-Cutting Architectural Concerns (12A-12O)

This section documents all 15 cross-cutting concerns that span across multiple modules and require consistent implementation throughout the platform.

### Implementation Priority Matrix

| Priority | Concerns | Phase |
|----------|----------|-------|
| **CRITICAL** | 12A, 12B, 12C, 12D | Before MVP |
| **HIGH** | 12E, 12F, 12G, 12H, 12I, 12J, 12K, 12L, 12M, 12N | MVP Phase 1 |
| **MEDIUM** | 12O | Phase 2 |

### 🔴 CRITICAL PRIORITY (Before MVP)

#### 12A. Payment & Wallet Architecture
**Status**: ⚠️ Partially Implemented
- Wallet State Machine: Pending → Settled → Cleared
- Double-Entry Bookkeeping for all transactions
- Weekly reconciliation with payment gateway
- PCI-DSS Compliance for secure payment handling
- Multi-Gateway Support with fallback
- 2-Factor Confirmation for amounts > ₹10K

#### 12B. Authentication & Multi-Tenancy
**Status**: ✅ Mostly Implemented
- Row-Level Security at database level ✅
- Field Encryption (AES-256) ⚠️
- JWT Rotation every 8 hours ✅
- Device Fingerprinting with SMS OTP ⚠️
- Rate Limiting (5 attempts/15 min) ✅
- Session Termination on password change ✅

#### 12C. Escrow & Dispute Resolution
**Status**: ❌ Not Implemented
- Escrow Lifecycle: On-Hold → Buyer-Confirms (24h) → Release
- 3-Way Verification for high-value transactions
- Auto-Release after 7 days
- Partial Refunds support
- Mediation for disputes > ₹50K

#### 12D. Audit & Compliance Logging
**Status**: ⚠️ Partially Implemented
- Action Logging (actor, entity, old/new value, timestamp, IP) ✅
- Immutable Append-Only Log ⚠️
- 7-Year Minimum Retention ❌
- Monthly Signed Exports ❌
- Full-Text Search ✅
- SIEM Integration ❌

### 🟠 HIGH PRIORITY (MVP Phase 1)

**12E. Data Validation & Consistency**: Frontend/backend validation, DB constraints, integration tests
**12F. Offline Sync & Conflict Resolution**: Last-write-wins, server timestamp truth, CRDTs, soft-delete
**12G. Scalability & Performance**: Cursor pagination, Redis caching, DB indexes, async processing
**12H. Security & Encryption**: TLS 1.3+, cert pinning, API key rotation, bcrypt hashing
**12I. Data Retention & GDPR**: Retention policies, GDPR export, right to delete
**12J. Fraud & Anti-Counterfeiting**: ML fraud detection, behavioral biometrics, whistleblower program
**12K. Notification Architecture**: Multi-channel delivery, opt-out preferences, retry logic
**12L. Analytics & Reporting**: BI integration, predefined/custom reports, export formats
**12M. Batch Operations**: Chunked processing, progress tracking, idempotency
**12N. Mobile Network Resilience**: Protobuf protocol, exponential backoff, selective sync

### 🟡 MEDIUM PRIORITY (Phase 2)

#### 12O. Regulatory Compliance by Region
| Region | Regulations |
|--------|-------------|
| **India** | GST invoicing, FSSAI for food |
| **EU** | GDPR, ePrivacy Directive |
| **US Medical** | HIPAA, FDA compliance |
| **Global** | Region-specific feature toggles |

---

## Cross-Cutting Architectural Concerns (12A-12O)

These concerns span all modules and must be addressed systematically across the platform.

### Critical Priority (Before MVP)

**12A - Payment & Wallet Architecture**: Define wallet state machine (Pending → Settled → Cleared). Double-entry bookkeeping. Weekly reconciliation with payment gateway. PCI-DSS compliance. Multi-gateway support. 2FA for amounts > ₹10K.

**12B - Authentication & Multi-Tenancy**: Row-Level Security at database. AES-256 encryption for sensitive fields. JWT rotation every 8 hours. Device fingerprinting with SMS OTP. Rate limiting (5 attempts/15 min). Session termination on password change.

**12C - Escrow & Dispute Resolution**: Escrow lifecycle: On-Hold → Buyer-Confirms-Receipt (24h) → Release or Dispute (7-day freeze). 3-way verification for high-value transactions. Auto-release after 7 days. Partial refunds. Mediation for disputes > ₹50K.

**12D - Audit & Compliance Logging**: Log every action with actor, entity, old/new value, timestamp, IP, device fingerprint. Immutable append-only log. 7-year retention. Monthly signed exports. Full-text search. SIEM integration.

### High Priority (MVP Phase 1)

**12E - Data Validation & Consistency**: Validate at frontend and backend. Database constraints (NOT NULL, UNIQUE, CHECK, FK). Integration tests per workflow. Checksums on critical data (CRC32).

**12F - Offline Sync & Conflict Resolution**: Last-write-wins for non-critical data. Server timestamp as source of truth for codes. CRDTs for non-losable operations. Sync changelog. Visual diff UI. Soft-delete for offline deletions.

**12G - Scalability & Performance**: Cursor-based pagination (default 25, max 100). Redis caching (TTL 1h). Database indexes on FKs and date ranges. Async processing via job queue. CDN for static assets.

**12H - Security & Encryption**: TLS 1.3+ for all APIs. SSL certificate pinning in Flutter. API key rotation every 90 days. Secrets management (Vault/AWS). PII encryption at rest. bcrypt (min 12 rounds). Annual OWASP audits.

**12I - Data Retention & GDPR Compliance**: Retention policy per data type. GDPR export (ZIP/JSON within 30 days). Right to Delete with legal exceptions. Cookie consent. Annual Privacy Policy updates.

**12J - Fraud & Anti-Counterfeiting**: ML-based fraud detection with score (0-100). Behavioral biometrics. Batch-level counterfeit aggregation. Whistleblower program. Authority collaboration.

**12K - Notification Architecture**: Multi-channel (in-app, email, SMS, push, WhatsApp). User opt-out per type. Exponential backoff retry. Dead-letter queue. A/B testing.

**12L - Analytics & Reporting**: BI integration (Metabase/Superset). Predefined + custom reports. PDF/CSV/JSON export. Scheduled reports. Predictive analytics.

**12M - Batch Operations & Async Processing**: Chunked processing (1000-item chunks). Progress tracking API. Idempotency. Webhook on completion. DLQ for failures.

**12N - Mobile Network Resilience**: Protobuf for low bandwidth. Service Worker for web offline. Exponential backoff retries. Request debouncing (500ms). Selective sync.

### Medium Priority (Phase 2)

**12O - Regulatory Compliance by Region**: India: GST, FSSAI. EU: GDPR, ePrivacy. Medical: HIPAA, FDA. Feature toggles per region.

---

## 🛠️ Support & Maintenance

### Support Channels

#### Tier 1: User Support
- **Email**: support@nexatrace.com
- **Chat**: In-app chat support
- **Phone**: Business hours support
- **Knowledge Base**: Self-service documentation

#### Tier 2: Technical Support
- **Email**: techsupport@nexatrace.com
- **Slack**: Dedicated support channel
- **Escalation**: 24/7 for critical issues

#### Tier 3: Engineering Support
- **On-call Rotation**: Engineering team rotation
- **SLA**: 1-hour response for critical issues
- **Root Cause Analysis**: Post-incident reviews

### Maintenance Schedule

#### Daily Maintenance
```bash
# Database backups
pg_dump -U postgres nexasystem_db > backup_$(date +%Y%m%d).sql

# Log rotation
logrotate /etc/logrotate.d/nexatrace

# Health checks (Production)
curl -f http://135.181.46.27/api/health

# Health checks (Development)
curl -f http://localhost:8090/api/health
```

#### Weekly Maintenance
```bash
# Database optimization
psql -U postgres -c "VACUUM ANALYZE;"

# Cache cleanup
redis-cli FLUSHALL

# Log analysis
analyze_logs.sh
```

#### Monthly Maintenance
- **Security updates**: Apply patches and updates
- **Performance review**: Analyze metrics and optimize
- **Backup testing**: Restore from backups to verify
- **Capacity planning**: Review usage trends

### Monitoring & Alerting

#### System Monitoring
```yaml
# Prometheus metrics
- job_name: 'nexatrace'
  static_configs:
    - targets: ['localhost:9090']
  
# Key metrics to monitor
metrics:
  - api_response_time
  - database_connections
  - memory_usage
  - disk_space
  - error_rate
```

#### Alerting Rules
```yaml
# Alert on high error rate
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
    description: "Error rate is {{ $value }}%"

# Alert on database issues
- alert: DatabaseSlowQueries
  expr: pg_stat_database_xact_commit{datname="nexasystem_db"} < 10
  for: 10m
  labels:
    severity: warning
```

### Backup & Disaster Recovery

#### Backup Strategy
```bash
# Full database backup (daily)
pg_dump -U postgres -Fc nexasystem_db > full_backup.dump

# Incremental backup (hourly)
pg_basebackup -D /backups/incremental -U postgres

# File storage backup
aws s3 sync /var/www/nexatrace/storage s3://nexatrace-backups/storage
```

#### Recovery Procedures
```bash
# Database recovery
pg_restore -U postgres -d nexasystem_db full_backup.dump

# Application recovery
git pull origin main
composer install
php artisan migrate
php artisan cache:clear

# Full system recovery
./deploy.sh --restore-from-backup backup_20240115.tar.gz
```

#### Disaster Recovery Plan
1. **Identification**: Detect disaster scenario
2. **Notification**: Alert recovery team
3. **Assessment**: Determine recovery strategy
4. **Recovery**: Execute recovery procedures
5. **Validation**: Verify system functionality
6. **Documentation**: Record incident and recovery

### Performance Optimization

#### Database Optimization
```sql
-- Regular maintenance queries
ANALYZE;
REINDEX TABLE large_table;
VACUUM FULL verbose_table;

-- Query optimization
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Index optimization
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

#### Application Optimization
```dart
// Flutter performance optimization
// Use const constructors
const MyWidget();

// Implement lazy loading
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListItem(index),
);

// Optimize image loading
Image.network(
  url,
  fit: BoxFit.cover,
  cacheWidth: 300,
  cacheHeight: 300,
);
```

### Scaling Strategy

#### Vertical Scaling
- **Database**: Upgrade PostgreSQL instance (CPU, RAM, storage)
- **Backend**: Increase Laravel server resources
- **Cache**: Scale Redis memory and connections

#### Horizontal Scaling
```yaml
# Load balancer configuration
upstream backend {
    server backend1.nexatrace.com;
    server backend2.nexatrace.com;
    server backend3.nexatrace.com;
}

# Database replication
primary: postgres-primary
replicas:
  - postgres-replica-1
  - postgres-replica-2
```

#### Microservices Architecture (Future)
```
Current: Monolithic Laravel + Flutter
Future:
  - Auth Service
  - Product Service
  - Code Generation Service
  - Delivery Service
  - Payment Service
```

### Documentation Maintenance

#### Living Documentation
- **API Documentation**: Auto-generated from OpenAPI/Swagger
- **Database Documentation**: ER diagrams updated with schema changes
- **Deployment Documentation**: Updated with infrastructure changes
- **User Guides**: Updated with feature releases

#### Documentation Review Cycle
- **Weekly**: Review and update technical documentation
- **Monthly**: Update user-facing documentation
- **Quarterly**: Comprehensive documentation audit

### Change Management

#### Release Process
```
1. Development → Feature branches
2. Testing → Staging environment
3. Review → Code review and QA
4. Deployment → Production rollout
5. Monitoring → Post-deployment monitoring
6. Feedback → User feedback collection
```

#### Rollback Procedures
```bash
# Database rollback
php artisan migrate:rollback --step=1

# Code rollback
git revert <commit-hash>

# Configuration rollback
cp config.backup.php config.php
```

---
## 🎯 Conclusion

### Project Status Summary

#### Implementation Progress: ~25% Complete

This section provides a comprehensive view of all features organized by implementation status.

##### ✅ IMPLEMENTED FEATURES

| Module | Feature ID | Feature Name | Description |
|--------|------------|--------------|-------------|
| **Super Admin** | 1A | Dashboard | Command Center with overview, quick actions, graphics, and data display |
| **Super Admin** | 1B | Subscription Plans | Complete 5-tier subscription system with feature matrix |
| **Super Admin** | 1C | Companies Management | Company CRUD, subscription assignment, user management |
| **Factory** | 3B-3I | Code Management | Bundle/Carton/Packet/Unit code generation, publishing workflow |
| **Factory** | 3AE | Factory Billing Dashboard | Owed balance, invoices, usage summary display |
| **Factory** | 3AF | Pay-per-Publish Billing | Auto-invoice creation on code publish |
| **Factory** | 3AG | Download Lock | CSV/PDF download blocked until invoice payment |
| **Factory** | 3AH | Payment History Ledger | Payment history + invoice PDF download |
| **Auth** | - | Authentication | JWT-based login, multi-tenant support, role management |

##### ⚠️ PARTIALLY IMPLEMENTED FEATURES

| Module | Feature ID | Feature Name | Status | Remaining Work |
|--------|------------|--------------|--------|----------------|
| **Super Admin** | 1D | Earnings & Employees | Partial | Complete earnings dashboard, employee management |
| **Transport** | - | Transport Framework | Partial | Wallet models exist, need full integration |
| **Wallet** | - | Wallet System | Partial | Basic models implemented, need full workflow |

##### ⚠️ PLANNED FEATURES (NOT YET IMPLEMENTED)

**Super Admin Panel (1E-1P):**
| ID | Feature | Priority |
|----|---------|----------|
| 1E | Audit Logs | Critical |
| 1F | Notification Engine | High |
| 1G | Integration Hub | High |
| 1H | Dispute Resolution Center | High |
| 1I | Subscription Limit Enforcement | Critical |
| 1J | Financial Reconciliation | Critical |
| 1K | Sub-Admin Permission Matrix | High |
| 1L | Backup & Data Retention | High |
| 1M | Fraud Detection Dashboard | High |
| 1N | Rate Limiting & API Quota | High |
| 1O | Announcement & Maintenance | Medium |
| 1P | Custom Workflow Builder | Medium |

**Sub-Admin Panels (2B-2E):**
| ID | Feature | Priority |
|----|---------|----------|
| 2B | Role Definition & Scope | High |
| 2C | Scoped Dashboard | High |
| 2D | Delegated Report Generator | Medium |
| 2E | Escalation & Handoff | Medium |

**Factory Panel (3L-3AD):**
| ID | Feature | Priority |
|----|---------|----------|
| 3L-3N | Product Management | Critical |
| 3O | Factory Driver Management | High |
| 3P-3S | Storekeeper/Reseller Linking | High |
| 3T | Anti-Counterfeit Analytics | High |
| 3U-3AD | Advanced Factory Features | Medium |

**Driver App (4T-4AC):**
| ID | Feature | Priority |
|----|---------|----------|
| 4T-4AC | Enhanced Driver Features | High |

**Storekeeper App (5S-5AB):**
| ID | Feature | Priority |
|----|---------|----------|
| 5S-5AB | Enhanced Storekeeper Features | Medium |

**Reseller App (6O-6S):**
| ID | Feature | Priority |
|----|---------|----------|
| 6O-6S | Enhanced Reseller Features | Medium |

**Shopkeeper App (7N-7R):**
| ID | Feature | Priority |
|----|---------|----------|
| 7N-7R | Enhanced Shopkeeper Features | Medium |

**Customer App (8N-8U):**
| ID | Feature | Priority |
|----|---------|----------|
| 8N-8U | Enhanced Customer Features | Medium |

**Goods Company Panel (9O-9U):**
| ID | Feature | Priority |
|----|---------|----------|
| 9O-9U | Enhanced Goods Company Features | High |

**Truck Owner App (10M-10S):**
| ID | Feature | Priority |
|----|---------|----------|
| 10M-10S | Enhanced Truck Owner Features | High |

**Truck Driver App (11J-11R):**
| ID | Feature | Priority |
|----|---------|----------|
| 11J-11R | Enhanced Truck Driver Features | High |

**Cross-Cutting Concerns (12A-12O):**
| ID | Feature | Priority |
|----|---------|----------|
| 12A | Payment & Wallet Architecture | Critical |
| 12B | Authentication & Multi-Tenancy | Critical |
| 12C | Escrow & Dispute Resolution | Critical |
| 12D | Audit & Compliance Logging | Critical |
| 12E-12N | Other Cross-Cutting Concerns | High |
| 12O | Regulatory Compliance by Region | Medium |

#### 🚀 New Features to Implement
1. **Driver Delivery System**: Real-time delivery tracking with GPS integration
2. **Courier Integration**: TCS, Leopards, and other courier service integration
3. **Transport Marketplace**: B2B truck booking and logistics marketplace

#### 🏗️ Architecture & Technology
- **Frontend**: Flutter 3.0+ with BLoC state management
- **Backend**: Laravel 10+ REST API with PostgreSQL
- **Database**: PostgreSQL 13+ with multi-tenant architecture
- **Performance**: Rust module for high-performance algorithms
- **Deployment**: Docker-based deployment with CI/CD pipeline

### Success Metrics

#### Technical Metrics
- **Uptime**: 99.9% availability target
- **Performance**: < 2s page load, < 100ms API response
- **Scalability**: Support 10,000+ concurrent users
- **Security**: Zero critical vulnerabilities

#### Business Metrics
- **User Adoption**: 80% of invited companies active
- **Revenue Growth**: 20% month-over-month growth target
- **Customer Satisfaction**: 4.5+ average rating
- **Retention Rate**: 90% monthly retention target

### Future Roadmap

#### Phase 1: Q1 2024
- Complete Driver Delivery System implementation
- Launch courier integration with TCS
- Implement basic transport marketplace

#### Phase 2: Q2 2024
- Advanced analytics and machine learning features
- Mobile apps for iOS and Android
- International expansion support

#### Phase 3: Q3 2024
- AI-powered fraud detection
- Blockchain integration for enhanced security
- API marketplace for third-party integrations

#### Phase 4: Q4 2024
- White-label solution for enterprise clients
- Advanced supply chain optimization
- Global deployment with multi-region support

### Final Notes

This `PROJECT_MASTER.md` file serves as the single source of truth for the NexaTrace System. It consolidates all project information, architecture decisions, implementation details, and future plans into one comprehensive document.

#### Key Principles
1. **Maintainability**: Clean architecture with separation of concerns
2. **Scalability**: Designed for growth from day one
3. **Security**: Security-first approach throughout the stack
4. **User Experience**: Intuitive interfaces for all user types
5. **Business Value**: Features that directly solve customer problems

#### Usage Guidelines
- **For Developers**: Follow the coding standards and architecture patterns
- **For AI Agents**: Use this document as the definitive reference
- **For New Team Members**: Read this document to understand the entire system
- **For Stakeholders**: Refer to the roadmap and success metrics

#### Maintenance
- **Updates**: Keep this document updated with all major changes
- **Review**: Review quarterly to ensure accuracy
- **Distribution**: Share with all team members and stakeholders

---

**Last Updated**: April 2026  
**Version**: 1.1.0  
**Next Review**: July 2026  

*This document replaces all previous documentation files. All project information is now consolidated in this single master file.*
