import SwiftUI

struct AuthLandingView: View {
    var body: some View {
        AppBackground {
            VStack(spacing: 24) {
                Spacer(minLength: 80)

                AppLogoHeader()

                Spacer(minLength: 40)

                NavigationLink(destination: LoginView()) {
                    Text("Log In")
                }
                .buttonStyle(FilledPrimaryButtonStyle())

                NavigationLink(destination: SignupView()) {
                    Text("Sign Up")
                }
                .buttonStyle(OutlinedPrimaryButtonStyle())

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

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        AuthLandingView()
    }
}
