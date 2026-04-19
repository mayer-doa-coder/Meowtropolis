# KPI Tracking Sheet

## Scope
Marketplace pre-implementation KPI tracking for locked sprint features.

| KPI Name | Definition | Target | Current Baseline | Measurement Method | Data Source | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| Add-to-Cart Rate | add_to_cart_events / marketplace_product_impressions | +15% vs baseline in 2 weeks | TBD (capture 7-day pre-release average) | Compare daily add_to_cart events to product impression events | Firebase Analytics plus app logs | Member B |
| Detail-to-Cart Conversion | sessions_with_add_to_cart_from_detail / product_detail_view_sessions | +10% vs baseline in 2 weeks | TBD (capture 7-day pre-release average) | Session-level funnel from detail view to add action | Firebase Analytics screen/action events | Member C |
| Search-to-Purchase Conversion | sessions_with_checkout_after_search / sessions_with_search_submission | +8% vs baseline in 3 weeks | TBD (capture 14-day pre-release average) | Funnel linking search submit to checkout complete by session id | Firebase Analytics funnel events and checkout logs | Member D |
| Average Cart Value | sum_cart_value_at_checkout / number_of_checkouts | +12% vs baseline in 3 weeks | TBD (capture 14-day pre-release average) | Aggregate checkout totals divided by completed checkout count | Firebase order and checkout telemetry | Member A |

## Baseline Capture Plan
1. Capture baseline before release using current production behavior.
2. Use minimum 7 days for cart and detail metrics.
3. Use minimum 14 days for search and cart value stability.
4. Freeze baseline values in this file before implementation starts.

## Weekly Review Cadence
- Data refresh: every Monday and Thursday.
- KPI review meeting: weekly.
- Owner update format: status, variance, blocker, next action.

## Signoff
- Product Owner: [name] [date]
- iOS Lead: [name] [date]
- Analytics Owner: [name] [date]
