import SwiftUI
import FirebaseAuth
struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Login")
                .font(.title)
                .bold()

            Text("Sign in to continue to dashboard")
                .foregroundStyle(.secondary)

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

            Button(isLoading ? "Logging in..." : "Login") {
                loginUser()
            }
            .disabled(isLoading)
            .buttonStyle(.borderedProminent)

            if isLoading {
                ProgressView("Signing in...")
            }

            NavigationLink("Create new account", destination: SignupView())
                .padding(.top, 8)
        }
        .padding()
        .navigationTitle("Welcome")
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
