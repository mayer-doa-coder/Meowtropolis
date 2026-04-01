# Backend Stabilization and Verification Checklist

Use this checklist before adding new backend features.

## A. Auth Service
- [ ] Signup with test email returns success.
- [ ] Login with same credentials returns success.
- [ ] Logout returns success.
- [ ] Root routing moves to dashboard after login.
- [ ] Root routing returns to auth flow after logout.

## B. User Service
- [ ] createUserProfile writes user document to users collection.
- [ ] fetchCurrentUser returns matching id, name, and email.

## C. Pet Service
- [ ] addPet creates pet document.
- [ ] listPets returns at least the inserted pet.
- [ ] updatePet saves changed pet name/breed.
- [ ] deletePet removes pet document.

## D. Booking Service
- [ ] createBooking writes booking document.
- [ ] listBookingsByUser returns created booking.
- [ ] listBookingsByPet returns created booking.
- [ ] updateBookingStatus changes status field successfully.

## E. Product Service
- [ ] Firestore products fetch works when documents exist.
- [ ] Fallback to local JSON works when Firestore is empty/fails.
- [ ] Product decoding succeeds for id, name, price, category, imageURL.

## F. UI and Backend Separation
- [ ] No direct Auth.auth() calls in UI views.
- [ ] No direct Firestore.firestore() calls in UI views.
- [ ] UI calls AppState and services only.

## G. Final Stability Gate
- [ ] Backend smoke tests run with success logs.
- [ ] No compile errors in app target.
- [ ] No compile errors in test target.
- [ ] Service method signatures are unchanged and documented.
