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
                    }
                    .padding(.bottom, 4)

                    Text(text("Welcome to Meowtropolis", "Meowtropolis-এ স্বাগতম"))
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    Text(text("Manage your pets, book services, and more", "আপনার পোষা প্রাণী পরিচালনা করুন, সেবা বুক করুন এবং আরও অনেক কিছু করুন"))
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.muted)

                    CardView {
                        AppInputField(title: text("Email", "ইমেইল"), text: $email, fieldIdentifier: "loginEmailField") {
                            fieldSupportText(
                                helpText: text("Enter your email address", "আপনার ইমেইল ঠিকানা লিখুন"),
                                errorText: emailError
                            )
                        }

                        AppInputField(title: text("Password", "পাসওয়ার্ড"), text: $password, isSecure: true, fieldIdentifier: "loginPasswordField") {
                            fieldSupportText(
                                helpText: text("At least 6 characters", "কমপক্ষে ৬ অক্ষর"),
                                errorText: passwordError
                            )
                        }

                        if let successMessage {
                            Text(successMessage)
                                .font(TextStyles.caption)
                                .foregroundStyle(.green)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(TextStyles.caption)
                                .foregroundStyle(.red)
                        }

                        Button(isLoading ? text("Logging in...", "লগইন হচ্ছে...") : text("Login", "লগইন করুন")) {
                            loginUser()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                        .disabled(isLoading)
                        .accessibilityIdentifier("loginSubmitButton")

                        if isLoading {
                            ProgressView(text("Logging in...", "লগইন হচ্ছে..."))
                                .frame(maxWidth: .infinity)
                        }

                        HStack(spacing: 4) {
                            Text(text("Don't have an account?", "অ্যাকাউন্ট নেই?"))
                                .foregroundStyle(AppDesign.muted)

                            NavigationLink(text("Sign Up", "নিবন্ধন করুন"), destination: SignupView())
                                .foregroundStyle(.blue)
                        }
                        .font(TextStyles.body)
                        .frame(maxWidth: .infinity)

                        NavigationLink(text("Forgot password?", "পাসওয়ার্ড ভুলে গেছেন?"), destination: ForgotPasswordView())
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    DividerWithText(text: text("Or", "অথবা"))

                    SocialActionButton(title: text("Continue with Google", "গুগল দিয়ে চালিয়ে যান"), icon: "g.circle.fill")
                    SocialActionButton(title: text("Continue with Facebook", "ফেসবুক দিয়ে চালিয়ে যান"), icon: "f.cursive.circle.fill")
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loginUser() {
        print("[AuthUI] Login attempt")
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
            successMessage = text("Login successful. Redirecting to dashboard...", "লগইন সফল। ড্যাশবোর্ডে নেওয়া হচ্ছে...")
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
                    successMessage = text("Login successful. Redirecting to dashboard...", "লগইন সফল। ড্যাশবোর্ডে নেওয়া হচ্ছে...")
                    // RootView observes appState.isLoggedIn and shows DashboardView automatically.
                case let .failure(error):
                    let defaultMessage = text(
                        "Login failed. Please check your email and password.",
                        "লগইন ব্যর্থ হয়েছে। ইমেইল এবং পাসওয়ার্ড যাচাই করুন।"
                    )
                    let detailedMessage = appState.userFriendlyAuthError(error)
                    errorMessage = detailedMessage.isEmpty ? defaultMessage : "\(defaultMessage)\n\(detailedMessage)"
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedEmail.isEmpty {
            print("[AuthUI] Validation error: email")
            emailError = text("Please enter your email address.", "দয়া করে আপনার ইমেইল ঠিকানা লিখুন।")
            isValid = false
        } else if !isValidEmail(cleanedEmail) {
            print("[AuthUI] Validation error: email")
            emailError = text("Please enter a valid email address.", "দয়া করে একটি সঠিক ইমেইল ঠিকানা লিখুন।")
            isValid = false
        }

        if password.isEmpty {
            passwordError = text("Please enter your password.", "দয়া করে আপনার পাসওয়ার্ড লিখুন।")
            isValid = false
        } else if password.count < 6 {
            passwordError = text("Password must be at least 6 characters.", "পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।")
            isValid = false
        }

        return isValid
    }

    // Simple regex for beginner-level email format validation.
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    @ViewBuilder
    private func fieldSupportText(helpText: String, errorText: String?) -> some View {
        Text(helpText)
            .font(TextStyles.caption)
            .foregroundStyle(AppDesign.muted)

        if let errorText {
            Text(errorText)
                .font(TextStyles.caption)
                .foregroundStyle(.red)
        }
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
