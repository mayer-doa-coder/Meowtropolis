import SwiftUI
import MapKit

struct DemoPetServiceMapView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    )

    private let locations: [DemoPetServiceLocation] = [
        DemoPetServiceLocation(
            name: "Meowtropolis Vet Center",
            nameBangla: "মিয়াওট্রোপলিস ভেট সেন্টার",
            subtitle: "24/7 emergency and routine checkups",
            subtitleBangla: "২৪/৭ জরুরি ও রুটিন চেকআপ",
            category: "Vet",
            coordinate: CLLocationCoordinate2D(latitude: 23.7808, longitude: 90.4075)
        ),
        DemoPetServiceLocation(
            name: "Paws Groom Studio",
            nameBangla: "পজ গ্রুম স্টুডিও",
            subtitle: "Bath, trim, and coat care",
            subtitleBangla: "বাথ, ট্রিম এবং কোট কেয়ার",
            category: "Grooming",
            coordinate: CLLocationCoordinate2D(latitude: 23.7937, longitude: 90.4066)
        ),
        DemoPetServiceLocation(
            name: "Pet Metro Store",
            nameBangla: "পেট মেট্রো স্টোর",
            subtitle: "Food, toys, and essentials",
            subtitleBangla: "খাবার, খেলনা ও প্রয়োজনীয় সামগ্রী",
            category: "Pet Store",
            coordinate: CLLocationCoordinate2D(latitude: 23.7516, longitude: 90.3935)
        ),
        DemoPetServiceLocation(
            name: "Happy Tails Boarding",
            nameBangla: "হ্যাপি টেইলস বোর্ডিং",
            subtitle: "Safe overnight pet care",
            subtitleBangla: "নিরাপদ রাত্রীকালীন পোষা প্রাণী সেবা",
            category: "Boarding",
            coordinate: CLLocationCoordinate2D(latitude: 23.8223, longitude: 90.4256)
        )
    ]

    var body: some View {
        AppBackground {
            VStack(spacing: Spacing.medium) {
                CardView {
                    Text(text("Demo map with hard-coded pet service locations.", "ডেমো ম্যাপে হার্ড-কোডেড পেট সার্ভিস লোকেশন দেখানো হয়েছে।"))
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Map(position: $position) {
                    ForEach(locations) { location in
                        Marker(location.displayName(language: currentLanguage), coordinate: location.coordinate)
                            .tint(AppDesign.primary)
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(locations) { location in
                            CardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(location.displayName(language: currentLanguage))
                                        .font(TextStyles.subtitle)
                                        .foregroundStyle(AppDesign.text)

                                    Text(location.displaySubtitle(language: currentLanguage))
                                        .font(TextStyles.caption)
                                        .foregroundStyle(AppDesign.muted)

                                    Text(text("Category", "ক্যাটাগরি") + ": \(location.category)")
                                        .font(TextStyles.caption)
                                        .foregroundStyle(AppDesign.primary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(text("Demo Map", "ডেমো ম্যাপ"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .map,
                action: "Opened demo pet map"
            )
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

private struct DemoPetServiceLocation: Identifiable {
    let id = UUID()
    let name: String
    let nameBangla: String
    let subtitle: String
    let subtitleBangla: String
    let category: String
    let coordinate: CLLocationCoordinate2D

    func displayName(language: AppLanguage) -> String {
        language.text(english: name, bangla: nameBangla)
    }

    func displaySubtitle(language: AppLanguage) -> String {
        language.text(english: subtitle, bangla: subtitleBangla)
    }
}

#Preview {
    NavigationStack {
        DemoPetServiceMapView()
    }
}
