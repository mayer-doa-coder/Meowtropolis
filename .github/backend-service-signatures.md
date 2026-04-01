# Finalized Backend Service Signatures (Freeze)

Do not change these signatures after stabilization.

## AuthService
- currentUserId: String?
- addAuthStateDidChangeListener(_ listener: @escaping (String?) -> Void) -> NSObjectProtocol
- removeAuthStateDidChangeListener(_ handle: NSObjectProtocol)
- signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
- signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
- signOut(completion: @escaping (Result<Void, Error>) -> Void)
- resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)

## UserService
- createUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void)
- fetchCurrentUser(userId: String, completion: @escaping (Result<User, Error>) -> Void)

## PetService
- listPets(userId: String, completion: @escaping (Result<[Pet], Error>) -> Void)
- addPet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void)
- updatePet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void)
- deletePet(petId: String, completion: @escaping (Result<Void, Error>) -> Void)

## BookingService
- createBooking(_ booking: Booking, completion: @escaping (Result<Void, Error>) -> Void)
- listBookingsByUser(userId: String, completion: @escaping (Result<[Booking], Error>) -> Void)
- listBookingsByPet(petId: String, completion: @escaping (Result<[Booking], Error>) -> Void)
- updateBookingStatus(bookingId: String, status: BookingStatus, completion: @escaping (Result<Void, Error>) -> Void)

## ProductService
- fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)

## LocalProductService
- loadProducts(completion: @escaping (Result<[Product], Error>) -> Void)

## FirestoreProductService
- fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)
