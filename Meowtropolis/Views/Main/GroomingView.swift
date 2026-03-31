import SwiftUI

struct GroomingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Grooming")
                .font(.title)
                .bold()

            Text("Placeholder screen for grooming booking flow")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Grooming")
    }
}

#Preview {
    NavigationStack {
        GroomingView()
    }
}
