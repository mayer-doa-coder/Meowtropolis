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
                        try FirestoreModelCoder.decode(Pet.self, from: document.data())
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
}
