import SwiftUI
import MapKit
import UIKit

enum MapCategory: String, CaseIterable, Identifiable {
    case vet
    case grooming
    case petStore
    case pharmacy
    case boarding

    var id: String { rawValue }

    var query: String {
        switch self {
        case .vet:
            return "veterinary clinic"
        case .grooming:
            return "pet grooming"
        case .petStore:
            return "pet store"
        case .pharmacy:
            return "pet pharmacy"
        case .boarding:
            return "pet boarding"
        }
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .vet:
            return language.text(english: "Vet", bangla: "ভেট")
        case .grooming:
            return language.text(english: "Grooming", bangla: "গ্রুমিং")
        case .petStore:
            return language.text(english: "Pet Store", bangla: "পেট স্টোর")
        case .pharmacy:
            return language.text(english: "Pharmacy", bangla: "ফার্মেসি")
        case .boarding:
            return language.text(english: "Boarding", bangla: "বোর্ডিং")
        }
    }
}

extension MapCategory {
    static func from(initialCategory: String?) -> MapCategory? {
        guard let initialCategory else {
            return nil
        }

        let normalized = initialCategory
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalized {
        case "vet", "veterinary", "veterinary clinic":
            return .vet
        case "grooming", "pet grooming":
            return .grooming
        case "pet store", "pet_store", "store", "shop":
            return .petStore
        case "pharmacy", "pet pharmacy":
            return .pharmacy
        case "boarding", "pet boarding":
            return .boarding
        default:
            return nil
        }
    }
}

private enum MapUITestScenario: String {
    case loading
    case empty
    case error
}

struct MapView: View {
    @StateObject private var mapState: MapState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
    @Environment(\.openURL) private var openURL

    @State private var selectedCategory: MapCategory = .vet
    @State private var cameraPosition: MapCameraPosition = .region(MapView.defaultRegion)
    @State private var uiTestRetryTapCount: Int = 0
    private let initialCategory: String?

