# Meowtropolis Demo Script

## Purpose

This script is for final MVP demo rehearsal.
It includes:
- Exact presenter flow
- What to say
- Expected result
- Backup action if a step fails

---

## Demo Setup (Before Starting)

1. Use a clean simulator install if possible
2. Confirm network is available
3. Keep one test user ready
4. Keep one fallback user ready
5. Start app and record logs in Xcode console

---

## Step 1: App Launch

What to do:
- Launch the app

What to say:
- "We begin from a fresh app launch. The app checks startup dependencies and session state."

Expected result:
- Splash/onboarding/auth path appears correctly based on session
- No startup crash

Backup if failure:
- Force close app and relaunch
- If still failing, clean build folder and relaunch

---

## Step 2: User Login or Signup

What to do:
- Login with demo account
- If needed, use signup flow

What to say:
- "Authentication is Firebase-backed and routes users to the dashboard on success."

Expected result:
- Successful auth message
- Dashboard opens

Backup if failure:
- Use fallback user credentials
- Retry once after confirming network

---

## Step 3: Add Pet

What to do:
- Open Pet Profile
- Add a new pet entry

What to say:
- "Pet profiles are persisted and loaded through the service layer with clear state handling."

Expected result:
- Pet is added and visible in list

Backup if failure:
- Refresh screen once
- Show previously created pet as stored data proof

---

## Step 4: Navigate Dashboard

What to do:
- Move across tabs

What to say:
- "Main MVP navigation is stable and keeps existing flows intact."

Expected result:
- Tabs open without route break
- No crash or stuck state

Backup if failure:
- Return to Dashboard tab and re-open failed tab

---

## Step 5: Book Grooming

What to do:
- Open Grooming
- Create booking
- Verify in list

What to say:
- "Grooming booking supports create and lifecycle updates with reliable loading/error handling."

Expected result:
- Booking appears in list
- Status update path works

Backup if failure:
- Retry booking once with same pet
- Show existing booking from prior run

---

## Step 6: Request Vet Consultation

What to do:
- Open Vet
- Submit consultation request
- Verify request in list

What to say:
- "Vet requests are captured and displayed in user history for quick follow-up."

Expected result:
- Request saved and shown

Backup if failure:
- Submit a shorter text request and retry once

---

## Step 7: Browse Marketplace

What to do:
- Open Marketplace
- Browse list
- Open product detail

What to say:
- "Marketplace MVP includes product browsing and detail, with safe data source handling."

Expected result:
- Products load
- Detail screen opens

Backup if failure:
- Use search reset and reopen first product

---

## Step 8: Open Map

What to do:
- Open Map tab
- Tap category chips (for example: Vet, Grooming)
- Show result handling

What to say:
- "The map tab supports category-based nearby discovery with explicit state handling."

Expected result:
- Map screen opens
- Category selection triggers search path
- Nearby results appear when available

Backup if failure:
- Re-select category
- Use retry action if error is shown

---

## Step 9: Map State Handling Showcase

### Loading
What to do:
- Trigger search by switching category

What to say:
- "Loading state is visible and responsive while search is running."

Expected result:
- Loading indicator appears

### Empty
What to do:
- Use category or test condition that returns no results

What to say:
- "Empty state is handled gracefully with no crash."

Expected result:
- No-results message appears

### Error + Retry
What to do:
- Show error state and tap Retry

What to say:
- "Error messaging is explicit, and retry allows immediate recovery attempt."

Expected result:
- Error message is visible
- Retry action is triggerable

Backup if failure:
- Return to Dashboard and reopen Map tab

---

## Step 10: Logout and Close

What to do:
- Logout from app

What to say:
- "Session is cleared and the app returns to authentication flow."

Expected result:
- Auth screen appears

Backup if failure:
- Force-close and relaunch app to verify session clear behavior

---

## Quick Fallback Plan (If Demo Environment Becomes Unstable)

1. Restart app and repeat only critical path:
   - Login -> Dashboard -> Pet list -> Grooming list -> Marketplace list -> Map tab -> Logout
2. Focus on proving core flow continuity
3. Keep console logs visible to explain transient external failures

---

## Presenter Closing Line

"Meowtropolis is now in MVP freeze. Core user flows are stable, tested, and demo-ready. Only critical demo-impacting issues will be fixed from this point onward."
