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
                        completion(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "You must be logged in to update profile.", bangla: "প্রোফাইল আপডেট করতে লগ ইন করতে হবে।")])))
            return
        }

        let cleanedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "Name is required.", bangla: "নাম প্রয়োজন।")])))
            return
        }

        guard isValidEmail(cleanedEmail) else {
            completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "Please enter a valid email address.", bangla: "দয়া করে একটি সঠিক ইমেইল ঠিকানা দিন।")])))
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
                        self.userService.fetchCurrentUser(userId: currentUserId) { fetchResult in
                            DispatchQueue.main.async {
                                switch fetchResult {
                                case let .success(freshUser):
                                    self.currentUser = freshUser
                                    UserDefaults.standard.set(preferredLanguageCode, forKey: self.appLanguageDefaultsKey)
                                    completion(.success(()))
                                case let .failure(error):
                                    completion(.failure(error))
                                }
                            }
                        }
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }

        if cleanedEmail.caseInsensitiveCompare(currentUser.email) != .orderedSame {
            guard let currentPasswordForEmailChange,
                  !currentPasswordForEmailChange.isEmpty else {
                                completion(.failure(NSError(domain: "AppState", code: 422, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "Current password is required to change email.", bangla: "ইমেইল পরিবর্তন করতে বর্তমান পাসওয়ার্ড প্রয়োজন।")])))
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
            completion(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "No logged-in user found.", bangla: "কোনো লগ ইন করা ব্যবহারকারী পাওয়া যায়নি।")])))
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
            completion?(.failure(NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: localizedText(english: "No logged-in user.", bangla: "কোনো লগ ইন করা ব্যবহারকারী নেই।")])))
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
            return localizedText(english: "Authentication failed. Please try again.", bangla: "অথেনটিকেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।")
        }

        switch code {
        case .wrongPassword:
            return localizedText(english: "Incorrect password", bangla: "ভুল পাসওয়ার্ড")
        case .userNotFound:
            return localizedText(english: "No account found with this email", bangla: "এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি")
        case .invalidEmail:
            return localizedText(english: "Invalid email format", bangla: "ইমেইল ফরম্যাট সঠিক নয়")
        case .emailAlreadyInUse:
            return localizedText(english: "This email is already registered.", bangla: "এই ইমেইল ইতোমধ্যে নিবন্ধিত।")
        case .weakPassword:
            return localizedText(english: "Password is too weak. Use at least 6 characters.", bangla: "পাসওয়ার্ড দুর্বল। কমপক্ষে ৬ অক্ষর ব্যবহার করুন।")
        case .networkError:
            return localizedText(english: "Network error. Please check your internet connection and try again.", bangla: "নেটওয়ার্ক ত্রুটি। ইন্টারনেট সংযোগ যাচাই করে আবার চেষ্টা করুন।")
        default:
            return authError.localizedDescription
        }
    }

    /// Converts profile and Firestore errors into simple UI messages.
    func userFriendlyProfileError(_ error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            return localizedText(english: "Network error while loading your profile.", bangla: "প্রোফাইল লোড করার সময় নেটওয়ার্ক ত্রুটি হয়েছে।")
        }

        if nsError.code == 404 {
            return localizedText(english: "Profile not found. Please complete signup again.", bangla: "প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে আবার সাইন আপ সম্পন্ন করুন।")
        }

        return localizedText(english: "Unable to load profile right now. Please try again.", bangla: "এই মুহূর্তে প্রোফাইল লোড করা যাচ্ছে না। আবার চেষ্টা করুন।")
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    private func localizedText(english: String, bangla: String) -> String {
        let code = UserDefaults.standard.string(forKey: appLanguageDefaultsKey) ?? AppLanguage.englishUS.rawValue
        return AppLanguage.from(code: code).text(english: english, bangla: bangla)
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
