import Foundation

/// Shared app state for simple login-based routing.
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
