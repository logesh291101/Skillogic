# Navigation & Display Checks - From main.dart to HomePage

This document lists all the checks and conditions that determine navigation and display from app start to the HomePage.

---

## 1. main.dart → MyApp

### Checks/Initialization:
- ✅ **Firebase Initialization** - `Firebase.initializeApp()`
- ✅ **Firebase Analytics** - Enabled
- ✅ **FCM Background Handler** - Set up
- ✅ **FCM Topic Subscription** - `datamites-v3-app-ios` (runs after app start)

### Navigation:
- **Home Widget**: `MainPage()` (always)

---

## 2. MainPage - Initialization Flow

### State Variables:
```dart
bool refreshing = true;        // Shows loading screen
int refreshed = 0;             // Login status: 0 = not logged in, 1 = logged in
int _selectedIndex = 0;        // Selected tab index
bool showUpdateDialog = false; // Version update dialog
bool forceUpdate = false;      // Force update flag
bool showPopup = false;        // Onboarding popup
```

### Initial Checks (initState → _doInitialization):

#### 2.1 Internet Connection Check
```dart
ConnectionCheck.isAvailable()
```
- **If NO connection**: Does nothing (commented out dialog)
- **If YES connection**: Proceeds to `_getConfig()`

#### 2.2 Version Check (_getConfig → getCurrentVersion)
```dart
PackageInfo.fromPlatform() // Gets current app version
```
- Gets `currentVersion` from package info

#### 2.3 Remote Config Check (_getConfig → getConfig)
```dart
FirebaseRemoteConfig.instance.fetchAndActivate()
```
- Fetches config from Firebase Remote Config
- Compares: `remoteConfigModel.ios_version != currentVersion`
  - **If mismatch**: 
    - `showUpdateDialog = true`
    - If `force_update == "true"`: `forceUpdate = true`
  - **If match**: Proceeds normally

#### 2.4 Update Dialog Display
**Condition**: `if (showUpdateDialog)`
- Shows update dialog
- **If forceUpdate**: Only "Update" button (mandatory)
- **If NOT forceUpdate**: "Update Later" + "Update" buttons
- **After dialog closed**: Calls `_proceedFurther()`

#### 2.5 Proceed Further (_proceedFurther)
```dart
await _checkLogin();
getCandidateDetails();
```

---

## 3. MainPage - Authentication Check (_checkLogin)

### 3.1 Initial State
```dart
refreshing = true  // Shows loading screen with Skillogic icon
```

### 3.2 Token Login Check
```dart
refreshed = await _userAuth.tokenLogin(context)
```
**Returns**:
- `1` = Success (valid token, user logged in)
- `0` = Failed (no token or invalid)
- `2` = Error
- `3` = Unauthorized

### 3.3 Session Validation Check
```dart
userSession = prefs.getString('userSession')
session = prefs.getString('session')

if (userSession == null || session == null || userSession != session)
```
**If session mismatch**:
- Calls `logoutOnly()` - Clears user data
- Sets `refreshed = 0`
- Sets `refreshing = false`
- **Returns early** - Navigation stays limited (2 tabs)

### 3.4 Navigation Options Update
**Condition**: `if (refreshed == 1)`

**Sets `_navigationOptions` to:**
```dart
[
  HomePage(),                    // Index 0
  JoinCodeV2(),                  // Index 1 (with RatingProviderAll)
  ReferralScreen(),              // Index 2
  AccountScreen(),               // Index 3
]
```

**If `refreshed != 1`**:
- Tries `tokenRefresh()` to refresh expired token
- If refresh succeeds → Recursively calls `_checkLogin()`
- If refresh fails → Calls `logoutOnly()` → `refreshed = 0`

### 3.5 Final State Update
```dart
refreshing = false
_firebaseMessaging()  // Sets up FCM listeners
setState({})          // Triggers UI rebuild
```

---

## 4. MainPage - Build Method Display Conditions

### 4.1 Loading Screen Display
**Condition**: `if (refreshing)`
- Shows: Skillogic icon centered
- **Hides**: All navigation, app bar, bottom nav

### 4.2 Main Scaffold Display
**Condition**: `if (!refreshing)`

