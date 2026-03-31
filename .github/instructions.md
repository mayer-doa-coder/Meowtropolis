# Meowtropolis Project Instructions

## Purpose
Use this file as the default project context in every new thread.
If context is missing, read this file first, then read project_document.md.

## Project Summary
Meowtropolis is an iOS SwiftUI app for pet care.
It combines grooming booking, vet support, pet profile management, and a pet marketplace in one app.

## MVP First (Do This Before Any Extra Features)
Build and stabilize these in order:
1. Project setup and Firebase connection
2. Authentication (signup, login, logout, session)
3. Pet profile management (add, edit, delete, list)
4. Home dashboard navigation
5. Grooming booking flow
6. Vet consultation request flow
7. Marketplace basics (product list, cart, simple checkout)
8. Testing and bug fixing

Do not add future features (GPS, video consult, subscriptions, community forum) until MVP is stable.

## Current Tech Stack
- Frontend: Swift + SwiftUI
- Backend: Firebase (Auth, Firestore, Storage later)
- Version Control: GitHub with pull requests
- Data Mapping: Codable and JSON parsing
- Testing: Swift Testing for unit tests, XCTest for UI tests

## Architecture Rules
- Keep code simple and layered:
  - Views: UI screens
  - Models: User, Pet, Booking, Product data shapes
  - Services: Firebase read/write logic
  - State layer: screen state, loading, and error handling
- Start simple. Avoid over-engineering patterns early.
- Prefer clear and small components over complex shared abstractions.

## Data Models (Minimum)
- User: id, name, email, pets[]
- Pet: id, name, age, breed, medicalHistory
- Booking: id, userId, petId, serviceType, date, status
- Product: id, name, price, category

## Team Split (3 Members)
- Member A: SwiftUI screens and navigation
- Member B: Firebase integration and data/services
- Member C: Testing, QA, and bug tracking

## Definition of Done per Feature
A feature is done only when:
1. UI flow works end-to-end
2. Firestore data saves and reads correctly
3. Error and loading states are handled
4. At least one happy-path test exists
5. No major navigation breaks

## Daily Working Rules
- Build one complete user flow at a time.
- Keep pull requests small and focused.
- Re-test auth after any Firebase or session change.
- Keep one shared field naming reference to avoid Firestore key mismatches.
- Track bugs by severity: critical, high, medium, low.

## Quick Start for Any New Thread
1. Read .github/instructions.md
2. Read project_document.md
3. Check current repository state
4. Continue from the next unfinished MVP step only

## Reference Files
- project_document.md
- Meowtropolis/MeowtropolisApp.swift
- Meowtropolis/ContentView.swift
- MeowtropolisTests/MeowtropolisTests.swift
- MeowtropolisUITests/MeowtropolisUITests.swift
