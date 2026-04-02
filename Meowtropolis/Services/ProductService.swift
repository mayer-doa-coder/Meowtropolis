import Foundation

/// Main product service with Firestore-first strategy and local JSON fallback.
final class ProductService {
    enum ProductDataSource: String {
        case firestore = "Firestore"
        case local = "Local JSON"
    }

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
                self.logLoadedSource(.firestore, count: products.count)
                completion(.success(products))

            case .success:
                self.logFallbackReason("Firestore returned empty product list")
                self.loadLocalProducts(completion: completion)

            case let .failure(error):
                self.logFallbackReason("Firestore request failed: \(error.localizedDescription)")
                self.loadLocalProducts(completion: completion)
            }
        }
    }

    private func loadLocalProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        localService.loadProducts { localResult in
            switch localResult {
            case let .success(products):
                self.logLoadedSource(.local, count: products.count)
                completion(.success(products))
            case let .failure(error):
                print("[ProductService] Local fallback failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    private func logLoadedSource(_ source: ProductDataSource, count: Int) {
        print("[ProductService] Source: \(source.rawValue). Products loaded: \(count)")
    }

    private func logFallbackReason(_ reason: String) {
        print("[ProductService] Falling back to local data. Reason: \(reason)")
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
