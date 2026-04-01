import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

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

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button(isLoading ? "Logging in..." : "Login") {
                errorMessage = nil
                isLoading = true
                appState.login(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        if case let .failure(error) = result {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)

            NavigationLink("Create new account", destination: SignupView())
                .padding(.top, 8)
        }
        .padding()
        .navigationTitle("Welcome")
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
    }
}
