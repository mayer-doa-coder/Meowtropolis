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
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text(text("Vet Consultation", "ভেট পরামর্শ"))
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    requestFormCard

                    if let successMessage {
                        Text(successMessage)
                            .font(TextStyles.caption)
                            .foregroundStyle(.green)
                    }

                    if let errorMessage {
                        ErrorStateView(
                            title: text("Couldn't complete the consultation request.", "পরামর্শের অনুরোধ সম্পন্ন করা যায়নি।"),
                            message: text(
                                "Please check your details or internet connection. Tap Retry to load your requests again.",
                                "দয়া করে আপনার তথ্য বা ইন্টারনেট সংযোগ যাচাই করুন। অনুরোধগুলো আবার লোড করতে Retry চাপুন।"
                            ) + "\n\n" + errorMessage,
                            messageAccessibilityIdentifier: "vetErrorMessage",
                            retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                            retryAccessibilityIdentifier: "vetRetryButton",
                            onRetry: {
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .vet,
                                    action: "Tapped retry in vet"
                                )
                                loadRequests()
                            }
                        )
                    }

                    DividerWithText(text: text("My Consultation Requests", "আমার পরামর্শের অনুরোধ"))

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
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .vet,
                action: "Opened vet screen"
            )
        }
    }

    private var requestFormCard: some View {
        CardView {
            Text(text("Describe your pet issue", "আপনার পোষা প্রাণীর সমস্যাটি লিখুন"))
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)

            TextEditor(text: $issueDescription)
                .accessibilityIdentifier("vetIssueInput")
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

            Button(isSubmitting ? text("Sending request...", "অনুরোধ পাঠানো হচ্ছে...") : text("Request Vet Consultation", "ভেট পরামর্শের অনুরোধ করুন")) {
                submitRequest()
            }
            .accessibilityIdentifier("requestVetConsultationButton")
            .buttonStyle(FilledPrimaryButtonStyle(disabled: isSubmitting || isLoading))
            .disabled(isSubmitting || isLoading)
        }
    }

    @ViewBuilder
    private var requestListSection: some View {
        if isLoading {
            LoadingBlockView(message: text("Loading your consultation requests...", "আপনার পরামর্শের অনুরোধগুলো লোড হচ্ছে..."))
        } else if requests.isEmpty && errorMessage == nil {
            EmptyStateView(
                icon: "stethoscope",
                title: text("No vet consultation requests yet.", "এখনও কোনো ভেট পরামর্শের অনুরোধ নেই।"),
                message: text("Tap Request Vet Consultation to get support for your pet.", "আপনার পোষা প্রাণীর সহায়তার জন্য Request Vet Consultation চাপুন।")
            )
        } else {
            ForEach(requests, id: \.id) { request in
                requestCard(request)
            }
        }
    }

    private func requestCard(_ request: VetRequest) -> some View {
        CardView {
            Text(request.issueDescription)
            .font(TextStyles.body)
                .foregroundStyle(AppDesign.text)

            Text(text("Status:", "স্ট্যাটাস:") + " \(request.status.localizedLabel(language: currentLanguage))")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            Text(text("Created:", "তৈরি হয়েছে:") + " \(displayDate(from: request.createdAt))")
                .font(TextStyles.caption)
                .foregroundStyle(AppDesign.muted)
        }
    }

    private func submitRequest() {
        let cleanedIssue = issueDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let userId = appState.currentUserId else {
            errorMessage = text("You need to log in before requesting a vet consultation.", "ভেট পরামর্শের অনুরোধ করতে লগ ইন করতে হবে।")
            return
        }

        guard !cleanedIssue.isEmpty else {
            errorMessage = text("Please describe the issue before sending your request.", "অনুরোধ পাঠানোর আগে সমস্যাটি লিখুন।")
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
                    UserHistoryService.shared.recordCurrentUser(
                        category: .vet,
                        action: "Requested vet consultation",
                        details: cleanedIssue
                    )
                    successMessage = text("Vet consultation request sent successfully.", "ভেট পরামর্শের অনুরোধ সফলভাবে পাঠানো হয়েছে।")
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
            errorMessage = text("You need to log in before viewing vet consultation requests.", "ভেট পরামর্শের অনুরোধ দেখতে লগ ইন করতে হবে।")
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
