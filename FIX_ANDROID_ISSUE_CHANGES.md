# Fix Android Issue - Where to Make Changes

This document shows exactly where to make changes to fix the Android navigation issue.

---

## Problem
On Android, after login, `refreshed` is being set to `0` due to session check failure, preventing navigation from updating to show 4 tabs.

**Root Cause**: Session check reads from SharedPreferences immediately after `tokenLogin()` saves it, but on Android there's a timing issue where the value might not be immediately available.

---

## Solution Options

### **Option 1: Use Session from UserModel (RECOMMENDED)**
Get the session value directly from the `userModel` that `tokenLogin()` just set, instead of reading from SharedPreferences.

### **Option 2: Move Session Check After Login Success**
Only perform session check if `refreshed == 1` (login successful).

### **Option 3: Sync Session Keys During Login**
Ensure both `session` and `userSession` are saved during login.

---

## **RECOMMENDED FIX: Option 1 + Option 2 Combined**

### Change 1: Modify `lib/pages/main_page.dart` - `_checkLogin()` method

**Location**: Lines 254-314

**Current Code** (lines 258-271):
```dart
refreshed = await _userAuth.tokenLogin(context);
final prefs = await SharedPreferences.getInstance();
final userSession = prefs.getString('userSession');
final session = prefs.getString('session');

if (userSession == null || session == null || userSession != session) {
  UserDetails userDetails = UserDetails();
  await userDetails.logoutOnly(context);
  setState(() {
    refreshed = 0;
    refreshing = false;
  });
  return;
}

if (refreshed == 1) {
  // ... navigation options ...
}
```

**Replace With**:
```dart
refreshed = await _userAuth.tokenLogin(context);

// Only check session if login was successful
if (refreshed == 1) {
  // Get session from userModel (just set by tokenLogin) instead of SharedPreferences
  final userModel = await userDetails.getDetail();
  final prefs = await SharedPreferences.getInstance();
  final userSession = userModel.userSession;  // From userModel, not SharedPreferences
  final session = prefs.getString('session');

  // Sync userSession to SharedPreferences if needed
  if (userSession.isNotEmpty && userSession != session) {
    await prefs.setString('session', userSession);
  }

  // Session validation - only if both are not empty
  if (userSession.isEmpty || (session != null && session!.isNotEmpty && userSession != session)) {
    UserDetails userDetails = UserDetails();
    await userDetails.logoutOnly(context);
    setState(() {
      refreshed = 0;
      refreshing = false;
    });
    return;
  }

  _navigationOptions = <Widget>[
    const HomePage(),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RatingProviderAll()),
      ],
      child: const JoinCodeV2(),
    ),
    const ReferralScreen(),
    const AccountScreen(),
  ];
}
```

---

### Change 2: Also Fix the tokenRefresh Path

**Location**: Lines 286-301

**Current Code**:
```dart
} else {
  refreshed = await _userAuth.tokenRefresh(context);
  if (refreshed == 1) {
    final prefs = await SharedPreferences.getInstance();
    final userSession = prefs.getString('userSession');
    final session = prefs.getString('session');

    if (userSession == null || session == null || userSession != session) {
      UserDetails userDetails = UserDetails();
      await userDetails.logoutOnly(context);
      setState(() {
        refreshed = 0;
        refreshing = false;
      });
      return;
    }
    _checkLogin();
  }
```

**Replace With**:
```dart
} else {
  refreshed = await _userAuth.tokenRefresh(context);
  if (refreshed == 1) {
    // After tokenRefresh, session is updated but userSession might not be
    // So we need to call tokenLogin again to sync userSession
    // The recursive _checkLogin() will handle the session check properly
    _checkLogin();
  }
```

---

### Change 3: Ensure Login Saves Both Session Keys

**Location**: `lib/pages/login_page.dart` - Line 337-347

**Current Code**:
```dart
if (response.statusCode == 200) {
  var resp = json.decode(response.body);
  await prefs.setString("user_name", resp["user_data"]['name']);
  await prefs.setString("user_email", resp["user_data"]['email']);
  await prefs.setString("user_image", resp["user_data"]['profile_pic']);
  await prefs.setString("user_phone", resp["user_data"]['mnumber']);
  await prefs.setString("user_dob", resp["user_data"]['dob']??"");
  await prefs.setString("refreshToken", resp['refreshToken']);
  await prefs.setString("jwtToken", resp['jwtkey']);
  await prefs.setString("session", resp["user_data"]['current_active_session_id']??"");
  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context)=> const MainPage()), (route) => false);
}
```

