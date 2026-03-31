import SwiftUI

struct PetProfileView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Pet Profile")
                .font(.title)
                .bold()

            Text("Placeholder screen for pet details and management")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Pet Profile")
    }
}

#Preview {
    NavigationStack {
        PetProfileView()
    }
}
