import SwiftUI

struct GroomingView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(ReminderService.preferenceKey) private var remindersEnabled: Bool = false
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    private let bookingService: BookingService
    private let petService: PetService
    private let reminderService: ReminderService

    @State private var pets: [Pet] = []
    @State private var bookings: [Booking] = []

    @State private var selectedPetIdForCreate: String = ""
    @State private var selectedServiceType: String = "grooming"
    @State private var selectedDate: Date = Date()

    @State private var selectedPetIdFilter: String = "all"

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let serviceTypes: [String] = ["grooming", "bathing", "nail trimming"]
    private let statusOptions: [BookingStatus] = [.pending, .confirmed, .completed, .cancelled]

    init(
        bookingService: BookingService = BookingService(),
        petService: PetService = PetService(),
        reminderService: ReminderService = ReminderService()
    ) {
        self.bookingService = bookingService
        self.petService = petService
        self.reminderService = reminderService
    }

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text(text("Book Grooming", "গ্রুমিং বুক করুন"))
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    bookingFormCard

                    if let successMessage {
                        Text(successMessage)
                            .font(TextStyles.caption)
                            .foregroundStyle(.green)
                    }

                    if let errorMessage {
                        ErrorStateView(
                            title: text("Couldn't complete the grooming action.", "গ্রুমিং কাজটি সম্পন্ন করা যায়নি।"),
                            message: text(
                                "Please check your details or internet connection. Tap Retry to load your bookings again.",
                                "দয়া করে আপনার তথ্য বা ইন্টারনেট সংযোগ যাচাই করুন। বুকিং আবার লোড করতে Retry চাপুন।"
                            ) + "\n\n" + errorMessage,
                            messageAccessibilityIdentifier: "groomingErrorMessage",
                            retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                            retryAccessibilityIdentifier: "groomingRetryButton",
                            onRetry: {
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .grooming,
                                    action: "Tapped retry in grooming"
                                )
                                loadBookings()
                            }
                        )
                    }

                    DividerWithText(text: text("My Bookings", "আমার বুকিং"))

                    filterCard

                    if isLoading {
                        LoadingBlockView(message: text("Loading your bookings...", "আপনার বুকিংগুলো লোড হচ্ছে..."))
                    } else if bookings.isEmpty && errorMessage == nil {
                        EmptyStateView(
                            icon: "calendar.badge.exclamationmark",
                            title: text("No grooming bookings yet.", "এখনও কোনো গ্রুমিং বুকিং নেই।"),
                            message: text("Tap Book Grooming to create your first appointment.", "প্রথম অ্যাপয়েন্টমেন্ট তৈরি করতে Book Grooming চাপুন।")
                        )
                    } else {
                        ForEach(bookings, id: \.id) { booking in
                            bookingRow(booking)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(text("Grooming", "গ্রুমিং"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadInitialData()
        }
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .grooming,
                action: "Opened grooming screen"
            )
        }
    }

    private var bookingFormCard: some View {
        CardView {
            Text(text("Book Grooming", "গ্রুমিং বুক করুন"))
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))

                AppPlaceholderImageView(assetName: AppImageLibrary.groomingServiceImageAssetName(for: selectedServiceType), cornerRadius: 12, iconSize: 24)
            }
            .frame(height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(text("Pet", "পোষা প্রাণী"))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Picker(text("Pet", "পোষা প্রাণী"), selection: $selectedPetIdForCreate) {
                Text(text("Select a pet", "একটি পোষা প্রাণী বাছুন")).tag("")
                ForEach(pets, id: \.id) { pet in
                    Text(pet.name).tag(pet.id)
                }
            }
            .pickerStyle(.menu)

            Text(text("Service Type", "সেবার ধরন"))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Picker(text("Service Type", "সেবার ধরন"), selection: $selectedServiceType) {
                ForEach(serviceTypes, id: \.self) { type in
                    Text(serviceTypeLabel(type)).tag(type)
                }
            }
            .pickerStyle(.segmented)

            DatePicker(text("Date & Time", "তারিখ ও সময়"), selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)

            Button(text("Book Grooming", "গ্রুমিং বুক করুন")) {
                createBooking()
            }
            .accessibilityIdentifier("bookGroomingButton")
            .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading || pets.isEmpty))
            .disabled(isLoading || pets.isEmpty)
        }
    }

    private var filterCard: some View {
        CardView {
            Text(text("Filter by Pet (Optional)", "পোষা প্রাণী অনুযায়ী ফিল্টার (ঐচ্ছিক)"))
                .font(TextStyles.caption)
                .foregroundStyle(AppDesign.muted)

            Picker(text("Filter by Pet", "পোষা প্রাণী অনুযায়ী ফিল্টার"), selection: $selectedPetIdFilter) {
                Text(text("All pets", "সব পোষা প্রাণী")).tag("all")
                ForEach(pets, id: \.id) { pet in
                    Text(pet.name).tag(pet.id)
                }
            }
            .accessibilityIdentifier("groomingFilterPicker")
            .pickerStyle(.menu)
            .onChange(of: selectedPetIdFilter) { _ in
                UserHistoryService.shared.recordCurrentUser(
                    category: .grooming,
                    action: "Changed grooming filter",
                    details: selectedPetIdFilter
                )
                loadBookings()
            }
        }
    }

    private func bookingRow(_ booking: Booking) -> some View {
        CardView {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.18))

                AppPlaceholderImageView(assetName: AppImageLibrary.groomingServiceImageAssetName(for: booking.serviceType), cornerRadius: 10, iconSize: 22)
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(petDisplayName(for: booking.petId))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text(text("Service:", "সেবা:") + " \(serviceTypeLabel(booking.serviceType))")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text(text("Date:", "তারিখ:") + " \(displayDate(from: booking.date))")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text(text("Status:", "স্ট্যাটাস:") + " \(booking.status.localizedLabel(language: currentLanguage))")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            Picker(text("Update Status", "স্ট্যাটাস আপডেট"), selection: bindingForStatus(booking)) {
                ForEach(statusOptions, id: \.rawValue) { status in
                    Text(status.localizedLabel(language: currentLanguage)).tag(status)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private func loadInitialData() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = text("You need to log in before booking grooming.", "গ্রুমিং বুক করতে লগ ইন করতে হবে।")
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        petService.listPets(userId: userId) { petResult in
            DispatchQueue.main.async {
                switch petResult {
                case let .success(loadedPets):
                    pets = loadedPets.sorted { $0.name.lowercased() < $1.name.lowercased() }
                    if selectedPetIdForCreate.isEmpty, let firstPet = pets.first {
                        selectedPetIdForCreate = firstPet.id
                    }
                    loadBookings()
                case let .failure(error):
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadBookings() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = text("You need to log in before viewing bookings.", "বুকিং দেখতে লগ ইন করতে হবে।")
            bookings = []
            return
        }

        isLoading = true
        errorMessage = nil

        let completion: (Result<[Booking], Error>) -> Void = { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case let .success(loadedBookings):
                    bookings = loadedBookings.sorted { $0.date > $1.date }
                case let .failure(error):
                    bookings = []
                    errorMessage = error.localizedDescription
                }
            }
        }

        if selectedPetIdFilter == "all" {
            bookingService.listBookingsByUser(userId: userId, completion: completion)
        } else {
            bookingService.listBookingsByPet(petId: selectedPetIdFilter, completion: completion)
        }
    }

    private func createBooking() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = text("You need to log in before booking grooming.", "গ্রুমিং বুক করতে লগ ইন করতে হবে।")
            return
        }

        guard !selectedPetIdForCreate.isEmpty else {
            errorMessage = text("Please select a pet.", "দয়া করে একটি পোষা প্রাণী নির্বাচন করুন।")
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let booking = Booking(
            id: UUID().uuidString,
            userId: userId,
            petId: selectedPetIdForCreate,
            serviceType: selectedServiceType,
            date: ISO8601DateFormatter().string(from: selectedDate),
            status: .pending
        )

        bookingService.createBooking(booking) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success:
                    if remindersEnabled {
                        reminderService.scheduleBookingReminder(booking)
                    }
                    UserHistoryService.shared.recordCurrentUser(
                        category: .grooming,
                        action: "Created grooming booking",
                        details: serviceTypeLabel(booking.serviceType)
                    )
                    successMessage = text("Grooming booked successfully.", "গ্রুমিং সফলভাবে বুক হয়েছে।")
                    loadBookings()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateBookingStatus(bookingId: String, status: BookingStatus) {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        bookingService.updateBookingStatus(bookingId: bookingId, status: status) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success:
                    if let index = bookings.firstIndex(where: { $0.id == bookingId }) {
                        let current = bookings[index]
                        bookings[index] = Booking(
                            id: current.id,
                            userId: current.userId,
                            petId: current.petId,
                            serviceType: current.serviceType,
                            date: current.date,
                            status: status
                        )
                    }
                    UserHistoryService.shared.recordCurrentUser(
                        category: .grooming,
                        action: "Updated booking status",
                        details: status.localizedLabel(language: currentLanguage)
                    )
                    successMessage = text("Booking status updated.", "বুকিং স্ট্যাটাস আপডেট হয়েছে।")
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func bindingForStatus(_ booking: Booking) -> Binding<BookingStatus> {
        Binding(
            get: {
                booking.status
            },
            set: { newStatus in
                updateBookingStatus(bookingId: booking.id, status: newStatus)
            }
        )
    }

    private func petDisplayName(for petId: String) -> String {
        if let pet = pets.first(where: { $0.id == petId }) {
            return pet.name
        }
        return text("Pet ID:", "পেট আইডি:") + " \(petId)"
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

    private func serviceTypeLabel(_ rawType: String) -> String {
        switch rawType.lowercased() {
        case "grooming":
            return text("Grooming", "গ্রুমিং")
        case "bathing":
            return text("Bathing", "বাথিং")
        case "nail trimming":
            return text("Nail Trimming", "নখ ট্রিমিং")
        default:
            return rawType.capitalized
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

private extension BookingStatus {
    func localizedLabel(language: AppLanguage) -> String {
        switch self {
        case .pending:
            return language.text(english: "Pending", bangla: "অপেক্ষমাণ")
        case .confirmed:
            return language.text(english: "Confirmed", bangla: "নিশ্চিত")
        case .completed:
            return language.text(english: "Completed", bangla: "সম্পন্ন")
        case .cancelled:
            return language.text(english: "Cancelled", bangla: "বাতিল")
        }
    }
}

#Preview {
    NavigationStack {
        GroomingView()
            .environmentObject(AppState())
    }
}
