import SwiftUI

struct OnboardingView: View {
    let onGetStarted: () -> Void

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                // Top visual block to match the mockup shape.
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.gray.opacity(0.45))
                        .frame(height: 360)
                        .clipShape(
                            UnevenRoundedRectangle(bottomLeadingRadius: 220, bottomTrailingRadius: 220)
                        )
                }

                VStack(spacing: 24) {
                    Text("Welcome to Happy Pet!")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Text("Manage your pet care journey from one app. Track services, shop essentials, and stay connected.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button("Get Started") {
                        onGetStarted()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
