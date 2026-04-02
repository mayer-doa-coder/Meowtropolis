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

    func testVetRequestModelFieldsAndDefaultPendingStatus() {
        let request = VetRequest(
            id: "vet_001",
            userId: "user_001",
            petId: "pet_001",
            issueDescription: "My cat is not eating well.",
            status: .pending,
            createdAt: "2026-04-02T10:00:00Z"
        )

        XCTAssertEqual(request.userId, "user_001")
        XCTAssertEqual(request.issueDescription, "My cat is not eating well.")
        XCTAssertEqual(request.status, .pending)
    }

    func testVetRequestEncodingDecodingRoundTrip() throws {
        let request = VetRequest(
            id: "vet_002",
            userId: "user_002",
            petId: nil,
            issueDescription: "Dog has itchy skin.",
            status: .resolved,
            createdAt: "2026-04-02T11:00:00Z"
        )

        let encoded = try FirestoreModelCoder.encode(request)
        let decoded = try FirestoreModelCoder.decode(VetRequest.self, from: encoded)

        XCTAssertEqual(decoded.id, request.id)
        XCTAssertEqual(decoded.userId, request.userId)
        XCTAssertEqual(decoded.petId, request.petId)
        XCTAssertEqual(decoded.issueDescription, request.issueDescription)
        XCTAssertEqual(decoded.status, request.status)
        XCTAssertEqual(decoded.createdAt, request.createdAt)
    }

    func testCartStateAddProductCreatesItem() {
        let cart = CartState()
        let product = Product(id: "p_001", name: "Cat Toy", price: 5.5, category: "toys", imageURL: "")

        cart.addToCart(product: product)

        XCTAssertEqual(cart.items.count, 1)
        XCTAssertEqual(cart.items.first?.productId, "p_001")
        XCTAssertEqual(cart.items.first?.quantity, 1)
    }

    func testCartStateRemoveProductRemovesItem() {
        let cart = CartState()
        let product = Product(id: "p_002", name: "Cat Brush", price: 7.0, category: "grooming", imageURL: "")

        cart.addToCart(product: product)
        cart.removeFromCart(productId: product.id)

        XCTAssertTrue(cart.items.isEmpty)
    }

    func testCartStateUpdateQuantityUpdatesCorrectly() {
        let cart = CartState()
        let product = Product(id: "p_003", name: "Cat Food", price: 12.0, category: "food", imageURL: "")

        cart.addToCart(product: product)
        cart.updateQuantity(productId: product.id, quantity: 3)

        XCTAssertEqual(cart.items.first?.quantity, 3)
        XCTAssertEqual(cart.totalItemCount, 3)
    }

    func testCartStateClearCartEmptiesItems() {
        let cart = CartState()
        let productA = Product(id: "p_004", name: "Cat Bed", price: 20.0, category: "sleep", imageURL: "")
        let productB = Product(id: "p_005", name: "Cat Bowl", price: 6.0, category: "feeding", imageURL: "")

        cart.addToCart(product: productA)
        cart.addToCart(product: productB, quantity: 2)
        cart.clearCart()

        XCTAssertTrue(cart.items.isEmpty)
        XCTAssertEqual(cart.totalItemCount, 0)
        XCTAssertEqual(cart.totalPrice, 0, accuracy: 0.0001)
    }
}
