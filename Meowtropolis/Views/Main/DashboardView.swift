import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var sessionErrorMessage: String?
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            MarketplaceView()
                .tabItem { Label("Shop", systemImage: "cart") }
                .tag(1)

            VetView()
                .tabItem { Label("Message", systemImage: "bubble.left") }
                .tag(2)

            AccountView()
                .tabItem { Label("Account", systemImage: "person") }
                .tag(3)
        }
        .tint(AppDesign.primary)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Logout") {
                    appState.logout { result in
                        if case let .failure(error) = result {
                            sessionErrorMessage = error.localizedDescription
                        }
                    }
                }
                .foregroundStyle(.red)
            }
        }
        .alert("Session", isPresented: .constant(sessionErrorMessage != nil)) {
            Button("OK") { sessionErrorMessage = nil }
        } message: {
            Text(sessionErrorMessage ?? "")
        }
    }
}

private struct HomeTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(width: 56, height: 56)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hello, \(appState.currentUser?.name ?? "Pet Parent")")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppDesign.text)
                            Text("Good Morning!")
                                .font(.system(size: 22, weight: .regular, design: .rounded))
                                .foregroundStyle(AppDesign.muted)
                        }

                        Spacer()

                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                    }

                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.78, green: 0.86, blue: 0.95))
                        .frame(height: 150)
                        .overlay(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Adopt A Pet\nComplete The Family")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.07, green: 0.22, blue: 0.35))
                                Text("Up to 30% off")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.red)
                                Text("Use code COMBO30")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(.red)
                            }
                            .padding(.leading, 18)
                        }

                    sectionTitle("Our Services")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            chip("All", selected: true)
                            chip("Cat")
                            chip("Dog")
                            chip("Bird")
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        serviceCard(title: "Bathing & Drying", destination: GroomingView())
                        serviceCard(title: "Hair Triming", destination: GroomingView())
                        serviceCard(title: "Pet Checkup", destination: VetView())
                        serviceCard(title: "Pet Profile", destination: PetProfileView())
                    }
                }
                .padding(20)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)
            Spacer()
            Text("See All")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.blue)
        }
    }

    private func chip(_ title: String, selected: Bool = false) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selected ? Color.white.opacity(0.8) : Color.gray.opacity(0.45))
                .frame(width: 28, height: 28)
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 100)
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
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState())
    }
}
