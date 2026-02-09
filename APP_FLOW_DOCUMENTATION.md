# Skillogic App - Full Flow Documentation

## Overview
This document describes the complete flow of the Skillogic Flutter application, from app launch to user interactions.

---

## 1. App Initialization (`main.dart`)

### Entry Point
```dart
void main() async
```

**Flow:**
1. **WidgetsFlutterBinding.ensureInitialized()** - Initializes Flutter bindings
2. **Firebase.initializeApp()** - Initializes Firebase services (Analytics, Messaging)
3. **FirebaseMessaging.onBackgroundMessage** - Sets up background message handler
4. **FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)** - Enables analytics
5. **runApp(MyApp())** - Starts the Flutter app
6. **_setupFCM()** - Sets up Firebase Cloud Messaging subscription (async, after app start)

### MyApp Widget
- Sets up **MultiProvider** with various state providers:
  - `Auth` - Authentication state
  - `Categories` - Course categories
  - `Courses` - Available courses
  - `MyCourses` - User's enrolled courses
  - `Bundles` - Course bundles
  - `MyBundles` - User's bundles
  - `Languages` - Language settings
  - `CourseForum` - Forum discussions
  - `InternshipBatchProvider` - Internship batches
  - `HandbookProvider` - Handbooks

- **MaterialApp** home: `MainPage()`
- **Routes** defined for LMS screens (TabsScreen, LmsHomeScreen, CoursesScreen, etc.)

---

## 2. MainPage Flow (`lib/pages/main_page.dart`)

### Initial State
- `refreshing = true` (shows loading screen)
- `refreshed = 0` (user not logged in)
- `_selectedIndex = 0` (Home tab selected)

### InitState Sequence
1. **_doInitialization()** is called

### _doInitialization()
1. **ConnectionCheck.isAvailable()** - Checks internet connectivity
2. If connected → calls **_getConfig()**

### _getConfig()
1. **getCurrentVersion()** - Gets app version from PackageInfo
2. **getConfig(context)** - Fetches Firebase Remote Config:
   - Auth URLs
   - Base URLs
   - Candidate portal URL
   - App store URLs
   - Force update settings
   - Version information
   - Other configuration parameters
3. **saveConfigToPrefs()** - Saves config to SharedPreferences
4. **setupMessaging()** - Sets up Firebase Cloud Messaging
5. **Version Check**:
   - Compares `ios_version` from remote config with current version
   - If mismatch → shows update dialog
   - If `force_update == "true"` → makes update mandatory
6. **Firebase Token** - Gets FCM token and stores it via `storeFirebaseToken()`
7. If no update needed → calls **_proceedFurther()**

### _proceedFurther()
1. Calls **_checkLogin()**
2. Calls **getCandidateDetails()** (fetches candidate_id from API)

### _checkLogin()
1. Sets `refreshing = true` (shows loading screen)
2. **tokenLogin(context)** - Attempts login with JWT token from SharedPreferences
   - If token exists → validates with API
   - Returns `1` if successful, `0` if failed, `3` if unauthorized
3. **Session Validation**:
   - Checks `userSession` vs `session` from SharedPreferences
   - If mismatch → calls `logoutOnly()` and exits
4. **If refreshed == 1** (logged in):
   - Updates `_navigationOptions` with full navigation:
     - HomePage (index 0)
     - JoinCodeV2 (index 1) - Classroom/Classes
     - ReferralScreen (index 2) - Referrals
     - AccountScreen (index 3) - Account/Profile
5. **If refreshed == 0** (not logged in):
   - Attempts **tokenRefresh(context)** to refresh expired token
   - If refresh succeeds → recursively calls `_checkLogin()`
   - If refresh fails → calls `logoutOnly()`
6. Sets `refreshing = false`
7. Calls **_firebaseMessaging()** - Sets up FCM message listeners
8. **setState({})** - Updates UI

