import Foundation
import FirebaseFirestore

// GUARDRAIL:
// Do not modify Firestore wiring or vet service contracts in this phase.
// Required for MVP stability and demo consistency.
// If a requested change risks backend connectivity, stop and log it in docs/issue_inventory.md.

/// Handles minimal Firestore operations for vet requests.
final class VetService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// Creates a new vet request document.
    func createRequest(_ vetRequest: VetRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let payload = try FirestoreModelCoder.encode(vetRequest)
            db.collection(FirestoreCollections.vetRequests)
                .document(vetRequest.id)
                .setData(payload) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
        } catch {
            completion(.failure(error))
        }
    }

    /// Lists vet requests for one user, newest first.
    func listRequestsByUser(userId: String, completion: @escaping (Result<[VetRequest], Error>) -> Void) {
        db.collection(FirestoreCollections.vetRequests)
            .whereField("userId", isEqualTo: userId)
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
                    let requests = try documents.map { document in
                        let data = document.data()
                        return try self.decodeRequest(data: data, documentId: document.documentID)
                    }
                    .sorted { $0.createdAt > $1.createdAt }
                    completion(.success(requests))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Lists all vet requests for admin dashboard, newest first.
    func listAllRequests(completion: @escaping (Result<[VetRequest], Error>) -> Void) {
        db.collection(FirestoreCollections.vetRequests)
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
                    let requests = try documents.map { document in
                        try self.decodeRequest(data: document.data(), documentId: document.documentID)
                    }
                    .sorted { $0.createdAt > $1.createdAt }
                    completion(.success(requests))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Updates request status for admin handling.
    func updateRequestStatus(requestId: String, status: VetRequestStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.vetRequests)
            .document(requestId)
            .updateData(["status": status.rawValue]) { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    /// Supports legacy docs where id may be missing from payload.
    private func decodeRequest(data: [String: Any], documentId: String) throws -> VetRequest {
        var normalized = data

        if (normalized["id"] as? String)?.isEmpty != false {
            normalized["id"] = documentId
        }

        return try FirestoreModelCoder.decode(VetRequest.self, from: normalized)
    }
}
