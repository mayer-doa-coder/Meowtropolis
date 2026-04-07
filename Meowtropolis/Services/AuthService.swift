import Foundation

/// Simple interface for authentication operations.
/// AppState depends on this protocol instead of Firebase directly.
protocol AuthService {
    /// Current signed-in user id, or nil when logged out.
    var currentUserId: String? { get }

    /// Listen for login/logout changes.
    @discardableResult
    func addAuthStateDidChangeListener(_ listener: @escaping (String?) -> Void) -> NSObjectProtocol

    /// Remove a previously added auth listener.
    func removeAuthStateDidChangeListener(_ handle: NSObjectProtocol)

    /// Create a new account and return created user id.
    func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)

    /// Sign in an existing user.
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Sign out current user.
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)

    /// Send password reset email.
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Update signed-in user email after re-authentication with current password.
    func updateEmail(currentPassword: String, newEmail: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Update signed-in user password after re-authentication with current password.
    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void)

    /// Permanently delete signed-in user after re-authentication with current password.
    func deleteCurrentUser(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void)
}
