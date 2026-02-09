# `refreshed` Variable - When and Where It Gets Updated

This document shows exactly when and where the `refreshed` variable is updated in the MainPage.

---

## Variable Declaration

**Location**: `lib/pages/main_page.dart` (line 49)

```dart
int refreshed = 0;  // Initial value: 0 (not logged in)
```

**Initial Value**: `0` (means user is NOT logged in)

---

## All Places Where `refreshed` Gets Updated

### 1. Initial Declaration (Line 49)
```dart
int refreshed = 0;
```
**When**: When MainPage state is initialized
**Value Set**: `0` (not logged in)

---

### 2. After tokenLogin() Call (Line 258)
**Location**: `_checkLogin()` method

```dart
refreshed = await _userAuth.tokenLogin(context);
```

**When**: 
- App starts (in `_proceedFurther()` → `_checkLogin()`)
- After token refresh succeeds (recursive call to `_checkLogin()`)

**Value Set**: 
- `1` = Success (valid JWT token, user is logged in)
- `0` = Failed (no token or token invalid)
- `2` = Error response
- `3` = Unauthorized (401 response)

**What `tokenLogin()` does** (`lib/helper/auth.dart`):
- Gets JWT token from SharedPreferences
- Sends GET request to `/tokenLogin` API endpoint with JWT token
- **If status 200 (success)**:
  - Updates userModel with user data from API
  - Calls `userDetails.setDetail(userModel)` - saves `userSession` to SharedPreferences
  - **Returns `1`**
- **If status 401 (unauthorized)**:
  - Calls `logoutUser()` - clears user data
  - **Returns `3`**
- **If other error**:
  - Calls `logoutUser()` - clears user data
  - **Returns `2`**
- **If no token**:
  - Calls `logoutUser()` - clears user data
  - **Returns `0`**

---

### 3. Session Validation Failure (Line 267)
**Location**: `_checkLogin()` method, inside session check (AFTER tokenLogin)

```dart
if (userSession == null || session == null || userSession != session) {
  UserDetails userDetails = UserDetails();
  await userDetails.logoutOnly(context);
  setState(() {
    refreshed = 0;  // ← UPDATED HERE (forces logout even if tokenLogin returned 1)
    refreshing = false;
  });
  return;
}
```

**When**: 
- After `tokenLogin()` returns (regardless of return value)
- If session validation fails:
  - `userSession` is null OR
  - `session` is null OR
  - `userSession != session`

**Value Set**: `0` (forced logout)

**Important**: This happens BEFORE checking if `refreshed == 1`, so even if login succeeds, session mismatch causes logout.

---

### 4. After tokenRefresh() Call (Line 286)
**Location**: `_checkLogin()` method, in the `else` block when `refreshed != 1`

```dart
else {
  refreshed = await _userAuth.tokenRefresh(context);  // ← UPDATED HERE (line 286)
  if (refreshed == 1) {
    // ... session check ...
    _checkLogin();  // Recursive call (line 301)
  }
  else {
    // ... logout ...
    refreshed = 0;  // ← Also updated here (line 306, see #5)
  }
}
```

**When**: 
- If `tokenLogin()` returned `0` (failed) or any value other than `1`
- Attempts to refresh the expired token using refresh token

**Value Set**: 
- `1` = Token refresh successful
- `0` = Token refresh failed
- `2` = Error
- `3` = Unauthorized

**What `tokenRefresh()` does** (`lib/helper/auth.dart`):
- Gets refresh token from SharedPreferences
- Sends GET request to `/refresh` API endpoint with refresh token
- **If status 200 (success)**:
  - Updates `jwtToken` in SharedPreferences
  - Updates `refreshToken` in SharedPreferences
  - Updates `session` in SharedPreferences (NOT `userSession`)
  - **Returns `1`**
- **If status 401**:
  - **Returns `3`**
- **If other error**:
  - **Returns `2`**
- **If no refresh token**:
  - **Returns `0`**

---

### 5. Token Refresh Failure (Line 306)
**Location**: `_checkLogin()` method, in the `else` block when token refresh fails

```dart
else {  // if refreshed != 1 after tokenRefresh
  UserDetails userDetails = UserDetails();
  await userDetails.logoutOnly(context);
  setState(() {
    refreshed = 0;  // ← UPDATED HERE (line 306)
  });
}
```

**When**: 
- If `tokenRefresh()` returned `0`, `2`, or `3` (failed)

**Value Set**: `0` (logout)

---

## Complete Flow Diagram

