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

    private let appLanguageDefaultsKey = "appLanguageCode"

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
                let user = User(
                    id: uid,
                    name: fullName,
                    email: email,
                    preferredLanguageCode: UserDefaults.standard.string(forKey: appLanguageDefaultsKey)
                )

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

    func updatePersonalInformation(
        fullName: String,
        email: String,
        preferredLanguageCode: String,
        profileImageBase64: String?,
        currentPasswordForEmailChange: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUserId,
              let currentUser else {
            completion(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: "You must be logged in to update profile."])))
            return
        }

        let cleanedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: "Name is required."])))
            return
        }

        guard isValidEmail(cleanedEmail) else {
            completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email address."])))
            return
        }

        let updatedUser = User(
            id: currentUserId,
            name: cleanedName,
            email: cleanedEmail,
            preferredLanguageCode: preferredLanguageCode,
            profileImageBase64: profileImageBase64
        )

        let saveProfile: () -> Void = { [weak self] in
            guard let self else {
                return
            }

            self.userService.updateUserProfile(user: updatedUser) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.currentUser = updatedUser
                        UserDefaults.standard.set(preferredLanguageCode, forKey: self.appLanguageDefaultsKey)
                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }

        if cleanedEmail.caseInsensitiveCompare(currentUser.email) != .orderedSame {
            guard let currentPasswordForEmailChange,
                  !currentPasswordForEmailChange.isEmpty else {
                completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: "Current password is required to change email."])))
                return
            }

            authService.updateEmail(currentPassword: currentPasswordForEmailChange, newEmail: cleanedEmail) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        saveProfile()
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        } else {
            saveProfile()
        }
    }

    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func deleteAccount(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId else {
            completion(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])))
            return
        }

        userService.deleteUserProfile(userId: currentUserId) { [weak self] profileDeletionResult in
            guard let self else {
                return
            }

            switch profileDeletionResult {
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }

            case .success:
                self.authService.deleteCurrentUser(currentPassword: currentPassword) { authDeletionResult in
                    DispatchQueue.main.async {
                        switch authDeletionResult {
                        case .success:
                            self.isLoggedIn = false
                            self.currentUserId = nil
                            self.currentUser = nil
                            self.isProfileLoading = false
                            self.profileErrorMessage = nil
                            completion(.success(()))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
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
                    if let code = user.preferredLanguageCode, !code.isEmpty {
                        UserDefaults.standard.set(code, forKey: self.appLanguageDefaultsKey)
                    }
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

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
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