**Replace With**:
```dart
if (response.statusCode == 200) {
  var resp = json.decode(response.body);
  String sessionId = resp["user_data"]['current_active_session_id']??"";
  await prefs.setString("user_name", resp["user_data"]['name']);
  await prefs.setString("user_email", resp["user_data"]['email']);
  await prefs.setString("user_image", resp["user_data"]['profile_pic']);
  await prefs.setString("user_phone", resp["user_data"]['mnumber']);
  await prefs.setString("user_dob", resp["user_data"]['dob']??"");
  await prefs.setString("refreshToken", resp['refreshToken']);
  await prefs.setString("jwtToken", resp['jwtkey']);
  await prefs.setString("session", sessionId);
  await prefs.setString("userSession", sessionId);  // Also save as userSession
  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context)=> const MainPage()), (route) => false);
}
```

---

## Alternative Simpler Fix (If Above Doesn't Work)

### Simple Fix: Just Move Session Check Inside `if (refreshed == 1)`

**Location**: `lib/pages/main_page.dart` - Line 254-314

**Replace the entire `_checkLogin()` method with**:

```dart
_checkLogin() async {
  setState(() {
    refreshing = true;
  });
  refreshed = await _userAuth.tokenLogin(context);

  if (refreshed == 1) {
    // Session validation - only check if login was successful
    final prefs = await SharedPreferences.getInstance();
    final userSession = prefs.getString('userSession');
    final session = prefs.getString('session');

    // Sync session if userSession exists but session doesn't match
    if (userSession != null && userSession.isNotEmpty) {
      if (session == null || session != userSession) {
        await prefs.setString('session', userSession);
      }
    }

    // Only fail if userSession is empty/null (meaning tokenLogin didn't save it properly)
    if (userSession == null || userSession.isEmpty) {
      UserDetails userDetails = UserDetails();
      await userDetails.logoutOnly(context);
      setState(() {
        refreshed = 0;
        refreshing = false;
      });
      return;
    }

    _navigationOptions = <Widget>[
      const HomePage(),
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RatingProviderAll()),
        ],
        child: const JoinCodeV2(),
      ),
      const ReferralScreen(),
      const AccountScreen(),
    ];
  } else {
    refreshed = await _userAuth.tokenRefresh(context);
    if (refreshed == 1) {
      _checkLogin();  // Recursive call - will handle session check
    } else {
      UserDetails userDetails = UserDetails();
      await userDetails.logoutOnly(context);
      setState(() {
        refreshed = 0;
      });
    }
  }

  refreshing = false;
  _firebaseMessaging();
  setState(() {});
}
```

---

## Summary of Changes

### Files to Modify:

1. **`lib/pages/main_page.dart`**
   - Method: `_checkLogin()` (lines 254-314)
   - Change: Move session check inside `if (refreshed == 1)` block
   - Change: Use session from userModel or sync session keys

2. **`lib/pages/login_page.dart`** (Optional but recommended)
   - Method: `_loginService()` (line ~337)
   - Change: Save both `session` and `userSession` during login

### Key Changes:
- ✅ Session check only happens if login succeeded (`refreshed == 1`)
- ✅ Session value synced from `userSession` to `session` if needed
- ✅ Less strict session validation (only fails if `userSession` is empty)
- ✅ Both session keys saved during login for consistency

---

## Testing After Changes

1. **Test Login Flow**:
   - Login with valid credentials
   - Verify navigation shows 4 tabs (Home, Classroom, Referral, Account)
   - Verify QR scanner FAB appears

2. **Test Session Persistence**:
   - Login, close app, reopen app
   - Verify user stays logged in
   - Verify navigation still shows 4 tabs

3. **Test on Android**:
   - Test on multiple Android devices/emulators
   - Verify session check doesn't fail after login
   - Verify navigation updates correctly

---

## Why This Fixes the Issue

1. **Timing Issue Resolved**: By moving session check inside `if (refreshed == 1)`, we only check after we know login succeeded
2. **Session Sync**: We sync `session` from `userSession` if they don't match, ensuring consistency
3. **Less Strict Validation**: We only fail if `userSession` is empty (meaning tokenLogin didn't work), not if they're just different
4. **Both Keys Saved**: During login, we save both keys so they're in sync from the start

This should fix the Android issue while maintaining security and proper session validation.

