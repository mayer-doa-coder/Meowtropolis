import SwiftUI

struct VetView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

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
                    Text(text("Vet Requests", "ভেট রিকোয়েস্ট"))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    NavigationLink(destination: MapView(initialCategory: "vet")) {
                        Text(text("Find Nearby Vets on Map", "ম্যাপে কাছাকাছি ভেট দেখুন"))
                    }
                    .buttonStyle(OutlinedPrimaryButtonStyle())
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            print("[Navigation] Open Map from Vet (category: vet)")
                        }
                    )

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

                    Text(text("My Requests", "আমার রিকোয়েস্ট"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    requestListSection

                }
                .padding(20)
            }
        }
        .navigationTitle(text("Vet", "ভেট"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadRequests()
        }
    }

    private var requestFormCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text("Describe your pet issue", "আপনার পোষা প্রাণীর সমস্যাটি লিখুন"))
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

            Text(text("Keep it short and clear (for example: cat not eating since morning)", "সংক্ষেপে ও পরিষ্কারভাবে লিখুন (যেমন: সকাল থেকে বিড়াল খাচ্ছে না)"))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Button(isSubmitting ? text("Submitting...", "জমা হচ্ছে...") : text("Submit Request", "রিকোয়েস্ট জমা দিন")) {
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
            ProgressView(text("Loading requests...", "রিকোয়েস্ট লোড হচ্ছে..."))
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
        } else if requests.isEmpty {
            Text(text("No requests yet", "এখনো কোনো রিকোয়েস্ট নেই"))
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

            Text(text("Status:", "স্ট্যাটাস:") + " \(request.status.localizedLabel(language: currentLanguage))")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            Text(text("Created:", "তৈরি হয়েছে:") + " \(displayDate(from: request.createdAt))")
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
            errorMessage = text("You need to log in before creating a vet request.", "ভেট রিকোয়েস্ট তৈরি করতে লগ ইন করতে হবে।")
            return
        }

        guard !cleanedIssue.isEmpty else {
            errorMessage = text("Please describe the issue before submitting.", "জমা দেওয়ার আগে সমস্যাটি লিখুন।")
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
                    successMessage = text("Vet request submitted successfully.", "ভেট রিকোয়েস্ট সফলভাবে জমা হয়েছে।")
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
            errorMessage = text("You need to log in before viewing vet requests.", "ভেট রিকোয়েস্ট দেখতে লগ ইন করতে হবে।")
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

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

private extension VetRequestStatus {
    func localizedLabel(language: AppLanguage) -> String {
        switch self {
        case .pending:
            return language.text(english: "Pending", bangla: "অপেক্ষমাণ")
        case .resolved:
            return language.text(english: "Resolved", bangla: "সমাধান হয়েছে")
        }
    }
}

#Preview {
    NavigationStack {
        VetView()
            .environmentObject(AppState())
    }
}
