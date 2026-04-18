import SwiftUI
import PhotosUI
import UserNotifications
import UIKit

struct AccountView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(ReminderService.preferenceKey) private var remindersEnabled: Bool = false
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var logoutError: String?
    @State private var isLoggingOut: Bool = false
    @State private var permissionStatusText: String = ""
    @State private var languageUpdateMessage: String?

    private let reminderService = ReminderService()

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
                            } else {
                                AsyncImage(url: AppImageLibrary.userAvatarURL) { phase in
                                    switch phase {
                                    case let .success(image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    default:
                                        Circle().fill(Color.gray.opacity(0.35))
                                    }
                                }
                            }
                            .frame(width: 94, height: 94)
                            .clipShape(Circle())

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
                            title: text("Could not load account", "অ্যাকাউন্ট লোড করা যায়নি"),
                            message: profileError
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
                                        Label(language.displayTitle, systemImage: "checkmark")
                                    } else {
                                        Text(language.displayTitle)
                                    }
                                }
                            }
                        } label: {
                            accountRow(icon: "globe", text: text("Language", "ভাষা"), trailing: currentLanguage.displayTitle)
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
                        Text(text("More", "আরও"))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        accountRow(icon: "info.circle", text: text("Help Center", "সহায়তা কেন্দ্র"))

                        Button {
                            isLoggingOut = true
                            appState.logout { result in
                                isLoggingOut = false
                                if case let .failure(error) = result {
                                    logoutError = appState.userFriendlyAuthError(error)
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.square")
                                    .foregroundStyle(.red)
                                Text(isLoggingOut ? text("Logging out...", "লগ আউট হচ্ছে...") : text("Logout", "লগ আউট"))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppDesign.text)
                            }
                        }
                        .disabled(isLoggingOut)
                    }

                    if let logoutError {
                        ErrorStateView(
                            title: text("Logout failed", "লগ আউট ব্যর্থ হয়েছে"),
                            message: logoutError
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
        }
        .onChange(of: appLanguageCode) { _ in
            refreshPermissionStatus()
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
                languageUpdateMessage = text("Language updated.", "ভাষা আপডেট হয়েছে।")
            case .failure:
                appLanguageCode = oldValue
                languageUpdateMessage = text("Could not update language right now.", "এই মুহূর্তে ভাষা আপডেট করা যায়নি।")
            }
        }
    }

    private func handleReminderToggle(enabled: Bool) {
        if !enabled {
            permissionStatusText = text("Permission: Reminders disabled", "অনুমতি: রিমাইন্ডার বন্ধ")
            return
        }

        reminderService.requestPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    permissionStatusText = text("Permission: Allowed", "অনুমতি: অনুমোদিত")
                } else {
                    remindersEnabled = false
                    permissionStatusText = text("Permission: Denied (enable in iPhone Settings)", "অনুমতি: প্রত্যাখ্যাত (iPhone Settings থেকে চালু করুন)")
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
                    permissionStatusText = text("Permission: Denied (enable in iPhone Settings)", "অনুমতি: প্রত্যাখ্যাত (iPhone Settings থেকে চালু করুন)")
                case .notDetermined:
                    permissionStatusText = text("Permission: Not requested", "অনুমতি: এখনো চাওয়া হয়নি")
                @unknown default:
                    permissionStatusText = text("Permission: Unknown", "অনুমতি: অজানা")
                }
            }
        }
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
                AsyncImage(url: AppImageLibrary.userAvatarURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                }
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
