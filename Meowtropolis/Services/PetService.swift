import Foundation
import FirebaseFirestore

/// Handles Firestore operations for pet profile data.
final class PetService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// Lists pets for a specific user id.
    func listPets(userId: String, completion: @escaping (Result<[Pet], Error>) -> Void) {
        db.collection(FirestoreCollections.pets)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                do {
                    let pets = try documents.map { document in
                        try self.decodePet(document)
                    }
                    completion(.success(pets))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Adds a pet document.
    func addPet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let payload = try FirestoreModelCoder.encode(pet)
            db.collection(FirestoreCollections.pets)
                .document(pet.id)
                .setData(payload) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
        } catch {
            completion(.failure(error))
        }
    }

    /// Updates an existing pet document.
    func updatePet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        addPet(pet, completion: completion)
    }

    /// Deletes a pet document by id.
    func deletePet(petId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.pets)
            .document(petId)
            .delete { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    /// Decodes pet safely from Firestore and supports legacy docs where id may be missing in payload.
    private func decodePet(_ document: QueryDocumentSnapshot) throws -> Pet {
        let data = document.data()

        let id = (data["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = (data["userId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = (data["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let breed = (data["breed"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

        let resolvedId = (id?.isEmpty == false ? id! : document.documentID)

        guard let resolvedUserId = userId, !resolvedUserId.isEmpty,
              let resolvedName = name, !resolvedName.isEmpty,
              let resolvedBreed = breed, !resolvedBreed.isEmpty else {
            throw NSError(
                domain: "PetService",
                code: 422,
                userInfo: [NSLocalizedDescriptionKey: "Invalid pet data found in database."]
            )
        }

        let age: Int?
        if let ageInt = data["age"] as? Int {
            age = ageInt
        } else if let ageNumber = data["age"] as? NSNumber {
            age = ageNumber.intValue
        } else if let ageString = data["age"] as? String {
            age = Int(ageString)
        } else {
            age = nil
        }

        return Pet(id: resolvedId, userId: resolvedUserId, name: resolvedName, breed: resolvedBreed, age: age)
    }
}
