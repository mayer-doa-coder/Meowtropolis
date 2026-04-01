import Foundation

/// Main product service with Firestore-first strategy and local JSON fallback.
final class ProductService {
    private let firestoreService: FirestoreProductService
    private let localService: LocalProductService

    init(
        firestoreService: FirestoreProductService = FirestoreProductService(),
        localService: LocalProductService = LocalProductService()
    ) {
        self.firestoreService = firestoreService
        self.localService = localService
    }

    /// Loads products from Firestore first.
    /// Falls back to local JSON when Firestore fails or returns empty.
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        firestoreService.fetchProducts { [weak self] firestoreResult in
            guard let self else {
                return
            }

            switch firestoreResult {
            case let .success(products) where !products.isEmpty:
                completion(.success(products))

            case .success, .failure:
                self.localService.loadProducts { localResult in
                    completion(localResult)
                }
            }
        }
    }
}

/// Manual validation helper for local + Firestore decoding.
enum ProductServiceSmokeTest {
    static func run(service: ProductService = ProductService()) {
        service.fetchProducts { result in
            switch result {
            case let .success(products):
                print("Product smoke test success. Count:", products.count)
                print("Products:", products)
            case let .failure(error):
                print("Product smoke test failed:", error.localizedDescription)
            }
        }
    }
}
