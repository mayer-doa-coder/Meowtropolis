import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var emailError: String?
    @State private var isLoading: Bool = false
    @State private var message: String?
    @State private var goToOTP: Bool = false

    var body: some View {
        AppBackground {
            VStack(alignment: .leading, spacing: 24) {
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

                    Text("Forgot Password")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Spacer()
                    Color.clear.frame(width: 34, height: 34)
                }

                Text("Enter the email associated with your account and we'll send a reset password email.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)

                AppInputField(title: "Email", text: $email) {
                    if let emailError {
                        Text(emailError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(message.contains("sent") ? .green : .red)
                }

                Button(isLoading ? "Sending..." : "Confirm") {
                    sendReset()
                }
                .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                .disabled(isLoading)

                NavigationLink("", destination: VerifyOTPView(), isActive: $goToOTP)
                    .hidden()

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func sendReset() {
        emailError = nil
        message = nil

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedEmail.isEmpty {
            emailError = "Email is required."
            return
        }

        isLoading = true
        appState.resetPassword(email: cleanedEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    message = "Password reset email sent."
                    goToOTP = true
                case let .failure(error):
                    message = error.localizedDescription
                    return
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
