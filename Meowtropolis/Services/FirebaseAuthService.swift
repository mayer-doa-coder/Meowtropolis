import Foundation
import FirebaseAuth

/// Firebase implementation of AuthService.
final class FirebaseAuthService: AuthService {
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    @discardableResult
    func addAuthStateDidChangeListener(_ listener: @escaping (String?) -> Void) -> NSObjectProtocol {
        Auth.auth().addStateDidChangeListener { _, user in
            listener(user?.uid)
        }
    }

    func removeAuthStateDidChangeListener(_ handle: NSObjectProtocol) {
        guard let typedHandle = handle as? AuthStateDidChangeListenerHandle else {
            return
        }
        Auth.auth().removeStateDidChangeListener(typedHandle)
    }

    func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user."])))
                return
            }

            completion(.success(uid))
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
