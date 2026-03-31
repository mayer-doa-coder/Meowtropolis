import SwiftUI

struct VetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Vet")
                .font(.title)
                .bold()

            Text("Placeholder screen for vet consultation requests")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Vet")
    }
}

#Preview {
    NavigationStack {
        VetView()
    }
}
