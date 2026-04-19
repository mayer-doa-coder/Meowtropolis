import Foundation
import FirebaseFirestore

/// One-time seed helper that uploads bundled products to Firestore when the
/// products collection is empty.
final class ProductSeedService {
    private let db: Firestore
    private let localService: LocalProductService
    private let defaults: UserDefaults
    private let seedFlagKey = "products.firestore.seed.completed.v1"

    init(
        db: Firestore = Firestore.firestore(),
        localService: LocalProductService = LocalProductService(),
        defaults: UserDefaults = .standard
    ) {
        self.db = db
        self.localService = localService
        self.defaults = defaults
    }

    /// Ensures products are seeded to Firestore once per device installation.
    /// If Firestore already has products, the seed is marked complete and skipped.
    func ensureSeededIfNeeded(completion: @escaping () -> Void) {
        guard !defaults.bool(forKey: seedFlagKey) else {
            completion()
            return
        }

        db.collection(FirestoreCollections.products)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self else {
                    completion()
                    return
                }

                if let error {
                    print("[ProductSeedService] Seed check failed: \(error.localizedDescription)")
                    completion()
                    return
                }

                if let snapshot, !snapshot.documents.isEmpty {
                    print("[ProductSeedService] Products already exist. Seed skipped.")
                    completion()
                    return
                }

                self.seedFromLocalProducts(completion: completion)
            }
    }

    private func seedFromLocalProducts(completion: @escaping () -> Void) {
        localService.loadProducts { [weak self] result in
            guard let self else {
                completion()
                return
            }

            switch result {
            case let .success(products):
                guard !products.isEmpty else {
                    print("[ProductSeedService] Local products list is empty; skipping seed.")
                    completion()
                    return
                }

                do {
                    let batch = self.db.batch()
                    for product in products {
                        let docRef = self.db.collection(FirestoreCollections.products).document(product.id)
                        let data = try product.toFirestoreData()
                        batch.setData(data, forDocument: docRef, merge: true)
                    }

                    batch.commit { error in
                        if let error {
                            print("[ProductSeedService] Seed commit failed: \(error.localizedDescription)")
                        } else {
                            self.defaults.set(true, forKey: self.seedFlagKey)
                            print("[ProductSeedService] Seeded \(products.count) products to Firestore.")
                        }
                        completion()
                    }
                } catch {
                    print("[ProductSeedService] Failed to encode products for seed: \(error.localizedDescription)")
                    completion()
                }

            case let .failure(error):
                print("[ProductSeedService] Failed to load local products for seed: \(error.localizedDescription)")
                completion()
            }
        }
    }
}
