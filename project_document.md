# Meowtropolis Final MVP Project Document

## 1. Phase Status

This project is in the final phase before demo.

Current focus:
- Documentation completion
- End-to-end validation
- Stability checks
- Freeze enforcement

No new feature development is allowed in this phase.

---

## 2. MVP Scope (Locked)

Included MVP features:
- Authentication: signup, login, logout, session restore
- Dashboard navigation
- Pet profile management: add, edit, delete, list
- Grooming booking flow
- Vet consultation request flow
- Marketplace browsing and product detail
- Map tab with nearby place discovery

Excluded from MVP:
- Payments and advanced checkout
- Video consultation
- Community/social features
- Subscription system
- Non-critical redesign/refactor work

---

## 3. Architecture Snapshot

Technology:
- Swift + SwiftUI frontend
- Firebase Auth + Firestore backend
- XCTest unit tests and UI tests

Layering rules:
- Views: screen UI only
- State: loading/error/data orchestration
- Services: Firebase and external SDK integration
- Models: Codable data structures

The freeze phase keeps this architecture unchanged.

---

## 4. Full MVP End-to-End Flow

Primary demo flow:
1. Auth
2. Dashboard
3. Pet Profile
4. Grooming
5. Vet
6. Marketplace
7. Map
8. Logout back to auth

Detailed verification path:
1. Launch app and verify startup route
2. Signup or login with valid user
3. Confirm Dashboard opens and tab navigation works
4. Open Pet Profile and perform add/edit/delete/list checks
5. Open Grooming and create/view/update booking
6. Open Vet and submit/view consultation request
7. Open Marketplace and browse products, open product detail
8. Open Map tab and validate nearby search states
9. Logout and confirm auth route is restored

---

## 5. Map Flow (New in Final MVP)

Map user flow:
1. Open Map tab
2. Select a category chip
3. Trigger place search
4. View nearby places
5. Verify state handling:
   - Loading
   - Empty
   - Error
   - Retry

Map state expectations:
- Loading state shows indicator and no crash
- Empty state shows no-results message and remains interactive
- Error state shows error message and retry button
- Retry action triggers new search attempt path

---

## 6. Acceptance Criteria (Critical)

### Authentication
- [ ] Signup works with valid credentials
- [ ] Login works with valid credentials
- [ ] Logout clears session and returns to auth
- [ ] Auth/session restore works after app restart
- [ ] Auth errors are visible and non-blocking

### Dashboard Navigation
- [ ] Dashboard opens after login
- [ ] Tab switching works without route breaks
- [ ] Existing tabs remain unchanged
- [ ] No shared-state conflicts between tabs

### Pet Profile
- [ ] Add pet saves successfully
- [ ] Edit pet updates successfully
- [ ] Delete pet removes item successfully
- [ ] Pet list loads correctly
- [ ] Empty and error states are handled

### Grooming
- [ ] Booking creation works
- [ ] Booking list loads correctly
- [ ] Booking status update works
- [ ] Loading and error states are handled
- [ ] No navigation regressions

### Vet
- [ ] Request submission works
- [ ] Request list loads correctly
- [ ] Request status display is correct
- [ ] Loading and error states are handled
- [ ] No navigation regressions

### Marketplace
- [ ] Product list loads correctly
- [ ] Product detail opens correctly
- [ ] Firestore/local fallback path is stable
- [ ] Loading/empty/error states are handled
- [ ] No crash when data source changes

### Map Feature
- [ ] Map tab opens successfully
- [ ] Categories trigger search
- [ ] Places load correctly
- [ ] Empty state handled
- [ ] Error state and retry work
- [ ] No crashes during map interactions

---

## 7. Fresh Install Simulator Rehearsal

Run this on macOS + Xcode:
1. Delete app from simulator
2. Product -> Clean Build Folder
3. Reinstall and launch app
4. Run the full MVP demo flow

Validation targets:
- [ ] Firebase auth works from scratch
- [ ] No cached-data dependency
- [ ] No first-launch crash
- [ ] Map tab loads correctly
- [ ] Location permission paths are handled

Execution note for current environment:
- Runtime simulator rehearsal cannot be executed from this Windows workspace.
- Code and documentation were updated for a macOS/Xcode rehearsal run.

---

## 8. Bug Sweep Rules (Final Phase)

Allowed fixes only:
- Crashes
- Broken flow/navigation
- Data not loading
- Blocking error-state failures

Not allowed in final phase:
- New features
- Non-critical UI polish
- Refactors not required for stability
- Design/system changes

---

## 9. Logging Verification

Required logging domains:
- App startup logs
- Auth flow logs
- Map usage logs
- Error logs

Verification status:
- App startup logs: present (app init and root appear)
- Auth logs: present (check session, login, signup, logout, auth state)
- Map logs: present (map open, category select, retry, search, service status)
- Error logs: present (location, places, map state, fallback errors)

---

## 10. Freeze Policy

Project is now in freeze state. Only critical issues affecting demo or core functionality will be addressed.

Freeze rules:
- No new features
- No refactoring
- No UI redesign
- Critical bug fixes only

---

## 11. Final Checklist

- [ ] All MVP features implemented
- [ ] All flows tested end-to-end
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] No major bugs
- [ ] Demo script ready
- [ ] App works on fresh install
- [ ] Freeze policy declared

---

## 12. Demo-Ready Deliverables

- Updated final project document
- Demo script with speaking notes and backup paths
- Freeze policy declaration
- Final checklist for sign-off
