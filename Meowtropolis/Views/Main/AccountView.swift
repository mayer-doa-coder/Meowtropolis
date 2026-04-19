import SwiftUI
import PhotosUI
import UserNotifications
import UIKit

private enum UserHistoryFilter: String, CaseIterable, Identifiable {
    case all
    case auth
    case pets
    case grooming
    case vet
    case shop
    case map
    case account

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .all:
            return language.text(english: "All", bangla: "সব")
        case .auth:
            return language.text(english: "Auth", bangla: "লগইন")
        case .pets:
            return language.text(english: "Pets", bangla: "পোষা প্রাণী")
        case .grooming:
            return language.text(english: "Grooming", bangla: "গ্রুমিং")
        case .vet:
            return language.text(english: "Vet", bangla: "ভেট")
        case .shop:
            return language.text(english: "Shop", bangla: "শপ")
        case .map:
            return language.text(english: "Map", bangla: "ম্যাপ")
        case .account:
            return language.text(english: "Account", bangla: "অ্যাকাউন্ট")
        }
    }

    var category: UserHistoryCategory? {
        switch self {
        case .all:
            return nil
        case .auth:
            return .auth
        case .pets:
            return .pets
        case .grooming:
            return .grooming
        case .vet:
            return .vet
        case .shop:
            return .shop
        case .map:
            return .map
        case .account:
            return .account
        }
    }
}

