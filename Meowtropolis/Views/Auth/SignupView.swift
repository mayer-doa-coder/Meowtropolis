import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

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

            Button("Create Account (Temporary)") {
                // Day 3: temporary signup without backend.
                appState.isLoggedIn = true
            }
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
