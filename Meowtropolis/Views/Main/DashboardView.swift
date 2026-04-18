import SwiftUI

// GUARDRAIL:
// Do not change TabView structure, navigation flow, font family usage, or color theme bindings here.
// Required for MVP stability and demo consistency.
// If a requested change risks these areas, stop and log it in docs/issue_inventory.md.

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
    @State private var sessionErrorMessage: String?
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView()
                .tabItem { Label(text("Home", "হোম"), systemImage: "house") }
                .tag(0)

            MarketplaceView()
                .tabItem { Label(text("Shop", "শপ"), systemImage: "cart") }
                .tag(1)

            VetView()
                .tabItem { Label(text("Vet", "ভেট"), systemImage: "bubble.left") }
                .tag(2)

            AccountView()
                .tabItem { Label(text("Account", "অ্যাকাউন্ট"), systemImage: "person") }
                .tag(3)

            MapView()
                .tabItem { Label(text("Map", "ম্যাপ"), systemImage: "map") }
                .accessibilityIdentifier("mapTab")
                .tag(4)
        }
        .accessibilityIdentifier("dashboardTabView")
        .tint(AppDesign.primary)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(text("Logout", "লগ আউট")) {
                    appState.logout { result in
                        if case let .failure(error) = result {
                            sessionErrorMessage = error.localizedDescription
                        }
                    }
                }
                .accessibilityIdentifier("dashboardLogoutButton")
                .foregroundStyle(.red)
            }
        }
        .alert(text("Session", "সেশন"), isPresented: .constant(sessionErrorMessage != nil)) {
            Button(text("OK", "ঠিক আছে")) { sessionErrorMessage = nil }
        } message: {
            Text(
                text(
                    "Session action failed. Please check your internet connection and tap OK, then try again.",
                    "সেশন কাজটি ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ যাচাই করুন, ঠিক আছে চাপুন, তারপর আবার চেষ্টা করুন।"
                ) + (sessionErrorMessage.map { "\n\n\($0)" } ?? "")
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

private struct HomeTabView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    HStack {
                        if let profileImage = AppImageLibrary.profileImage(fromBase64: appState.currentUser?.profileImageBase64) {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            AsyncImage(url: AppImageLibrary.userAvatarURL) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                default:
                                    Circle().fill(Color.gray.opacity(0.35))
                                }
                            }
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(text("Hello,", "হ্যালো,") + " \(appState.currentUser?.name ?? text("Pet Parent", "পেট প্যারেন্ট"))")
                                .font(TextStyles.subtitle)
                                .foregroundStyle(AppDesign.text)
                            Text(text("Good Morning!", "শুভ সকাল!"))
                                .font(TextStyles.body)
                                .foregroundStyle(AppDesign.muted)
                        }

                        Spacer()

                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                    }

                    CardView {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.78, green: 0.86, blue: 0.95))

                            AsyncImage(url: AppImageLibrary.adoptionBannerURL) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                default:
                                    Color.clear
                                }
                            }

                            LinearGradient(
                                colors: [Color.black.opacity(0.45), Color.black.opacity(0.12)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(text("Adopt A Pet\nComplete The Family", "একটি পোষা প্রাণী নিন\nপরিবার পূর্ণ করুন"))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(text("Up to 30% off", "সর্বোচ্চ ৩০% ছাড়"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 1.0, green: 0.88, blue: 0.4))
                                Text(text("Use code COMBO30", "কোড ব্যবহার করুন COMBO30"))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.95))
                            }
                            .padding(.leading, 18)
                        }
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    CardView {
                        sectionTitle(text("Our Services", "আমাদের সেবাসমূহ"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.small) {
                                chip(text("All", "সব"), selected: true)
                                chip(text("Cat", "বিড়াল"))
                                chip(text("Dog", "কুকুর"))
                                chip(text("Bird", "পাখি"))
                            }
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.small) {
                            serviceCard(title: text("Bathing & Drying", "বাথিং ও ড্রাইং"), destination: GroomingView())
                            serviceCard(title: text("Hair Trimming", "হেয়ার ট্রিমিং"), destination: GroomingView())
                            serviceCard(title: text("Pet Checkup", "পেট চেকআপ"), destination: VetView())
                            serviceCard(title: text("Pet Profile", "পেট প্রোফাইল"), destination: PetProfileView())
                        }
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            print("[UI Redesign] Dashboard updated")
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)
            Spacer()
            Text(text("See All", "সব দেখুন"))
                .font(TextStyles.caption)
                .foregroundStyle(.blue)
        }
    }

    private func chip(_ title: String, selected: Bool = false) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selected ? Color.white.opacity(0.8) : Color.gray.opacity(0.45))
                .frame(width: 28, height: 28)
            Text(title)
                .font(TextStyles.body)
        }
        .foregroundStyle(selected ? .white : AppDesign.muted)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(selected ? AppDesign.primary : Color.white.opacity(0.3))
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(AppDesign.line, lineWidth: selected ? 0 : 1)
        }
    }

    private func serviceCard<Destination: View>(title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.4))

                    if let imageURL = AppImageLibrary.serviceImageURL(for: title) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundStyle(AppDesign.muted)
                            }
                        }
                    }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppDesign.text)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
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
        DashboardView()
            .environmentObject(AppState())
    }
}
