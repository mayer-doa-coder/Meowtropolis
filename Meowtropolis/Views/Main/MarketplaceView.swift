import SwiftUI

struct MarketplaceView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Marketplace")
                .font(.title)
                .bold()

            Text("Placeholder screen for products and shopping flow")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Marketplace")
    }
}

#Preview {
    NavigationStack {
        MarketplaceView()
    }
}
