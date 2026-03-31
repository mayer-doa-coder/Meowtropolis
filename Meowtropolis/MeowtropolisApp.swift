import SwiftUI
import FirebaseCore

@main
struct MeowtropolisApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured successfully")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
