import SwiftUI

struct PetProfileView: View {
    @EnvironmentObject private var appState: AppState

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
            VStack(spacing: 12) {
                if isLoading {
                    ProgressView("Loading pets...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 10) {
                        Text("Could not load pets")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)
                        Text(errorMessage)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            loadPets()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle())
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if pets.isEmpty {
                    VStack(spacing: 12) {
                        Text("No pets found")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)
                        Text("Tap Add Pet to create your first pet profile.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(pets, id: \.id) { pet in
                            HStack(spacing: 12) {
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
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppDesign.text)

                                    Text("Breed: \(pet.breed)")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundStyle(AppDesign.muted)

                                    Text("Age: \(pet.age.map { "\($0) years" } ?? "Not set")")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundStyle(AppDesign.muted)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    petPendingDelete = pet
                                    showingDeleteAlert = true
                                }

                                Button("Edit") {
                                    editingPet = pet
                                    showingPetForm = true
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("My Pets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingPet = nil
                    showingPetForm = true
                } label: {
                    Label("Add Pet", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingPetForm) {
            PetFormView(existingPet: editingPet) { name, breed, age in
                if let editingPet {
                    updatePet(existingPet: editingPet, name: name, breed: breed, age: age)
                } else {
                    createPet(name: name, breed: breed, age: age)
                }
            }
        }
        .alert("Delete Pet", isPresented: $showingDeleteAlert, presenting: petPendingDelete) { pet in
            Button("Delete", role: .destructive) {
                deletePet(pet)
            }
            Button("Cancel", role: .cancel) {
                petPendingDelete = nil
            }
        } message: { pet in
            Text("Are you sure you want to delete \(pet.name)?")
        }
        .task {
            loadPets()
        }
    }

    private func loadPets() {
        guard let userId = appState.currentUserId else {
            isLoading = false
            errorMessage = "You must be logged in to view pets."
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
            errorMessage = "You must be logged in to add a pet."
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
}

private struct PetFormView: View {
    @Environment(\.dismiss) private var dismiss

    let existingPet: Pet?
    let onSave: (String, String, Int?) -> Void

    @State private var name: String
    @State private var breed: String
    @State private var ageInput: String
    @State private var formError: String?

    init(existingPet: Pet?, onSave: @escaping (String, String, Int?) -> Void) {
        self.existingPet = existingPet
        self.onSave = onSave
        _name = State(initialValue: existingPet?.name ?? "")
        _breed = State(initialValue: existingPet?.breed ?? "")
        _ageInput = State(initialValue: existingPet?.age.map(String.init) ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet Details") {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    TextField("Age (years)", text: $ageInput)
                        .keyboardType(.numberPad)
                }

                if let formError {
                    Section {
                        Text(formError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(existingPet == nil ? "Add Pet" : "Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        savePet()
                    }
                }
            }
        }
    }

    private func savePet() {
        formError = nil

        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBreed = breed.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            formError = "Name is required."
            return
        }

        guard !cleanedBreed.isEmpty else {
            formError = "Breed is required."
            return
        }

        let cleanedAge = ageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        var age: Int?

        if !cleanedAge.isEmpty {
            guard let parsedAge = Int(cleanedAge), parsedAge >= 0 else {
                formError = "Age must be a valid positive number."
                return
            }
            age = parsedAge
        }

        onSave(cleanedName, cleanedBreed, age)
    }
}

#Preview {
    NavigationStack {
        PetProfileView()
            .environmentObject(AppState())
    }
}
