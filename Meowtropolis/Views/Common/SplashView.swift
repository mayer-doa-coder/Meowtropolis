import SwiftUI

struct SplashView: View {
    let onContinue: () -> Void
    @State private var didAutoContinue: Bool = false

    var body: some View {
        AppBackground {
            VStack {
                Spacer()
                AppLogoHeader()
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !didAutoContinue else { return }
                didAutoContinue = true
                onContinue()
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            guard !didAutoContinue else { return }
            didAutoContinue = true
            onContinue()
        }
    }
}

#Preview {
    SplashView(onContinue: {})
}