#### 4.2.1 AppBar Display
```dart
CustomWidget.getSkillogicAppBar(context, userModel, refreshed)
```

**AppBar Contents:**
- **Logo**: Always shown (Skillogic logo from Firebase Storage)
- **Notification Icon**: Always shown
- **User Profile Image**: 
  - **Condition**: `if (refreshed == 1 && userModel != null)`
  - Shows user profile picture (circular, 40x40)
  - Clickable → navigates to ProfileScreen

#### 4.2.2 Body Display (IndexedStack)
```dart
IndexedStack(
  index: _selectedIndex,
  children: _navigationOptions,
)
```
- Shows the widget at `_selectedIndex` from `_navigationOptions`
- Maintains state of all widgets (not disposed on switch)

#### 4.2.3 Onboarding Popup Display
**Condition**: `if (showPopup)`
- Shows overlay with "Candidate Onboarding Form" dialog
- **Check**: `prefs.getBool('form_filled') ?? false`
- If `form_filled == false` → Shows popup

#### 4.2.4 Bottom Navigation Display
```dart
CustomBottomNavBar(
  selectedIndex: _selectedIndex,
  onItemTapped: _onItemTapped,
  refreshed: refreshed,
)
```

**Navigation Items Based on `refreshed`:**

**If `refreshed == 0`** (Not logged in):
- ✅ Home (index 0)
- ✅ Classroom (index 1)

**If `refreshed == 1`** (Logged in):
- ✅ Home (index 0)
- ✅ Classroom (index 1)
- ✅ Empty space for FAB (index 2)
- ✅ Referral (index 2 in navigation, but 3 in bar due to FAB)
- ✅ More/Account (index 3 in navigation, but 4 in bar due to FAB)

**Navigation Bar Behavior:**
```dart
currentIndex = selectedIndex >= 2 && refreshed != 0 
    ? selectedIndex + 1  // Adjust for FAB space
    : selectedIndex

onTap: (index) {
  if (refreshed != 0 && index == 2) return; // Skip FAB space
  onItemTapped(refreshed != 0 && index > 2 ? index - 1 : index);
}
```

#### 4.2.5 Floating Action Button (QR Scanner) Display
**Condition**: `if (refreshed == 1)`
- ✅ Shows purple QR scanner FAB
- ✅ Position: `FloatingActionButtonLocation.centerDocked`
- **If `refreshed != 1`**: No FAB shown

**FAB Action:**
- Checks `showFeedback` global variable
- **If `showFeedback == true`**: Opens JoinCodeV2 with RatingProviderAll
- **If `showFeedback == false`**: Opens QRScanner()

---

## 5. HomePage - Display Conditions

### 5.1 Initial Load (initState → _refreshMain)

**Checks:**
```dart
ConnectionCheck.isAvailable()
```

**If connected**, calls:
- `_getUserDetail()` - Gets user model from SharedPreferences
- `_getCarousel()` - Fetches carousel banners
- `_getCourses()` - Fetches course list
- `_getCategory()` - Fetches categories
- `_getBanner()` - Fetches banner ads

### 5.2 User Detail Check (_getUserDetail)
```dart
userModel = await userDetails.getDetail()
```
**Retrieves from SharedPreferences:**
- `userName`, `userEmail`, `userPhone`, `userImage`, `userDob`
- `jwtToken`, `refreshToken`, `userSession`

**Display Conditions:**
- **If `userModel` exists**: Shows user name in greeting
- **If `userModel` is null**: Shows generic greeting

### 5.3 Greeting Display
```dart
String greeting = "Good Morning,"; // Changes based on time
String userName = userModel?.userName ?? "";
```
- Time-based greeting (Morning/Afternoon/Evening)
- User name if available

### 5.4 Login Status Check
```dart
bool loggedIn = false;
// Checked via: userModel != null || jwtToken exists
```

### 5.5 Carousel/Banner Display
**Condition**: `if (carouselList.isNotEmpty)`
- Shows carousel slider with banners
- If empty → Shows shimmer loader or nothing

### 5.6 Category Display
**Condition**: `if (categoryList.isNotEmpty)`
- Shows category grid
- If empty → Shows shimmer loader or nothing

### 5.7 Course List Display
**Condition**: `if (coursesList.isNotEmpty)`
- Shows course cards/grid
- If empty → Shows shimmer loader or nothing

