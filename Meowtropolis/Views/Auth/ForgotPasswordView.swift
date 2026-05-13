import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var email: String = ""
    @State private var emailError: String?
    @State private var isLoading: Bool = false
    @State private var message: String?
    @State private var isSuccessMessage: Bool = false

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

                    Text(text("Forgot Password", "পাসওয়ার্ড ভুলে গেছেন"))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Spacer()
                    Color.clear.frame(width: 34, height: 34)
                }

                Text(text("Enter the email linked to your account and we will send a password reset email.", "আপনার অ্যাকাউন্টের সাথে যুক্ত ইমেইল দিন, আমরা পাসওয়ার্ড রিসেটের ইমেইল পাঠাব।"))
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)

                AppInputField(title: text("Email", "ইমেইল"), text: $email) {
                    if let emailError {
                        Text(emailError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(isSuccessMessage ? .green : .red)
                }

                Button(isLoading ? text("Sending email...", "ইমেইল পাঠানো হচ্ছে...") : text("Send Reset Email", "রিসেট ইমেইল পাঠান")) {
                    sendReset()
                }
                .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading))
                .disabled(isLoading)

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
        isSuccessMessage = false

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedEmail.isEmpty {
            emailError = text("Email is required.", "ইমেইল প্রয়োজন।")
            return
        }

        isLoading = true
        appState.resetPassword(email: cleanedEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    isSuccessMessage = true
                    message = text("Password reset email sent. Please check your inbox.", "পাসওয়ার্ড রিসেট ইমেইল পাঠানো হয়েছে। ইনবক্স দেখুন।")
                case let .failure(error):
                    isSuccessMessage = false
                    message = appState.userFriendlyAuthError(error)
                    return
                }
            }
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
        ForgotPasswordView()
    }
}
