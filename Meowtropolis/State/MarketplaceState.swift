import Foundation
import SwiftUI

enum MarketplaceCategoryFilter: String, CaseIterable, Identifiable {
    case all
    case cat
    case dog

    var id: String { rawValue }
}

enum MarketplacePriceFilter: String, CaseIterable, Identifiable {
    case all
    case under500
    case between500And1000
    case above1000

    var id: String { rawValue }
}

@MainActor
final class MarketplaceState: ObservableObject {
    @Published var query: String = ""
    @Published var debouncedQuery: String = ""
    @Published var selectedCategory: MarketplaceCategoryFilter = .all
    @Published var selectedPriceFilter: MarketplacePriceFilter = .all
    @Published var feedbackMessage: String?
    @Published var feedbackRequiresRetry: Bool = false
    @Published var lastSelectedProductId: String?

    private var searchDebounceTask: Task<Void, Never>?

    deinit {
        searchDebounceTask?.cancel()
    }

    func scheduleDebouncedSearch() {
        searchDebounceTask?.cancel()
        let latestQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else {
                return
            }
            self?.debouncedQuery = latestQuery
        }
    }

    func resetFilters() {
        query = ""
        debouncedQuery = ""
        selectedCategory = .all
        selectedPriceFilter = .all
    }

    func categoryMatches(_ product: Product) -> Bool {
        switch selectedCategory {
        case .all:
            return true
        case .cat:
            return product.animalType == "cat" || product.animalType == "all"
        case .dog:
            return product.animalType == "dog" || product.animalType == "all"
        }
    }

    func priceMatches(_ product: Product) -> Bool {
        switch selectedPriceFilter {
        case .all:
            return true
        case .under500:
            return product.price < 500
        case .between500And1000:
            return product.price >= 500 && product.price <= 1000
        case .above1000:
            return product.price > 1000
        }
    }

    func showFeedback(_ message: String, requiresRetry: Bool = false) {
        feedbackMessage = message
        feedbackRequiresRetry = requiresRetry
    }

    func clearFeedback() {
        feedbackMessage = nil
        feedbackRequiresRetry = false
    }
}
