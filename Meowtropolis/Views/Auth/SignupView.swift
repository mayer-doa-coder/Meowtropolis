import SwiftUI
import FirebaseAuth
import Combine
struct SignupView: View {
    @EnvironmentObject private var appState: AppState

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Signup")
                .font(.title)
                .bold()

            Text("Create account to access Meowtropolis")
                .foregroundStyle(.secondary)

            TextField("Full Name", text: $fullName)
                .textFieldStyle(.roundedBorder)

            if let fullNameError {
                Text(fullNameError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            if let emailError {
                Text(emailError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let passwordError {
                Text(passwordError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let successMessage {
                Text(successMessage)
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(isLoading ? "Creating Account..." : "Create Account") {
                createAccount()
            }
            .disabled(isLoading)
            .buttonStyle(.borderedProminent)

            if isLoading {
                ProgressView("Creating your account...")
            }
        }
        .padding()
        .navigationTitle("Create Account")
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
                    errorMessage = userFriendlyAuthError(error)
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

        return isValid
    }

    // Simple regex for beginner-level email format validation.
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    private func clearMessages() {
        fullNameError = nil
        emailError = nil
        passwordError = nil
        errorMessage = nil
        successMessage = nil
    }

    // Convert Firebase errors into simple messages for users.
    private func userFriendlyAuthError(_ error: Error) -> String {
        guard let authError = error as NSError?,
              let code = AuthErrorCode(rawValue: authError.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "The email format is invalid."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Your password is too weak. Use at least 6 characters."
        default:
            return authError.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
