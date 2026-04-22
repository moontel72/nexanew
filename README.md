# NexaTrace


**NexaTrace Ecosystem**
----
Flutter Dart, Flutter BloC, PostgreSQL PgAdmin, Backend Laravel also must use Shared folder for coding , 
Before PostgreSQL PgAdmin withport 5544, Backend Laravel direct run on my Computer now ,
Clean Old Files
Run this command in SSH (Use with caution):

Bash
rm -rf /var/www/nexatrace/admin-web/*
2. Reset Permissions
After uploading files, you must run these commands so Nginx can read them:

Bash
chown -R www-data:www-data /var/www/nexatrace/admin-web
chmod -R 755 /var/www/nexatrace/admin-web
3. Reload Nginx
Bash
systemctl reload nginx
URL: http://135.181.46.27

4. Delete Flutter Service Worker (Temporary)
Run in SSH:

Bash
rm -f /var/www/nexatrace/admin-web/flutter_service_worker.js
5. Local Build Commands (Windows)
PowerShell
cd C:\Ecosystem\NexaTrace_System
flutter clean
flutter pub get
flutter build web --release --no-tree-shake-icons
6. Restart API in Background
If you closed the terminal, restart the API in the background:

Bash
cd /var/www/nexatrace/admin-panel
php artisan serve --host=0.0.0.0 --port=8090 > /dev/null 2>&1 &
7. Manual API Start via SSH
Bash
ssh root@135.181.46.27
# Password: qUXXErRRghjE
cd /var/www/nexatrace/admin-panel
php artisan serve --host=0.0.0.0 --port=8090
8. Clearing Cache/Optimization
Command to enter the server:
Type this in your CMD and press Enter:

DOS
ssh root@135.181.46.27
# User: root
# Password: qUXXErRRghjE
Clear Cache:

Bash
cd /var/www/nexatrace/admin-panel
php artisan optimize:clear
9. Login Credentials
URL: http://135.181.46.27

(Note: Press Ctrl + F5 to hard refresh the browser)

Super Admin:

Email: admin@nexatrace.local

Password: admin12345

Factory Admin:

Email: factory-admin@nexatrace.local

Password: admin12345

10. Hetzner Server Details
IPv4: 135.181.46.27/32

IPv6: 2a01:4f9:c014:2997::/64

Server Name: ubuntu-16gb-hel1-2

User: root

Password: qUXXErRRghjE
--------------
**1. Super Admin Panel (Billing & Monitoring) - Under NexaTrace**

1A = Dashboard by Command Center button, Overview screen with Quick Action buttons, graphics and data display.

1B = Subscription Plans,

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

#### 2. **Basic Plan** ($49/month)+per code rate
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

#### 3. **Standard Plan** ($149/month)+per code rate
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

#### 4. **Premium Plan** ($499/month)+per code rate
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

#### 1. **Basic Goods Company Plan** ($29/month)+per truk rate
- **Truck Connections**: 20 trucks
- **Factory Connections**: 10 factories
- **Monthly Trips**: 50 trips
- **Commission Range**: 5-15%
- **Features**:
  - Live tracking enabled
  - Basic bidding system
  - Email support
  - 1,000 API calls per day

#### 2. **Professional Goods Company Plan** ($79/month)+per truk rate
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

#### 3. **Enterprise Goods Company Plan** ($199/month)+per truk rate
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

1C = After reviewing the remaining panels and apps, coding must be done in the Super Admin panel according to their requirements.

1D = Earnings, employees and other related coding.

1E = Audit Logs - A complete log system for the Super Admin that records which Super Admin or Sub-Admin changed which setting, which user was blocked, or which data was deleted.

1F = Notification Engine - A central screen from which the Super Admin can send push notifications, SMS, or email to all panels (Factory, Driver, Shop Keeper).

1G = Integration Hub - API Keys for TCS, Leopards, Zoho Sheet, etc., will be entered here once. The Super Admin will determine which Sub-Admins or factories have permission for which integrations.

1H = Dispute Resolution Center - If there is a complaint regarding a deduction from the wallet, the Super Admin can review it and make a decision.

1I = Subscription Limit Enforcement & Overage Management - Real-time monitoring of plan limits (code counts, stores, drivers, API calls). When a customer approaches 90% of monthly limits, trigger warnings. Define overage pricing for controlled excess usage. Prevent access if hard limits exceeded without prior notice.

1J = Financial Reconciliation & Revenue Reporting - Monthly automated reconciliation of subscriptions, payments, and refunds. Generate financial reports segmented by plan tier, region, and company. Validate that all transactions reconcile with payment gateway records.

1K = Sub-Admin Permission Matrix & Delegation - Define granular permissions per Super Admin function (who can manage plans, companies, billing, integrations, notifications). Allow Super Admins to delegate specific tasks to Sub-Admins with audit logging.

1L = Backup, Archive & Data Retention Policies - Define retention windows for audit logs (min. 7 years for regulated data), code scan records (3 years typical), and transaction history. Implement automated backup to secondary location. Allow customers to export their complete data via GDPR export API endpoint.

1M = Proactive Fraud Detection Dashboard - Real-time monitoring of suspicious patterns: multiple IP logins, unusual API call spikes, abnormal code generation rates, geographic impossibilities. Auto-alert Super Admin for manual review or auto-disable risky accounts.

1N = Tiered Rate Limiting & API Quota Management - Implement rate limiting per plan (Free: 100 req/min, Basic: 500, Standard: 2,000, Premium: 10,000). Track consumption in real-time. Provide API quota dashboard. Allow burst capacity for legitimate traffic spikes.

1O = Announcement & Maintenance Scheduling - Super Admin can post platform announcements (maintenance windows, feature rollouts, policy changes) visible to all logged-in users. Scheduled maintenance with countdown notifications.

1P = Custom Workflow Builder - Allow Super Admin to define conditional workflows (e.g., auto-approve orders < $10K, require manual approval for > $50K). Apply to payment approval, shipment triggering, or escalation rules.

---------

**2. Sub Admin Panels - Under NexaTrace**

2A = The features that the Super Admin allows for the Sub-Admin will be displayed in the Sub-Admin panel.

2B = Sub-Admin Role Definition & Scope Boundary - Define role types: Factory Manager, Finance Manager, Transport Manager, Support Manager. Each role inherits specific permissions from Super Admin's delegation. Role UI shows only permitted functions.

2C = Dashboard Scoped to Permissions - Sub-Admin dashboard displays only metrics relevant to their role. Finance manager sees billing/revenue; Factory manager sees code generation/product stats.

2D = Report Generator (Delegated) - Sub-Admin generates reports within their scope. Reports auto-watermarked with Sub-Admin name and generation timestamp for accountability and audit trail.

2E = Escalation & Handoff Workflow - Sub-Admin can escalate issues to Super Admin with context. Super Admin can take ownership or delegate to different Sub-Admin. All escalations tracked in audit log.

---------

**3. Factory (Companies) Panel - Under Factory**

3A = This Factory panel will function according to the subscription plan from the Super Admin panel.
3AA = Create new Product < select food/madical or Non food/maedical product> if food/medical need MFG and Expiry date and if Non food/medical in box will write total worrenty month ,, there also shown product list screen with saparete sub button on dashboard
3B = Create bundle codes, bundle code list < inside list will show all codes and relaited buttons like publish button etc>. 

3C = In the bundle code, storekeeper codes and international codes will be generated together.

3D = In the bundle code list, there will be a "Published" button. Before clicking this button, the bundle code can be edited or deleted. When the Published button is clicked, the status of the bundle code will change in the list, and then this list can be downloaded for the printing press.

3E = After a bundle code is published, it cannot be deleted.

3F = The entire process for Carton Codes and Packet Codes will be the same as (3B, 3C, 3D, and 3E).

3G - Revised Functional Requirements
The overall process for Unit Codes remains consistent with sections 3B, 3D, and 3E . However, the generation and management of Unit Codes follow these specific rules:

1. Generation without Product Selection: Unlike other codes, there is no requirement to select a product at the time of generating Unit Codes.

2. Mandatory Batch Name: While generating codes, the Batch Name is not optional; it is a mandatory field that must be filled.

3. Grouped Batch Processing: If a user specifies a quantity (eg, 5 codes ) in the generation box, all 5 codes will be generated simultaneously under that specific Batch Name.

These codes will appear on the Unit Codes List Screen grouped together under the Batch Name with their respective Serial Numbers .

Individual codes cannot be viewed or downloaded separately; they are managed strictly as a collective batch.

Post-Generation Linking & Configuration:
Before publishing, the following steps must be completed on the List Screen:

Product Linking: Each batch will have a dropdown menu next to the Batch Name. The user must select a product from this menu to link the entire batch to that specific item.

MFG & Expiry Date Management: Once a product is selected, the system will display the Default MFG and Expiry dates associated with that product.

The user can keep the default dates as they are.

Alternatively, the user can manually select new dates, which will overwrite the default dates for that specific batch.

Publishing Actions:
Clicking the Publish button triggers two simultaneous actions:

Batch Download: An option to download the entire batch together (for printing/production) will be enabled.

Subscription & Billing Calculation: If the Super Admin subscription plan includes a "Per Unit Price," the system will automatically calculate the total cost for the batch (eg, Price × 5 codes) and apply it accordingly. 
3H = Unit Codes are different from bundle, carton, and packet codes. The code for storekeepers will be similar, but Unit Codes will not have an international code. Instead, there will be an authentic/fake product code that the customer will scan using their app.

3I = Before clicking the Publish button for Unit Codes, the product must be selected. If the product is not selected, it will not be published. If it is not published, these codes cannot be downloaded.

3J = Bundle, carton, and packet codes will be independent. They will not be linked to any product before publishing. They will be linked later through the storekeeper apps.

3K = The Super Admin's subscription plan will apply when any code list is published. Any codes generated before that will not be subject to the subscription plan.

3L = Create product - i.e., product creation screen, product list screen.

3M = There are two types of products: one is Food+Medical product, which will have a manufacturing date and expiry date. The second type is Electronic, Engine Oil, etc. products. When a customer checks its authenticity, the warranty date will start from that day. That is, when creating a product, if Non-Medical + Non-Food products are selected, the factory admin will write the total number of months in a field, i.e., how many months of warranty.

3N = Update screen, delete, edit, active, inactive, blocked products, etc.

3O = Factory personal driver - create driver, driver list, update screen, delete, edit, active, inactive, blocked driver, etc. Further details are present in the Driver App number 4. The Factory Admin should have screens and functions related to whatever is in this Driver App.

3P = Any reseller or shopkeeper must be linked with the company panel via QR code or configuration form.

3Q = Maintain a record of any shop, reseller, or commission agent who works after being linked from the Factory Admin panel.

3R = Add product price for any reseller or shopkeeper. And add commission for the commission agent.

3S = Further review the Shopkeeper, Reseller, and Commission Agent apps and adapt the admin panel according to their requirements.

3T = Anti-Counterfeit Analytics - If the same authentic code is scanned repeatedly from different cities, an alert should be sent to the factory that a copy of this code has appeared in the market.

3U = Batch Code Import & Template Upload - Allow Factory to bulk import code mappings from CSV (bundle_id, carton_ids, packet_ids, unit_ids). Validate for duplicates and hierarchical integrity. Preview before confirming.

3V = Code Generation Scheduling & Reservation - Factory can schedule code generation to run at off-peak hours (e.g., nightly). Reserve monthly code quota upfront. Prevent overspend.

3W = Product Versioning & Change History - Track product attribute changes (price, expiry date, warranty period). Show active version vs. historical versions. Allow rollback to previous version. Capture who changed what and when.

3X = Re-Linking & Audit Trail for Storekeeper/Reseller - When a Storekeeper scans codes, log who linked to whom, when, and for which product batch. Allow Factory to view all active links and revoke access to specific Storekeepers.

3Y = Commission & Pricing Rule Engine - Factory defines commission tiers by Storekeeper volume (tier 1: 0-1K codes = 5%; tier 2: 1K-10K = 7%; tier 3: 10K+ = 10%). Auto-apply based on actual scans. Send commission reports monthly.

3Z = Inventory Sync & Code Depletion Warnings - Track which codes have been scanned (consumed) vs. unused. When 80% of a batch consumed, auto-alert Factory to plan reorder. Show depletion velocity (codes/day).

3AA = Multi-Language & Currency Support for Products - Allow Factory to define products in multiple languages and list prices in multiple currencies. Storekeeper app displays based on their locale.

3AB = Product Recall Management - Factory can mark product batch as recalled. System auto-notifies all linked Storekeepers, Drivers, and Customers who scanned that batch. Prevent further scanning of recalled products.

3AC = Driver Performance Analytics - Track per-driver metrics: delivery success rate, average delivery time, customer ratings, code scanning compliance (% of deliveries with proof). Highlight underperformers.

3AD = Storekeeper Shift Management & Attendance - Define Storekeeper shifts (e.g., 8 AM-5 PM). Track clock-in/out via app. Auto-disable scanning outside scheduled hours (configurable). Generate attendance reports.

3AE = Factory Billing Dashboard - Every Factory Admin must have a dedicated Billing section showing their current 'Owed Balance' to the Super Admin (NexaTrace). Displays outstanding invoices, payment due dates, credit limit status, and payment method on file.

3AF = Pay-per-Publish Billing Model - The system must calculate the cost based on the subscription tier the moment the Factory clicks 'Publish' on any code list (Bundle/Carton/Packet/Unit). An invoice is generated automatically upon publish, reflecting the tier-based rate for the number of codes published.

3AG = Download Lock (Payment Gate) - Prevent the Factory from downloading the generated code PDF/CSV until the calculated invoice for that batch is paid or cleared via their wallet/credit limit. Unpaid batches show a locked download icon with the outstanding amount displayed.

3AH = Factory Payment History & Ledger - A clear ledger for the Factory to see all past payments made to NexaTrace. Includes: invoice number, date, amount, payment method, status (paid/pending/overdue), and downloadable receipt for each transaction.

-------

**4. Drivers App - Under Factory**

4A = Will receive the product by scanning it through his app.

4B = Then, at the address where the product needs to be delivered, the option to scan the product again will appear. Until he scans it, the delivery process will not be complete.

4C = The button to scan at the delivery location will only appear when the driver is standing within 100 meters. The button will not appear before that.

4D = If the driver is standing within 100 meters at the correct delivery location, but for an unknown reason the button still does not appear, then he will contact the person to whom the product is to be delivered, send a photo of that person's location. When that person confirms from their app "Yes, this is the location", then the scan button will appear in the driver's app.

4E = In the Proof of Delivery, either take a PIN from the buyer to whom the goods are being delivered, or the second option is to take a photo of the recipient holding documents in their hand, i.e., a photo of the recipient with documents in their hand where everything on the documents is clearly visible.

4F = Address tracking via Google Maps.

4G = Earnings (Salary or Commission or Bonus or Trip Fee or all combined – whatever income there is will be displayed).

4H = Previous payment history and invoice.

4I = Which vehicle is being used? Vehicle plate number.

4J = Vehicle meter reading initially, then at the delivery location, then back to the factory. All these options are there; if the factory admin has made them mandatory, then they will be mandatory.

4K = Fuel receipt upload – optional, if mandatory by the factory, then mandatory, along with the field to write the fuel amount.

4L = Upload food receipt and write the total amount in the adjacent field – this is also optional until the factory admin makes it mandatory.

4M = Mechanic or any spare parts receipt and the total amount in the adjacent field – this is also optional until the factory admin makes it required from the panel.

4N = As long as these three (4K, 4L, and 4M) are optional, if the driver fills them, a red message will remain in his Earnings box or in the Inbox stating: "You cannot receive this amount until you inform the admin." The amount will be given after admin approval. And any receipt and amount that are added on a Required basis will automatically go to the factory's account to pay the driver.

4O = In the discretion box, the driver can select any of these three categories (Fuel Receipt, Food Receipt, Mechanic/Spare Part Receipt) or select "Other" and write a message for the admin.

4P = The driver can contact the admin panel and the client (where he has to deliver the goods) via chat and phone through the app.

4Q = Vehicle Maintenance Log - Vehicle service date, next service date, and reminder system for tire/battery replacement.

4R = Digital Signature - In Proof of Delivery, instead of just a PIN or photo, there should also be an option to take a digital signature (on the touch screen) from the recipient.

4S = Fake GPS Protection - The system should check whether the driver has installed any third-party app that changes location.

4T = Trip Lifecycle & Status Tracking - Define trip states: Assigned → Picked-Up → In-Transit → Arrived → Delivered → Completed. Show current state on home screen. Prevent backward transitions.

4U = Delivery Window & Time-Window Optimization - Customer specifies acceptable delivery window. Driver app shows remaining time and suggests optimal route to hit window. Penalize late deliveries.

4V = Real-Time Geofencing & Geolocation Verification - Use GPS + cell tower triangulation + WiFi SSID to verify true location. Reject location if inconsistent across methods. Alert if driver disabled GPS.

4W = Trip Debrief & Photo Upload - After delivery, driver uploads photos of: product at delivery location, recipient signature or face, any damage/issues. Store photos with trip ID in immutable log.

4X = Communication History & Chat Archival - All driver-admin and driver-customer chats stored with timestamps. Searchable by date/keyword. Auto-delete after 1 year unless flagged as evidence.

4Y = Driver Documents & Compliance Verification - Track driver's license expiry, vehicle insurance expiry, vehicle registration. System blocks driver from accepting trips if docs expired. Send 30-day advance notice to renew.

4Z = Offline Mode & Trip Sync - If no internet, driver can accept trips and scan codes locally. Cache trip data. Auto-sync when connection restored. Detect conflicts and resolve via server timestamp.

4AA = Performance Incentive Program - Track driver KPIs: on-time %, rating, scans/day, photo quality score. Tier drivers (Bronze, Silver, Gold). Gold drivers get preferential trip assignments and 5% bonus.

4AB = Dispute Notification & Escalation - If customer disputes delivery, driver auto-notified with evidence summary. Driver can provide counter-evidence. Dispute goes to arbiter if unresolved in 24 hrs.

4AC = Fatigue Detection & Mandatory Rest Periods - Track cumulative driving hours per day/week. If threshold exceeded (e.g., 12 hrs/day), system blocks new trip assignment and recommends rest. Log rest compliance.

////////////

**5. Store Keepers App - Under Factory**

5A = This app will only be linked to the relevant factory or company.

5B = This app will also work offline.

5C = Besides barcode or QR code, this app can also directly scan numeric codes. Example: AX34567. When the mobile camera goes over it, the system will capture the code. Just like Deliveroo riders in Italy scan product codes. In darkness, there will be a torch light button on the scanner that will turn on the mobile light only until the system captures the code, then the torch will automatically turn off.

5D = The storekeeper will first scan the bundle code.

5E = Then an option will appear: Scan Carton or Packet Code.

5F = If Carton is selected, he will scan any carton code, and that carton will be linked to this bundle.

5G = If he selects only Packet (without Carton), then that packet will be directly linked to the bundle.

5H = Then, to put Units into this packet, he will first select the product.

5I = Then, before putting units into this packet, he will select the number of units, e.g., any from 2, 4, 6, 8, 10, 12.

5J = Then, according to that number, he will scan the units of the related product one by one and keep placing them into the related packet whose packet code he scanned before the unit codes.

5K = If there is no network, there will be an option to sync later.

5L = The storekeeper will decide in which section of the store to keep the product, carton, packet, or bundle. He will create the name of this section from his app, or if the company admin has already created a section, hall, or room number, the storekeeper will select that.

5M = Then, in this selected section, hall, or room, he will scan the three-number or rack code (the code attached to the rack) and will place this product, packet, carton, or bundle on that rack.

5N = The storekeeper will receive a buyer link from the admin. He will link this bundle, carton, or packet to that buyer. When he presses the "Push" button, an alert or notification will be sent to the factory admin panel. Then it is the admin's task to take the next step: link the buyer's goods with a driver or courier service.

5O = The storekeeper's app will give an alert a short time before the work time ends or before his duty time ends, or an alert for rest time during work.

5P = The storekeeper can call or chat with the admin panel or admin's phone from his app.

5Q = Low Stock Alert - When a product (especially Units) goes below a specific threshold, the app will automatically send an alert to the admin or reseller.

5R = Batch Scanning Mode - An option to quickly scan multiple packets or units at once.

5S = Sync Conflict Resolution & Merging - If Storekeeper scans while offline and another Storekeeper scans the same code online, detect conflict. Prefer the first-scan (by timestamp). Log conflict for audit.

5T = Inventory Variance & Physical Count Reconciliation - Storekeeper initiates physical count of a section. App guides through count process. Compare physical vs. scanned count. If variance > 2%, flag for investigation.

5U = Bundle/Packet Opening Audit - When Storekeeper marks packet as Opened, log timestamp, who opened it, and initial unit count vs. withdrawn count. Prevent re-scanning Opened packets.

5V = Storekeeper Shift Completion & Handover - Storekeeper marks end-of-shift. System auto-locks further scanning for that shift. Show summary: codes scanned, inventory moved, time worked. Next Storekeeper reviews and accepts handover.

5W = Product Recall Response & Quarantine - Factory sends recall alert. Storekeeper app highlights affected batch with red warning. Storekeeper can mark batch as Quarantined. Prevent further scanning.

5X = Scanner Calibration & Quality Check - Periodic camera/barcode scanner test by scanning test codes. If success rate < 95%, prompt Storekeeper to check phone camera.

5Y = Notification Delivery Confirmation - When buyer link is pushed to Factory Admin, show Storekeeper a confirmation. If admin hasn't acknowledged in 5 mins, escalate.

5Z = Inventory Transfer Between Sections - Storekeeper can move codes from one section/rack to another. Log source section, destination, timestamp, reason. Support bulk transfers via batch mode.

5AA = Audit Trail & Activity Report - Daily report showing: codes scanned, inventory moved, times, anomalies. Exportable as PDF for store manager review.

5AB = Visual Hierarchy Map - Within the app, a Storekeeper can see a tree view of which Units are in which Packet, and which Packets are in which Carton. This visual map provides instant clarity on the full code hierarchy for any product batch.

---

**6. Reseller (Wholesaler) and Medical Companies Agent App - Under NexaTrace (Universal App)**

6A = The features of Reseller and Shopkeeper are similar; the main difference is that a reseller can have multiple personal shops. He can control the records of all shops and employees from this app.

6B = The Reseller app can also be linked with any panel or app like the other apps.

6C = Through the NexaTrace Universal App, a Shopkeeper can directly buy goods from any factory and can also sell homemade products or raw materials to any factory or shopkeeper.

6D = Can place a Bit and can also receive a Bit.

6E = Can track the delivery of his purchased or sold products, whether through his personal driver or through a goods company.

6F = (Removed - Now transferred to Integration Hub)

6G = Can create his own driver, on a salary basis or as a trip fee.

6H = List of drivers.

6I = Receive the product, carton, bundle, or packet sent by the factory or shopkeeper by scanning it to maintain the supply chain.

6J = Show income from goods purchased from factories and goods sold.

6K = (Removed - Now transferred to Integration Hub)

6L = (Removed - Now transferred to Integration Hub)

6M = To prevent fraud, Bits must be placed so that transactions do not happen directly outside. For this, there will be a wallet system in the app. That is, whenever a Bit is canceled, an amount equal to the price of a cup of tea will be deducted from the NexaTrace Wallet. It is necessary to have credit in the wallet beforehand. If someone tries to share the phone, a fraud alert will go to both apps with a warning.

6N = Bulk Order Requests - Feature to send quotations for large orders directly to the factory.

6O = Shop Performance Dashboard - Show per-shop metrics: revenue, profit margin, SKUs, inventory turnover. Highlight top/bottom performers.

6P = Tiered Pricing by Buyer Type - Reseller can define different prices for retail customers vs. wholesale buyers vs. hospital networks. App applies correct tier based on buyer profile.

6Q = Inventory Aggregation Across Shops - Reseller sees total inventory across all shops. Can transfer stock between shops via app. Supports inventory rebalancing.

6R = Returns & Refund Workflow - Buyer initiates return (reason: defective, expired, wrong item). Reseller scans returned code. System verifies against original Bit. If valid, auto-refunds to buyer wallet. Log return reason for analytics.

6S = Employee Role Management - Reseller can add employees (Shop Manager, Cashier, Stock Keeper) per shop. Define permissions per role. Track activity by employee.

---

**7. Shop Keepers App - Under NexaTrace (Universal App)**

7A = The Shopkeeper's app can also be linked with any panel or app like the other apps.

7B = Through the NexaTrace Universal App, a Shopkeeper can directly buy goods from any factory or from any reseller, wholesaler, or shopkeeper, and can also sell homemade products or raw materials to any factory or reseller.

7C = Can place a Bit and can also receive a Bit.

7D = Can track the delivery of his purchased or sold products, whether through his personal driver or through a goods company.

7E = (Removed - Now transferred to Integration Hub)

7F = Can create his own driver, on a salary basis or as a trip fee.

7G = List of drivers.

7H = Receive the product, carton, bundle, or packet sent by the factory or reseller by scanning it to maintain the supply chain.

7I = When he takes Units out of a product packet, he must scan this packet as "Open Packets". If the Shopkeeper does not do so, when the customer scans the product to check its authenticity, a message will be shown to the customer: "The packet for this product has not been opened yet. Please contact the shopkeeper, or contact the product-related company, or file a complaint."

7J = (Removed - Now transferred to Integration Hub)

7K = (Removed - Now transferred to Integration Hub)

7L = To prevent fraud, Bits must be placed so that transactions do not happen directly outside. For this, there will be a wallet system in the app. That is, whenever a Bit is canceled, an amount equal to the price of a cup of tea will be deducted from the NexaTrace Wallet. It is necessary to have credit in the wallet beforehand. If someone tries to share the phone, a fraud alert will go to both apps.

7M = Inventory Auto-Update - As soon as the shopkeeper scans and sells a unit, that item will be reduced from his inventory.

7N = Customer Loyalty Program - Shopkeeper can create loyalty programs. Customers earn points per scan. Redeem for discounts or free products. Track participation rate.

7O = Promotion & Discount Campaign - Shopkeeper can run time-limited promotions with push notifications. Track campaign effectiveness (scans, conversions).

7P = Product Recommendations via Analytics - Track which products customers scan most. Recommend high-demand items to highlight on shelves. Show trending products.

7Q = Supplier Order Management - Shopkeeper tracks inventory levels per product. One-click reorder from preferred suppliers. Track reorder time and lead time. Forecast demand.

7R = QR Code Labeling for In-Store Promotions - Shopkeeper prints promo QR codes linking to discounts, loyalty points, product videos, supplier info. Customers scan for instant coupon. Track redemptions.

---

**8. Customers App - Under NexaTrace (Universal App)**

8A = Can check the authenticity (original or fake) of any product from his app.

8B = Can link with any panel or app to place a Bit and also receive a Bit if a truck is needed for household goods.

8C = Can track any of his parcels or deliveries.

8D = Previous record.

8E = Wallet.

8F = Discount codes for future purchases, or vouchers, or points record.

8G = The customer will scan products from different companies, e.g., different pharmaceutical companies, to check authenticity through this single NexaTrace Universal App. Then the record of discounts, points, or vouchers for each company will be separate under that company's name.

8H = There will be two types of wallets: one Main Wallet as mentioned in 8E above, which will contain the customer's personal credit to pay NexaTrace. The second will be subsidiary wallets. These will contain discounts or some returned amount from different companies for future purchases, which will be in that company's subsidiary wallet so that amount can only be used for future purchases from that specific company.

8I = If a customer checks a non-food or non-medical product for authenticity, on the date he scans the code, the warranty for that product will start.

8J = The customer can directly contact the shopkeeper or the relevant company regarding any issue with the product.

8K = Warranty Claim - If a product becomes defective, the customer should have a "Claim Warranty" button directly inside the app, which will connect him to the storekeeper or factory.

8L = Product Registration - Instead of just scanning, give the customer the option to register the purchased product (especially electronics) in his account so he can track the remaining warranty period.

8M = Price Comparison - See the price of the scanned product at different shops (if data is available).

8N = Counterfeit Report & Escalation - If customer determines product is counterfeit, show Report Counterfeit button. Customer provides photos and location. Auto-notify Factory and authorities. Reward customer with wallet credit.

8O = Warranty Claim Evidence Collection - When customer initiates warranty claim, guide through photo/video capture workflow. Store in immutable log. Factory can review and approve/deny.

8P = Product Review & Rating System - Customer can rate products (1-5 stars) with optional review. Aggregated ratings at product level. Identify problematic batches with low ratings.

8Q = Expiry Date Alert & Reminder - For Food/Medical products, show expiry date on scan. Enable reminder before expiry. Show warning if product already expired.

8R = Supply Chain Transparency & Origin Traceability - Show full supply chain of scanned product: Factory → Distributor → Retailer with dates and locations.

8S = Retailer Comparison & Nearby Store Locator - When scanning product, show prices at nearby retailers with store hours, distance, and route via Google Maps.

8T = Subscription-Based Instant Rebate Program - Customers subscribe to Product-Specific Rebate Programs. When scanning subscribed product, auto-receive rebate code.

8U = Saved Products & Watchlist - Customer can save scanned products to favorites. Track prices over time. Get notified when saved product goes on sale.

---

**9. Goods Company Panel - Under Goods Companies**

9A = A Goods Company can link its admin panel with any app or panel via QR code or configuration form.

9B = If the Goods Company's admin panel is linked with the Truck Owners' app, then all the trucks of that truck owner will also be linked, which the truck owner has allowed from his app.

9C = The truck list will show the truck number plate, truck ID, truck owner's name, and truck driver's name.

9D = Place a Bit and receive a Bit after linking with any panel or app.

9E = Bit record.

9F = Earnings record.

9G = Record of who was paid or given commission.

9H = Track any truck driver.

9I = Track any delivery, i.e., a single truck contains products from different shopkeepers or companies. Track via Product ID to see which truck it is in.

9J = (Removed - Now transferred to Integration Hub)

9K = (Removed - Now transferred to Integration Hub)

9L = To prevent fraud, Bits must be placed so that transactions do not happen directly outside. For this, there will be a wallet system in the app. That is, whenever a Bit is canceled, an amount equal to the price of a cup of tea will be deducted from the NexaTrace Wallet. It is necessary to have credit in the wallet beforehand. If someone tries to share the phone, a fraud alert will go to both apps.

9M = Dynamic Route Optimization - If a single truck has goods for different cities, the system will automatically suggest the best route to minimize fuel consumption.

9N = Load Occupancy Tracker - Graphical display of how much space is left in the truck.

9O = Real-Time Dispatch & Load Assignment - Live map of all available trucks with current location and capacity. Drag-drop load assignment or auto-assign based on proximity/capacity. Driver gets instant notification.

9P = Dynamic Pricing & Surge Pricing - Enable surge pricing during peak hours. Prices shown to loaders upfront. Helps manage demand.

9Q = Delivery Quality Score & Penalty System - Track per-truck metrics: on-time %, cargo damage %, customer rating. If quality score drops below 75%, apply penalty until recovery.

9R = Load History & Repeat Customer Pricing - Track frequent loaders. Offer loyalty discount after threshold loads. Show loader preferences.

9S = Profitability Analytics Per Truck - Show per-truck profit (revenue - driver salary - fuel - maintenance). Identify trucks breaking even vs. losing money. Recommend decommissioning low-profit trucks.

9T = Integration with External Logistics Providers - If at capacity, auto-forward excess loads to partner logistics firms via API. Track external fulfillment.

9U = Compliance & Hazmat Documentation - For hazmat loads, ensure truck has hazmat certification and driver has training cert. System prevents unqualified trucks from accepting hazmat loads.

---

**10. Truck Owners App - Under Truck Owners**

10A = Each truck owner will have a personal app account.

10B = Along with a 5-digit NexaTrace ID that will be randomly created by the system.

10C = This truck owner can link his account (app) with whomever he wants to work with. That is, if he wants to work with a Goods Company, he will be linked with the Goods Company panel. If he wants to pick up goods directly from a factory, he can link with the Factory panel. If he wants to work with a truck driver, he can link with the Truck Driver App. That is, he can link with every panel and app. If there are big shopkeepers (Resellers app) who need a truck directly, or Shopkeepers, or even ordinary customers who need a truck to transfer household goods – the Truck Owner's app can link with every panel and every app. There should be an easy configuration form for linking with each other, or linking should happen by clicking on the Truck Owner's app from Google Maps.

10D = Option to place a Bit and receive a Bit.

10E = Ratings – The rating of this truck owner will be maintained with whichever app/panel he is linked.

10F = Earning History (If he owns a truck, details of income from Bits).

10G = The difference between the Truck Owner's app and the Truck Driver's app is that a truck owner can have more than one truck.

10H = Record of each truck's number plate and the driver assigned to that truck. He will ask any new truck driver: if the driver does not have the NexaTrace Truck Driver app, he must first register on the Truck Driver app, then link this driver with his own app via QR code from the Truck Driver app or through a configuration form.

10I = Can place a Bit and receive a Bit after linking with any factory or goods company panel.

10J = Can track the location of any of his trucks by linking with the Truck Driver's app.

10K = To prevent fraud, Bits must be placed so that transactions do not happen directly outside. For this, there will be a wallet system in the app. That is, whenever a Bit is canceled, an amount equal to the price of a cup of tea will be deducted from the NexaTrace Wallet. It is necessary to have credit in the wallet beforehand. If someone tries to share the phone, a fraud alert will go to both apps.

10L = Document Expiry Alert - Notification before truck registration or insurance expires.

10M = Fleet Health Monitoring & Maintenance Scheduling - Track vehicle service dates, next service due, tire condition, battery health. Maintenance reminders 30 days before due. Link to trusted mechanics.

10N = Truck Insurance & Compliance Tracking - Track insurance, pollution certificate, fitness certificate expiry. Color-code: Green (valid), Yellow (7 days), Red (expired). Block trips if expired.

10O = Fuel Efficiency Analytics - Track fuel consumption per trip (mileage, cost, cost per km). Compare against fleet average. Identify inefficient trucks. Show driver behavior impact.

10P = Driver-Truck Assignment & Availability Calendar - Assign drivers to trucks. Calendar view of availability. Auto-notify on license expiry. Support driver-truck reassignment.

10Q = GPS Tracking Dashboard for Fleet - View all trucks on map in real-time (location, speed, idle time). Historical trip logs. Geofencing alerts when truck leaves designated area.

10R = Competitive Bidding Dashboard - View all available loads from all platforms. Auto-notify on matching loads. One-click bid acceptance.

10S = Vehicle-Specific Document Upload & Expiry Reminders - Upload registration, insurance, fitness, pollution certs. System parses expiry dates. Automatic reminders 30 days before expiry.

---

**11. Truck Driver App - Under Truck Driver**

11A = Each truck driver will have a personal app account.

11B = Along with a 5-digit NexaTrace ID that will be randomly created by the system.

11C = This truck driver can link his account (app) with whomever he wants to work with. That is, if he wants to work with a Goods Company, he will be linked with the Goods Company panel. If he wants to pick up goods directly from a factory, he can link with the Factory panel. If he wants to work with a truck owner, he can link with the Truck Owners App. That is, he can link with every panel and app. If there are big shopkeepers (Resellers app) who need a truck directly, or Shopkeepers, or even ordinary customers who need a truck to transfer household goods – the Truck Driver's app can link with every panel and every app. There should be an easy configuration form for linking with each other, or linking should happen by clicking on the Truck Driver's app from Google Maps.

11D = Option to place a Bit and receive a Bit.

11E = Ratings – The rating of this truck driver will be maintained with whichever app/panel he is linked.

11F = Earning History (Salary if working with a truck owner + Commission + if he owns a truck, details of income from Bits).

11G = There will be a location tracking system. The panel or app with which the driver's app is linked will be able to track this driver's location, i.e., delivery location.

11H = To prevent fraud, Bits must be placed so that transactions do not happen directly outside. For this, there will be a wallet system in the app. That is, whenever a Bit is canceled, an amount equal to the price of a cup of tea will be deducted from the NexaTrace Wallet. It is necessary to have credit in the wallet beforehand. If someone tries to share the phone, a fraud alert will go to both apps.

11I = Night Drive Alert - If the driver has been driving continuously for several hours, he should be advised to take a rest.

11J = Trip Acceptance & Load Details - Driver sees available trips on map (distance, destination, payload, pay rate). Accepts trip and gets full details including contacts, delivery address, required documents, estimated time, pay breakdown.

11K = Pre-Trip Checklist & Vehicle Inspection - Before trip: vehicle health check (lights, mirrors, tire pressure), upload odometer reading, fuel level, cargo inspection photo. System blocks trip if any check fails.

11L = Real-Time Earnings Breakdown - Driver sees per-trip pay: base pay + distance bonus + on-time bonus - late penalty. Running total for day/week/month.

11M = Safe Routes & Danger Zone Alerts - Recommended route on Google Maps. Highlights danger zones (high-crime, flood-prone, accident hotspots). Option for longer but safer route.

11N = Emergency SOS & Breakdown Roadside Assistance - SOS button logs location, contacts roadside assistance, alerts dispatcher and nearby drivers, auto-calls emergency contact.

11O = Driver Rest & Fatigue Compliance - Track consecutive driving hours. Alert after 5 hours. Force break after 10 hours. Log break duration and location.

11P = Income Tax Estimation & GST Compliance - Calculate estimated tax liability. Show GST amount if registered. Digital receipts for expense deductions. Support GST filing export.

11Q = Skills & Certification Tracking - Track CDL expiry, hazmat cert, defensive driving training. Highlight trips requiring specific certs. Auto-notify renewal due dates.

11R = Driver Performance Leaderboard - Public leaderboard by rating, on-time %, earnings. Badges for milestones (100 trips, 4.8+ rating, zero incidents).

---

**12. Cross-Cutting Architectural Concerns**

12A = Payment & Wallet Architecture (Critical) - Define explicit wallet state machine: Pending → Settled → Cleared. Implement double-entry bookkeeping. Weekly reconciliation with payment gateway. PCI-DSS compliance. Multi-gateway support with fallback. 2-factor confirmation for amounts > ₹10K.

12B = Authentication & Multi-Tenancy (Critical) - Row-Level Security at database. Encrypt sensitive fields (AES-256). JWT rotation every 8 hours. Device fingerprinting with SMS OTP for new devices. Rate limiting on login (5 attempts/15 min). Session termination on password change.

12C = Escrow & Dispute Resolution (Critical) - Escrow lifecycle: On-Hold → Buyer-Confirms-Receipt (24 hrs grace) → Seller-Funds-Released or Dispute-Filed (7-day freeze). 3-way verification for high-value transactions. Auto-release after 7 days. Partial refunds. Mediation for disputes > ₹50K.

12D = Audit & Compliance Logging (Critical) - Log every action with actor, entity, old/new value, timestamp, IP, device fingerprint. Immutable append-only log. 7-year minimum retention. Monthly signed exports. Full-text search. SIEM integration.

12E = Data Validation & Consistency (High) - Validate at frontend and backend. Database constraints (NOT NULL, UNIQUE, CHECK, FK). Integration tests per workflow (happy path + 3 error paths). Checksums on critical data (CRC32).

12F = Offline Sync & Conflict Resolution (High) - Last-write-wins for non-critical data. Server timestamp as source of truth for codes. CRDTs for non-losable operations. Sync changelog with conflict detection. Visual diff UI. Soft-delete for offline deletions.

12G = Scalability & Performance (High) - Cursor-based pagination (default 25, max 100). Redis caching (TTL 1 hour). Database indexes on all FKs and date ranges. Async processing via job queue. CDN for static assets. Rate limiting at API gateway.

12H = Security & Encryption (High) - TLS 1.3+ for all APIs. SSL/TLS certificate pinning in Flutter. API key rotation every 90 days. Secrets management (Vault/AWS). PII encryption at rest. bcrypt passwords (min 12 rounds). Annual OWASP audits.

12I = Data Retention & GDPR Compliance (High) - Retention policy per data type. GDPR Data Export (ZIP/JSON within 30 days). Right to Delete with legal exceptions. Cookie consent. Annual Privacy Policy updates.

12J = Fraud & Anti-Counterfeiting (High) - ML-based fraud detection with fraud score (0-100). Behavioral biometrics. Report aggregation for batch-level counterfeit detection. Whistleblower program with rewards. Collaboration with authorities.

12K = Notification Architecture (High) - Multi-channel delivery (in-app, email, SMS, push, WhatsApp). User opt-out preferences per type. Retry with exponential backoff. Dead-letter queue. A/B testing for templates.

12L = Analytics & Reporting (High) - BI tool integration (Metabase or Superset). Predefined + custom reports. Export as PDF/CSV/JSON. Scheduled reports. Predictive analytics (churn prediction, demand forecast, anomaly detection).

12M = Batch Operations & Async Processing (High) - Chunked processing (1000-item chunks with checkpoints). Progress tracking API. Idempotency. Webhook notification on completion. Dead-letter queue for failed chunks.

12N = Mobile Network Resilience (High) - Binary protocol (protobuf) for low bandwidth. Service Worker for web offline. Exponential backoff retries. Request debouncing (500ms). Selective sync.

12O = Regulatory Compliance by Region (Medium) - India: GST invoicing, FSSAI for food. EU: GDPR, ePrivacy Directive. Medical: HIPAA (US), FDA compliance. Enable/disable features per region during onboarding.

---------

**Important Notes for Development:**
- **Escrow Logic**: In all Bit transactions, the amount must first be "On Hold" and released upon scanning (receipt).
- **API Centralization**: Control all third-party services from the Super Admin's "Integration Hub" to avoid repeatedly changing code.
- **RAM Management**: Since your RAM is 8GB, avoid unnecessary `emit` in BloC while writing code to reduce state memory usage.