```
MainPage State Initialized
  ↓
refreshed = 0  (initial)
  ↓
_doInitialization() → _getConfig() → _proceedFurther()
  ↓
_checkLogin() called
  ↓
refreshed = await tokenLogin(context)
  ├─ Returns 1 → Continue
  ├─ Returns 0 → Go to tokenRefresh
  ├─ Returns 2 → Go to tokenRefresh
  └─ Returns 3 → Go to tokenRefresh
  ↓
Session Check (ALWAYS happens, even if refreshed == 1)
  ├─ userSession == null? → refreshed = 0, logout, return
  ├─ session == null? → refreshed = 0, logout, return
  └─ userSession != session? → refreshed = 0, logout, return
  ↓
If refreshed == 1 (AND session check passed)
  → Update _navigationOptions to 4 items
  → Continue to set refreshing = false
  ↓
If refreshed != 1
  → refreshed = await tokenRefresh(context)
    ├─ Returns 1 → Session check → Recursive _checkLogin()
    └─ Returns 0/2/3 → refreshed = 0, logout
  ↓
refreshing = false
setState({})  ← Triggers UI rebuild with new refreshed value
```

---

## Key Points About `refreshed` Updates

### 1. **After Login (from LoginPage)**
When user logs in successfully:
- Login page saves `jwtToken`, `refreshToken`, and `session` to SharedPreferences
- Navigates to MainPage using `pushAndRemoveUntil`
- MainPage `initState()` → `_doInitialization()` → `_checkLogin()`
- `tokenLogin()` validates the saved JWT token
- **If valid**: `refreshed = 1`
- **Session check happens**: If `userSession != session`, `refreshed = 0` (CRITICAL!)

### 2. **Session Check Timing**
The session check happens **immediately after `tokenLogin()`**, even if it returned `1`. This is the problem on Android!

The check compares:
- `userSession` - saved by `tokenLogin()` via `setDetail()` (from API response)
- `session` - saved during login (from login API response)

**On Android, there might be a timing issue where:**
- `tokenLogin()` saves `userSession` via `setDetail()`
- But when we read it back immediately, it might not be available yet
- Causing the session check to fail
- Setting `refreshed = 0`
- Preventing navigation from updating

### 3. **Token Refresh Flow**
If `tokenLogin()` fails (`refreshed != 1`):
- Calls `tokenRefresh()` to get new tokens
- **Important**: `tokenRefresh()` saves to `session` but NOT to `userSession`
- If refresh succeeds (`refreshed = 1`), recursively calls `_checkLogin()`
- Then `tokenLogin()` runs again with new token

### 4. **UI Update Trigger**
After all checks:
```dart
refreshing = false;
setState({});  // ← Triggers rebuild, UI reads refreshed value
```

The UI reads `refreshed` value in:
- `CustomBottomNavBar` - determines number of tabs
- `FloatingActionButton` - determines if QR scanner shows
- `AppBar` - determines if profile image shows

---

## Summary Table

| Location | When | Value Set | Condition |
|----------|------|-----------|-----------|
| **Initial Declaration** | State init | `0` | Always |
| **After tokenLogin()** | After API call | `0, 1, 2, or 3` | Based on API response |
| **Session Check Failure** | After tokenLogin | `0` | If sessions don't match |
| **After tokenRefresh()** | If tokenLogin failed | `0, 1, 2, or 3` | Based on refresh API response |
| **Token Refresh Failure** | If tokenRefresh failed | `0` | Always sets to 0 |

---

## The Android Issue

**Problem**: On Android, `refreshed` might be getting set to `0` due to session check failure, even though login succeeded.

**Why**: After `tokenLogin()` saves `userSession`, immediately reading it back from SharedPreferences might not work reliably on Android due to async timing.

**Solution would be**: 
- Get session value directly from the `tokenLogin()` response instead of reading from SharedPreferences
- Or delay the session check
- Or sync both session keys during login

---

## Code Locations Reference

| Update Location | File | Line | Method | Condition |
|----------------|------|------|--------|-----------|
| Initialization | `lib/pages/main_page.dart` | 49 | State variable | Always on init |
| After tokenLogin | `lib/pages/main_page.dart` | 258 | `_checkLogin()` | Always executes |
| Session check fail | `lib/pages/main_page.dart` | 267 | `_checkLogin()` | If session mismatch |
| After tokenRefresh | `lib/pages/main_page.dart` | 286 | `_checkLogin()` | If tokenLogin failed |
| Refresh fail | `lib/pages/main_page.dart` | 306 | `_checkLogin()` | If tokenRefresh failed |
| tokenLogin implementation | `lib/helper/auth.dart` | 16-56 | `tokenLogin()` | Returns int value |
| tokenRefresh implementation | `lib/helper/auth.dart` | 58-87 | `tokenRefresh()` | Returns int value |

