import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Signup")
                .font(.title)
                .bold()

            Text("Create account to access Meowtropolis")
                .foregroundStyle(.secondary)

            TextField("Full Name", text: $fullName)
                .textFieldStyle(.roundedBorder)

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

            Button(isLoading ? "Creating Account..." : "Create Account") {
                errorMessage = nil
                isLoading = true
                appState.signup(fullName: fullName, email: email, password: password) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        if case let .failure(error) = result {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            .disabled(isLoading || fullName.isEmpty || email.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Create Account")
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AppState())
    }
}
