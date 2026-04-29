# Cliniq — Architecture, Bug & Deploy Audit Report

> Generated: 2026-04-26

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Critical Bugs (Deploy Blockers)](#critical-bugs-deploy-blockers)
3. [Logic Bugs](#logic-bugs)
4. [Security Notes](#security-notes)
5. [Deploy Readiness Summary](#deploy-readiness-summary)
6. [Fix Checklist](#fix-checklist)

---

## Architecture Overview

### cliniq (User App) — Flutter + Provider

```
lib/
├── core/          → Router (GoRouter), theme, constants, routes
├── providers/     → ChangeNotifier state (auth, user, scanner, reminders, diary, purchase, ads, news)
├── services/      → Firebase abstraction (auth, firestore, notifications, purchases, ads)
├── screens/       → Feature screens + widgets per feature
├── models/        → Data models
├── database/      → SQLite via sqflite — offline storage (chats, diary, reminders, scans)
└── widgets/       → Shared widgets (bottom nav)
```

**State Management:** Provider (ChangeNotifier)  
**Router:** GoRouter with ShellRoute for bottom nav  
**Local DB:** SQLite (sqflite) for offline-first storage  
**Backend:** Firebase Cloud Functions (region: asia-south1)  
**AI Engine:** Gemini 2.5 Flash via Cloud Functions  
**Monetization:** RevenueCat (in-app purchases) + Google AdMob (rewarded ads)

**User Flow:**
```
Splash → maintenance/force-update check → onboarding → login (Google Sign-In) → terms → home
```

**Credit System:**
- Free users: 5 `freeCredits` (reset daily) + `adCredits` earned by watching ads (max 3 ads/day, +2 credits each)
- Pro users: Unlimited access via RevenueCat entitlement

---

### cliniq_admin (Admin Dashboard) — Flutter Web

A Flutter web app for internal admin use. Features:
- Dashboard with real-time stats (users, scans, pro subscribers)
- Last 7-day charts (scans, new users)
- User management table
- App config editor (maintenance mode, force update)
- Push notification sender (target: all / pro / free)
- Subscription management

---

### Backend — Firebase Cloud Functions (Node.js)

| Function | Type | Purpose |
|---|---|---|
| `scanMedicine` | `onCall` | OCR text → Gemini → medicine explanation + cache |
| `sicknessGuide` | `onCall` | Multi-step AI symptom assessment |
| `summarizePrescription` | `onCall` | Prescription OCR text summarizer |
| `generateDiaryInsights` | `onCall` | AI insights from diary entries |
| `fetchHealthNews` | `onCall` | Health news feed |
| `rewardAdCredits` | `onCall` | Ad watch reward → +2 adCredits |
| `sendNotification` | `onDocumentCreated` | FCM push to user segments |
| `onUserCreate` | `onDocumentCreated` | Initialize new user data |
| `resetDailyCredits` | `onSchedule` | Daily credit reset at midnight IST — **NOT DEPLOYED** ⚠️ |

---

## Critical Bugs (Deploy Blockers)

### 🔴 Bug 1 — RevenueCat TEST API Key in Production Code

**Files:**
- `lib/main.dart:58`
- `lib/services/purchase_service.dart:11`

```dart
// main.dart
PurchasesConfiguration('test_VAKmDgIfZyXWuGdDIDfGucozGZZ')

// purchase_service.dart
static const String _apiKey = 'test_VAKmDgIfZyXWuGdDIDfGucozGZZ';
```

**Impact:** The `test_` prefix means this is a sandbox key. Real purchases will fail completely in production. No user will be able to subscribe.

**Fix:** Replace with your live RevenueCat production API key.

---

### 🔴 Bug 2 — RevenueCat Double Initialization

**Files:**
- `lib/main.dart:56-58` (initializes before `runApp`)
- `lib/services/purchase_service.dart:15-26` (initializes again via `PurchaseService.initialize()`)

```dart
// main.dart — runs first, before any user context
await Purchases.setLogLevel(LogLevel.debug);
await Purchases.configure(
  PurchasesConfiguration('test_VAKmDgIfZyXWuGdDIDfGucozGZZ'),
);
```

**Impact:** RevenueCat is configured without a `userId` in `main()`, then reconfigured later. The `PurchaseService._initialized` guard may prevent the second init from running correctly, leaving the SDK with no user attached.

**Fix:** Remove RevenueCat init from `main.dart` entirely. Let only `PurchaseService.initialize(userId)` manage it, called after the user is authenticated.

---

### 🔴 Bug 3 — `resetDailyCredits` Never Deployed (Missing from index.js)

**File:** `cliniq_admin/functions/index.js`

The scheduled Cloud Function that resets free credits daily exists at `functions/src/credits/resetDailyCredits.js` but is **never imported or exported** in `index.js`. It is therefore never deployed to Firebase.

```js
// index.js — resetDailyCredits is MISSING
module.exports = {
  onUserCreate,
  scanMedicine,
  sicknessGuide,
  rewardAdCredits,
  summarizePrescription: summarizePrescriptionFn,
  generateDiaryInsights,
  fetchHealthNews,
  sendNotification,
  // ← resetDailyCredits is not here!
};
```

**Impact:** User credits are **never reset**. Free users who exhaust their 5 daily credits on day 1 never get them back unless they watch ads. This breaks the core free-tier experience.

**Fix:**
```js
// Add to index.js
const { resetDailyCredits } = require('./src/credits/resetDailyCredits');

module.exports = {
  // ...existing exports
  resetDailyCredits,
};
```

---

### 🔴 Bug 4 — Broken Code Structure in `geminiHelper.js`

**File:** `cliniq_admin/functions/src/utils/geminiHelper.js`

The `summarizePrescription` function and an inner `module.exports` are defined **inside `getSicknessGuide` after its `return` statement** — making them unreachable dead code:

```js
const getSicknessGuide = async (...) => {
  // ... logic ...
  return text;  // ← function returns here

  // ↓ DEAD CODE — never executes
  const summarizePrescription = async (ocrText) => { ... };
  module.exports = { explainMedicine, getSicknessGuide, summarizePrescription };
};

// Outer module.exports overwrites inner (which never ran anyway)
module.exports = { explainMedicine, getSicknessGuide, callGemini };
```

**Impact:** The `summarizePrescription` in `geminiHelper.js` is completely inaccessible. The app uses the separate `src/ai/summarizePrescription.js` so it still works, but the dead code causes confusion and the file has two `module.exports` which is a maintenance hazard.

**Fix:** Remove the dead code block from inside `getSicknessGuide`. Clean up the outer `module.exports` to only list what's actually defined at the top level.

---

## Logic Bugs

### 🟡 Bug 5 — `_isLoading` in `UserProvider` is `final` (Loading State Broken)

**File:** `lib/providers/user_provider.dart:53`

```dart
final bool _isLoading = false;  // ← `final` means it can never be reassigned
```

The `isLoading` getter always returns `false`. Any UI widget that shows a loading indicator based on `UserProvider.isLoading` will never show it.

**Fix:**
```dart
bool _isLoading = false;  // remove `final`
```

---

### 🟡 Bug 6 — Credit Race Condition (TOCTOU) in `scanMedicine`

**File:** `cliniq_admin/functions/src/ai/scanMedicine.js:29-69`

The function checks if the user has credits, then calls Gemini (an async operation that can take 2-5 seconds), then deducts credits. Two simultaneous requests from the same user both pass the credit check before either deduction runs.

```js
// Step 1: check credits (both requests pass)
const credits = await hasCredits(uid);

// Step 2: call Gemini — ~2-5s window where both requests are "in flight"
explanation = await explainMedicine(medicineName);

// Step 3: deduct (both requests deduct — user loses 2 credits for 2 scans but had only 1)
await deductCredit(uid);
```

**Impact:** A user with 1 credit can trigger 2 scans simultaneously and both succeed.

**Fix:** Use a Firestore transaction to atomically check and decrement credits in a single operation before calling Gemini.

---

### 🟡 Bug 7 — `deleteReminder` Deletes by Medicine Name (Not Unique)

**File:** `lib/providers/reminders_provider.dart:94-105`

```dart
final reminderName = _allReminders.firstWhere((r) => r.id == id).medicineName;
final snap = await _db
    .collection('users').doc(uid).collection('reminders')
    .where('medicineName', isEqualTo: reminderName)
    .get();
for (final doc in snap.docs) {
  await doc.reference.delete();  // deletes ALL reminders with this name
}
```

**Impact:** If a user has two reminders for the same medicine (e.g., "Paracetamol" morning and "Paracetamol" night added separately), deleting one deletes both from Firestore.

**Fix:** Store the Firestore document ID in the local SQLite row, then delete by document ID directly.

---

### 🟡 Bug 8 — `RevenueCat LogLevel.debug` in Production

**Files:**
- `lib/main.dart:56`
- `lib/services/purchase_service.dart:18`

```dart
await Purchases.setLogLevel(LogLevel.debug);
```

**Impact:** Verbose purchase logs are printed in release builds, exposing internal flow and potentially sensitive purchase data in logs.

**Fix:**
```dart
await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
```

---

### 🟡 Bug 9 — Hospitals Screen is a Placeholder

**File:** `lib/core/router.dart:47-50`

```dart
GoRoute(
  path: AppRoutes.hospitals,
  builder: (context, state) => const Scaffold(
    body: Center(child: Text('Hospitals')),
  ),
),
```

**Impact:** If this route is reachable from the UI, users see a blank "Hospitals" text with no functionality.

**Fix:** Either implement the feature or remove the route and any UI entry points leading to it before releasing.

---

### 🟡 Bug 10 — Fragile Timezone Detection

**File:** `lib/services/notification_service.dart:123-148`

Uses `offset.inHours` (integer truncation) to guess the timezone. Half-hour and quarter-hour offsets (IST = UTC+5:30, NPT = UTC+5:45, etc.) are mishandled. IST works by accident because 5:30 truncates to 5, which hits the special-case `if (hours == 5) return 'Asia/Kolkata'` — but UTC+5 (Pakistan) also returns `'Asia/Kolkata'`, and many timezones are not in the map at all, silently falling back to `'Asia/Kolkata'`.

**Fix:** Add the `flutter_timezone` package and use `FlutterTimezone.getLocalTimezone()` for an accurate IANA timezone name.

---

### 🟡 Bug 11 — `onUserCreate` Function is Redundant

**File:** `cliniq_admin/functions/src/auth/onUserCreate.js`

When a new user signs in, `AuthService._createUserIfNew()` in the Flutter app already writes all default values (`freeCredits: 5`, `plan: 'free'`, etc.) to Firestore. The `onUserCreate` Cloud Function then triggers on the same document creation and writes the same values again.

**Impact:** An extra Firestore write per user signup. No user-facing bug, but wastes reads/writes and could cause subtle overwrites if timings differ.

---

### 🟡 Bug 12 — `print()` Statements in cliniq_admin Production Code

**File:** `cliniq_admin/lib/services/auth_service.dart:23,27,30`

```dart
print('Checking admin for UID: $uid');   // leaks in release
print('Document exists: ${doc.exists}');
print('Error: $e');
// Also has: // ← ADD THIS comments left in code
```

**Impact:** `print()` (unlike `debugPrint()`) outputs in release builds, leaking internal logic details.

**Fix:** Replace all `print()` with `debugPrint()`, and remove leftover development comments.

---

## Security Notes

### 🔵 Note 1 — Firebase API Key in `firebase_options.dart`

The Firebase Android API key (`AIzaSy...`) is hardcoded in `lib/firebase_options.dart`. This is standard Flutter practice — Firebase client keys are designed to be public and access is controlled by **Firestore Security Rules** and **Firebase App Check**.

**Action Required:** Verify your Firestore Security Rules strictly enforce:
- Users can only read/write their own documents (`request.auth.uid == userId`)
- `adminUsers` collection is not readable by regular users
- `medicine_cache`, `appStats`, `appConfig` are read-only for users

---

### 🔵 Note 2 — Admin Panel Auth is Client-Side Only

**File:** `cliniq_admin/lib/services/auth_service.dart:21-31`

The admin check reads the `adminUsers` Firestore collection from the client app. The security entirely depends on Firestore rules.

**Recommended Firestore Rule for adminUsers:**
```
match /adminUsers/{uid} {
  allow read: if request.auth != null && request.auth.uid == uid;
  allow write: if false;
}
```

---

### 🔵 Note 3 — `sendNotification` Loads All Users into Memory

**File:** `cliniq_admin/functions/src/notifications/sendNotification.js:22-26`

For `target: 'all'`, the function fetches every user document into memory at once. At small scale this is fine. At 100k+ users this will hit Cloud Functions memory limits and timeout.

**Future Fix (when needed):** Use batch processing with Firestore cursors or Firebase Admin's FCM topic subscriptions.

---

## Deploy Readiness Summary

| Component | Status | Reason |
|---|---|---|
| **cliniq — Android** | ❌ Not Ready | RevenueCat test key, double-init, debug log level |
| **cliniq — iOS** | ❌ Blocked | Firebase not configured for iOS (`UnsupportedError` thrown) |
| **Firebase Functions** | ❌ Not Ready | `resetDailyCredits` never deployed, geminiHelper dead code |
| **cliniq_admin dashboard** | ✅ Usable | Minor issues only (debug prints, no user-facing impact) |

---

## Fix Checklist

### Before Any Release

- [ ] **Replace RevenueCat test key** with production key in `purchase_service.dart`
- [ ] **Remove RevenueCat init from `main.dart`** — let `PurchaseService.initialize()` own it
- [ ] **Set RevenueCat log level to error** in release: `kDebugMode ? LogLevel.debug : LogLevel.error`
- [ ] **Add `resetDailyCredits` to `functions/index.js`** — most critical backend fix
- [ ] **Clean up `geminiHelper.js`** — remove dead code inside `getSicknessGuide`, fix double `module.exports`
- [ ] **Fix `final bool _isLoading`** in `UserProvider` → remove `final`
- [ ] **Remove or implement** the Hospitals placeholder route

### Before iOS Release

- [ ] **Configure Firebase for iOS** using FlutterFire CLI: `flutterfire configure`
- [ ] **Add iOS signing config** and provisioning profile
- [ ] **Set up AdMob iOS App ID** in `Info.plist`
- [ ] **Add required iOS permission strings** to `Info.plist` (camera, photo library, location, notifications)

### Recommended Improvements

- [ ] **Fix credit race condition** in `scanMedicine` using Firestore transaction
- [ ] **Fix `deleteReminder`** to use Firestore document ID instead of medicine name
- [ ] **Replace timezone detection** with `flutter_timezone` package
- [ ] **Replace `print()`** with `debugPrint()` in `cliniq_admin`
- [ ] **Review Firestore Security Rules** for all collections
- [ ] **Verify `adminUsers` rules** restrict reads to own UID only
