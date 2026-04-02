# Meowtropolis Stabilization and Sign-off (Final Integration Check)

## 1) Goal (Simple)

### What is stabilization and sign-off?
Stabilization and sign-off means we pause adding features and verify the full app is reliable.

We focus on:
- End-to-end testing
- Fixing only critical and high-priority issues
- Confirming architecture rules
- Freezing service interfaces so team members stop changing contracts

### Why this step matters before new features
- Prevents hidden bugs from spreading into new work
- Gives confidence for demo/release
- Keeps integration predictable for all team members

---

## 2) Backend Smoke Test Plan

Use `BackendSmokeTests.runAll()` to test all core services in sequence:
- AuthService: signup, login, logout, session-restore login
- UserService: create profile, fetch profile
- PetService: add, list, update, delete
- BookingService: create, list, update status
- ProductService: Firestore first, then local JSON fallback
- LocalProductService: direct bundle JSON load and decode check

Smoke logger format is now standardized:
- `[PASS] <step>`
- `[FAIL] <step> => <error>`
- Final summary line

---

## 3) Manual User Journey Checklist

Run this as one continuous flow on a clean build:

1. Signup
- [ ] Create account successfully
- [ ] See success message

2. Login
- [ ] Login succeeds
- [ ] App routes to dashboard automatically

3. Pet CRUD
- [ ] Add pet from My Pets screen
- [ ] Pet appears in list
- [ ] Edit pet and verify update
- [ ] Delete pet and verify removal

4. Booking (Grooming)
- [ ] Create booking with pet + service + date/time
- [ ] Booking appears in list
- [ ] Update status (pending/confirmed/completed/cancelled)
- [ ] Optional pet filter updates list

5. Marketplace
- [ ] Products load in Store screen
- [ ] If Firestore has data, products come from Firestore
- [ ] If Firestore fails/empty, fallback local JSON products appear
- [ ] Product detail opens with selected product data

6. Logout
- [ ] Session clears
- [ ] App routes back to auth flow

7. Stability
- [ ] No crashes
- [ ] No broken navigation
- [ ] No stale user data after logout

---

## 4) Architecture Check (Must Pass)

### Rule
UI views must not call Firebase/Firestore directly.

### Current status
PASS: Views use state/services. Backend calls are in service layer only:
- `AuthService` / `FirebaseAuthService`
- `UserService`
- `PetService`
- `BookingService`
- `ProductService` (+ `FirestoreProductService`, `LocalProductService`)

---

## 5) Example Critical Bug Fix (Done)

### Bug
`ProductService.fetchProducts` previously captured `self` weakly and could return early without calling completion in edge cases (service deallocation during async flow).

### Impact
Marketplace screen could stay in loading state forever.

### Fix
Refactored fetch flow to use captured service references and always call completion from either Firestore path or local fallback path.

---

## 6) Frozen Service Method Signatures

Do not change these signatures after sign-off.

### AuthService
- `var currentUserId: String? { get }`
- `func addAuthStateDidChangeListener(_ listener: @escaping (String?) -> Void) -> NSObjectProtocol`
- `func removeAuthStateDidChangeListener(_ handle: NSObjectProtocol)`
- `func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)`
- `func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)`
- `func signOut(completion: @escaping (Result<Void, Error>) -> Void)`
- `func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)`

### UserService
- `func createUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void)`
- `func fetchCurrentUser(userId: String, completion: @escaping (Result<User, Error>) -> Void)`

### PetService
- `func listPets(userId: String, completion: @escaping (Result<[Pet], Error>) -> Void)`
- `func addPet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void)`
- `func updatePet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void)`
- `func deletePet(petId: String, completion: @escaping (Result<Void, Error>) -> Void)`

### BookingService
- `func createBooking(_ booking: Booking, completion: @escaping (Result<Void, Error>) -> Void)`
- `func listBookingsByUser(userId: String, completion: @escaping (Result<[Booking], Error>) -> Void)`
- `func listBookingsByPet(petId: String, completion: @escaping (Result<[Booking], Error>) -> Void)`
- `func updateBookingStatus(bookingId: String, status: BookingStatus, completion: @escaping (Result<Void, Error>) -> Void)`

### ProductService and product data providers
- `func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)`
- `FirestoreProductService.fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)`
- `LocalProductService.loadProducts(completion: @escaping (Result<[Product], Error>) -> Void)`

---

## 7) Example Smoke Test Output (Expected Format)

```
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
[PASS] Local product load count => 3
=== Backend Smoke Tests: End ===
Summary: 16/16 checks passed, 0 failed
```

Fallback example:

```
[ProductService] Falling back to local data. Reason: Firestore returned empty product list
[ProductService] Source: Local JSON. Products loaded: 3
```

---

## 8) Sign-off Decision

Mark project as READY for next phase only when:
- Smoke test summary has no failed checks
- Manual journey checklist passes end-to-end
- No critical/high-priority bugs remain
- Service signatures remain unchanged
