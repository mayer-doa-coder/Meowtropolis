import SwiftUI

struct GroomingView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(ReminderService.preferenceKey) private var remindersEnabled: Bool = false

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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Book Grooming")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    bookingFormCard

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

                    Text("My Bookings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    filterCard

                    if isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                    } else if bookings.isEmpty {
                        Text("No bookings found")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 14)
                    } else {
                        ForEach(bookings, id: \.id) { booking in
                            bookingRow(booking)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Grooming")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadInitialData()
        }
    }

    private var bookingFormCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Create Booking")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text("Pet")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Picker("Pet", selection: $selectedPetIdForCreate) {
                Text("Select a pet").tag("")
                ForEach(pets, id: \.id) { pet in
                    Text(pet.name).tag(pet.id)
                }
            }
            .pickerStyle(.menu)

            Text("Service Type")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Picker("Service Type", selection: $selectedServiceType) {
                ForEach(serviceTypes, id: \.self) { type in
                    Text(type.capitalized).tag(type)
                }
            }
            .pickerStyle(.segmented)

            DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)

            Button("Create Booking") {
                createBooking()
            }
            .buttonStyle(FilledPrimaryButtonStyle(disabled: isLoading || pets.isEmpty))
            .disabled(isLoading || pets.isEmpty)
        }
        .padding(14)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var filterCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Pet (Optional)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Picker("Filter by Pet", selection: $selectedPetIdFilter) {
                Text("All pets").tag("all")
                ForEach(pets, id: \.id) { pet in
                    Text(pet.name).tag(pet.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedPetIdFilter) { _ in
                loadBookings()
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func bookingRow(_ booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(petDisplayName(for: booking.petId))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text("Service: \(booking.serviceType.capitalized)")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text("Date: \(displayDate(from: booking.date))")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text("Status: \(booking.status.label)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            Picker("Update Status", selection: bindingForStatus(booking)) {
                ForEach(statusOptions, id: \.rawValue) { status in
                    Text(status.label).tag(status)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func loadInitialData() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = "You need to log in before creating bookings."
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
            errorMessage = "You need to log in before viewing bookings."
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
            errorMessage = "You need to log in before creating bookings."
            return
        }

        guard !selectedPetIdForCreate.isEmpty else {
            errorMessage = "Please select a pet."
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
                    successMessage = "Booking created successfully."
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
                    successMessage = "Booking status updated."
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
        return "Pet ID: \(petId)"
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

private extension BookingStatus {
    var label: String {
        switch self {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

#Preview {
    NavigationStack {
        GroomingView()
            .environmentObject(AppState())
    }
}
