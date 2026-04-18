import XCTest
import CoreLocation
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

    func testMapCategoryMappingKnownCategoryReturnsExpectedQuery() {
        let vetCategory = MapCategory.from(initialCategory: "Vet") ?? .vet
        let groomingCategory = MapCategory.from(initialCategory: "Grooming") ?? .vet

        XCTAssertEqual(vetCategory, .vet)
        XCTAssertEqual(vetCategory.query, "veterinary clinic")

        XCTAssertEqual(groomingCategory, .grooming)
        XCTAssertEqual(groomingCategory.query, "pet grooming")
    }

    func testMapCategoryMappingUnknownCategoryFallsBackToVetQuery() {
        let fallbackCategory = MapCategory.from(initialCategory: "unknown-category") ?? .vet

        XCTAssertEqual(fallbackCategory, .vet)
        XCTAssertEqual(fallbackCategory.query, "veterinary clinic")
    }

    func testPlaceDecodingValidJSONSucceeds() throws {
        let json = """
        {
          "id": "place_001",
          "name": "Happy Paws Vet",
          "address": "12 Pet Street",
          "latitude": 23.8103,
          "longitude": 90.4125,
          "rating": 4.7,
          "types": ["veterinary_care", "point_of_interest"]
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let place = try JSONDecoder().decode(Place.self, from: data)

        XCTAssertEqual(place.id, "place_001")
        XCTAssertEqual(place.name, "Happy Paws Vet")
        XCTAssertEqual(place.address, "12 Pet Street")
        XCTAssertEqual(place.latitude, 23.8103, accuracy: 0.0001)
        XCTAssertEqual(place.longitude, 90.4125, accuracy: 0.0001)
        XCTAssertEqual(place.rating, 4.7, accuracy: 0.0001)
        XCTAssertEqual(place.types, ["veterinary_care", "point_of_interest"])
    }

    func testPlaceDecodingMissingOptionalFieldsStillSucceeds() throws {
        let json = """
        {
          "id": "place_002",
          "name": "Groom House",
          "address": "34 Grooming Ave",
          "latitude": 23.7000,
          "longitude": 90.3500,
          "types": ["pet_grooming"]
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let place = try JSONDecoder().decode(Place.self, from: data)

        XCTAssertEqual(place.id, "place_002")
        XCTAssertNil(place.rating)
        XCTAssertEqual(place.types, ["pet_grooming"])
    }

    func testPlaceDecodingInvalidDataFailsGracefully() throws {
        let invalidJSON = """
        {
          "id": "place_003",
          "name": "Bad Place",
          "address": "Unknown",
          "latitude": "not-a-number",
          "longitude": 90.0000,
          "types": []
        }
        """

        let data = try XCTUnwrap(invalidJSON.data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decode(Place.self, from: data))
    }

    func testLocationServicePermissionGrantedReturnsSuccess() {
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 23.81, longitude: 90.41)
        let service = LocationService(
            testAuthorizationStatus: .authorizedWhenInUse,
            testLocationRequestHandler: { completion in
                completion(.success(expectedCoordinate))
            }
        )

        let expectation = expectation(description: "Location success")

        service.getCurrentLocation { result in
            switch result {
            case let .success(coordinate):
                XCTAssertEqual(coordinate.latitude, expectedCoordinate.latitude, accuracy: 0.0001)
                XCTAssertEqual(coordinate.longitude, expectedCoordinate.longitude, accuracy: 0.0001)
            case let .failure(error):
                XCTFail("Expected success, got failure: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testLocationServicePermissionDeniedReturnsFailure() {
        let service = LocationService(
            testAuthorizationStatus: .denied,
            testLocationRequestHandler: { completion in
                completion(.failure(LocationService.LocationServiceError.permissionDenied))
            }
        )

        let expectation = expectation(description: "Location denied")

        service.getCurrentLocation { result in
            switch result {
            case .success:
                XCTFail("Expected permission denied failure")
            case let .failure(error):
                XCTAssertEqual(
                    error as? LocationService.LocationServiceError,
                    .permissionDenied
                )
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testLocationServiceUnavailableReturnsFailure() {
        let service = LocationService(
            testAuthorizationStatus: .authorizedWhenInUse,
            testLocationRequestHandler: { completion in
                completion(.failure(LocationService.LocationServiceError.locationUnavailable))
            }
        )

        let expectation = expectation(description: "Location unavailable")

        service.getCurrentLocation { result in
            switch result {
            case .success:
                XCTFail("Expected location unavailable failure")
            case let .failure(error):
                XCTAssertEqual(
                    error as? LocationService.LocationServiceError,
                    .locationUnavailable
                )
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPlacesServiceAPIFailureReturnsFailure() {
        let service = PlacesService(testSearchHandler: { _, completion in
            completion(.failure(MapTestError.apiFailure))
        })

        let expectation = expectation(description: "Places API failure")

        service.searchPlaces(request: PlaceSearchRequest(query: "vet", latitude: nil, longitude: nil)) { result in
            switch result {
            case .success:
                XCTFail("Expected failure when API fails")
            case let .failure(error):
                XCTAssertEqual(error as? MapTestError, .apiFailure)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPlacesServiceEmptyResultReturnsSuccessWithEmptyArray() {
        let service = PlacesService(testSearchHandler: { _, completion in
            completion(.success([]))
        })

        let expectation = expectation(description: "Places empty result")

        service.searchPlaces(request: PlaceSearchRequest(query: "grooming", latitude: nil, longitude: nil)) { result in
            switch result {
            case let .success(places):
                XCTAssertTrue(places.isEmpty)
            case let .failure(error):
                XCTFail("Expected empty success, got failure: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

private enum MapTestError: LocalizedError {
    case apiFailure

    var errorDescription: String? {
        switch self {
        case .apiFailure:
            return "Simulated API failure"
        }
    }
}
