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

                        Text(text("Sign Up", "সাইন আপ"))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()
                        Color.clear.frame(width: 34, height: 34)
                    }
                    .padding(.bottom, 24)

                    AppInputField(title: text("Name", "নাম"), text: $fullName) {
                        if let fullNameError {
                            Text(fullNameError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    AppInputField(title: text("Email", "ইমেইল"), text: $email) {
                        if let emailError {
                            Text(emailError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    AppInputField(title: text("Password", "পাসওয়ার্ড"), text: $password, isSecure: true) {
                        if let passwordError {
                            Text(passwordError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    AppInputField(title: text("Confirm password", "পাসওয়ার্ড নিশ্চিত করুন"), text: $confirmPassword, isSecure: true) {
                        if let confirmPasswordError {
                            Text(confirmPasswordError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
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

                    Button(isLoading ? text("Creating Account...", "অ্যাকাউন্ট তৈরি হচ্ছে...") : text("Sign Up", "সাইন আপ")) {
                        createAccount()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView(text("Creating your account...", "আপনার অ্যাকাউন্ট তৈরি হচ্ছে..."))
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
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func createAccount() {
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
                    errorMessage = appState.userFriendlyAuthError(error)
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        let cleanedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedName.isEmpty {
            fullNameError = text("Name is required.", "নাম প্রয়োজন।")
            isValid = false
        }

        if cleanedEmail.isEmpty {
            emailError = text("Email is required.", "ইমেইল প্রয়োজন।")
            isValid = false
        } else if !isValidEmail(cleanedEmail) {
            emailError = text("Please enter a valid email address.", "দয়া করে একটি সঠিক ইমেইল ঠিকানা দিন।")
            isValid = false
        }

        if password.isEmpty {
            passwordError = text("Password is required.", "পাসওয়ার্ড প্রয়োজন।")
            isValid = false
        } else if password.count < 6 {
            passwordError = text("Password must be at least 6 characters.", "পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।")
            isValid = false
        }

        if confirmPassword.isEmpty {
            confirmPasswordError = text("Please confirm your password.", "দয়া করে আপনার পাসওয়ার্ড নিশ্চিত করুন।")
            isValid = false
        } else if confirmPassword != password {
            confirmPasswordError = text("Passwords do not match.", "পাসওয়ার্ড মিলছে না।")
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
