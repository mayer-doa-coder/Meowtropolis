import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            Section("Main Features") {
                NavigationLink("Pet Profile", destination: PetProfileView())
                NavigationLink("Grooming", destination: GroomingView())
                NavigationLink("Vet", destination: VetView())
                NavigationLink("Marketplace", destination: MarketplaceView())
            }

            Section("Session") {
                Button("Logout") {
                    appState.isLoggedIn = false
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Dashboard")
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState())
    }
}
