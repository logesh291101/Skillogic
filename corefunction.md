# Core Functions & Screen Responsibilities

Central reference for the **Skillogic** Flutter application (`skillogic`, v15.0.1+16).  
Use this document to locate where behavior lives before making changes.

---

## Table of Contents

1. [Application Entry & Bootstrap](#1-application-entry--bootstrap)
2. [Authentication & Session](#2-authentication--session)
3. [Main Navigation Shell](#3-main-navigation-shell)
4. [Screen-Level Responsibilities](#4-screen-level-responsibilities)
5. [Services (API / State)](#5-services-api--state)
6. [Helpers & Utilities](#6-helpers--utilities)
7. [Providers & State Management](#7-providers--state-management)
8. [Module Map](#8-module-map)
9. [Data Flow Overview](#9-data-flow-overview)

---

## 1. Application Entry & Bootstrap

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | App entry: Firebase init, Crashlytics, FCM topic subscription, global `MultiProvider` setup, `MaterialApp` with `MainPage` as home, LMS named routes. |
| `lib/pages/main_page.dart` | Root shell: Remote Config fetch, login/session bootstrap, bottom navigation, force-update dialog, FCM setup, QR FAB. |

**Bootstrap sequence**

1. `main()` initializes Firebase, Crashlytics, and FCM.
2. `MyApp` registers global providers (LMS, handbook, internship, course %, certificates, etc.).
3. `MainPage` loads Remote Config URLs into `SharedPreferences`.
4. `_checkLogin()` runs `tokenLogin` / `tokenRefresh` and validates session.
5. Navigation tabs are built based on `refreshed` (logged in vs guest).

---

## 2. Authentication & Session

| File | Core Functions |
|------|----------------|
| `lib/helper/auth.dart` | **`UserAuth`** — `tokenLogin()`, `tokenRefresh()`. Returns status codes: `0` no token, `1` success, `2` error, `3` unauthorized. |
| `lib/helper/user_details.dart` | **`UserDetails`** — read/write user profile to prefs; `logout()`, `manualLogout()`, `logoutOnly()`. |
| `lib/pages/login_page.dart` | Email/password login; stores JWT, refresh token, session; navigates to OTP on 401; on success → `MainPage`. |
| `lib/pages/register_page.dart` | New user registration. |
| `lib/pages/verify_otp.dart` | OTP verification for unverified accounts. |
| `lib/pages/forget_password.dart` | Password recovery flow. |
| `lib/pages/password_change_page.dart` | In-app password change. |

**Session keys (SharedPreferences)**

| Key | Purpose |
|-----|---------|
| `jwtToken` | API auth header |
| `refreshToken` | Token refresh |
| `session` | Active session ID from server |
| `userSession` | Session ID stored with user profile |
| `auth_url`, `base_url`, `candidate_portal_url` | API base URLs from Remote Config |

**Session rule:** `userSession` must equal `session` or the user is logged out (`main_page.dart` → `_checkLogin()`).

---

## 3. Main Navigation Shell

**File:** `lib/pages/main_page.dart`

### Guest (`refreshed == 0`)

| Tab | Screen | File |
|-----|--------|------|
| 0 — Home | Dashboard (limited) | `lib/pages/home_page.dart` |
| 1 — Classroom | Join code / rating gate | `lib/pages/join_code/join_code_v2.dart` |

No QR FAB.

### Logged in (`refreshed == 1`)

| Tab | Screen | File |
|-----|--------|------|
| 0 — Home | Full dashboard | `lib/pages/home_page.dart` |
| 1 — Classroom | Join code / class access | `lib/pages/join_code/join_code_v2.dart` |
| 2 — *(FAB spacer)* | — | — |
| 3 — Referral | Referral dashboard | `lib/pages/referral/referral_page.dart` |
| 4 — Account | Profile & settings | `lib/pages/account_page.dart` |

**QR FAB (logged-in only)**

1. Request location permission.
2. `_checkQRRatingStatus()` — if rating pending → `JoinCodeV2` with callback.
3. Otherwise → `lib/pages/qr_scanner/qr_scanner.dart` for geo-tagged attendance.

---

## 4. Screen-Level Responsibilities

### 4.1 Home & Dashboard

| Screen | File | Responsibilities |
|--------|------|------------------|
| **HomePage** | `lib/pages/home_page.dart` | Carousel/banners, course catalog preview, success stories (guest), welcome + progress bar (logged in), quick-action tiles (enrollment, ratings, certificates, referral, tickets, doubt clearance, project status, handbook, topics, attendance), referral CTA, device/location session tracking. |
| **App Update** | `lib/pages/app_update_screen.dart` | Force/optional update UI driven by Remote Config. |

### 4.2 Account & Profile

| Screen | File | Responsibilities |
|--------|------|------------------|
| **AccountScreen** | `lib/pages/account_page.dart` | Profile header, edit profile, notifications, Freshdesk tickets, raise ticket, my activity/assessment, privacy/TOS links, logout; offline LMS download sync via `DatabaseHelper`. |
| **UpdateProfilePage** | `lib/pages/update_profile_page.dart` | Edit user profile fields. |
| **ProfileScreen** | `lib/pages/profile_screen.dart` | Profile display. |
| **ContactUs** | `lib/pages/contact_us.dart` | Contact/support form. |
| **NotificationPage** | `lib/pages/notification_page.dart` | Notification inbox with pull-to-refresh; Sembast cache; inline `NotificationService`. |
| **UserActivity** | `lib/pages/user_activity.dart` | User activity history. |
| **ActivityDetailsPage** | `lib/pages/activity_details_page.dart` | Single activity detail view. |
| **AssessmentDetailsPage** | `lib/pages/assessment_details_page.dart` | Assessment result/detail view. |

### 4.3 Classroom, Join Code & Attendance

| Screen | File | Responsibilities |
|--------|------|------------------|
| **JoinCodeV2** | `lib/pages/join_code/join_code_v2.dart` | Classroom tab: rating gate, class code display, login/error states. Uses `RatingProviderAll`. |
| **ShowClassCode** | `lib/pages/join_code/show_class_code.dart` | Active class code, batch/course info, join links. |
| **QRScanner** | `lib/pages/qr_scanner/qr_scanner.dart` | QR scan → geo-tagged attendance POST to `CandidateAttendance` API. |
| **AttendancePage** | `lib/pages/attendance_record_page.dart` | Calendar color-coding (present/absent/future); schedule detail panel via `AttendanceProvider`. |
| **Feedback screens** | `lib/pages/join_code/feedback_screen.dart`, `feedback_popup_all_classroom.dart` | Post-class feedback collection. |

### 4.4 Candidate Portal

| Screen | File | Responsibilities |
|--------|------|------------------|
| **CandidateRestRequest** | `lib/pages/candidate_portal/candidate_rest_request.dart` | Central REST client: enrollments, payments, ratings, certificates, course events; stores `enrollment_number`. |
| **EnrolledCourse** | `lib/pages/candidate_portal/enrolled_course.dart` | Lists enrolled courses/bundles. |
| **EnrolledCourseDetails** | `lib/pages/candidate_portal/enrolled_course_details.dart` | Course event details, dates, schedules. |
| **CourseSchedules** | `lib/pages/candidate_portal/course_schedules.dart` | Session schedule list with Zoom/classroom join links. |
| **EnrolledCertificate** | `lib/pages/candidate_portal/enrolled_certificate.dart` | Certificate list; view/share/download PDFs. |
| **RatingPage** | `lib/pages/candidate_portal/rating_page.dart` | Submit/view classroom/trainer/material ratings. |
| **CandidatePaymentPage** | `lib/pages/candidate_portal/payment_page.dart` | Payment history cards. |
| **EnrollmentPage** | `lib/pages/enrollment_page.dart` | Enrollment listing and navigation. |

### 4.5 Learning Support Screens

| Screen | File | Responsibilities |
|--------|------|------------------|
| **DoubtClearScreen** | `lib/pages/doubtClearance_screen.dart` | Doubt-clearance session list; share/copy actions. |
| **HandbookScreen** | `lib/pages/handbook_screen.dart` | Learner handbook PDF list; inline `SfPdfViewer`. |
| **TopicsCoveredPage** | `lib/pages/topics_covered_page.dart` | Trainer topics covered for an enrollment. |
| **ProjectStatusCallScreen** | `lib/pages/project_statusCall_screen.dart` | Scheduled project status call sessions. |
| **InternshipForm** | `lib/pages/internship_form.dart` | Internship application submission. |
| **InternshipSubmissionSuccess** | `lib/pages/internship_submissionSuccess_screen.dart` | Post-submission confirmation. |

### 4.6 Referral Module

| Screen | File | Responsibilities |
|--------|------|------------------|
| **ReferralScreen** | `lib/pages/referral/referral_page.dart` | Bottom-nav referral tab; auth refresh, login prompt, split dashboard. |
| **ReferralPageScaffold** | `lib/pages/referral/referral_page_scaffold.dart` | Same scaffold used from home shortcuts and notifications. |
| **ReferralScreenLeft** | `lib/pages/referral/referral_widgets/referral_screen_left.dart` | Credits summary, expandable sections, navigation to add/history/credit. |
| **AddReferral (NewReferral)** | `lib/pages/referral/new_referral.dart` | Referral submission form with campaign selection. |
| **ReferralHistory** | `lib/pages/referral/referral_history.dart` | Searchable referral history with `SearchProvider`. |
| **CreditScreen** | `lib/pages/referral/credit_screen.dart` | Credit/transaction history by status. |
| **ReferralListPage** | `lib/pages/referral/referral_list_page.dart` | Full-screen referral history wrapper. |

### 4.7 Support (Freshdesk)

| Screen | File | Responsibilities |
|--------|------|------------------|
| **TicketPage** | `lib/pages/freshdesk/ticket_page.dart` | Freshdesk ticket list and creation. |
| **FreshDeskCard** | `lib/pages/freshdesk/fresh_desk_card.dart` | Ticket summary card widget. |

### 4.8 LMS Module

| Screen | File | Responsibilities |
|--------|------|------------------|
| **LmsHomeScreen** | `lib/pages/lms/screens/lms_home_screen.dart` | LMS entry; loads categories → `TabsScreen`. |
| **TabsScreen** | `lib/pages/lms/screens/tabs_screen.dart` | LMS bottom tabs: Browse, My Courses, Wishlist, Account. |
| **CoursesScreen** | `lib/pages/lms/screens/courses_screen.dart` | Course list by category/subcategory. |
| **CourseDetailScreen** | `lib/pages/lms/screens/course_detail_screen.dart` | Course detail, lessons, forum, wishlist. |
| **MyCoursesScreen** | `lib/pages/lms/screens/my_courses_screen.dart` | Enrolled courses and bundles. |
| **MyCourseDetailScreen** | `lib/pages/lms/screens/my_course_detail_screen.dart` | Enrolled course lesson player/progress. |
| **BundleListScreen** | `lib/pages/lms/screens/bundle_list_screen.dart` | Bundle catalog. |
| **BundleDetailsScreen** | `lib/pages/lms/screens/bundle_details_screen.dart` | Bundle detail and contained courses. |
| **DownloadedCourseList** | `lib/pages/lms/screens/downloaded_course_list.dart` | Offline downloads from SQLite. |
| **MyWishlistScreen** | `lib/pages/lms/screens/my_wishlist_screen.dart` | Wishlisted courses. |
| **WebViewScreen** | `lib/pages/lms/screens/webview_screen.dart` | Embedded web lesson content. |
| **MeetingScreen** | `lib/pages/lms/screens/meeting_screen.dart` | Live meeting/session launcher. |

> LMS routes are registered in `main.dart`. Direct home → LMS navigation may be commented out in places.

### 4.9 D-Tribe (Community)

| Screen | File | Responsibilities |
|--------|------|------------------|
| **DTribe** | `lib/pages/d_tribe.dart` | D-Tribe module entry. |
| **TribePage / TribeHome** | `lib/pages/d_tribe/tribe_page.dart`, `tribe_home.dart` | Community home and navigation. |
| **TribeProfile** | `lib/pages/d_tribe/tribe_profile.dart` | Community user profile. |
| **WelcomeScreen** | `lib/pages/d_tribe/welcome_screen.dart` | D-Tribe onboarding. |

### 4.10 Course Catalog (Non-LMS)

| Screen | File | Responsibilities |
|--------|------|------------------|
| **CourseListPage** | `lib/pages/sub_page/course/course_list_page.dart` | Browse courses by category. |
| **CoursePreviewPage** | `lib/pages/sub_page/course/course_preview_page.dart` | Course preview/detail before enrollment. |

---

## 5. Services (API / State)

All services read URLs and tokens from `SharedPreferences` (populated by Remote Config in `MainPage`).

| Service | File | API / Purpose |
|---------|------|---------------|
| **AttendanceProvider** | `lib/service/attendance_record_service.dart` | `attendance_candidate_api/get_attendance_details` — calendar attendance data. |
| **CoursePercentageService** | `lib/service/course_percentage_service.dart` | `bundle_details_api/getbundledetailsbyemail` — home dashboard progress %. |
| **DoubtClearanceService** | `lib/service/doubtClearance_service.dart` | `DoubtClearance_api/schedule` — doubt-clearance sessions. |
| **EnrolledCertificateProvider** | `lib/service/enrolled_certificate_service.dart` | `CandidateCertifications` — earned certificates. |
| **HandbookProvider** | `lib/service/handbook_service.dart` | `getLearnersHandbook` — handbook PDF list. |
| **HomeScreenMessageService** | `lib/service/homeScreen_message_service.dart` | `nocCertificateApi/getMessage` — home banner message. |
| **InternshipBatchProvider** | `lib/service/internship_batchDetails_service.dart` | `Internship_api` — eligibility and form submission. |
| **ProjectStatusService** | `lib/service/project_statusCall_service.dart` | `Project_status_call_api/schedule` — project status calls. |
| **TopicCoveredProvider** | `lib/service/topics_covered_service.dart` | `trainer_topics_api/get_topics_details` — topics covered. |
| **Referral RestService** | `lib/pages/referral/service/rest_service.dart` | Referral CRUD and credit APIs. |

---

## 6. Helpers & Utilities

| Helper | File | Purpose |
|--------|------|---------|
| **UserAuth** | `lib/helper/auth.dart` | JWT login and refresh. |
| **UserDetails** | `lib/helper/user_details.dart` | User profile persistence and logout. |
| **ConnectionCheck** | `lib/helper/connection.dart` | DNS-based internet availability check. |
| **NotificationNavigationHelper** | `lib/helper/notification_navigation_helper.dart` | Maps push notification `action` codes to target screens. |
| **FirebaseMessagingHelper** | `lib/helper/FirebaseMessagingHelper.dart` | FCM topic subscription. |
| **MainColor / colors** | `lib/helper/color.dart`, `hex_color.dart` | Brand and theme colors. |
| **ResponsiveHelper** | `lib/helper/responsive_helper.dart` | Layout breakpoints (referral split-pane vs mobile). |
| **TextValidation** | `lib/helper/text_validation.dart` | Form validation (referral forms). |

---

## 7. Providers & State Management

Uses the `provider` package. Global providers are registered in `lib/main.dart`.

### App-level (`lib/provider/`)

| Provider | File | Scope |
|----------|------|-------|
| **RatingProviderAll** | `lib/provider/rating_provider_all.dart` | Classroom ratings — Join Code, Rating pages. |
| **SearchProvider** | `lib/provider/search_provider.dart` | Referral search, sort, refresh. |
| **ScannerProvider** | `lib/provider/scanner_provider.dart` | Last scanned QR value. |

### Service providers (registered in `main.dart`)

- `InternshipBatchProvider`, `HandbookProvider`, `CoursePercentageService`, `HomeScreenMessageService`, `EnrolledCertificateProvider`

### LMS providers (`lib/pages/lms/providers/`)

- `Auth`, `Categories`, `Courses`, `MyCourses`, `Bundles`, `MyBundles`, `CourseForum`, `Languages`, `MiscProvider`, `DatabaseHelper`

---

## 8. Module Map

```
skillogic/
├── lib/
│   ├── main.dart                    ← Entry, global providers, routes
│   ├── helper/                      ← Auth, user details, connection, notifications
│   ├── service/                     ← Candidate-portal API services
│   ├── provider/                    ← App-wide ChangeNotifiers
│   ├── model/                       ← Data models (user, course, freshdesk, etc.)
│   ├── widgets/                     ← Shared UI components
│   └── pages/
│       ├── main_page.dart           ← Navigation shell
│       ├── home_page.dart           ← Dashboard
│       ├── login_page.dart          ← Auth
│       ├── account_page.dart        ← Account tab
│       ├── candidate_portal/        ← Enrollments, payments, ratings, certificates
│       ├── join_code/               ← Classroom access & feedback
│       ├── qr_scanner/              ← Attendance QR scan
│       ├── referral/                ← Referral & credits
│       ├── lms/                     ← Learning management system
│       ├── freshdesk/               ← Support tickets
│       └── d_tribe/                 ← Community module
```

---

## 9. Data Flow Overview

```
Remote Config (Firebase)
        │
        ▼
SharedPreferences (URLs, tokens, session)
        │
        ├── UserAuth.tokenLogin / tokenRefresh
        │         │
        │         ▼
        │   MainPage (refreshed → tabs + FAB)
        │         │
        │         ├── HomePage → Services → Candidate Portal APIs
        │         ├── JoinCodeV2 → RatingProviderAll → Candidate Portal
        │         ├── ReferralScreen → RestService → Referral APIs
        │         └── AccountScreen → Profile / Freshdesk / Notifications
        │
        └── QRScanner → CandidateAttendance API (geo + JWT)
```

### Push notification routing

`NotificationNavigationHelper` maps notification `action` values to screens: referral, course detail, web view, enrolled courses, payments, ratings, tickets, login.

### Offline storage

| Store | Used for |
|-------|----------|
| **Sembast** | Notification cache |
| **SQLite (`DatabaseHelper`)** | LMS downloaded videos/courses |

---

## Maintenance Notes

- **Remote Config keys** (`auth_url_v3`, `base_url_v3`, `candidate_portal_v3`, etc.) are defined in `MainPage.getConfig()` → `RemoteConfigModel`.
- **Single-session enforcement** is in `MainPage._checkLogin()` — see also `FIX_ANDROID_ISSUE_CHANGES.md` for Android session timing notes.
- When adding a new screen, update the relevant section in this file and link its service/helper dependencies.

---

*Last organized: August 2026*
