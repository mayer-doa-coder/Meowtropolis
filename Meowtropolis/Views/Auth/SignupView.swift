import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
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
                        AppInputField(title: text("Name", "নাম"), text: $fullName) {
                            fieldSupportText(
                                helpText: text("Enter your full name", "আপনার পুরো নাম লিখুন"),
                                errorText: fullNameError
                            )
                        }

                        AppInputField(title: text("Email", "ইমেইল"), text: $email) {
                            fieldSupportText(
                                helpText: text("Enter your email address", "আপনার ইমেইল ঠিকানা লিখুন"),
                                errorText: emailError
                            )
                        }

                        AppInputField(title: text("Password", "পাসওয়ার্ড"), text: $password, isSecure: true) {
                            fieldSupportText(
                                helpText: text("At least 6 characters", "কমপক্ষে ৬ অক্ষর"),
                                errorText: passwordError
                            )
                        }

                        AppInputField(title: text("Confirm password", "পাসওয়ার্ড নিশ্চিত করুন"), text: $confirmPassword, isSecure: true) {
                            fieldSupportText(
                                helpText: text("Re-enter your password", "আপনার পাসওয়ার্ড আবার লিখুন"),
                                errorText: confirmPasswordError
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

                        Button(isLoading ? text("Creating account...", "অ্যাকাউন্ট তৈরি হচ্ছে...") : text("Sign Up", "নিবন্ধন করুন")) {
                            createAccount()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                        .disabled(isLoading)

                        if isLoading {
                            ProgressView(text("Creating your account...", "আপনার অ্যাকাউন্ট তৈরি হচ্ছে..."))
                                .frame(maxWidth: .infinity)
                        }

                        HStack(spacing: 4) {
                            Text(text("Already have an account?", "ইতিমধ্যে অ্যাকাউন্ট আছে?"))
                                .foregroundStyle(AppDesign.muted)

                            NavigationLink(text("Login", "লগইন করুন"), destination: LoginView())
                                .foregroundStyle(.blue)
                        }
                        .font(TextStyles.body)
                        .frame(maxWidth: .infinity)
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

    private func createAccount() {
        print("[AuthUI] Signup attempt")
        clearMessages()

        guard validateInputs() else {
            return
        }

        isLoading = true
        appState.signup(fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines), email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success:
                    successMessage = text("Account created successfully.", "অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।")
                case let .failure(error):
                    let defaultMessage = text(
                        "Sign up failed. Please review your details and try again.",
                        "নিবন্ধন ব্যর্থ হয়েছে। আপনার তথ্য যাচাই করে আবার চেষ্টা করুন।"
                    )
                    let detailedMessage = appState.userFriendlyAuthError(error)
                    errorMessage = detailedMessage.isEmpty ? defaultMessage : "\(defaultMessage)\n\(detailedMessage)"
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        let cleanedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedName.isEmpty {
            fullNameError = text("Please enter your name.", "দয়া করে আপনার নাম লিখুন।")
            isValid = false
        }

        if cleanedEmail.isEmpty {
            print("[AuthUI] Validation error: email")
            emailError = text("Please enter your email address.", "দয়া করে আপনার ইমেইল ঠিকানা লিখুন।")
            isValid = false
        } else if !isValidEmail(cleanedEmail) {
            print("[AuthUI] Validation error: email")
            emailError = text("Please enter a valid email address.", "দয়া করে একটি সঠিক ইমেইল ঠিকানা দিন।")
            isValid = false
        }

        if password.isEmpty {
            passwordError = text("Please enter a password.", "দয়া করে একটি পাসওয়ার্ড লিখুন।")
            isValid = false
        } else if password.count < 6 {
            passwordError = text("Password must be at least 6 characters.", "পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।")
            isValid = false
        }

        if confirmPassword.isEmpty {
            confirmPasswordError = text("Please re-enter your password.", "দয়া করে আপনার পাসওয়ার্ড আবার লিখুন।")
            isValid = false
        } else if confirmPassword != password {
            confirmPasswordError = text("Passwords do not match. Please try again.", "পাসওয়ার্ড মিলছে না। আবার চেষ্টা করুন।")
            isValid = false
        }

        return isValid
    }

    // Simple regex for beginner-level email format validation.
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    private func clearMessages() {
        fullNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        errorMessage = nil
        successMessage = nil
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

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
