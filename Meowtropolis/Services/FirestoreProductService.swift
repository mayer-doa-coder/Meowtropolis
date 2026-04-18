import Foundation
import FirebaseFirestore

// GUARDRAIL:
// Do not modify Firestore connection behavior or product fetch contract in this phase.
// Required for MVP stability and demo consistency.
// If a requested change risks backend connectivity, stop and log it in docs/issue_inventory.md.

/// Loads product data from Firestore.
final class FirestoreProductService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// Fetches all products from Firestore products collection.
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        db.collection(FirestoreCollections.products)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                do {
                    let products = try documents.map { document in
                        try FirestoreModelCoder.decode(Product.self, from: document.data())
                    }
                    completion(.success(products))
                } catch {
                    completion(.failure(error))
                }
            }
    }
}
