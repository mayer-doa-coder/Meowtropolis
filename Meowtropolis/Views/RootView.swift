import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
    @State private var showSplash: Bool = !ProcessInfo.processInfo.arguments.contains("-uiTestSkipSplash")
    @State private var showOnboarding: Bool = !ProcessInfo.processInfo.arguments.contains("-uiTestSkipOnboarding")

    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    showSplash = false
                }
            } else if !appState.isLoggedIn && showOnboarding {
                OnboardingView {
                    showOnboarding = false
                    UserHistoryService.shared.recordCurrentUser(
                        category: .system,
                        action: "Completed onboarding"
                    )
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
                Text(text("Loading your profile...", "আপনার প্রোফাইল লোড হচ্ছে..."))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }
            .padding(20)
        }
    }

    private func profileErrorView(_ message: String) -> some View {
        AppBackground {
            VStack(spacing: 16) {
                Text(text("Could not load profile", "প্রোফাইল লোড করা যায়নি"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)

                Text(message)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)

                Button(text("Retry", "আবার চেষ্টা করুন")) {
                    UserHistoryService.shared.recordCurrentUser(
                        category: .account,
                        action: "Tapped retry on profile load"
                    )
                    appState.loadCurrentUserProfile()
                }
                .buttonStyle(FilledPrimaryButtonStyle())

                Button(text("Logout", "লগ আউট")) {
                    UserHistoryService.shared.recordCurrentUser(
                        category: .auth,
                        action: "Tapped logout from profile error"
                    )
                    appState.logout()
                }
                .buttonStyle(OutlinedPrimaryButtonStyle())
            }
            .padding(20)
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
