import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSplash: Bool = true
    @State private var showOnboarding: Bool = true

    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                }
            } else if !appState.isLoggedIn && showOnboarding {
                OnboardingView {
                    showOnboarding = false
                }
            } else if appState.isLoggedIn && appState.isProfileLoading {
                profileLoadingView
            } else if appState.isLoggedIn, let profileError = appState.profileErrorMessage {
                profileErrorView(profileError)
            } else if appState.isLoggedIn {
                NavigationStack {
                    DashboardView()
                }
                // Reset authenticated navigation tree when auth state changes.
                .id("authenticated")
            } else {
                NavigationStack {
                    AuthLandingView()
                }
                // Reset login navigation tree when auth state changes.
                .id("unauthenticated")
            }
        }
    }

    private var profileLoadingView: some View {
        AppBackground {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading your profile...")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }
            .padding(20)
        }
    }

    private func profileErrorView(_ message: String) -> some View {
        AppBackground {
            VStack(spacing: 16) {
                Text("Could not load profile")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)

                Text(message)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    appState.loadCurrentUserProfile()
                }
                .buttonStyle(FilledPrimaryButtonStyle())

                Button("Logout") {
                    appState.logout()
                }
                .buttonStyle(OutlinedPrimaryButtonStyle())
            }
            .padding(20)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