struct AccountView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(ReminderService.preferenceKey) private var remindersEnabled: Bool = false
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var logoutError: String?
    @State private var isLoggingOut: Bool = false
    @State private var permissionStatusText: String = ""
    @State private var languageUpdateMessage: String?
    @State private var historyEntries: [UserHistoryEntry] = []
    @State private var selectedHistoryFilter: UserHistoryFilter = .all

    private let reminderService = ReminderService()
    private let userHistoryService = UserHistoryService.shared

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    CardView {
                        VStack(spacing: 8) {
                            if let profileImage = AppImageLibrary.profileImage(fromBase64: appState.currentUser?.profileImageBase64) {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 94, height: 94)
                                    .clipShape(Circle())
                            } else {
                                AppPlaceholderImageView(
                                    assetName: AppImageLibrary.userAvatarAssetName,
                                    cornerRadius: 47,
                                    iconSize: 28
                                )
                                .frame(width: 94, height: 94)
                                .clipShape(Circle())
                            }

                            Text(appState.currentUser?.name ?? text("Loading...", "লোড হচ্ছে..."))
                                .font(TextStyles.subtitle)
                                .foregroundStyle(AppDesign.text)
                            Text(appState.currentUser?.email ?? "-")
                                .font(TextStyles.body)
                                .foregroundStyle(AppDesign.muted)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if appState.isProfileLoading {
                        LoadingBlockView(message: text("Loading account...", "অ্যাকাউন্ট লোড হচ্ছে..."))
                            .frame(maxWidth: .infinity)
                    }

                    if let profileError = appState.profileErrorMessage {
                        ErrorStateView(
                            title: text("Couldn't load your account.", "আপনার অ্যাকাউন্ট লোড করা যায়নি।"),
                            message: text(
                                "Please check your internet connection. Tap Retry to try again.",
                                "দয়া করে ইন্টারনেট সংযোগ যাচাই করুন। আবার চেষ্টা করতে পুনরায় চেষ্টা বোতাম চাপুন।"
                            ) + "\n\n" + profileError,
                            messageAccessibilityIdentifier: "accountProfileErrorMessage",
                            retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                            retryAccessibilityIdentifier: "accountProfileRetryButton",
                            onRetry: {
                                appState.loadCurrentUserProfile()
                            }
                        )
                    }

                    CardView {
                        Text(text("My Account", "আমার অ্যাকাউন্ট"))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        NavigationLink {
                            PersonalInformationView()
                        } label: {
                            accountRow(icon: "person.badge.plus", text: text("Personal Information", "ব্যক্তিগত তথ্য"), showsChevron: true)
                        }
                        .buttonStyle(.plain)

                        Menu {
                            ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                                Button {
                                    updateLanguage(language)
                                } label: {
                                    if language.rawValue == currentLanguage.rawValue {
                                        Label(language.displayTitle(in: currentLanguage), systemImage: "checkmark")
                                    } else {
                                        Text(language.displayTitle(in: currentLanguage))
                                    }
                                }
                            }
                        } label: {
                            accountRow(icon: "globe", text: text("Language", "ভাষা"), trailing: currentLanguage.displayTitle(in: currentLanguage))
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PasswordSecurityView()
                        } label: {
                            accountRow(icon: "lock.shield", text: text("Password and Security", "পাসওয়ার্ড ও নিরাপত্তা"), showsChevron: true)
                        }
                        .buttonStyle(.plain)

                        if let languageUpdateMessage {
                            Text(languageUpdateMessage)
                                .font(TextStyles.caption)
                                .foregroundStyle(.green)
                        }
                    }

                    CardView {
                        Text(text("Notifications", "নোটিফিকেশন"))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        HStack {
                            accountRow(icon: "bell", text: text("Enable Reminders", "রিমাইন্ডার চালু করুন"))
                            Spacer()
                            Toggle("", isOn: $remindersEnabled)
                                .labelsHidden()
                                .onChange(of: remindersEnabled) { enabled in
                                    handleReminderToggle(enabled: enabled)
                                }
                        }

                        Text(permissionStatusText)
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)
                    }

                    CardView {
                        HStack {
                            Text(text("User History", "ব্যবহারকারীর ইতিহাস"))
                                .font(TextStyles.subtitle)
                                .foregroundStyle(AppDesign.text)
                            Spacer()
                            Button(text("Clear", "মুছুন")) {
                                userHistoryService.clear(for: appState.currentUserId)
                                loadHistoryEntries()
                            }
                            .font(TextStyles.caption)
                            .foregroundStyle(.red)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(UserHistoryFilter.allCases) { filter in
                                    Button {
                                        selectedHistoryFilter = filter
                                    } label: {
                                        Text(filter.title(language: currentLanguage))
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundStyle(selectedHistoryFilter == filter ? Color.white : AppDesign.text)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedHistoryFilter == filter ? AppDesign.primary : Color.white.opacity(0.85))
                                            .clipShape(Capsule())
                                            .overlay {
                                                Capsule()
                                                    .stroke(AppDesign.line, lineWidth: selectedHistoryFilter == filter ? 0 : 1)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if filteredHistoryEntries.isEmpty {
                            Text(text("No user activity yet.", "এখনও কোনো ব্যবহারকারী কার্যকলাপ নেই।"))
                                .font(TextStyles.caption)
                                .foregroundStyle(AppDesign.muted)
                        } else {
                            ForEach(filteredHistoryEntries.prefix(20)) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(localizedHistoryAction(entry.action))
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(AppDesign.text)
                                        Spacer()
                                        Text(entry.category.displayTitle(language: currentLanguage))
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppDesign.muted)
                                    }

                                    if let details = entry.details, !details.isEmpty {
                                        Text(localizedHistoryDetails(details))
                                            .font(TextStyles.caption)
                                            .foregroundStyle(AppDesign.muted)
                                    }

                                    Text(relativeDate(entry.timestamp))
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundStyle(AppDesign.muted)
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.65))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    CardView {
                        Text(text("More", "আরও"))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        accountRow(icon: "info.circle", text: text("Help Center", "সহায়তা কেন্দ্র"))

                        Button {
                            performLogout()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.square")
                                    .foregroundStyle(.red)
                                Text(isLoggingOut ? text("Logging out...", "লগ আউট হচ্ছে...") : text("Logout", "লগ আউট"))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppDesign.text)
                            }
                        }
                        .accessibilityIdentifier("accountLogoutButton")
                        .disabled(isLoggingOut)
                    }

                    if let logoutError {
                        ErrorStateView(
                            title: text("Couldn't log you out.", "আপনাকে লগ আউট করা যায়নি।"),
                            message: text(
                                "Please check your internet connection and tap Retry, or tap Logout again.",
                                "দয়া করে ইন্টারনেট সংযোগ যাচাই করে পুনরায় চেষ্টা বোতাম চাপুন, অথবা আবার লগ আউট চাপুন।"
                            ) + "\n\n" + logoutError,
                            messageAccessibilityIdentifier: "accountLogoutErrorMessage",
                            retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                            retryAccessibilityIdentifier: "accountLogoutRetryButton",
                            onRetry: performLogout
                        )
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(text("Account", "অ্যাকাউন্ট"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshPermissionStatus()
            loadHistoryEntries()
            userHistoryService.recordCurrentUser(
                category: .account,
                action: "Opened account screen"
            )
        }
        .onChange(of: appLanguageCode) { _ in
            refreshPermissionStatus()
        }
        .onChange(of: appState.currentUserId) { _ in
            loadHistoryEntries()
        }
        .onChange(of: selectedHistoryFilter) { filter in
            userHistoryService.recordCurrentUser(
                category: .account,
                action: "Changed history filter",
                details: filter.title(language: currentLanguage)
            )
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }

    private func accountRow(icon: String, text: String, trailing: String? = nil, showsChevron: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppDesign.text)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.text)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppDesign.muted)
            }
        }
    }

    private func performLogout() {
        isLoggingOut = true
        appState.logout { result in
            isLoggingOut = false
            if case let .failure(error) = result {
                logoutError = appState.userFriendlyAuthError(error)
            }
        }
    }

    private func updateLanguage(_ language: AppLanguage) {
        let oldValue = appLanguageCode
        appLanguageCode = language.rawValue
        languageUpdateMessage = nil

        guard let currentUser = appState.currentUser else {
            return
        }

        appState.updatePersonalInformation(
            fullName: currentUser.name,
            email: currentUser.email,
            preferredLanguageCode: language.rawValue,
            profileImageBase64: currentUser.profileImageBase64,
            currentPasswordForEmailChange: nil
        ) { result in
            switch result {
            case .success:
                userHistoryService.recordCurrentUser(
                    category: .account,
                    action: "Changed app language",
                    details: language.displayTitle(in: currentLanguage)
                )
                languageUpdateMessage = text("Language updated.", "ভাষা আপডেট হয়েছে।")
            case .failure:
                appLanguageCode = oldValue
                languageUpdateMessage = text("Could not update language right now.", "এই মুহূর্তে ভাষা আপডেট করা যায়নি।")
            }
        }
    }

    private func handleReminderToggle(enabled: Bool) {
        if !enabled {
            userHistoryService.recordCurrentUser(
                category: .account,
                action: "Disabled reminders"
            )
            permissionStatusText = text("Permission: Reminders disabled", "অনুমতি: রিমাইন্ডার বন্ধ")
            return
        }

        reminderService.requestPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    userHistoryService.recordCurrentUser(
                        category: .account,
                        action: "Enabled reminders"
                    )
                    permissionStatusText = text("Permission: Allowed", "অনুমতি: অনুমোদিত")
                } else {
                    remindersEnabled = false
                    userHistoryService.recordCurrentUser(
                        category: .account,
                        action: "Reminder permission denied"
                    )
                    permissionStatusText = text("Permission: Denied (enable in iPhone Settings)", "অনুমতি: প্রত্যাখ্যাত (আইফোন সেটিংস থেকে চালু করুন)")
                }
            }
        }
    }

    private func refreshPermissionStatus() {
        reminderService.getPermissionStatus { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .provisional, .ephemeral:
                    permissionStatusText = remindersEnabled
                        ? text("Permission: Allowed", "অনুমতি: অনুমোদিত")
                        : text("Permission: Reminders disabled", "অনুমতি: রিমাইন্ডার বন্ধ")
                case .denied:
                    permissionStatusText = text("Permission: Denied (enable in iPhone Settings)", "অনুমতি: প্রত্যাখ্যাত (আইফোন সেটিংস থেকে চালু করুন)")
                case .notDetermined:
                    permissionStatusText = text("Permission: Not requested", "অনুমতি: এখনো চাওয়া হয়নি")
                @unknown default:
                    permissionStatusText = text("Permission: Unknown", "অনুমতি: অজানা")
                }
            }
        }
    }

    private var filteredHistoryEntries: [UserHistoryEntry] {
        guard let category = selectedHistoryFilter.category else {
            return historyEntries
        }

        return historyEntries.filter { $0.category == category }
    }

    private func loadHistoryEntries() {
        historyEntries = userHistoryService.entries(for: appState.currentUserId)
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: currentLanguage == .bangla ? "bn_BD" : "en_US")
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func localizedHistoryAction(_ action: String) -> String {
        guard currentLanguage == .bangla else {
            return action
        }

        let localizedActions: [String: String] = [
            "Opened account screen": "অ্যাকাউন্ট স্ক্রিন খোলা হয়েছে",
            "Changed history filter": "ইতিহাসের ফিল্টার পরিবর্তন করা হয়েছে",
            "Changed app language": "অ্যাপের ভাষা পরিবর্তন করা হয়েছে",
            "Disabled reminders": "রিমাইন্ডার বন্ধ করা হয়েছে",
            "Enabled reminders": "রিমাইন্ডার চালু করা হয়েছে",
            "Reminder permission denied": "রিমাইন্ডার অনুমতি প্রত্যাখ্যাত হয়েছে",
            "Opened map screen": "ম্যাপ স্ক্রিন খোলা হয়েছে",
            "Tapped retry on map error": "ম্যাপ ত্রুটি থেকে আবার চেষ্টা করা হয়েছে",
            "Tapped retry on map empty state": "খালি ম্যাপ অবস্থা থেকে আবার চেষ্টা করা হয়েছে",
            "Selected map category": "ম্যাপ ক্যাটাগরি নির্বাচন করা হয়েছে",
            "Opened location settings": "লোকেশন সেটিংস খোলা হয়েছে",
            "Opened marketplace": "মার্কেটপ্লেস খোলা হয়েছে",
            "Opened product from list": "পণ্যের তালিকা থেকে পৃষ্ঠা খোলা হয়েছে",
            "Opened cart from marketplace": "মার্কেটপ্লেস থেকে কার্ট খোলা হয়েছে",
            "Opened cart": "কার্ট খোলা হয়েছে",
            "Opened checkout": "চেকআউট খোলা হয়েছে",
            "Opened checkout screen": "চেকআউট স্ক্রিন খোলা হয়েছে",
            "Placed order": "অর্ডার সম্পন্ন হয়েছে",
            "Order placement failed": "অর্ডার সম্পন্ন করা যায়নি",
            "Closed order confirmation": "অর্ডার নিশ্চিতকরণ বন্ধ করা হয়েছে",
            "Tapped add to cart": "কার্টে যোগ করুন চাপা হয়েছে",
            "Viewed product details": "পণ্যের বিস্তারিত দেখা হয়েছে",
            "Decreased product quantity": "পণ্যের পরিমাণ কমানো হয়েছে",
            "Increased product quantity": "পণ্যের পরিমাণ বাড়ানো হয়েছে",
            "Changed marketplace sort": "মার্কেটপ্লেস সাজানো পরিবর্তন করা হয়েছে",
            "Changed marketplace animal filter": "মার্কেটপ্লেস প্রাণী ফিল্টার পরিবর্তন করা হয়েছে",
            "Changed stock filter": "স্টক ফিল্টার পরিবর্তন করা হয়েছে",
            "Submitted store search": "স্টোরে খোঁজ জমা দেওয়া হয়েছে",
            "Tapped retry in marketplace": "মার্কেটপ্লেসে আবার চেষ্টা চাপা হয়েছে"
        ]

        return localizedActions[action] ?? action
    }

    private func localizedHistoryDetails(_ details: String) -> String {
        guard currentLanguage == .bangla else {
            return details
        }

        let lowered = details.lowercased()
        if lowered == "enabled" {
            return "চালু"
        }
        if lowered == "disabled" {
            return "বন্ধ"
        }

        return details
    }
}

