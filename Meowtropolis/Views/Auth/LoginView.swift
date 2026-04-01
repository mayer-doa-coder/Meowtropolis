import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(AppDesign.primary)
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("Log In")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()
                        Color.clear.frame(width: 34, height: 34)
                    }
                    .padding(.bottom, 24)

                    AppInputField(title: "Email", text: $email) {
                        if let emailError {
                            Text(emailError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    AppInputField(title: "Password", text: $password, isSecure: true) {
                        if let passwordError {
                            Text(passwordError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    HStack {
                        Label("Remember me", systemImage: "checkmark.square.fill")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()

                        NavigationLink("Forgot password?", destination: ForgotPasswordView())
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                    }

                    if let successMessage {
                        Text(successMessage)
                            .font(.footnote)
                            .foregroundStyle(.green)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button(isLoading ? "Logging in..." : "Log In") {
                        loginUser()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView("Signing in...")
                            .frame(maxWidth: .infinity)
                    }

                    HStack {
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                        Text("Or")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .padding(.horizontal, 8)
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                    }
                    .padding(.top, 8)

                    SocialActionButton(title: "Continue with Google", icon: "g.circle.fill")
                    SocialActionButton(title: "Continue with Facebook", icon: "f.cursive.circle.fill")

                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(AppDesign.muted)
                        NavigationLink("Register", destination: SignupView())
                            .foregroundStyle(.blue)
                    }
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loginUser() {
        clearMessages()

        guard validateInputs() else {
            return
        }

        isLoading = true
        appState.login(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        ) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success:
                    successMessage = "Login successful. Redirecting to dashboard..."
                    // RootView observes appState.isLoggedIn and shows DashboardView automatically.
                case let .failure(error):
                    errorMessage = userFriendlyAuthError(error)
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedEmail.isEmpty {
            emailError = "Email is required."
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Password is required."
            isValid = false
        }

        return isValid
    }

    private func clearMessages() {
        emailError = nil
        passwordError = nil
        errorMessage = nil
        successMessage = nil
    }

    // Convert Firebase Auth error codes into simple messages.
    private func userFriendlyAuthError(_ error: Error) -> String {
        guard let authError = error as NSError?,
              let code = AuthErrorCode(rawValue: authError.code) else {
            return "Login failed. Please try again."
        }

        switch code {
        case .wrongPassword:
            return "Incorrect password"
        case .userNotFound:
            return "No account found with this email"
        case .invalidEmail:
            return "Invalid email format"
        default:
            return "Login failed. Please try again."
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
    }
}
