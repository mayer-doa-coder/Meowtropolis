import SwiftUI
import FirebaseCore
import UIKit

// GUARDRAIL:
// Do not modify fonts, colors, navigation structure, or Firebase setup in this phase.
// Required for MVP stability and demo consistency.
// If a requested change risks these areas, stop and log it in docs/issue_inventory.md.

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("[AppStartup] didFinishLaunching")
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("[AppStartup] Firebase configured from AppDelegate")
        }
        return true
    }
}

@main
struct MeowtropolisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let authService: any AuthService
    @StateObject private var appState: AppState
    @StateObject private var cartState = CartState()

    init() {
        print("[AppStartup] App init started")
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("[AppStartup] Firebase configured from App init")
        }

        MapsService.shared.configure()
        print("[AppStartup] Maps service configure invoked")
        let service = FirebaseAuthService()
        self.authService = service
        _appState = StateObject(wrappedValue: AppState(authService: service))
        print("[AppStartup] App init completed")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(cartState)
                .onAppear {
                    // Check Firebase session when app starts.
                    print("[AppStartup] Root content appeared, checking session")
                    appState.checkSession()
                }
        }
    }
}
