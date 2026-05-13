import Foundation
import FirebaseFirestore

/// Handles order creation with stock-safe Firestore transaction updates.
final class OrderService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func placeOrder(
        userId: String,
        cartItems: [CartItem],
        totalAmount: Double,
        currencyCode: String = "BDT",
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        let normalizedUserId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedItems = cartItems.filter { $0.quantity > 0 }

        guard !normalizedUserId.isEmpty else {
            completion(.failure(OrderServiceError.invalidUser))
            return
        }

        guard !normalizedItems.isEmpty else {
            completion(.failure(OrderServiceError.emptyCart))
            return
        }

        let orderId = UUID().uuidString
        let createdAt = ISO8601DateFormatter().string(from: Date())

        let orderItems = normalizedItems.map { item in
            OrderItem(
                productId: item.productId,
                name: item.name,
                category: item.category,
                imageURL: item.imageURL,
                unitPrice: item.price,
                quantity: item.quantity,
                lineTotal: item.price * Double(item.quantity)
            )
        }

        let order = Order(
            id: orderId,
            userId: normalizedUserId,
            items: orderItems,
            totalAmount: totalAmount,
            currencyCode: currencyCode,
            status: "placed",
            createdAt: createdAt
        )

        db.runTransaction({ transaction, errorPointer in
            do {
                for item in normalizedItems {
                    let productRef = self.db.collection(FirestoreCollections.products).document(item.productId)
                    let snapshot = try transaction.getDocument(productRef)

                    let currentStock: Int
                    if snapshot.exists {
                        currentStock = snapshot.data()? ["stock"] as? Int ?? item.availableStock
                    } else {
                        currentStock = item.availableStock
                    }

                    if currentStock < item.quantity {
                        errorPointer?.pointee = OrderServiceError.insufficientStock(productName: item.name) as NSError
                        return nil
                    }

                    let updatedStock = currentStock - item.quantity
                    if snapshot.exists {
                        transaction.updateData(["stock": updatedStock], forDocument: productRef)
                    } else {
                        transaction.setData(
                            [
                                "id": item.productId,
                                "name": item.name,
                                "price": item.price,
                                "category": item.category,
                                "imageURL": item.imageURL,
                                "stock": updatedStock
                            ],
                            forDocument: productRef,
                            merge: true
                        )
                    }
                }

                let orderData = try FirestoreModelCoder.encode(order)
                let orderRef = self.db.collection(FirestoreCollections.orders).document(order.id)
                transaction.setData(orderData, forDocument: orderRef)
                return order
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(order))
        }
    }

    /// Lists all orders for admin dashboard, newest first.
    func listAllOrders(completion: @escaping (Result<[Order], Error>) -> Void) {
        db.collection(FirestoreCollections.orders)
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
                    let orders = try documents.map { document in
                        var data = document.data()
                        if (data["id"] as? String)?.isEmpty != false {
                            data["id"] = document.documentID
                        }
                        return try FirestoreModelCoder.decode(Order.self, from: data)
                    }
                    .sorted { $0.createdAt > $1.createdAt }
                    completion(.success(orders))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Updates order status (for example: processing, completed, cancelled).
    func updateOrderStatus(orderId: String, status: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.orders)
            .document(orderId)
            .updateData(["status": status]) { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }
}

enum OrderServiceError: LocalizedError {
    case invalidUser
    case emptyCart
    case insufficientStock(productName: String)

    var errorDescription: String? {
        switch self {
        case .invalidUser:
            return "User is not valid for order placement."
        case .emptyCart:
            return "Cannot place order with an empty cart."
        case let .insufficientStock(productName):
            return "Insufficient stock for \(productName)."
        }
    }
}
