import Foundation
import Combine
import FirebaseAuth

/// Shared app state for simple login-based routing.
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserId: String?
    @Published var currentUser: User?
    @Published var isProfileLoading: Bool = false
    @Published var profileErrorMessage: String?

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
                self?.handleAuthStateChanged(userId: userId)
            }
        }
    }

    deinit {
        if let authListenerHandle {
            authService.removeAuthStateDidChangeListener(authListenerHandle)
        }
    }

    func checkSession() {
        handleAuthStateChanged(userId: authService.currentUserId)
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.handleAuthStateChanged(userId: self?.authService.currentUserId)
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
                            self.handleAuthStateChanged(userId: uid)
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
                    self?.currentUser = nil
                    self?.isProfileLoading = false
                    self?.profileErrorMessage = nil
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

    /// Loads profile after login to make user data available app-wide.
    func loadCurrentUserProfile(completion: ((Result<User, Error>) -> Void)? = nil) {
        guard let userId = currentUserId else {
            currentUser = nil
            isProfileLoading = false
            profileErrorMessage = nil
            completion?(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])))
            return
        }

        isProfileLoading = true
        profileErrorMessage = nil

        userService.fetchCurrentUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                self.isProfileLoading = false

                switch result {
                case let .success(user):
                    self.currentUser = user
                    self.profileErrorMessage = nil
                    completion?(.success(user))
                case let .failure(error):
                    self.currentUser = nil
                    self.profileErrorMessage = self.userFriendlyProfileError(error)
                    completion?(.failure(error))
                }
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
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        default:
            return authError.localizedDescription
        }
    }

    /// Converts profile and Firestore errors into simple UI messages.
    func userFriendlyProfileError(_ error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            return "Network error while loading your profile."
        }

        if nsError.code == 404 {
            return "Profile not found. Please complete signup again."
        }

        return "Unable to load profile right now. Please try again."
    }

    private func handleAuthStateChanged(userId: String?) {
        isLoggedIn = (userId != nil)
        currentUserId = userId

        guard userId != nil else {
            currentUser = nil
            isProfileLoading = false
            profileErrorMessage = nil
            return
        }

        // Fetch profile on every fresh authenticated state to avoid stale data.
        loadCurrentUserProfile()
    }
}