### Build Method
- **If refreshing**: Shows loading screen with Skillogic icon
- **If not refreshing**: Shows main scaffold with:
  - **AppBar**: Custom app bar with user info (via `CustomWidget.getSkillogicAppBar()`)
  - **Body**: `IndexedStack` containing `_navigationOptions` based on `_selectedIndex`
  - **BottomNavigationBar**: `CustomBottomNavBar` with:
    - Home (index 0)
    - Classroom (index 1)
    - Referral (index 2) - only if logged in
    - Account (index 3) - only if logged in
  - **FloatingActionButton**: QR Scanner button (purple, center-docked) - only if logged in

---

## 3. Authentication Flow

### Login Flow (`lib/pages/login_page.dart`)

#### User Taps "Log in" Button
1. **Form Validation**:
   - Email must contain "@"
   - Password must not be empty
2. If valid → calls **_loginUser()**

#### _loginUser()
1. Gets email and password from controllers
2. Sets `loading = true` (shows loading overlay)
3. Calls **_loginService(email, password)**
4. Sets `loading = false`

#### _loginService()
1. Gets `auth_url` from SharedPreferences
2. Constructs URL: `{auth_url}login`
3. **POST Request** with email and password
4. **Response Handling**:
   - **Status 200** (Success):
     - Saves user data to SharedPreferences:
       - `user_name`, `user_email`, `user_image`, `user_phone`, `user_dob`
       - `refreshToken`, `jwtToken`, `session`
     - **Navigates** to `MainPage()` using `pushAndRemoveUntil()` (clears navigation stack)
   - **Status 401** (Unauthorized - OTP Required):
     - **Navigates** to `VerifyOtp(email: email)` page

### OTP Verification Flow (`lib/pages/verify_otp.dart`)

#### User Enters OTP
1. User enters OTP code
2. Taps "Verify OTP" button
3. Calls **_verifyOTP()**

#### _verifyOTP()
1. **UserOTPService.verifyOTP** - Sends OTP to API for verification
2. **If verified** (Status 200):
   - Shows success message
   - **Navigates** back to `LoginPage()`
   - User can now login normally

### Token Authentication (`lib/helper/auth.dart`)

#### tokenLogin()
- Uses existing JWT token from SharedPreferences
- Validates token with API endpoint
- If valid → updates user model and returns 1
- If invalid → logs out and returns 0

#### tokenRefresh()
- Uses refresh token from SharedPreferences
- Gets new JWT token from refresh endpoint
- Updates tokens in SharedPreferences
- Returns 1 if successful, 0 if failed

---

## 4. HomePage Flow (`lib/pages/home_page.dart`)

### Initial Load
1. **initState()** calls **_refreshMain()**

### _refreshMain()
1. Checks internet connection
2. If connected:
   - **_getUserDetail()** - Gets user model
   - **_getCarousel()** - Fetches carousel banners
   - **_getCourses()** - Fetches course list
   - **_getCategory()** - Fetches categories
   - **_getBanner()** - Fetches banner ads

### Displayed Content
- **User Greeting** (Good Morning/Afternoon/Evening)
- **Carousel** - Banner images with navigation
- **Categories** - Course category grid
- **Courses** - Course list/cards
- **Quick Actions** - Various feature shortcuts

### Navigation from HomePage
Users can navigate to:
- Course details
- Category pages
- Enrollment pages
- Candidate portal features
- Payment pages
- Rating pages
- Handbook
- Doubt clearance
- Project status calls
- Referral pages

---

## 5. JoinCodeV2 Flow (`lib/pages/join_code/join_code_v2.dart`)

### Classroom/Classes Screen
- Shows user's enrolled classes
- Allows joining class sessions via class code
- Displays class schedules
- Rating/Feedback functionality
- QR Scanner integration

---

## 6. Referral Screen (`lib/pages/referral/referral_page.dart`)

### Features
- Referral code display
- Referral history
- Credit system (cash credit, course credit)
- Referral link sharing

---

## 7. Account Screen (`lib/pages/account_page.dart`)

### Features
- User profile information
- Settings
- Logout functionality
- Profile editing
- Password change

---

## 8. Firebase Cloud Messaging (Notifications)

### Setup (`setupMessaging()`)
1. **Background Message Handler** - Handles messages when app is in background
2. **Local Notifications** - Sets up Android notification channel
3. **Initial Message** - Handles notification that opened the app
4. **Foreground Messages** - Shows notification helper page when message received
5. **Message Opened App** - Handles notification taps when app was in background

