import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

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

                        Text("Sign Up")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()
                        Color.clear.frame(width: 34, height: 34)
                    }
                    .padding(.bottom, 24)

                    AppInputField(title: "Name", text: $fullName) {
                        if let fullNameError {
                            Text(fullNameError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

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

                    AppInputField(title: "Confirm password", text: $confirmPassword, isSecure: true) {
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

                    Button(isLoading ? "Creating Account..." : "Sign Up") {
                        createAccount()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView("Creating your account...")
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
                    successMessage = "Account created successfully."
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
            fullNameError = "Name is required."
            isValid = false
        }

        if cleanedEmail.isEmpty {
            emailError = "Email is required."
            isValid = false
        } else if !isValidEmail(cleanedEmail) {
            emailError = "Please enter a valid email address."
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Password is required."
            isValid = false
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters."
            isValid = false
        }

        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password."
            isValid = false
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
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
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
