import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var sessionErrorMessage: String?

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
                    appState.logout { result in
                        if case let .failure(error) = result {
                            sessionErrorMessage = error.localizedDescription
                        }
                    }
                }
                .foregroundStyle(.red)

                if let sessionErrorMessage {
                    Text(sessionErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
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
