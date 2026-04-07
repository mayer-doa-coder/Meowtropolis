import SwiftUI

struct AuthLandingView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 24) {
                    if let heroURL = AppImageLibrary.authHeroURL {
                        AsyncImage(url: heroURL) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    AppLogoHeader()

                    NavigationLink(destination: LoginView()) {
                        Text(text("Log In", "লগ ইন"))
                    }
                    .buttonStyle(FilledPrimaryButtonStyle())
                    .accessibilityIdentifier("authLandingLoginButton")

                    NavigationLink(destination: SignupView()) {
                        Text(text("Sign Up", "সাইন আপ"))
                    }
                    .buttonStyle(OutlinedPrimaryButtonStyle())
                    .accessibilityIdentifier("authLandingSignupButton")

                    HStack {
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                        Text(text("Or", "অথবা"))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .padding(.horizontal, 8)
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                    }
                    .padding(.top, 4)

                    SocialActionButton(title: text("Continue with Google", "গুগল দিয়ে চালিয়ে যান"), icon: "g.circle.fill")
                    SocialActionButton(title: text("Continue with Facebook", "ফেসবুক দিয়ে চালিয়ে যান"), icon: "f.cursive.circle.fill")
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    NavigationStack {
        AuthLandingView()
    }
}