### Notification Navigation
- Uses `NotificationNavigationHelper` to navigate based on notification data:
  - `action` - Main action type
  - `sub_action` - Sub action type
  - `external_url` - External URL to open
  - `external_action` - External action

---

## 9. QR Scanner Flow (`lib/pages/qr_scanner/qr_scanner.dart`)

### FAB (Floating Action Button)
- Purple QR scanner button in center of bottom navigation
- Only visible when user is logged in (`refreshed == 1`)

### Flow
1. User taps QR scanner FAB
2. Opens `QRScanner()` page
3. Scans QR code
4. Processes QR code data
5. Navigates to appropriate screen (e.g., class code entry, feedback screen)

---

## 10. Bottom Navigation Flow

### When Logged Out (`refreshed == 0`)
- **Tab 0**: Home
- **Tab 1**: Classroom (JoinCodeV2)

### When Logged In (`refreshed == 1`)
- **Tab 0**: Home
- **Tab 1**: Classroom (JoinCodeV2)
- **Tab 2**: Referral (ReferralScreen)
- **Tab 3**: Account (AccountScreen)
- **Center FAB**: QR Scanner

### Navigation Handler
- **onItemTapped(int index)** - Updates `_selectedIndex`
- **IndexedStack** - Maintains state of all pages, switches visible page based on index

---

## 11. Key State Management

### SharedPreferences Storage
- User data (name, email, image, phone, DOB)
- Authentication tokens (JWT, refresh token)
- Session information
- Remote config values (auth_url, base_url, etc.)
- Candidate ID
- Firebase token
- Form completion status

### Provider State Management
- **Auth** - Authentication state for LMS
- **Courses/Bundles** - Course and bundle listings
- **Categories** - Category listings
- **RatingProviderAll** - Rating and feedback state

---

## 12. Error Handling & Edge Cases

### Network Errors
- Connection check before API calls
- Internet dialog shown if no connection
- Retry mechanisms

### Authentication Errors
- Token expiration → automatic refresh attempt
- Refresh failure → logout and redirect to login
- Session mismatch → logout

### Version Updates
- Version check on app start
- Update dialog shown if new version available
- Force update option (blocks app usage if required)

### OTP Flow
- If login returns 401 → redirects to OTP verification
- After OTP verification → returns to login page

---

## 13. Complete User Journey

### New User
1. App Launch → MainPage
2. Version Check → Config Fetch
3. Token Check → No token found
4. Shows HomePage (limited features) and Classroom tab
5. User navigates to login (via app bar or other entry point)
6. Login Page → Enter credentials
7. If OTP required → Verify OTP → Return to login
8. Successful login → Save tokens → Navigate to MainPage
9. MainPage → Full navigation enabled (Home, Classroom, Referral, Account)
10. User can access all features

### Returning User (with valid token)
1. App Launch → MainPage
2. Version Check → Config Fetch
3. Token Check → Valid token found
4. tokenLogin() → Validates token
5. Session Check → Valid session
6. MainPage → Full navigation enabled immediately
7. User can access all features

### Returning User (with expired token)
1. App Launch → MainPage
2. Version Check → Config Fetch
3. Token Check → Expired/invalid token
4. tokenLogin() → Returns 0
5. tokenRefresh() → Attempts refresh with refresh token
6. If refresh succeeds → tokenLogin() again → Success
7. If refresh fails → Logout → Limited navigation

---

## 14. Key API Endpoints

### Authentication
- `{auth_url}login` - User login
- `{auth_url}tokenLogin` - Token validation
- `{auth_url}refresh` - Token refresh
- `{auth_url}verification/verifyOtp` - OTP verification
- `{auth_url}verification/resendOtp` - Resend OTP

### User Data
- `{auth_url}Candidate/getCandidateByEmail` - Get candidate details
- `{add_firebase_token}` - Store Firebase token

### Remote Config
- All config fetched from Firebase Remote Config

---

This documentation covers the complete flow of the Skillogic application from initialization to user interactions.