### 5.8 Sign In Button Display (in HomePage)
**Condition**: `if (!loggedIn || showSignIn)`
- Shows "Sign In" button/CTA
- Hidden when user is logged in

---

## 6. Complete Flow Summary

### Navigation Path:
```
main.dart
  ↓
MyApp (home: MainPage)
  ↓
MainPage.initState()
  ↓
_doInitialization()
  ↓
ConnectionCheck.isAvailable()?
  ├─ NO → Stop (no dialog shown currently)
  └─ YES → _getConfig()
      ↓
      Version Check (ios_version vs currentVersion)?
      ├─ Mismatch → Show Update Dialog
      │   ├─ forceUpdate? → Only "Update" button
      │   └─ !forceUpdate → "Update Later" + "Update"
      └─ Match → _proceedFurther()
          ↓
          _checkLogin()
          ↓
          tokenLogin()?
          ├─ Returns 1 → Session Check
          │   ├─ Session Valid → refreshed = 1 → Update _navigationOptions (4 items)
          │   └─ Session Invalid → refreshed = 0 → Logout → Keep 2 items
          └─ Returns 0 → tokenRefresh()?
              ├─ Success → Recursive _checkLogin()
              └─ Fail → refreshed = 0 → Logout
          ↓
          getCandidateDetails() (async, doesn't block)
          ↓
          refreshing = false
          ↓
          setState() → Rebuild UI
```

### Display Conditions Summary:

| Element | Condition | Shows When |
|---------|-----------|------------|
| **Loading Screen** | `refreshing == true` | During initialization/auth check |
| **AppBar Logo** | Always | Always shown |
| **AppBar Notification** | Always | Always shown |
| **AppBar Profile Image** | `refreshed == 1 && userModel != null` | Logged in + user data available |
| **Bottom Nav - 2 Items** | `refreshed == 0` | Not logged in (Home, Classroom) |
| **Bottom Nav - 4 Items** | `refreshed == 1` | Logged in (Home, Classroom, Referral, Account) |
| **QR Scanner FAB** | `refreshed == 1` | Logged in |
| **Navigation - 2 Screens** | `refreshed == 0` | HomePage, JoinCodeV2 |
| **Navigation - 4 Screens** | `refreshed == 1` | HomePage, JoinCodeV2, ReferralScreen, AccountScreen |
| **HomePage User Greeting** | `userModel != null` | User name available |
| **HomePage Carousel** | `carouselList.isNotEmpty` | Banners loaded |
| **HomePage Categories** | `categoryList.isNotEmpty` | Categories loaded |
| **HomePage Courses** | `coursesList.isNotEmpty` | Courses loaded |
| **Update Dialog** | `showUpdateDialog == true` | Version mismatch |
| **Onboarding Popup** | `showPopup == true && form_filled == false` | Form not filled |

---

## 7. Key Variables That Control Display

### MainPage State:
- ✅ `refreshing` - Controls loading screen
- ✅ `refreshed` - Controls navigation options (0 = 2 tabs, 1 = 4 tabs + FAB)
- ✅ `_selectedIndex` - Controls which screen is visible
- ✅ `_navigationOptions` - Array of widgets to display
- ✅ `showUpdateDialog` - Controls update dialog
- ✅ `forceUpdate` - Controls update dialog type
- ✅ `showPopup` - Controls onboarding popup
- ✅ `userModel` - User data for display

### HomePage State:
- ✅ `loggedIn` - Login status
- ✅ `userModel` - User data
- ✅ `carouselList` - Banner images
- ✅ `categoryList` - Categories
- ✅ `coursesList` - Courses
- ✅ `showSignIn` - Show sign in button

---

## 8. Critical Checks for Navigation

### The `refreshed` Variable is KEY:
- **`refreshed == 0`**: Limited navigation (2 tabs only)
- **`refreshed == 1`**: Full navigation (4 tabs + FAB)

### The Session Check is Critical:
If `userSession != session`, the app:
1. Logs out user
2. Sets `refreshed = 0`
3. Returns early
4. Navigation stays at 2 tabs

**This is likely the Android issue!** The session check might be failing on Android due to timing issues with SharedPreferences.

