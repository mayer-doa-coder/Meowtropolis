import SwiftUI

struct OnboardingView: View {
    let onGetStarted: () -> Void

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 0) {
                    // Top hero image block for onboarding.
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 360)
                            .clipShape(
                                UnevenRoundedRectangle(bottomLeadingRadius: 220, bottomTrailingRadius: 220)
                            )

                        if let heroURL = AppImageLibrary.onboardingHeroURL {
                            AsyncImage(url: heroURL) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                default:
                                    Color.clear
                                }
                            }
                            .frame(height: 360)
                            .clipShape(
                                UnevenRoundedRectangle(bottomLeadingRadius: 220, bottomTrailingRadius: 220)
                            )
                        }

                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
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
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
