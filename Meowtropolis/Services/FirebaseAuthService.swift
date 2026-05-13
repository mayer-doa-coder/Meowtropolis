import Foundation
import FirebaseAuth

// GUARDRAIL:
// Do not modify Firebase authentication wiring, completion semantics, or service contracts in this phase.
// Required for MVP stability and demo consistency.
// If a requested change risks backend connectivity, stop and log it in docs/issue_inventory.md.

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
        Auth.auth().removeStateDidChangeListener(handle)
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

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func updateEmail(currentPassword: String, newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(user):
                user.updateEmail(to: newEmail) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
        }
    }

    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(user):
                user.updatePassword(to: newPassword) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
        }
    }

    func deleteCurrentUser(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(user):
                user.delete { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
        }
    }

    private func reauthenticate(currentPassword: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            completion(.failure(NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No signed-in user found."])))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(user))
        }
    }
}
