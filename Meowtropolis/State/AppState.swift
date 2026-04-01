import Foundation
import Combine
import FirebaseAuth

/// Shared app state for simple login-based routing.
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserId: String?

    private let authService: any AuthService
    private let userService: UserService
    private var authListenerHandle: NSObjectProtocol?

    init(authService: any AuthService = FirebaseAuthService(), userService: UserService = UserService()) {
        self.authService = authService
        self.userService = userService

        // Set initial state immediately when app starts.
        checkSession()

        // Keep state synced with auth changes.
        authListenerHandle = authService.addAuthStateDidChangeListener { [weak self] userId in
            DispatchQueue.main.async {
                self?.isLoggedIn = (userId != nil)
                self?.currentUserId = userId
            }
        }
    }

    deinit {
        if let authListenerHandle {
            authService.removeAuthStateDidChangeListener(authListenerHandle)
        }
    }

    func checkSession() {
        currentUserId = authService.currentUserId
        isLoggedIn = (currentUserId != nil)
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.currentUserId = self?.authService.currentUserId
                    self?.isLoggedIn = (self?.currentUserId != nil)
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func signup(fullName: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.signUp(email: email, password: password) { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }

            case let .success(uid):
                let user = User(id: uid, name: fullName, email: email)

                userService.createUserProfile(user: user) { profileResult in
                    DispatchQueue.main.async {
                        switch profileResult {
                        case .success:
                            self.isLoggedIn = true
                            self.currentUserId = uid
                            completion(.success(()))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }

    func logout(completion: ((Result<Void, Error>) -> Void)? = nil) {
        authService.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isLoggedIn = false
                    self?.currentUserId = nil
                    completion?(.success(()))
                case let .failure(error):
                    completion?(.failure(error))
                }
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.resetPassword(email: email) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Converts backend auth errors into simple UI messages.
    func userFriendlyAuthError(_ error: Error) -> String {
        guard let authError = error as NSError?,
              let code = AuthErrorCode(rawValue: authError.code) else {
            return "Authentication failed. Please try again."
        }

        switch code {
        case .wrongPassword:
            return "Incorrect password"
        case .userNotFound:
            return "No account found with this email"
        case .invalidEmail:
            return "Invalid email format"
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        default:
            return authError.localizedDescription
        }
    }
}
