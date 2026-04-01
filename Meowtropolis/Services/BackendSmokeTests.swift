import Foundation

/// Simple manual smoke tests for backend services.
/// These tests are intentionally straightforward for beginner debugging.
enum BackendSmokeTests {
    /// Runs all service smoke tests in sequence.
    /// Note: Auth smoke test may fail if test email already exists.
    static func runAll(testEmail: String, testPassword: String, fullName: String = "Smoke User") {
        let authService = FirebaseAuthService()
        let userService = UserService()
        let petService = PetService()
        let bookingService = BookingService()
        let productService = ProductService()

        print("=== Backend Smoke Tests: Start ===")

        runAuthSmokeTest(authService: authService, email: testEmail, password: testPassword) { authResult in
            switch authResult {
            case let .success(userId):
                print("Auth smoke: success, userId =>", userId)

                let user = User(id: userId, name: fullName, email: testEmail)
                runUserSmokeTest(userService: userService, user: user) {
                    runPetSmokeTest(petService: petService, userId: userId) {
                        runBookingSmokeTest(bookingService: bookingService, userId: userId) {
                            runProductSmokeTest(productService: productService)
                            print("=== Backend Smoke Tests: End ===")
                        }
                    }
                }

            case let .failure(error):
                print("Auth smoke: failed =>", error.localizedDescription)
                // Continue to product smoke test at least.
                runProductSmokeTest(productService: productService)
                print("=== Backend Smoke Tests: End (Auth failed) ===")
            }
        }
    }

    /// Signup -> Login -> Logout flow smoke test.
    static func runAuthSmokeTest(
        authService: AuthService,
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        authService.signUp(email: email, password: password) { signUpResult in
            switch signUpResult {
            case let .success(uid):
                print("Auth smoke: signUp success")
                authService.signOut { _ in
                    authService.signIn(email: email, password: password) { signInResult in
                        switch signInResult {
                        case .success:
                            print("Auth smoke: signIn success")
                            authService.signOut { signOutResult in
                                switch signOutResult {
                                case .success:
                                    print("Auth smoke: signOut success")
                                case let .failure(error):
                                    print("Auth smoke: signOut failed =>", error.localizedDescription)
                                }
                                completion(.success(uid))
                            }
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// User profile create and fetch smoke test.
    static func runUserSmokeTest(
        userService: UserService,
        user: User,
        completion: @escaping () -> Void
    ) {
        userService.createUserProfile(user: user) { createResult in
            switch createResult {
            case .success:
                print("User smoke: create profile success")
                userService.fetchCurrentUser(userId: user.id) { fetchResult in
                    switch fetchResult {
                    case let .success(fetched):
                        print("User smoke: fetch profile success =>", fetched)
                    case let .failure(error):
                        print("User smoke: fetch profile failed =>", error.localizedDescription)
                    }
                    completion()
                }
            case let .failure(error):
                print("User smoke: create profile failed =>", error.localizedDescription)
                completion()
            }
        }
    }

    /// Pet add, list, update, delete smoke test.
    static func runPetSmokeTest(
        petService: PetService,
        userId: String,
        completion: @escaping () -> Void
    ) {
        let petId = "pet_smoke_\(UUID().uuidString)"
        let pet = Pet(id: petId, userId: userId, name: "Milo", breed: "Persian")

        petService.addPet(pet) { addResult in
            switch addResult {
            case .success:
                print("Pet smoke: add success")
                petService.listPets(userId: userId) { listResult in
                    switch listResult {
                    case let .success(pets):
                        print("Pet smoke: list success count =>", pets.count)
                    case let .failure(error):
                        print("Pet smoke: list failed =>", error.localizedDescription)
                    }

                    let updatedPet = Pet(id: pet.id, userId: pet.userId, name: "Milo Updated", breed: pet.breed)
                    petService.updatePet(updatedPet) { updateResult in
                        switch updateResult {
                        case .success:
                            print("Pet smoke: update success")
                        case let .failure(error):
                            print("Pet smoke: update failed =>", error.localizedDescription)
                        }

                        petService.deletePet(petId: pet.id) { deleteResult in
                            switch deleteResult {
                            case .success:
                                print("Pet smoke: delete success")
                            case let .failure(error):
                                print("Pet smoke: delete failed =>", error.localizedDescription)
                            }
                            completion()
                        }
                    }
                }
            case let .failure(error):
                print("Pet smoke: add failed =>", error.localizedDescription)
                completion()
            }
        }
    }

    /// Booking create, list, update status smoke test.
    static func runBookingSmokeTest(
        bookingService: BookingService,
        userId: String,
        completion: @escaping () -> Void
    ) {
        let bookingId = "booking_smoke_\(UUID().uuidString)"
        let petId = "pet_smoke_for_booking"
        let booking = Booking(
            id: bookingId,
            userId: userId,
            petId: petId,
            serviceType: "grooming",
            date: ISO8601DateFormatter().string(from: Date()),
            status: .pending
        )

        bookingService.createBooking(booking) { createResult in
            switch createResult {
            case .success:
                print("Booking smoke: create success")

                bookingService.listBookingsByUser(userId: userId) { listResult in
                    switch listResult {
                    case let .success(bookings):
                        print("Booking smoke: list by user success count =>", bookings.count)
                    case let .failure(error):
                        print("Booking smoke: list by user failed =>", error.localizedDescription)
                    }

                    bookingService.updateBookingStatus(bookingId: bookingId, status: .confirmed) { updateResult in
                        switch updateResult {
                        case .success:
                            print("Booking smoke: update status success")
                        case let .failure(error):
                            print("Booking smoke: update status failed =>", error.localizedDescription)
                        }
                        completion()
                    }
                }
            case let .failure(error):
                print("Booking smoke: create failed =>", error.localizedDescription)
                completion()
            }
        }
    }

    /// Product fetch smoke test (Firestore first, local fallback).
    static func runProductSmokeTest(productService: ProductService) {
        productService.fetchProducts { result in
            switch result {
            case let .success(products):
                print("Product smoke: load success count =>", products.count)
                if let first = products.first {
                    print("Product smoke: first product =>", first)
                }
            case let .failure(error):
                print("Product smoke: load failed =>", error.localizedDescription)
            }
        }
    }
}
