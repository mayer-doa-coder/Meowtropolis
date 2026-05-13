import SwiftUI

struct OnboardingView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
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

                        AppPlaceholderImageView(assetName: AppImageLibrary.onboardingHeroAssetName, cornerRadius: 0, iconSize: 52)
                            .frame(height: 360)
                            .clipShape(
                                UnevenRoundedRectangle(bottomLeadingRadius: 220, bottomTrailingRadius: 220)
                            )

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
                        Text(text("Welcome to Meowtropolis!", "Meowtropolis-এ স্বাগতম!"))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Text(text("Manage your pet care journey from one app. Track services, shop essentials, and stay connected.", "একটি অ্যাপ থেকেই আপনার পেট কেয়ার যাত্রা পরিচালনা করুন। সার্ভিস ট্র্যাক করুন, প্রয়োজনীয় জিনিস কিনুন এবং সংযুক্ত থাকুন।"))
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button(text("Get Started", "শুরু করুন")) {
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

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
