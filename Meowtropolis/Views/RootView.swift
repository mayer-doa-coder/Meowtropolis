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
            } else {
                NavigationStack {
                    if appState.isLoggedIn {
                        DashboardView()
                    } else {
                        LoginView()
                    }
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
