# Meowtropolis Team Workflow for Data Contracts

## Team Responsibility Breakdown

- Member 1: Define models
  - Own Swift data models in Meowtropolis/Models/DataModels.swift.
  - Keep field names in camelCase.
  - Avoid adding fields that are not part of MVP contract.

- Member 2: Verify Firestore structure
  - Own collection names and schema documentation in FIRESTORE_STRUCTURE.md.
  - Ensure collection names stay locked: users, pets, bookings, products.
  - Confirm Firestore document fields match Swift model fields exactly.

- Member 3: Test encoding/decoding
  - Own model coding utilities in Meowtropolis/Firestore/ModelCoding.swift.
  - Own round-trip tests in MeowtropolisTests/MeowtropolisTests.swift.
  - Verify Swift model -> dictionary -> Swift model flow works.

## Validation Checklist

- [ ] Models match Firestore fields.
- [ ] JSON matches models.
- [ ] Encoding/decoding works.

## How to Validate Quickly

1. Run Product round-trip test in MeowtropolisTests.
2. Check printed logs for encoded dictionary and decoded Product.
3. Confirm all assertions pass.
