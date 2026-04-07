import Foundation
import FirebaseFirestore

/// Handles Firestore operations for user profile data.
final class UserService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// Creates or updates a user profile in Firestore.
    func createUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let payload = try FirestoreModelCoder.encode(user)
            db.collection(FirestoreCollections.users)
                .document(user.id)
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

    /// Fetches one user profile by user id.
    func fetchCurrentUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection(FirestoreCollections.users)
            .document(userId)
            .getDocument { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let data = snapshot?.data() else {
                    completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])))
                    return
                }

                do {
                    let user = try FirestoreModelCoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Updates user profile document using full User payload.
    func updateUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        createUserProfile(user: user, completion: completion)
    }

    /// Deletes user profile document by user id.
    func deleteUserProfile(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.users)
            .document(userId)
            .delete { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }
}
