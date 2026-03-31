import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    var body: some View {
        Text("Hello, Meowtropolis")
            .onAppear {
                runStartupTest()
            }
    }

    func runStartupTest() {
        let db = Firestore.firestore()
        db.collection("healthcheck").document("startup").setData([
            "status": "ok",
            "time": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Firestore test failed: \(error.localizedDescription)")
            } else {
                print("Firestore test passed")
            }
        }
    }
}
