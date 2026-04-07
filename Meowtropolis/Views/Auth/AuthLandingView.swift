import SwiftUI

struct AuthLandingView: View {
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
                        Text("Log In")
                    }
                    .buttonStyle(FilledPrimaryButtonStyle())
                    .accessibilityIdentifier("authLandingLoginButton")

                    NavigationLink(destination: SignupView()) {
                        Text("Sign Up")
                    }
                    .buttonStyle(OutlinedPrimaryButtonStyle())
                    .accessibilityIdentifier("authLandingSignupButton")

                    HStack {
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                        Text("Or")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .padding(.horizontal, 8)
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                    }
                    .padding(.top, 4)

                    SocialActionButton(title: "Continue with Google", icon: "g.circle.fill")
                    SocialActionButton(title: "Continue with Facebook", icon: "f.cursive.circle.fill")
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        AuthLandingView()
    }
}
