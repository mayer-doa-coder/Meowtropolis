# Day 3 Plan - App Skeleton and Navigation

## Goal
Build a UI-only app skeleton with clear navigation flow. No Firebase logic and no backend logic in this phase.

## Scope
- Root navigation using NavigationStack
- Splash, Login, Signup, Dashboard, Pet Profile, Grooming, Vet, Marketplace screens
- Shared app state with isLoggedIn Bool
- Route switch: logged-out flow vs logged-in flow

## Step-by-Step

### 1. Create shared app state
- File: State/AppState.swift
- Purpose: keep simple login status shared across the app.

### 2. Create root routing view
- File: Views/RootView.swift
- Purpose: show Splash first, then use isLoggedIn to switch between Login and Dashboard.

### 3. Replace default ContentView body
- File: ContentView.swift
- Purpose: make ContentView point to RootView so all routing starts there.

### 4. Update app entry
- File: MeowtropolisApp.swift
- Purpose: create one AppState object and inject it with environmentObject.

### 5. Add auth screens
- Files:
  - Views/Auth/LoginView.swift
  - Views/Auth/SignupView.swift
- Purpose: temporary login/signup buttons to move to dashboard without backend.

### 6. Add main feature placeholders
- Files:
  - Views/Main/DashboardView.swift
  - Views/Main/PetProfileView.swift
  - Views/Main/GroomingView.swift
  - Views/Main/VetView.swift
  - Views/Main/MarketplaceView.swift
- Purpose: keep navigation path ready for upcoming feature implementation.

### 7. Add splash screen
- File: Views/Common/SplashView.swift
- Purpose: simple app entry screen before auth flow.

## Flow Summary
- Splash -> Login
- Login -> Signup (link)
- Login -> Dashboard (temporary button)
- Dashboard -> Pet Profile / Grooming / Vet / Marketplace
- Dashboard -> Logout -> Login

## Notes for Beginners
- Keep this phase UI-only.
- Do not add API calls yet.
- Use placeholder text and temporary buttons.
- Ensure each screen builds and opens in simulator before moving to Day 4.

## Verification Checklist
- App launches to splash.
- Continue from splash opens login flow.
- Temporary login opens dashboard.
- Dashboard links open all placeholder feature screens.
- Logout returns to login.
- No compile errors.
