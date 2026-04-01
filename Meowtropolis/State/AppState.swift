import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Shared app state for simple login-based routing.
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserId: String?

    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = (user != nil)
            self?.currentUserId = user?.uid
        }
    }

    deinit {
        if let authListenerHandle {
            Auth.auth().removeStateDidChangeListener(authListenerHandle)
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func signup(fullName: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.success(()))
                return
            }

            let user = User(id: uid, name: fullName, email: email)

            do {
                let data = try FirestoreModelCoder.encode(user)
                Firestore.firestore()
                    .collection(FirestoreCollection.users.rawValue)
                    .document(uid)
                    .setData(data) { firestoreError in
                        if let firestoreError {
                            completion(.failure(firestoreError))
                            return
                        }
                        completion(.success(()))
                    }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
