import Foundation
import FirebaseFirestore

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
