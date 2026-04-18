import SwiftUI

struct VerifyOTPView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
    @State private var code: String = ""

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

                    Text(text("Verify OTP", "ওটিপি যাচাই"))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Spacer()
                    Color.clear.frame(width: 34, height: 34)
                }

                Text(text("Enter your OTP that has been sent to your email to verify your account.", "আপনার অ্যাকাউন্ট যাচাই করতে ইমেইলে পাঠানো ওটিপি লিখুন।"))
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)

                TextField("123456", text: $code)
                    .keyboardType(.numberPad)
                    .font(.system(size: 36, weight: .semibold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(AppDesign.line).frame(height: 1)
                    }

                Text(text("A code has been sent to your email", "আপনার ইমেইলে একটি কোড পাঠানো হয়েছে"))
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(text("Resend code in 00:57", "০০:৫৭ পরে কোড আবার পাঠান"))
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(text("Verify OTP", "ওটিপি যাচাই করুন")) {}
                    .buttonStyle(FilledPrimaryButtonStyle())

                Spacer()
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
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
        VerifyOTPView()
    }
}