    private static let defaultCoordinate = CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125)
    private static let defaultRegion = MKCoordinateRegion(
        center: defaultCoordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )
    private static let uiTestScenarioEnvKey = "UI_TEST_MAP_SCENARIO"

    init(initialCategory: String? = nil, mapState: MapState = MapState()) {
        self.initialCategory = initialCategory
        _mapState = StateObject(wrappedValue: mapState)
        _selectedCategory = State(initialValue: MapCategory.from(initialCategory: initialCategory) ?? .vet)
    }

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MapHeaderView(
                        englishTitle: "Nearby Pet Services",
                        banglaTitle: "কাছাকাছি পোষা প্রাণীর সেবা"
                    )

                    CategoryChipsView(
                        categories: MapCategory.allCases,
                        selectedCategory: selectedCategory,
                        language: currentLanguage,
                        onSelect: handleCategorySelection
                    )

                    // Accessibility-only marker used by UI tests to validate category switch state.
                    Text(selectedCategory.rawValue)
                        .font(.caption)
                        .opacity(0.01)
                        .accessibilityIdentifier("selectedCategoryValue")

                    if shouldShowPermissionCard {
                        PermissionStatusCard(
                            state: mapState.permissionState,
                            language: currentLanguage,
                            onAllowLocation: {
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .map,
                                    action: "Requested location permission"
                                )
                                mapState.requestLocationPermission()
                            },
                            onOpenSettings: openLocationSettings
                        )
                    }

                    stateSection
                }
                .padding(20)
            }
        }
        .accessibilityIdentifier("mapScreen")
        .navigationTitle(text("Map", "ম্যাপ"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("[Navigation] Map tab opened")
            UserHistoryService.shared.recordCurrentUser(
                category: .map,
                action: "Opened map screen"
            )
            if let initialCategory {
                print("[MapView] Initial category: \(initialCategory)")
            }
        }
        .task {
            if uiTestScenario != nil {
                return
            }

            if mapState.places.isEmpty && !mapState.isLoading {
                triggerSearch(for: selectedCategory)
            }
        }
        .onChange(of: mapState.currentCoordinate) { coordinate in
            guard let coordinate, mapState.selectedPlace == nil else {
                return
            }

            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                )
            )
        }
        .onChange(of: mapState.selectedPlace?.id) { _ in
            guard let place = mapState.selectedPlace else {
                return
            }

            focusMap(on: place)
        }
    }

    @ViewBuilder
    private var stateSection: some View {
        if let uiTestScenario {
            switch uiTestScenario {
            case .loading:
                loadingSection
            case .empty:
                emptySection
            case .error:
                errorSection(message: "Simulated map failure")
            }
        } else if mapState.isLoading {
            loadingSection
        } else if let errorMessage = mapState.errorMessage {
            errorSection(message: errorMessage)
        } else if mapState.isEmpty {
            emptySection
        } else {
            successSection
        }
    }

    private var uiTestScenario: MapUITestScenario? {
        guard let rawValue = ProcessInfo.processInfo.environment[Self.uiTestScenarioEnvKey] else {
            return nil
        }
        return MapUITestScenario(rawValue: rawValue.lowercased())
    }

    private var isUITestScenarioActive: Bool {
        uiTestScenario != nil
    }

    private var loadingSection: some View {
        LoadingBlockView(message: text("Searching nearby services...", "কাছাকাছি সেবাগুলো খোঁজা হচ্ছে..."))
            .accessibilityIdentifier("loadingIndicator")
    }

    private func errorSection(message: String) -> some View {
        VStack(spacing: Spacing.small) {
            ErrorStateView(
                title: text("Could not load nearby places.", "কাছাকাছি সেবা লোড করা যায়নি।"),
                message: text(
                    "Please check your internet connection. Tap Retry to try again.",
                    "দয়া করে ইন্টারনেট সংযোগ যাচাই করুন। আবার চেষ্টা করতে Retry চাপুন।"
                ) + "\n\n" + message,
                messageAccessibilityIdentifier: "errorMessage",
                retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                retryAccessibilityIdentifier: "retryButton",
                onRetry: {
                    print("[MapView] Retry tapped")
                    UserHistoryService.shared.recordCurrentUser(
                        category: .map,
                        action: "Tapped retry on map error"
                    )

                    if isUITestScenarioActive {
                        uiTestRetryTapCount += 1
                        return
                    }

                    let retryQuery = mapState.lastQuery.isEmpty ? selectedCategory.query : mapState.lastQuery
                    mapState.searchPlaces(query: retryQuery)
                }
            )

            if isUITestScenarioActive {
                Text("retryCount:\(uiTestRetryTapCount)")
                    .font(.caption2)
                    .opacity(0.01)
                    .accessibilityIdentifier("retryTapCountValue")
            }
        }
    }

    private var emptySection: some View {
        VStack(spacing: Spacing.small) {
            EmptyStateView(
                icon: "map",
                title: text("No nearby services found.", "কাছাকাছি কোনো সেবা পাওয়া যায়নি।"),
                message: text("Try another category, then tap Retry.", "অন্য বিভাগ বেছে নিয়ে Retry চাপুন।")
            )
            .accessibilityIdentifier("noResultsMessage")

            Button(text("Retry", "আবার চেষ্টা করুন")) {
                let retryQuery = mapState.lastQuery.isEmpty ? selectedCategory.query : mapState.lastQuery
                UserHistoryService.shared.recordCurrentUser(
                    category: .map,
                    action: "Tapped retry on map empty state"
                )

                if isUITestScenarioActive {
                    print("[MapView] Retry tapped")
                    return
                }

                mapState.searchPlaces(query: retryQuery)
            }
            .accessibilityIdentifier("mapEmptyRetryButton")
            .buttonStyle(FilledPrimaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
    }

    private var successSection: some View {
        VStack(spacing: 12) {
            MapCanvasView(
                places: mapState.places,
                selectedPlaceId: mapState.selectedPlace?.id,
                userCoordinate: mapState.currentCoordinate,
                cameraPosition: $cameraPosition,
                onSelectPlace: { place in
                    print("[MapView] Marker selected: \(place.name)")
                    mapState.selectPlace(place)
                }
            )

            PlacesListView(
                places: mapState.places,
                selectedPlaceId: mapState.selectedPlace?.id,
                language: currentLanguage,
                onSelectPlace: { place in
                    mapState.selectPlace(place)
                }
            )

            if let selectedPlace = mapState.selectedPlace {
                PlaceDetailPanel(place: selectedPlace, language: currentLanguage)
            }
        }
    }

    private var shouldShowPermissionCard: Bool {
        switch mapState.permissionState {
        case .needed, .denied, .requesting, .unavailable:
            return true
        case .granted:
            return false
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }

    private func triggerSearch(for category: MapCategory) {
        print("[MapView] Category selected: \(category.rawValue)")
        mapState.searchPlaces(query: category.query)
    }

    private func handleCategorySelection(_ category: MapCategory) {
        selectedCategory = category
        UserHistoryService.shared.recordCurrentUser(
            category: .map,
            action: "Selected map category",
            details: category.rawValue
        )
        triggerSearch(for: category)
    }

    private func focusMap(on place: Place) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        )
    }

    private func openLocationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UserHistoryService.shared.recordCurrentUser(
            category: .map,
            action: "Opened location settings"
        )
        openURL(settingsURL)
    }
}

private struct MapHeaderView: View {
    let englishTitle: String
    let banglaTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(englishTitle)
                .font(TextStyles.title)
                .foregroundStyle(AppDesign.text)

            Text(banglaTitle)
                .font(TextStyles.body)
                .foregroundStyle(AppDesign.muted)
        }
    }
}

