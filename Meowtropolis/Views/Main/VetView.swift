import SwiftUI

struct VetView: View {
    @EnvironmentObject private var appState: AppState

    private let vetService: VetService

    @State private var issueDescription: String = ""
    @State private var requests: [VetRequest] = []

    @State private var isLoading: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    init(vetService: VetService = VetService()) {
        self.vetService = vetService
    }

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Vet Requests")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    requestFormCard

                    if let successMessage {
                        Text(successMessage)
                            .font(.footnote)
                            .foregroundStyle(.green)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Divider()

                    Text("My Requests")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    requestListSection

                }
                .padding(20)
            }
        }
        .navigationTitle("Vet")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadRequests()
        }
    }

    private var requestFormCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Describe your pet issue")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            TextEditor(text: $issueDescription)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .frame(minHeight: 110)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppDesign.line, lineWidth: 1)
                }

            Text("Keep it short and clear (for example: cat not eating since morning)")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Button(isSubmitting ? "Submitting..." : "Submit Request") {
                submitRequest()
            }
            .buttonStyle(FilledPrimaryButtonStyle(disabled: isSubmitting || isLoading))
            .disabled(isSubmitting || isLoading)
        }
        .padding(14)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var requestListSection: some View {
        if isLoading {
            ProgressView("Loading requests...")
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
        } else if requests.isEmpty {
            Text("No requests yet")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 14)
        } else {
            ForEach(requests, id: \.id) { request in
                requestCard(request)
            }
        }
    }

    private func requestCard(_ request: VetRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(request.issueDescription)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text("Status: \(request.status.label)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            Text("Created: \(displayDate(from: request.createdAt))")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func submitRequest() {
        let cleanedIssue = issueDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let userId = appState.currentUserId else {
            errorMessage = "You need to log in before creating a vet request."
            return
        }

        guard !cleanedIssue.isEmpty else {
            errorMessage = "Please describe the issue before submitting."
            return
        }

        isSubmitting = true
        errorMessage = nil
        successMessage = nil

        let request = VetRequest(
            id: UUID().uuidString,
            userId: userId,
            petId: nil,
            issueDescription: cleanedIssue,
            status: .pending,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        vetService.createRequest(request) { result in
            DispatchQueue.main.async {
                isSubmitting = false

                switch result {
                case .success:
                    issueDescription = ""
                    successMessage = "Vet request submitted successfully."
                    loadRequests()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadRequests() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            requests = []
            errorMessage = "You need to log in before viewing vet requests."
            return
        }

        isLoading = true
        errorMessage = nil

        vetService.listRequestsByUser(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case let .success(loadedRequests):
                    requests = loadedRequests
                case let .failure(error):
                    requests = []
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func displayDate(from isoString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()

        guard let date = inputFormatter.date(from: isoString) else {
            return isoString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
}

private extension VetRequestStatus {
    var label: String {
        switch self {
        case .pending:
            return "Pending"
        case .resolved:
            return "Resolved"
        }
    }
}

#Preview {
    NavigationStack {
        VetView()
            .environmentObject(AppState())
    }
}
