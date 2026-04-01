//
//  MeowtropolisTests.swift
//  MeowtropolisTests
//
//  Created by MD.Ashraful Islam  on 31/3/26.
//

import Testing
@testable import Meowtropolis

private final class MockFirestore {
    private var storage: [String: [String: [String: Any]]] = [:]

    func write<T: Encodable>(_ model: T, to collection: FirestoreCollection, documentId: String) throws {
        let encoded = try FirestoreModelCoder.encode(model)
        var collectionStore = storage[collection.rawValue] ?? [:]
        collectionStore[documentId] = encoded
        storage[collection.rawValue] = collectionStore
    }

    func read<T: Decodable>(_ type: T.Type, from collection: FirestoreCollection, documentId: String) throws -> T? {
        guard let encoded = storage[collection.rawValue]?[documentId] else {
            return nil
        }

        return try FirestoreModelCoder.decode(T.self, from: encoded)
    }
}

struct MeowtropolisTests {

    @Test func productEncodingDecodingRoundTrip() throws {
        // 1) Create a sample Product object.
        let product = Product(
            name: "Premium Salmon Cat Food",
            price: 18.99,
            category: "food",
            imageURL: "https://images.meowtropolis.app/products/premium-salmon-cat-food.png"
        )

        // 2) Encode Product -> dictionary.
        let encodedDictionary = try product.toFirestoreData()
        print("Encoded Product dictionary:", encodedDictionary)

        // 3) Decode dictionary -> Product.
        let decodedProduct = try Product.fromFirestoreData(encodedDictionary)
        print("Decoded Product:", decodedProduct)

        // 4) Validate values after round-trip.
        #expect(decodedProduct.name == product.name)
        #expect(decodedProduct.price == product.price)
        #expect(decodedProduct.category == product.category)
        #expect(decodedProduct.imageURL == product.imageURL)

        // Extra checks on encoded payload shape.
        #expect(encodedDictionary["name"] as? String == product.name)
        #expect(encodedDictionary["price"] as? Double == product.price)
        #expect(encodedDictionary["category"] as? String == product.category)
        #expect(encodedDictionary["imageURL"] as? String == product.imageURL)
    }

    @Test func productJSONDecodesSuccessfully() throws {
        let json = """
        {
          "name": "Premium Salmon Cat Food",
          "price": 18.99,
          "category": "food",
          "imageURL": "https://images.meowtropolis.app/products/premium-salmon-cat-food.png"
        }
        """

        let jsonData = try #require(json.data(using: .utf8))
        let product = try JSONDecoder().decode(Product.self, from: jsonData)
        print("Decoded Product from JSON:", product)

        #expect(product.name == "Premium Salmon Cat Food")
        #expect(product.price == 18.99)
        #expect(product.category == "food")
        #expect(product.imageURL == "https://images.meowtropolis.app/products/premium-salmon-cat-food.png")
    }

    @Test func firestoreCorePathsWriteAndReadRoundTrip() throws {
        let store = MockFirestore()

        let user = User(id: "user_001", name: "Ava Johnson", email: "ava@example.com")
        try store.write(user, to: .users, documentId: user.id)
        let fetchedUser = try #require(try store.read(User.self, from: .users, documentId: user.id))
        print("Read user:", fetchedUser)
        #expect(fetchedUser.id == user.id)
        #expect(fetchedUser.name == user.name)
        #expect(fetchedUser.email == user.email)

        let pet = Pet(id: "pet_001", userId: user.id, name: "Milo", breed: "Persian")
        try store.write(pet, to: .pets, documentId: pet.id)
        let fetchedPet = try #require(try store.read(Pet.self, from: .pets, documentId: pet.id))
        print("Read pet:", fetchedPet)
        #expect(fetchedPet.id == pet.id)
        #expect(fetchedPet.userId == pet.userId)
        #expect(fetchedPet.name == pet.name)
        #expect(fetchedPet.breed == pet.breed)

        let booking = Booking(
            id: "booking_001",
            userId: user.id,
            petId: pet.id,
            serviceType: "grooming",
            date: "2026-04-01T10:00:00Z",
            status: .pending
        )
        try store.write(booking, to: .bookings, documentId: booking.id)
        let fetchedBooking = try #require(try store.read(Booking.self, from: .bookings, documentId: booking.id))
        print("Read booking:", fetchedBooking)
        #expect(fetchedBooking.id == booking.id)
        #expect(fetchedBooking.userId == booking.userId)
        #expect(fetchedBooking.petId == booking.petId)
        #expect(fetchedBooking.serviceType == booking.serviceType)
        #expect(fetchedBooking.date == booking.date)
        #expect(fetchedBooking.status == booking.status)

        let productDocumentId = "product_001"
        let product = Product(
            name: "Premium Salmon Cat Food",
            price: 18.99,
            category: "food",
            imageURL: "https://images.meowtropolis.app/products/premium-salmon-cat-food.png"
        )
        try store.write(product, to: .products, documentId: productDocumentId)
        let fetchedProduct = try #require(try store.read(Product.self, from: .products, documentId: productDocumentId))
        print("Read product:", fetchedProduct)
        #expect(fetchedProduct.name == product.name)
        #expect(fetchedProduct.price == product.price)
        #expect(fetchedProduct.category == product.category)
        #expect(fetchedProduct.imageURL == product.imageURL)
    }

}
