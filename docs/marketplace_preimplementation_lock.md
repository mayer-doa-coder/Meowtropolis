# Marketplace Pre-Implementation Lock

## Phase Purpose
This is a pre-implementation lock for Meowtropolis marketplace enhancements.
No production development starts until this document is approved.

## Locked Sprint Feature Scope
Only the six features below are in scope.
No additional feature is allowed in this sprint.

### 1. Quick Add-to-Cart
Description: User can add a product from listing without opening product details.
User Action: Tap Add button on product row.
UI Placement: Right side of each product row in marketplace list.
Expected Outcome: Item is added to cart immediately and cart count updates.
Edge Cases:
- Product stock is 0: Add button is disabled and shows Out of stock state.
- User taps multiple times quickly: quantity increments up to available stock only.
- Product no longer available after sync: show non-blocking message and prevent add.

### 2. Category Filter
Description: User filters product list by product category.
User Action: Select one category chip from filter bar.
UI Placement: Horizontal filter section under search.
Expected Outcome: Listing updates to show only products with selected category.
Edge Cases:
- No products in selected category: show empty state with clear reset action.
- Legacy products missing category: treated as uncategorized and excluded from category-specific filters.
- Category names with inconsistent casing: normalized to lowercase for matching.

### 3. Price Filter
Description: User filters products by a selected price range.
User Action: Set min and max values in price filter control.
UI Placement: Filter section beside category filter.
Expected Outcome: Listing shows products where price is within range inclusive.
Edge Cases:
- Min greater than max: auto-swap values and apply corrected range.
- Invalid input: revert to previous valid value.
- No result range: show empty state with reset option.

### 4. Recently Viewed Products
Description: Shows products recently opened in product details.
User Action: User taps a product in listing or recommendation and revisits marketplace.
UI Placement: Recently Viewed section near top of marketplace, below filters.
Expected Outcome: Up to 10 most recent unique products shown in descending recency.
Edge Cases:
- First-time user or no history: section hidden.
- Product removed from catalog: silently excluded.
- Duplicate views: product moved to top, not duplicated.

### 5. Low-stock Badge
Description: Highlight products with low inventory urgency.
User Action: No action required, user passively sees status.
UI Placement: Product row badge near product title.
Expected Outcome: Badge shown when stock is between 1 and 5 inclusive.
Edge Cases:
- Stock is 0: show Out of stock label instead of low-stock badge.
- Missing stock field: treated as unknown and no low-stock badge shown.
- Stock updated while browsing: badge updates after data refresh.

### 6. Featured Badge
Description: Highlight curated products using featured flag.
User Action: No action required, user passively sees badge.
UI Placement: Product row badge near product title, before low-stock badge when both exist.
Expected Outcome: Badge appears only when isFeatured is true.
Edge Cases:
- Missing isFeatured field: default false.
- Both featured and low-stock true: show both badges in fixed order Featured then Low Stock.
- Conflicting metadata from local fallback: Firestore value has priority when available.

## KPI Definitions and Targets

### KPI 1: Add-to-Cart Rate
Definition: add_to_cart_events / marketplace_product_impressions.
Target: Increase by 15% from baseline within 2 weeks post-release.
Measurement Method: Compare daily unique add-to-cart events against product impression events.
Data Source: Firebase Analytics events and existing app event logs.

### KPI 2: Detail-to-Cart Conversion
Definition: sessions_with_add_to_cart_from_detail / product_detail_view_sessions.
Target: Increase by 10% from baseline within 2 weeks post-release.
Measurement Method: Track detail view open and add from detail within same session.
Data Source: Firebase Analytics screen and custom action events.

### KPI 3: Search-to-Purchase Conversion
Definition: sessions_with_checkout_after_search / sessions_with_search_submission.
Target: Increase by 8% from baseline within 3 weeks post-release.
Measurement Method: Link search_submit events to checkout_complete events by session id.
Data Source: Firebase Analytics funnel events and checkout logs.

### KPI 4: Average Cart Value
Definition: sum_cart_value_at_checkout / number_of_checkouts.
Target: Increase by 12% from baseline within 3 weeks post-release.
Measurement Method: Compute from checkout totals and order completion count.
Data Source: Firebase checkout/order events and order persistence logs.

## Resolved Assumptions
1. Product impression is counted when a product row becomes visible on marketplace list.
2. Recently viewed limit is fixed to 10 unique products per user.
3. Low-stock threshold is fixed at 1 through 5 units.
4. Price filter is inclusive of min and max bounds.
5. Legacy products without new fields use safe defaults and remain visible unless filter excludes them.
6. Only one category can be active at a time in this sprint.
7. This sprint does not include backend recommendation engine or personalized ranking.

## Team Alignment and Approval
Feature clarity status: complete for all six features.
Open questions status: none at scope-lock stage.
KPI measurability status: all KPIs have formula, target, method, and source.

Approval checklist:
- Product Owner approval pending
- iOS Lead approval pending
- Backend Lead approval pending
- QA Lead approval pending

Approval record:
- Product Owner: [name] [date]
- iOS Lead: [name] [date]
- Backend Lead: [name] [date]
- QA Lead: [name] [date]

## Exit Criteria Verification
- Sprint feature list finalized: yes
- KPI definitions documented: yes
- KPI tracking sheet created: yes
- Ambiguity removed: yes
- Team approval confirmed: pending signatures
