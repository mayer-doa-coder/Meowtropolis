# Lightweight Backend Validation Guide (Meowtropolis)

## Step-by-step validation guide

### 1) Goal

What is backend validation?
- Backend validation means confirming that Firebase Auth + Firestore services work correctly with the app's data models.
- It checks that writes and reads are correct, and data flows through service classes without crashes.

Why lightweight smoke testing matters before final submission
- It catches critical backend issues early (wrong collection path, auth session problems, decode errors).
- It gives confidence that MVP features are reliable for demo/submission.
- It avoids heavy test setup while still validating the most important paths.

---

### 2) Run backend smoke tests

Primary entry point:
- `BackendSmokeTests.runAll()` in `Meowtropolis/Services/BackendSmokeTests.swift`

What it now runs:
1. Auth smoke test
- signup
- login
- logout
- login again (session restore for Firestore rules)

2. UserService smoke test
- create profile
- fetch profile

3. PetService smoke test
- add pet
- list pets
- update pet
- delete pet

4. BookingService smoke test
- create booking
- list bookings by user
- update booking status

5. ProductService smoke test
- fetch products (Firestore first)
- fallback to local JSON when Firestore empty/fails

6. LocalProductService smoke test
- load products from `products.json`
- decode into `[Product]`
- print loaded products

Smoke log style:
- `[PASS] ...`
- `[FAIL] ... => ...`
- `[INFO] ...`
- Final summary line with passed/failed count

---

### 3) Verify Firestore paths

Collections validated by services:
- `users`
- `pets`
- `bookings`
- `products`

Where centralized constants are defined:
- `Meowtropolis/Services/FirestoreCollections.swift`

Validation result:
- Services use `FirestoreCollections.*` for collection names.
- No hardcoded collection names found in service `db.collection(...)` usage.

Notes:
- `whereField("userId")` and `whereField("petId")` are field filters, not collection path issues.

---

### 4) Validate ProductService behavior

Current behavior in `Meowtropolis/Services/ProductService.swift`:
- Firestore-first request is attempted first.
- If Firestore returns products, use Firestore result.
- If Firestore returns empty or fails, fallback to local JSON.

Added source logs:
- `[ProductService] Loaded from Firestore`
- `[ProductService] Loaded from Local JSON`

These appear in addition to count logs and fallback reason logs.

---

### 5) Validate LocalProductService

Current behavior in `Meowtropolis/Services/LocalProductService.swift`:
- Reads `products.json` from app bundle root or `SampleData/products.json`.
- Decodes into `[Product]`.

Verification support:
- `BackendSmokeTests.runLocalProductSmokeTest(...)` now prints:
  - load count
  - full decoded product array

---

### 6) Issues identified and fixed (critical-only)

Issue fixed:
- Smoke tests were ending auth flow in logged-out state before Firestore service checks.
- With rules `allow read, write: if request.auth != null`, downstream service tests could fail.

Fix applied:
- In `runAuthSmokeTest`, after validating logout, a final sign-in restores session before continuing.

Additional validation improvements:
- Added explicit product source logs required for quick debugging.
- Added dedicated local product smoke test execution and output.

No major refactor and no new features were introduced.

---

## Validation checklist

- [ ] `BackendSmokeTests.runAll()` executes start-to-end without interruption
- [ ] Auth signup/login/logout/session-restore logs show pass
- [ ] UserService create/fetch logs show pass
- [ ] PetService add/list logs show pass
- [ ] BookingService create/list logs show pass
- [ ] ProductService fetch logs show pass
- [ ] Firestore collections used are users/pets/bookings/products
- [ ] Service collection paths use `FirestoreCollections` constants
- [ ] ProductService logs include Firestore or Local JSON source
- [ ] LocalProductService loads and prints decoded products
- [ ] Final summary shows 0 failed checks

---

## Example logs

### Example success output

```text
=== Backend Smoke Tests: Start ===
[PASS] Auth signUp
[PASS] Auth signIn
[PASS] Auth signOut
[PASS] Auth signIn (session restore)
[PASS] Auth flow completed, userId => abc123
[PASS] User create profile
[PASS] User fetch profile => abc123
[PASS] Pet add
[PASS] Pet list count => 1
[PASS] Pet update
[PASS] Pet delete
[PASS] Booking create
[PASS] Booking list by user count => 1
[PASS] Booking update status
[ProductService] Source: Firestore. Products loaded: 3
[ProductService] Loaded from Firestore
[PASS] Product fetch count => 3
[INFO] Product list => [Meowtropolis.Product(...)]
[PASS] Local product load count => 3
[INFO] Local products => [Meowtropolis.Product(...)]
=== Backend Smoke Tests: End ===
Summary: 16/16 checks passed, 0 failed
```

### Example fallback output

```text
[ProductService] Falling back to local data. Reason: Firestore returned empty product list
[ProductService] Source: Local JSON. Products loaded: 3
[ProductService] Loaded from Local JSON
```

### Example debug statements to track product source

```text
[ProductService] Loaded from Firestore
[ProductService] Loaded from Local JSON
```
