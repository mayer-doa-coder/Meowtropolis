# Meowtropolis Firestore Structure (Locked)

This document defines the Firestore data contract for Meowtropolis.
Collection names and field names are locked for MVP.

## Why Collection Names Must Not Change

Collection names are part of the app-backend contract.
If a collection name changes after release:
- Existing app queries will read from the wrong path.
- Existing data becomes invisible to old app builds.
- Production writes may split across old and new collections.
- Migrations become required and increase outage risk.

For this reason, these collection names are locked and must stay unchanged.

## Locked Collections

- users
- pets
- bookings
- products

## Collection Structures and Example Documents

### users
Matches Swift model: User

Required fields:
- id: String
- name: String
- email: String

Example document:

```json
{
  "id": "user_001",
  "name": "Ava Johnson",
  "email": "ava@example.com"
}
```

### pets
Matches Swift model: Pet

Required fields:
- id: String
- userId: String
- name: String
- breed: String

Example document:

```json
{
  "id": "pet_001",
  "userId": "user_001",
  "name": "Milo",
  "breed": "Persian"
}
```

### bookings
Matches Swift model: Booking

Required fields:
- id: String
- userId: String
- petId: String
- serviceType: String
- date: String
- status: String

Example document:

```json
{
  "id": "booking_001",
  "userId": "user_001",
  "petId": "pet_001",
  "serviceType": "grooming",
  "date": "2026-04-01T10:00:00Z",
  "status": "pending"
}
```

### products
Matches Swift model: Product

Required fields:
- id: String
- name: String
- price: Double
- category: String
- imageURL: String
- stock: Int (optional, defaults to 50 if missing)

Example document:

```json
{
  "id": "product_cat_001",
  "name": "Cat Food Premium",
  "price": 19.99,
  "category": "food",
  "imageURL": "img_felix_cat_food_tuna_in_jelly_70g_jpg",
  "stock": 15
}
```

Auto-seeding behavior:
- On first product fetch, the app checks whether the `products` collection is empty.
- If empty, it uploads bundled items from `SampleData/products.json` to Firestore.
- A local one-time seed flag prevents repeated uploads on subsequent app launches.

## Naming Rules (Mandatory)

- Use camelCase for all field names.
- Use the same names in Swift models and Firestore documents.
- Do not rename collections or fields later.
- Keep names stable across all app versions.
