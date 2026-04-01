import SwiftUI
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MeowtropolisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let authService: any AuthService
    @StateObject private var appState: AppState

    init() {
        let service = FirebaseAuthService()
        self.authService = service
        _appState = StateObject(wrappedValue: AppState(authService: service))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Check Firebase session when app starts.
                    appState.checkSession()
                }
        }
    }
}