private struct PersonalInformationView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var currentPasswordForEmailChange: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    @State private var isSaving: Bool = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        avatarPreview

                        VStack(alignment: .leading, spacing: 8) {
                            Text(text("Profile Image", "প্রোফাইল ছবি"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppDesign.text)

                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label(text("Upload Photo", "ছবি আপলোড করুন"), systemImage: "photo.on.rectangle")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                        }
                    }

                    AppInputField(title: text("Name", "নাম"), text: $fullName)

                    AppInputField(title: text("Email", "ইমেইল"), text: $email)

                    AppInputField(
                        title: text("Current password (required only for email change)", "বর্তমান পাসওয়ার্ড (শুধু ইমেইল বদলালে প্রয়োজন)"),
                        text: $currentPasswordForEmailChange,
                        isSecure: true
                    )

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

                    Button(isSaving ? text("Saving...", "সেভ হচ্ছে...") : text("Save Changes", "পরিবর্তন সেভ করুন")) {
                        saveChanges()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle(disabled: isSaving))
                    .disabled(isSaving)
                }
                .padding(20)
            }
        }
        .navigationTitle(text("Personal Information", "ব্যক্তিগত তথ্য"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadInitialData()
        }
        .onChange(of: selectedPhotoItem) { item in
            guard let item else {
                return
            }
            loadPickedImage(item)
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }

    private var avatarPreview: some View {
        Group {
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let userImage = AppImageLibrary.profileImage(fromBase64: appState.currentUser?.profileImageBase64) {
                Image(uiImage: userImage)
                    .resizable()
                    .scaledToFill()
            } else {
                AppPlaceholderImageView(assetName: AppImageLibrary.userAvatarAssetName, cornerRadius: 45, iconSize: 24)
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(Circle())
    }

    private func loadInitialData() {
        guard let user = appState.currentUser else {
            return
        }

        if fullName.isEmpty {
            fullName = user.name
        }

        if email.isEmpty {
            email = user.email
        }
    }

    private func loadPickedImage(_ item: PhotosPickerItem) {
        Task {
            guard let rawData = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: rawData),
                  let compressedData = image.jpegData(compressionQuality: 0.72) else {
                await MainActor.run {
                    errorMessage = text("Could not load selected image.", "নির্বাচিত ছবি লোড করা যায়নি।")
                }
                return
            }

            await MainActor.run {
                selectedImageData = compressedData
                errorMessage = nil
            }
        }
    }

    private func saveChanges() {
        successMessage = nil
        errorMessage = nil

        let trimmedPassword = currentPasswordForEmailChange.trimmingCharacters(in: .whitespacesAndNewlines)
        let base64Image = selectedImageData?.base64EncodedString() ?? appState.currentUser?.profileImageBase64

        isSaving = true
        appState.updatePersonalInformation(
            fullName: fullName,
            email: email,
            preferredLanguageCode: appLanguageCode,
            profileImageBase64: base64Image,
            currentPasswordForEmailChange: trimmedPassword.isEmpty ? nil : trimmedPassword
        ) { result in
            isSaving = false

            switch result {
            case .success:
                currentPasswordForEmailChange = ""
                successMessage = text("Profile updated successfully.", "প্রোফাইল সফলভাবে আপডেট হয়েছে।")
            case let .failure(error):
                if (error as NSError).domain == "AppState" {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = appState.userFriendlyAuthError(error)
                }
            }
        }
    }
}

private struct PasswordSecurityView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var deleteAccountPassword: String = ""

    @State private var isChangingPassword: Bool = false
    @State private var isDeletingAccount: Bool = false
    @State private var successMessage: String?
    @State private var errorMessage: String?
    @State private var showDeleteConfirmAlert: Bool = false

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(text("Change Password", "পাসওয়ার্ড পরিবর্তন"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        AppInputField(title: text("Current Password", "বর্তমান পাসওয়ার্ড"), text: $currentPassword, isSecure: true)
                        AppInputField(title: text("New Password", "নতুন পাসওয়ার্ড"), text: $newPassword, isSecure: true)
                        AppInputField(title: text("Confirm New Password", "নতুন পাসওয়ার্ড নিশ্চিত করুন"), text: $confirmPassword, isSecure: true)

                        Button(isChangingPassword ? text("Updating...", "আপডেট হচ্ছে...") : text("Update Password", "পাসওয়ার্ড আপডেট করুন")) {
                            changePassword()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle(disabled: isChangingPassword || isDeletingAccount))
                        .disabled(isChangingPassword || isDeletingAccount)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 12) {
                        Text(text("Delete Account", "অ্যাকাউন্ট মুছে ফেলুন"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)

                        Text(text("This action is permanent and cannot be undone.", "এই কাজটি স্থায়ী এবং পরে ফিরিয়ে আনা যাবে না।"))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)

                        AppInputField(title: text("Current Password", "বর্তমান পাসওয়ার্ড"), text: $deleteAccountPassword, isSecure: true)

                        Button(isDeletingAccount ? text("Deleting...", "মুছে ফেলা হচ্ছে...") : text("Delete Account", "অ্যাকাউন্ট মুছে ফেলুন")) {
                            showDeleteConfirmAlert = true
                        }
                        .buttonStyle(FilledPrimaryButtonStyle(disabled: isChangingPassword || isDeletingAccount))
                        .disabled(isChangingPassword || isDeletingAccount)
                        .tint(.red)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

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
                }
                .padding(20)
            }
        }
        .navigationTitle(text("Password & Security", "পাসওয়ার্ড ও নিরাপত্তা"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(text("Delete Account", "অ্যাকাউন্ট মুছে ফেলুন"), isPresented: $showDeleteConfirmAlert) {
            Button(text("Cancel", "বাতিল"), role: .cancel) {}
            Button(text("Delete", "মুছে ফেলুন"), role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text(text("Are you sure you want to permanently delete your account?", "আপনি কি নিশ্চিত যে অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলতে চান?"))
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }

    private func changePassword() {
        successMessage = nil
        errorMessage = nil

        let trimmedCurrent = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNew = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCurrent.isEmpty else {
            errorMessage = text("Current password is required.", "বর্তমান পাসওয়ার্ড প্রয়োজন।")
            return
        }

        guard !trimmedNew.isEmpty else {
            errorMessage = text("New password is required.", "নতুন পাসওয়ার্ড প্রয়োজন।")
            return
        }

        guard trimmedNew.count >= 6 else {
            errorMessage = text("New password must be at least 6 characters.", "নতুন পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।")
            return
        }

        guard trimmedNew == trimmedConfirm else {
            errorMessage = text("New passwords do not match.", "নতুন পাসওয়ার্ড মিলছে না।")
            return
        }

        isChangingPassword = true
        appState.changePassword(currentPassword: trimmedCurrent, newPassword: trimmedNew) { result in
            isChangingPassword = false

            switch result {
            case .success:
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
                successMessage = text("Password updated successfully.", "পাসওয়ার্ড সফলভাবে আপডেট হয়েছে।")
            case let .failure(error):
                errorMessage = appState.userFriendlyAuthError(error)
            }
        }
    }

    private func deleteAccount() {
        successMessage = nil
        errorMessage = nil

        let trimmedPassword = deleteAccountPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPassword.isEmpty else {
            errorMessage = text("Current password is required.", "বর্তমান পাসওয়ার্ড প্রয়োজন।")
            return
        }

        isDeletingAccount = true
        appState.deleteAccount(currentPassword: trimmedPassword) { result in
            isDeletingAccount = false

            switch result {
            case .success:
                successMessage = text("Account deleted.", "অ্যাকাউন্ট মুছে ফেলা হয়েছে।")
                dismiss()
            case let .failure(error):
                errorMessage = appState.userFriendlyAuthError(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject(AppState())
    }
}
