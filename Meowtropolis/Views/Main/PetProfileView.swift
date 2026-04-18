import SwiftUI

struct PetProfileView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    private let petService: PetService

    @State private var pets: [Pet] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var showingPetForm: Bool = false
    @State private var editingPet: Pet?

    @State private var petPendingDelete: Pet?
    @State private var showingDeleteAlert: Bool = false

    init(petService: PetService = PetService()) {
        self.petService = petService
    }

    var body: some View {
        AppBackground {
            VStack(spacing: Spacing.small) {
                if isLoading {
                    LoadingBlockView(message: text("Loading your pets...", "আপনার পোষা প্রাণীগুলো লোড হচ্ছে..."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    ErrorStateView(
                        title: text("Couldn't load your pets.", "আপনার পোষা প্রাণীর তথ্য লোড করা যায়নি।"),
                        message: text(
                            "Please check your internet connection. Tap Retry to try again.",
                            "দয়া করে ইন্টারনেট সংযোগ যাচাই করুন। আবার চেষ্টা করতে Retry চাপুন।"
                        ) + "\n\n" + errorMessage,
                        messageAccessibilityIdentifier: "petProfileErrorMessage",
                        retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                        retryAccessibilityIdentifier: "petProfileRetryButton",
                        onRetry: loadPets
                    )
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if pets.isEmpty {
                    EmptyStateView(
                        icon: "pawprint",
                        title: text("No pets added yet.", "এখনও কোনো পোষা প্রাণী যোগ করা হয়নি।"),
                        message: text("Tap Add Pet to get started.", "শুরু করতে Add Pet চাপুন।")
                    )
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(pets, id: \.id) { pet in
                            CardView {
                                HStack(spacing: Spacing.small) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.25))

                                        if let imageURL = AppImageLibrary.petImageURL(forBreed: pet.breed) {
                                            AsyncImage(url: imageURL) { phase in
                                                switch phase {
                                                case let .success(image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                default:
                                                    Image(systemName: "pawprint.fill")
                                                        .foregroundStyle(AppDesign.muted)
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: 72, height: 72)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(pet.name)
                                            .font(TextStyles.subtitle)
                                            .foregroundStyle(AppDesign.text)

                                        Text(text("Breed:", "বংশ:") + " \(pet.breed)")
                                            .font(TextStyles.body)
                                            .foregroundStyle(AppDesign.muted)

                                        Text(text("Age:", "বয়স:") + " \(pet.age.map { "\($0) \(text("years", "বছর"))" } ?? text("Not set", "সেট করা হয়নি"))")
                                            .font(TextStyles.body)
                                            .foregroundStyle(AppDesign.muted)
                                    }

                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(text("Delete", "মুছুন"), role: .destructive) {
                                    petPendingDelete = pet
                                    showingDeleteAlert = true
                                }

                                Button(text("Edit", "এডিট")) {
                                    editingPet = pet
                                    showingPetForm = true
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .accessibilityIdentifier("petProfileList")
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle(text("My Pets", "আমার পোষা প্রাণী"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingPet = nil
                    showingPetForm = true
                } label: {
                    Label(text("Add Pet", "পোষা প্রাণী যোগ করুন"), systemImage: "plus")
                }
                .accessibilityIdentifier("addPetButton")
            }
        }
        .sheet(isPresented: $showingPetForm) {
            PetFormView(existingPet: editingPet, language: currentLanguage) { name, breed, age in
                if let editingPet {
                    updatePet(existingPet: editingPet, name: name, breed: breed, age: age)
                } else {
                    createPet(name: name, breed: breed, age: age)
                }
            }
        }
        .alert(text("Delete Pet", "পোষা প্রাণী মুছুন"), isPresented: $showingDeleteAlert, presenting: petPendingDelete) { pet in
            Button(text("Delete", "মুছুন"), role: .destructive) {
                deletePet(pet)
            }
            Button(text("Cancel", "বাতিল"), role: .cancel) {
                petPendingDelete = nil
            }
        } message: { pet in
            Text(text("Are you sure you want to delete", "আপনি কি নিশ্চিতভাবে মুছতে চান") + " \(pet.name)?")
        }
        .task {
            loadPets()
        }
    }

    private func loadPets() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = text("You must be logged in to view pets.", "পোষা প্রাণী দেখতে লগ ইন করতে হবে।")
            pets = []
            return
        }

        isLoading = true
        errorMessage = nil

        petService.listPets(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case let .success(loadedPets):
                    pets = loadedPets.sorted { $0.name.lowercased() < $1.name.lowercased() }
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func createPet(name: String, breed: String, age: Int?) {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = text("You must be logged in to add a pet.", "পোষা প্রাণী যোগ করতে লগ ইন করতে হবে।")
            return
        }

        let pet = Pet(id: UUID().uuidString, userId: userId, name: name, breed: breed, age: age)

        isLoading = true
        petService.addPet(pet) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    showingPetForm = false
                    loadPets()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updatePet(existingPet: Pet, name: String, breed: String, age: Int?) {
        let updatedPet = Pet(
            id: existingPet.id,
            userId: existingPet.userId,
            name: name,
            breed: breed,
            age: age
        )

        isLoading = true
        petService.updatePet(updatedPet) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    showingPetForm = false
                    loadPets()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deletePet(_ pet: Pet) {
        isLoading = true
        petService.deletePet(petId: pet.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    petPendingDelete = nil
                    pets.removeAll { $0.id == pet.id }
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

private struct PetFormView: View {
    @Environment(\.dismiss) private var dismiss

    let existingPet: Pet?
    let language: AppLanguage
    let onSave: (String, String, Int?) -> Void

    @State private var name: String
    @State private var breed: String
    @State private var ageInput: String
    @State private var formError: String?

    init(existingPet: Pet?, language: AppLanguage, onSave: @escaping (String, String, Int?) -> Void) {
        self.existingPet = existingPet
        self.language = language
        self.onSave = onSave
        _name = State(initialValue: existingPet?.name ?? "")
        _breed = State(initialValue: existingPet?.breed ?? "")
        _ageInput = State(initialValue: existingPet?.age.map(String.init) ?? "")
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text(text("Pet Details", "পোষা প্রাণীর তথ্য"))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        CardView {
                            AppInputField(title: text("Name", "নাম"), text: $name, fieldIdentifier: "petFormNameField")
                            AppInputField(title: text("Breed", "বংশ"), text: $breed, fieldIdentifier: "petFormBreedField")
                            AppInputField(title: text("Age (years)", "বয়স (বছর)"), text: $ageInput, fieldIdentifier: "petFormAgeField")
                                .keyboardType(.numberPad)
                        }

                        if let formError {
                            ErrorStateView(
                                title: text("Please review the form", "ফর্মটি যাচাই করুন"),
                                message: formError,
                                messageAccessibilityIdentifier: "petFormErrorMessage"
                            )
                        }
                    }
                    .padding(Spacing.medium)
                }
            }
            .navigationTitle(existingPet == nil ? text("Add Pet", "পোষা প্রাণী যোগ করুন") : text("Edit Pet", "পোষা প্রাণী সম্পাদনা করুন"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(text("Cancel", "বাতিল")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("petFormCancelButton")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(text("Save", "সংরক্ষণ করুন")) {
                        savePet()
                    }
                    .accessibilityIdentifier("petFormSaveButton")
                }
            }
        }
    }

    private func savePet() {
        formError = nil

        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBreed = breed.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            formError = text("Name is required.", "নাম প্রয়োজন।")
            return
        }

        guard !cleanedBreed.isEmpty else {
            formError = text("Breed is required.", "বংশ প্রয়োজন।")
            return
        }

        let cleanedAge = ageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        var age: Int?

        if !cleanedAge.isEmpty {
            guard let parsedAge = Int(cleanedAge), parsedAge >= 0 else {
                formError = text("Age must be a valid positive number.", "বয়স একটি বৈধ ধনাত্মক সংখ্যা হতে হবে।")
                return
            }
            age = parsedAge
        }

        onSave(cleanedName, cleanedBreed, age)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        language.text(english: english, bangla: bangla)
    }
}

#Preview {
    NavigationStack {
        PetProfileView()
            .environmentObject(AppState())
    }
}