private struct CategoryChipsView: View {
    let categories: [MapCategory]
    let selectedCategory: MapCategory
    let language: AppLanguage
    let onSelect: (MapCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        Text(category.title(language: language))
                            .font(TextStyles.caption)
                            .foregroundStyle(selectedCategory == category ? Color.white : AppDesign.text)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(selectedCategory == category ? AppDesign.primary : Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(AppDesign.line, lineWidth: selectedCategory == category ? 0 : 1)
                            }
                    }
                    .accessibilityIdentifier("categoryChip_\(category.rawValue)")
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct PermissionStatusCard: View {
    let state: MapPermissionState
    let language: AppLanguage
    let onAllowLocation: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        CardView {
            Text(title)
                .font(TextStyles.body)
                .foregroundStyle(AppDesign.text)

            Text(message)
                .font(TextStyles.caption)
                .foregroundStyle(AppDesign.muted)

            if state == .requesting {
                ProgressView(language.text(english: "Checking location...", bangla: "লোকেশন যাচাই হচ্ছে..."))
            } else {
                HStack(spacing: 10) {
                    if state == .needed || state == .unavailable {
                        Button(language.text(english: "Allow Location", bangla: "লোকেশন অনুমতি দিন")) {
                            onAllowLocation()
                        }
                        .accessibilityIdentifier("mapAllowLocationButton")
                        .buttonStyle(FilledPrimaryButtonStyle())
                    }

                    if state == .denied {
                        Button(language.text(english: "Open Settings", bangla: "সেটিংস খুলুন")) {
                            onOpenSettings()
                        }
                        .accessibilityIdentifier("mapOpenSettingsButton")
                        .buttonStyle(OutlinedPrimaryButtonStyle())
                    }
                }
            }
        }
    }

    private var title: String {
        switch state {
        case .needed:
            return language.text(english: "Location permission needed", bangla: "লোকেশন অনুমতি প্রয়োজন")
        case .denied:
            return language.text(english: "Location permission denied", bangla: "লোকেশন অনুমতি প্রত্যাখ্যাত")
        case .requesting:
            return language.text(english: "Location request in progress", bangla: "লোকেশন অনুরোধ চলছে")
        case .unavailable:
            return language.text(english: "Location unavailable", bangla: "লোকেশন পাওয়া যায়নি")
        case .granted:
            return ""
        }
    }

    private var message: String {
        switch state {
        case .needed:
            return language.text(
                english: "Allow location to improve nearby place results.",
                bangla: "কাছাকাছি সেবা ভালভাবে খুঁজতে লোকেশন অনুমতি দিন।"
            )
        case .denied:
            return language.text(
                english: "Enable location access from Settings to use nearby search.",
                bangla: "কাছাকাছি অনুসন্ধান চালাতে সেটিংস থেকে লোকেশন চালু করুন।"
            )
        case .requesting:
            return language.text(
                english: "Please wait while we check your location permission.",
                bangla: "লোকেশন অনুমতি যাচাই করা হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন।"
            )
        case .unavailable:
            return language.text(
                english: "We could not get your current location. You can still search by text.",
                bangla: "বর্তমান লোকেশন পাওয়া যায়নি। আপনি টেক্সট দিয়ে খোঁজা চালিয়ে যেতে পারেন।"
            )
        case .granted:
            return ""
        }
    }
}

private struct MapCanvasView: View {
    let places: [Place]
    let selectedPlaceId: String?
    let userCoordinate: CLLocationCoordinate2D?
    @Binding var cameraPosition: MapCameraPosition
    let onSelectPlace: (Place) -> Void

    var body: some View {
        Map(position: $cameraPosition) {
            if let userCoordinate {
                Annotation("You", coordinate: userCoordinate) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 14, height: 14)
                }
            }

            ForEach(places) { place in
                Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                    Button {
                        onSelectPlace(place)
                    } label: {
                        Image(systemName: selectedPlaceId == place.id ? "mappin.circle.fill" : "mappin.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(selectedPlaceId == place.id ? AppDesign.primary : .red)
                            .padding(4)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppDesign.line, lineWidth: 1)
        }
    }
}

private struct PlacesListView: View {
    let places: [Place]
    let selectedPlaceId: String?
    let language: AppLanguage
    let onSelectPlace: (Place) -> Void

    var body: some View {
        CardView {
            Text(language.text(english: "Nearby Results", bangla: "কাছাকাছি ফলাফল"))
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)

            ForEach(places) { place in
                Button {
                    onSelectPlace(place)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(AppDesign.primary)
                            .font(.system(size: 17, weight: .semibold))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppDesign.text)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(place.address)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(AppDesign.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let rating = place.rating {
                                Text(language.text(english: "Rating", bangla: "রেটিং") + ": " + String(format: "%.1f", rating))
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppDesign.primary)
                            }
                        }

                        if selectedPlaceId == place.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppDesign.primary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct PlaceDetailPanel: View {
    let place: Place
    let language: AppLanguage

    var body: some View {
        CardView {
            Text(language.text(english: "Selected Place", bangla: "নির্বাচিত স্থান"))
                .font(TextStyles.caption)
                .foregroundStyle(AppDesign.muted)

            Text(place.name)
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)

            Text(place.address)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            if let rating = place.rating {
                Text(language.text(english: "Rating", bangla: "রেটিং") + ": " + String(format: "%.1f", rating))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppDesign.primary)
            }

            if !place.types.isEmpty {
                Text(language.text(english: "Type", bangla: "ধরন") + ": " + place.types.joined(separator: ", "))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }

            Button(language.text(english: "View More", bangla: "আরও দেখুন")) {}
                .accessibilityIdentifier("mapViewMoreButton")
                .buttonStyle(OutlinedPrimaryButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}