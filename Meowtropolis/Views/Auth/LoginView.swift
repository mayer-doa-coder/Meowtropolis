import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""

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

            Button("Login (Temporary)") {
                // Day 3: temporary login without backend.
                appState.isLoggedIn = true
            }
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
