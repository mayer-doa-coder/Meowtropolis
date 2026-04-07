import SwiftUI
import UserNotifications

struct AccountView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(ReminderService.preferenceKey) private var remindersEnabled: Bool = false

    @State private var logoutError: String?
    @State private var isLoggingOut: Bool = false
    @State private var permissionStatusText: String = "Permission: Unknown"

    private let reminderService = ReminderService()

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(spacing: 8) {
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
                        .frame(width: 94, height: 94)
                        .clipShape(Circle())

                        Text(appState.currentUser?.name ?? "Loading...")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)
                        Text(appState.currentUser?.email ?? "-")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                    if appState.isProfileLoading {
                        ProgressView("Loading account...")
                            .frame(maxWidth: .infinity)
                    }

                    if let profileError = appState.profileErrorMessage {
                        Text(profileError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Group {
                        Text("My Account")
                        accountRow(icon: "person.badge.plus", text: "Personal information")
                        accountRow(icon: "globe", text: "Language", trailing: "English (US)")
                        accountRow(icon: "info.circle", text: "Privacy Policy")
                        accountRow(icon: "gearshape", text: "Setting")
                    }

                    Group {
                        Text("Notifications")
                        HStack {
                            accountRow(icon: "bell", text: "Enable Reminders")
                            Spacer()
                            Toggle("", isOn: $remindersEnabled)
                                .labelsHidden()
                                .onChange(of: remindersEnabled) { enabled in
                                    handleReminderToggle(enabled: enabled)
                                }
                        }

                        Text(permissionStatusText)
                            .font(.footnote)
                            .foregroundStyle(AppDesign.muted)
                    }

                    Group {
                        Text("More")
                        accountRow(icon: "info.circle", text: "Help Center")

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
                                Text(isLoggingOut ? "Logging out..." : "Log Out")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppDesign.text)
                            }
                        }
                        .disabled(isLoggingOut)
                    }

                    if let logoutError {
                        Text(logoutError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshPermissionStatus()
        }
    }

    private func accountRow(icon: String, text: String, trailing: String? = nil) -> some View {
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
            }
        }
    }

    private func handleReminderToggle(enabled: Bool) {
        if !enabled {
            permissionStatusText = "Permission: Reminders disabled"
            return
        }

        reminderService.requestPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    permissionStatusText = "Permission: Allowed"
                } else {
                    remindersEnabled = false
                    permissionStatusText = "Permission: Denied (enable in iPhone Settings)"
                }
            }
        }
    }

    private func refreshPermissionStatus() {
        reminderService.getPermissionStatus { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .provisional, .ephemeral:
                    permissionStatusText = remindersEnabled ? "Permission: Allowed" : "Permission: Reminders disabled"
                case .denied:
                    permissionStatusText = "Permission: Denied (enable in iPhone Settings)"
                case .notDetermined:
                    permissionStatusText = "Permission: Not requested"
                @unknown default:
                    permissionStatusText = "Permission: Unknown"
                }
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
