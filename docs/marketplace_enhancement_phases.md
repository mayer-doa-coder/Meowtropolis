# Marketplace Enhancement Plan (Phase-wise)

## Phase 0 - Scope Lock and KPI Setup
Duration: 0.5 day

### Goal
Freeze enhancement scope and define measurable outcomes before implementation.

### Tasks
- Finalize sprint feature list:
  - quick add-to-cart from listing
  - category and price filters
  - recently viewed products
  - low-stock and featured badges
- Define KPI targets:
  - add-to-cart rate
  - detail-to-cart conversion
  - search-to-purchase conversion
  - average cart value

### Deliverables
- Approved sprint scope.
- KPI tracking sheet.

### Exit Criteria
- Team agrees on exact sprint features.
- No unresolved requirement ambiguity.

---

## Phase 1 - Data Contract Upgrades
Duration: 1 day

### Goal
Upgrade product metadata so filtering and merchandising are reliable.

### Tasks
- Extend product schema with:
  - animalType (cat, dog, all)
  - brand
  - isFeatured
  - optional originalPrice and discountPercent
  - optional rating and reviewCount
- Add backward-compatible defaults for old product documents.
- Update Firestore sample product documents with new fields.

### Deliverables
- Updated product model contract.
- Seeded Firestore products with new metadata fields.

### Exit Criteria
- Old products still load correctly.
- New filters do not rely on keyword guessing.

---

## Phase 2 - Marketplace UX Quick Wins
Duration: 2 days

### Goal
Increase listing-page conversion and reduce friction to add items.

### Tasks
- Add quick add-to-cart action on product rows.
- Add category chips and price-range filter.
- Add low-stock and featured badges.
- Persist search and filter state when returning from detail page.
- Improve empty state with reset-filter action.

### Deliverables
- Updated marketplace listing UX.
- Improved filter and search usability.

### Exit Criteria
- User can add to cart from listing in one tap.
- Filters are visible, usable, and state-persistent.
- UI remains responsive while filtering.

---

## Phase 3 - Product Detail Conversion Layer
Duration: 1 day

### Goal
Improve add-to-cart conversion from product detail page.

### Tasks
- Add related products section ("You may also like").
- Add pricing treatment:
  - strike-through original price when discounted
  - savings label
- Add trust signals:
  - rating and review count
  - clearer low-stock urgency

### Deliverables
- Enhanced product detail page with cross-sell block.

### Exit Criteria
- Related product navigation works.
- Discount and stock signals display correctly.

---

## Phase 4 - Performance and Reliability
Duration: 1.5 days

### Goal
Keep store experience fast and stable as product volume increases.

### Tasks
- Add in-memory cache with TTL in product service.
- Add pagination or load-more in Firestore product fetching.
- Add search debounce.
- Improve fallback messaging when Firestore fails and local data is used.

### Deliverables
- Faster product load and smoother list performance.
- Stable behavior under weak network conditions.

### Exit Criteria
- Initial load time is improved.
- No regression in Firestore-to-local fallback behavior.

---

## Phase 5 - Cart and Checkout Enhancements
Duration: 1 day

### Goal
Improve cart quality and checkout readiness.

### Tasks
- Add cart recommendations based on selected categories.
- Show savings summary and estimated delivery message.
- Improve validation and stock-sync messaging in cart and checkout.

### Deliverables
- Enhanced cart summary and upsell surface.

### Exit Criteria
- Cart shows meaningful summary and recommendations.
- Checkout flow remains stable and clear.

---

## Phase 6 - Analytics, QA, and Release
Duration: 1 day

### Goal
Ship safely and measure real impact.

### Tasks
- Track analytics events:
  - filter changed
  - quick add clicked
  - recommendation clicked
  - add-to-cart success
- Run functional QA for:
  - search, filter, and sort combinations
  - stock edge cases
  - offline fallback behavior
- Run regression QA on cart and checkout.

### Deliverables
- QA pass checklist.
- Release notes with KPI baseline and target.

### Exit Criteria
- No critical or blocker-level issues.
- Metrics instrumentation verified.

---

## Suggested 7-Day Sprint Cut
- Day 1: Phase 0 + Phase 1
- Day 2-3: Phase 2
- Day 4: Phase 3
- Day 5: Phase 4
- Day 6: Phase 5
- Day 7: Phase 6 and release

## Team Split Suggestion
- Member A: Product model and Firestore contract updates.
- Member B: Marketplace list UX and filter interactions.
- Member C: Product detail conversion features and cart recommendations.
- Member D: Performance optimization, QA, and release validation.
