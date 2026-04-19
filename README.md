# Meowtropolis

Meowtropolis is a SwiftUI + Firebase pet care app that combines everyday pet workflows in one place: authentication, pet profiles, grooming bookings, vet requests, marketplace browsing, cart and checkout, account management, map-based nearby search, and pet-friendly blog content.

This repository contains the iOS app source, test targets, Firebase data contract docs, and demo/validation artifacts.

## Core Features

### Authentication and Session
- Sign up, log in, log out
- Password reset
- Session restore on app start
- User-friendly auth error handling

### Profile and Account
- Personal information update
- Profile image upload with optimization/compression
- Password change and account delete with reauthentication safeguards
- Local activity history with noise filtering for meaningful events

### Pet Management
- Create, edit, list, and delete pet profiles

### Grooming and Vet
- Grooming booking flow
- Vet request flow

### Marketplace
- Product listing and detail views
- Search and sort/filter controls
- Add-to-cart and cart quantity management
- Checkout flow with stock-safe order placement (no real payments)
- Cart recommendations and savings summary
- One-time Firestore auto-seeding from bundled product JSON when products collection is empty

### Blogs
- Built-in pet blog section with featured cards, list view, and detail pages

### Maps and Nearby Places
- Google Places-backed nearby place search flow (loading, empty, error, retry states)

## Tech Stack

- iOS: Swift, SwiftUI
- Backend: Firebase Authentication, Cloud Firestore
- Maps/Places: Google Maps SDK and Google Places SDK
- Testing: XCTest (unit + UI tests)

## Architecture

The project follows a clean layered structure:

- Models: Codable app/domain models
- Services: Firebase, maps, and data access logic
- State: Observable state orchestration and screen-level data flow
- Views: SwiftUI screens and reusable UI components

Design principle:
- Keep UI in Views, side effects in Services, and flow orchestration in State.

## Repository Structure

```text
Meowtropolis/
  Meowtropolis/
    Assets.xcassets/
    Firestore/
    Models/
    SampleData/
      products.json
    Services/
    State/
    Views/
      Auth/
      Common/
      Main/
      Shared/
    MeowtropolisApp.swift
    ContentView.swift
  MeowtropolisTests/
  MeowtropolisUITests/
  FIRESTORE_STRUCTURE.md
  docs/
```

## Prerequisites

- macOS with Xcode (latest stable recommended)
- iOS Simulator or physical iPhone
- Firebase project configured for Authentication + Firestore
- Google Maps/Places API key

## Setup

### 1. Clone and Open
1. Clone this repository.
2. Open Meowtropolis.xcodeproj in Xcode.

### 2. Firebase
1. Create/select a Firebase project.
2. Enable:
   - Authentication (Email/Password)
   - Cloud Firestore
3. Download GoogleService-Info.plist.
4. Add it to the app target (Meowtropolis) in Xcode.

### 3. Firestore Rules (Development Baseline)
Current baseline rule in this repo allows authenticated users to read/write.
Adjust rules for production hardening before release.

### 4. Google Maps and Places
1. Enable Google Maps SDK and Places API in Google Cloud.
2. Add GOOGLE_MAPS_API_KEY to app configuration (Info.plist based setup used by MapsService).
3. Build and run.

## Data Contracts

Primary Firestore collections:
- users
- pets
- bookings
- products
- orders
- vetRequests

Reference contract:
- FIRESTORE_STRUCTURE.md

Important product fields:
- id
- name
- price
- category
- imageURL
- stock (optional, defaults handled in model)

## Product Auto-Seeding

On first product fetch:
1. App checks whether products collection is empty.
2. If empty, app uploads bundled entries from SampleData/products.json.
3. A local one-time seed flag prevents repeated uploads on the same installation.

This behavior is implemented in ProductSeedService and integrated into ProductService.

## Running Tests

Use Xcode test runner for both targets:
- MeowtropolisTests
- MeowtropolisUITests

You can also run from command line on macOS:

```bash
xcodebuild test \
  -project Meowtropolis.xcodeproj \
  -scheme Meowtropolis \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting

### Profile image save fails
- Ensure user is still authenticated.
- Large images are automatically resized/compressed before save.
- If Firestore errors still occur, verify network and Firestore permissions.

### Marketplace has no products in Firestore
- Open marketplace once while signed in to trigger one-time auto-seeding.
- If one manual product already exists, seeding is skipped by design.

### Maps/Places returns configuration errors
- Confirm API key exists and required APIs are enabled.
- Confirm key restrictions allow your iOS bundle/app setup.

### Firebase auth/profile inconsistencies
- Verify GoogleService-Info.plist belongs to the same Firebase project you are inspecting in console.

## Current Status

The repository includes both implementation and validation documents for MVP/demo readiness, including:
- integration signoff
- validation report
- checklist and demo script
- marketplace enhancement planning artifacts

## License

See LICENSE for project license details.
