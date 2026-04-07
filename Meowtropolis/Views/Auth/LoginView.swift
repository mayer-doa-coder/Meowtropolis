import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

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

                        Text(text("Log In", "লগ ইন"))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()
                        Color.clear.frame(width: 34, height: 34)
                    }
                    .padding(.bottom, 24)

                    AppInputField(title: text("Email", "ইমেইল"), text: $email, fieldIdentifier: "loginEmailField") {
                        if let emailError {
                            Text(emailError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    AppInputField(title: text("Password", "পাসওয়ার্ড"), text: $password, isSecure: true, fieldIdentifier: "loginPasswordField") {
                        if let passwordError {
                            Text(passwordError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    HStack {
                        Label(text("Remember me", "মনে রাখুন"), systemImage: "checkmark.square.fill")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()

                        NavigationLink(text("Forgot password?", "পাসওয়ার্ড ভুলে গেছেন?"), destination: ForgotPasswordView())
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

                    Button(isLoading ? text("Logging in...", "লগ ইন হচ্ছে...") : text("Log In", "লগ ইন")) {
                        loginUser()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                    .disabled(isLoading)
                    .accessibilityIdentifier("loginSubmitButton")

                    if isLoading {
                        ProgressView(text("Signing in...", "সাইন ইন হচ্ছে..."))
                            .frame(maxWidth: .infinity)
                    }

                    HStack {
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                        Text(text("Or", "অথবা"))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .padding(.horizontal, 8)
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                    }
                    .padding(.top, 8)

                    SocialActionButton(title: text("Continue with Google", "গুগল দিয়ে চালিয়ে যান"), icon: "g.circle.fill")
                    SocialActionButton(title: text("Continue with Facebook", "ফেসবুক দিয়ে চালিয়ে যান"), icon: "f.cursive.circle.fill")

                    HStack(spacing: 4) {
                        Text(text("Don't have an account?", "অ্যাকাউন্ট নেই?"))
                            .foregroundStyle(AppDesign.muted)
                        NavigationLink(text("Register", "রেজিস্টার"), destination: SignupView())
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

        if ProcessInfo.processInfo.arguments.contains("-uiTestMockLoginSuccess") {
            appState.currentUserId = "ui_test_user"
            appState.currentUser = User(id: "ui_test_user", name: "UI Test User", email: email)
            appState.isProfileLoading = false
            appState.profileErrorMessage = nil
            appState.isLoggedIn = true
            successMessage = text("Login successful. Redirecting to dashboard...", "লগ ইন সফল। ড্যাশবোর্ডে নেওয়া হচ্ছে...")
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
                    successMessage = text("Login successful. Redirecting to dashboard...", "লগ ইন সফল। ড্যাশবোর্ডে নেওয়া হচ্ছে...")
                    // RootView observes appState.isLoggedIn and shows DashboardView automatically.
                case let .failure(error):
                    errorMessage = appState.userFriendlyAuthError(error)
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedEmail.isEmpty {
            emailError = text("Email is required.", "ইমেইল প্রয়োজন।")
            isValid = false
        }

        if password.isEmpty {
            passwordError = text("Password is required.", "পাসওয়ার্ড প্রয়োজন।")
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

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
    }
}
