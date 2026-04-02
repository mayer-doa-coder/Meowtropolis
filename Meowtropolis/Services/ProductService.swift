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
        let firestoreService = self.firestoreService
        let localService = self.localService

        firestoreService.fetchProducts { firestoreResult in
            let logLoadedSource: (ProductDataSource, Int) -> Void = { source, count in
                print("[ProductService] Source: \(source.rawValue). Products loaded: \(count)")
                if source == .firestore {
                    print("[ProductService] Loaded from Firestore")
                } else {
                    print("[ProductService] Loaded from Local JSON")
                }
            }

            let logFallbackReason: (String) -> Void = { reason in
                print("[ProductService] Falling back to local data. Reason: \(reason)")
            }

            let loadLocalProducts: () -> Void = {
                localService.loadProducts { localResult in
                    switch localResult {
                    case let .success(products):
                        logLoadedSource(.local, products.count)
                        completion(.success(products))
                    case let .failure(error):
                        print("[ProductService] Local fallback failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }

            switch firestoreResult {
            case let .success(products) where !products.isEmpty:
                logLoadedSource(.firestore, products.count)
                completion(.success(products))

            case .success:
                logFallbackReason("Firestore returned empty product list")
                loadLocalProducts()

            case let .failure(error):
                logFallbackReason("Firestore request failed: \(error.localizedDescription)")
                loadLocalProducts()
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
