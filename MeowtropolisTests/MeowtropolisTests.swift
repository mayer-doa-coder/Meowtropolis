import XCTest
@testable import Meowtropolis

final class MeowtropolisTests: XCTestCase {

    func testProductJSONDecoding() throws {
        let json = """
        {
          "id": "product_001",
          "name": "Premium Salmon Cat Food",
          "price": 18.99,
          "category": "food",
          "imageURL": "https://images.meowtropolis.app/products/premium-salmon-cat-food.png"
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let product = try JSONDecoder().decode(Product.self, from: data)

        XCTAssertEqual(product.id, "product_001")
        XCTAssertEqual(product.name, "Premium Salmon Cat Food")
        XCTAssertEqual(product.price, 18.99, accuracy: 0.0001)
        XCTAssertEqual(product.category, "food")
        XCTAssertEqual(product.imageURL, "https://images.meowtropolis.app/products/premium-salmon-cat-food.png")
    }

    func testBookingStatusRawValues() {
        XCTAssertEqual(BookingStatus.pending.rawValue, "pending")
        XCTAssertEqual(BookingStatus.confirmed.rawValue, "confirmed")
        XCTAssertEqual(BookingStatus.completed.rawValue, "completed")
        XCTAssertEqual(BookingStatus.cancelled.rawValue, "cancelled")
    }

    func testFirestoreCollectionLegacyMappingUsesCentralizedConstants() {
        XCTAssertEqual(FirestoreCollection.users.rawValue, FirestoreCollections.users)
        XCTAssertEqual(FirestoreCollection.pets.rawValue, FirestoreCollections.pets)
        XCTAssertEqual(FirestoreCollection.bookings.rawValue, FirestoreCollections.bookings)
        XCTAssertEqual(FirestoreCollection.products.rawValue, FirestoreCollections.products)
    }

    func testProductFirestoreDictionaryRoundTrip() throws {
        let product = Product(
            id: "product_002",
            name: "Cat Litter",
            price: 9.99,
            category: "hygiene",
            imageURL: ""
        )

        let dictionary = try product.toFirestoreData()
        let decoded = try Product.fromFirestoreData(dictionary)

        XCTAssertEqual(decoded.id, product.id)
        XCTAssertEqual(decoded.name, product.name)
        XCTAssertEqual(decoded.price, product.price, accuracy: 0.0001)
        XCTAssertEqual(decoded.category, product.category)
        XCTAssertEqual(decoded.imageURL, product.imageURL)
    }
}
