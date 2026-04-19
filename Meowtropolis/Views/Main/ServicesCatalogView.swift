import SwiftUI

struct ServicesCatalogView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text(text("Explore all pet services", "সব পেট সার্ভিস দেখুন"))
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    serviceCard(
                        title: text("Bathing & Drying", "বাথিং ও ড্রাইং"),
                        subtitle: text("Book gentle cleaning and drying sessions.", "নরম পরিষ্কার ও ড্রাইং সেশন বুক করুন।"),
                        destination: GroomingView()
                    )

                    serviceCard(
                        title: text("Hair Trimming", "হেয়ার ট্রিমিং"),
                        subtitle: text("Keep your pet neat with regular trims.", "নিয়মিত ট্রিমিংয়ে আপনার পোষা প্রাণীকে পরিপাটি রাখুন।"),
                        destination: GroomingView()
                    )

                    serviceCard(
                        title: text("Pet Checkup", "পেট চেকআপ"),
                        subtitle: text("Request quick vet consultation.", "দ্রুত ভেট পরামর্শের অনুরোধ করুন।"),
                        destination: VetView()
                    )

                    serviceCard(
                        title: text("Pet Profile", "পেট প্রোফাইল"),
                        subtitle: text("Manage pet details and records.", "পোষা প্রাণীর তথ্য ও রেকর্ড পরিচালনা করুন।"),
                        destination: PetProfileView()
                    )

                    serviceCard(
                        title: text("Nearby Services Map", "কাছাকাছি সার্ভিস ম্যাপ"),
                        subtitle: text("Find nearby places from map search.", "ম্যাপ সার্চ থেকে কাছাকাছি স্থান খুঁজুন।"),
                        destination: MapView()
                    )

                    serviceCard(
                        title: text("Demo Service Map", "ডেমো সার্ভিস ম্যাপ"),
                        subtitle: text("Open hard-coded demo locations.", "হার্ড-কোডেড ডেমো লোকেশন দেখুন।"),
                        destination: DemoPetServiceMapView()
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle(text("Our Services", "আমাদের সেবাসমূহ"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .system,
                action: "Opened services catalog"
            )
        }
    }

    private func serviceCard<Destination: View>(title: String, subtitle: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            CardView {
                HStack(spacing: 12) {
                    AppPlaceholderImageView(
                        assetName: AppImageLibrary.serviceImageAssetName(for: title),
                        cornerRadius: 12,
                        iconSize: 22
                    )
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        Text(subtitle)
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppDesign.muted)
                }
            }
        }
        .buttonStyle(.plain)
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
        ServicesCatalogView()
    }
}
