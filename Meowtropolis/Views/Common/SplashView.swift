import SwiftUI

struct SplashView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Meowtropolis")
                .font(.largeTitle)
                .bold()

            Text("Smart Pet Care Ecosystem")
                .foregroundStyle(.secondary)

            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    SplashView(onContinue: {})
}
