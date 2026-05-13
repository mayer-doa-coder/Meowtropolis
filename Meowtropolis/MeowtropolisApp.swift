import SwiftUI
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
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
        let service = FirebaseAuthService()
        self.authService = service
        _appState = StateObject(wrappedValue: AppState(authService: service))
        print("[AppStartup] App init completed")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(cartState)
                .onAppear {
                    appState.checkSession()
                }
        }
    }
}
