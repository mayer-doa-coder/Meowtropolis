# Issue Inventory (Phase 0 Baseline)

## Scope
This inventory is for observation and prioritization only.
No fixes are applied in this phase.

## Prioritization Rule
- Focus on usability first.
- Critical issues block demo readiness.
- High issues degrade user experience and should be addressed before demo if possible.
- Medium issues are optional unless time allows.

## Issue Entry Format
- Title
- Severity (Critical / High / Medium)
- Screen/Feature
- Description
- Steps to reproduce
- Expected behavior
- Actual behavior

---

## Critical (must fix before demo)

### 1) Title: End-to-end auth verification from fresh install is pending
- Severity: Critical
- Screen/Feature: Authentication (Login/Signup/Session)
- Description: Full auth reliability from a clean simulator install has not been validated yet in this environment.
- Steps to reproduce:
  1. Delete app from simulator.
  2. Clean build and reinstall.
  3. Run signup -> login -> logout -> login flow.
- Expected behavior: All auth actions succeed and route correctly.
- Actual behavior: Not yet verified in this environment (requires macOS simulator run).

### 2) Title: Grooming booking persistence from clean install is pending verification
- Severity: Critical
- Screen/Feature: Grooming
- Description: Booking create/list/update flow needs runtime verification on clean install to confirm Firestore write/read reliability.
- Steps to reproduce:
  1. Fresh install app.
  2. Login.
  3. Create grooming booking.
  4. Reload screen and verify booking persists.
- Expected behavior: Booking saves and reloads consistently.
- Actual behavior: Not yet verified in this environment (requires macOS simulator run).

### 3) Title: Vet request persistence from clean install is pending verification
- Severity: Critical
- Screen/Feature: Vet consultation flow
- Description: Vet request create/list behavior needs runtime verification to confirm stable write/read flow.
- Steps to reproduce:
  1. Fresh install app.
  2. Login.
  3. Submit vet request.
  4. Reload screen and verify request persists.
- Expected behavior: Request saves and appears in user list.
- Actual behavior: Not yet verified in this environment (requires macOS simulator run).

---

## High (affects usability)

### 4) Title: Onboarding branding text mismatch
- Severity: High
- Screen/Feature: Launch/Onboarding
- Description: Onboarding copy contains brand naming that does not match Meowtropolis.
- Steps to reproduce:
  1. Open app to onboarding screen.
  2. Review hero heading/subheading text.
- Expected behavior: Branding text consistently references Meowtropolis.
- Actual behavior: Inconsistent branding text appears.

### 5) Title: Checkout copy still indicates demo wording
- Severity: High
- Screen/Feature: Marketplace -> Checkout
- Description: User-facing checkout wording includes demo-style language, which reduces production confidence.
- Steps to reproduce:
  1. Open Marketplace.
  2. Open Cart.
  3. Navigate to Checkout.
- Expected behavior: Clear production-ready checkout wording.
- Actual behavior: Demo wording appears in checkout UI.

### 6) Title: Social auth actions appear enabled without confirmed backend path
- Severity: High
- Screen/Feature: Auth Landing
- Description: Google/Facebook buttons appear actionable but end-to-end behavior is not confirmed in current MVP baseline.
- Steps to reproduce:
  1. Open auth landing.
  2. Tap social login actions.
- Expected behavior: Actionable flow or clearly disabled/non-primary affordance.
- Actual behavior: Runtime behavior not confirmed for baseline.

### 7) Title: Feedback consistency varies across major screens
- Severity: High
- Screen/Feature: Auth, Grooming, Vet, Marketplace, Map
- Description: Loading/error feedback presentation is inconsistent, increasing cognitive load for first-time users.
- Steps to reproduce:
  1. Navigate each screen.
  2. Trigger loading or error states.
  3. Compare messaging style and placement.
- Expected behavior: Consistent loading/error feedback patterns.
- Actual behavior: Different styles and placements are used.

---

## Medium (minor UX polish)

### 8) Title: Placeholder-like descriptive copy in product detail
- Severity: Medium
- Screen/Feature: Product Detail
- Description: Product detail includes generic explanatory copy that reads like placeholder text.
- Steps to reproduce:
  1. Open Marketplace.
  2. Open any product detail.
- Expected behavior: Product-centric user-facing detail text.
- Actual behavior: Generic system-style explanatory text appears.

### 9) Title: Spacing and card opacity feel inconsistent across tabs
- Severity: Medium
- Screen/Feature: Dashboard tabs (Pet, Grooming, Vet, Marketplace)
- Description: Card spacing/opacity patterns vary and reduce visual consistency.
- Steps to reproduce:
  1. Compare card sections across major tabs.
  2. Observe spacing and background intensity.
- Expected behavior: Consistent layout rhythm and card treatment.
- Actual behavior: Minor variation between screens.

### 10) Title: Some user messages are longer than needed for beginners
- Severity: Medium
- Screen/Feature: Multiple screens
- Description: Some helper or status texts are verbose and could be simplified.
- Steps to reproduce:
  1. Visit auth and service screens.
  2. Review helper and status copy.
- Expected behavior: Short, direct beginner-friendly messages.
- Actual behavior: Mixed message lengths and tone.

---

## Team Alignment
- Phase: Blocking Phase 0 (observe, document, protect only)
- Branch: feature/ui-correction
- Next step after this file: complete simulator screenshot capture and update screenshot checklist.
