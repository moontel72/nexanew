# Factory Login Test Script

## Test Steps to Verify Factory Dashboard Access

### 1. Test Factory Login API
```bash
# Test factory login API endpoint
curl -X POST http://135.181.46.27/api/v1/factory/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"factory-admin@nexatrace.local","password":"admin12345"}'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "41673cdf-ad46-44fc-a699-54b8fd0e839d",
      "company_id": "a1f2c684-d4f0-4126-8860-eaa3cc3bc5b5",
      "email": "factory-admin@nexatrace.local",
      "full_name": "Factory Admin",
      "position": "admin",
      "permissions": []
    },
    "token": "xxx"
  }
}
```

### 2. Test Factory Login Page
- Navigate to: `http://135.181.46.27/factory/login`
- Verify the factory login page loads with:
  - "NexaTrace Factory" title
  - "Factory Administrator Portal" subtitle
  - Email field pre-filled with `factory-admin@nexatrace.local`
  - Password field pre-filled with `admin12345`
  - "Sign In to Factory Panel" button
  - "Super Admin Portal" button

### 3. Test Factory Login Flow
1. Click "Sign In to Factory Panel" button
2. Expected behavior:
   - Loading indicator appears
   - On success: Redirects to `/factory/dashboard`
   - On failure: Error dialog appears

### 4. Test Factory Dashboard
After successful login, verify:
- URL changes to `http://135.181.46.27/factory/dashboard`
- Dashboard loads with tabs: "Overview", "Products", "Transport"
- No error pages appear
- No "Page not found" messages

### 5. Test Error Handling
If "Page not found" appears with "Go to Login" button:
1. Click "Go to Login" button
2. Verify it goes to `/factory/login` (factory login), not `/login` (super admin login)

## Issues Fixed

### 1. Factory ID Not Set
**Problem**: `setFactoryAuthState` wasn't setting `factoryId` (company_id).
**Fix**: Updated `setFactoryAuthState` to accept and set `factoryId` parameter.

### 2. Factory Dashboard Crashes Without WalletBloc
**Problem**: Factory dashboard tried to use `WalletBloc` which wasn't provided.
**Fix**: 
- Removed `WalletBloc` dependency from factory dashboard
- Simplified dashboard to show basic factory information
- Added fallback for transport features without wallet

### 3. Error Page Goes to Wrong Login
**Problem**: Error page "Go to Login" button always went to `/login` (super admin).
**Fix**: Updated error page to go to `/factory/login` for factory routes.

### 4. Router Authentication Check
**Problem**: Router checks `isFactoryAuthenticatedCache` for factory routes.
**Fix**: `setFactoryAuthState` now properly sets `_isFactoryAuthenticatedCache = true`.

## Verification Steps

### Step 1: Clear Browser Cache
Clear browser cache and cookies to ensure fresh session.

### Step 2: Access Factory Login
1. Open `http://135.181.46.27/factory/login`
2. Verify factory login page loads

### Step 3: Login with Test Credentials
1. Email: `factory-admin@nexatrace.local`
2. Password: `admin12345`
3. Click "Sign In to Factory Panel"

### Step 4: Verify Dashboard Loads
1. Should redirect to `/factory/dashboard`
2. Should show factory dashboard with tabs
3. Should NOT show "Page not found" error

### Step 5: Test Navigation
1. Click between tabs: Overview, Products, Transport
2. Each tab should load without errors

## Expected Dashboard Content

### Overview Tab
- Factory ID display
- User ID display
- Status: Active
- Quick action buttons

### Products Tab
- Product management header
- "Add Product" button
- List of recent products

### Transport Tab (if plan allows)
- Transport features card
- Feature list based on plan limits
- Statistics display

## Troubleshooting

### If login fails:
1. Check API response with curl command above
2. Verify backend is running: `http://135.181.46.27/api/health`
3. Check browser console for JavaScript errors (F12)

### If dashboard doesn't load:
1. Check browser console for errors
2. Verify Flutter web app is built and deployed
3. Check nginx logs on server

### If wrong dashboard loads:
1. Clear browser cache and cookies
2. Verify URL is `/factory/dashboard` not `/dashboard`
3. Check router redirect logic in app

## Notes
- Factory authentication is separate from super admin authentication
- Factory users use different API endpoints (`/factory/auth/login`)
- Factory dashboard has different layout than super admin dashboard
- Transport features require plan upgrades (shown as upgrade prompt if not available)