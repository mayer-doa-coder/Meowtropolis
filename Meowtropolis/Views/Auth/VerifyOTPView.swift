import SwiftUI

struct VerifyOTPView: View {
    @Environment(\.dismiss) private var dismiss
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

                    Text("Verify OTP")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Spacer()
                    Color.clear.frame(width: 34, height: 34)
                }

                Text("Enter your OTP that has been sent to your email to verify your account.")
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

                Text("A code has been sent to your phone")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Resend in 00:57")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button("Confirm") {}
                    .buttonStyle(FilledPrimaryButtonStyle())

                Spacer()
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        VerifyOTPView()
    }
}
