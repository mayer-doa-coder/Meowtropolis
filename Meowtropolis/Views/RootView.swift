import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSplash: Bool = true

    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                }
            } else if appState.isLoggedIn {
                NavigationStack {
                    DashboardView()
                }
                // Reset authenticated navigation tree when auth state changes.
                .id("authenticated")
            } else {
                NavigationStack {
                    LoginView()
                }
                // Reset login navigation tree when auth state changes.
                .id("unauthenticated")
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
