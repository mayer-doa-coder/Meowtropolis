import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var appState: AppState
    @State private var logoutError: String?

    var body: some View {
        AppBackground {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 94, height: 94)
                    Text("Emmie Watson")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)
                    Text("emmie1709@gmail.com")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

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
                        accountRow(icon: "bell", text: "Push Notifications")
                        Spacer()
                        Toggle("", isOn: .constant(true)).labelsHidden()
                    }
                    HStack {
                        accountRow(icon: "bell", text: "Promotional Notifications")
                        Spacer()
                        Toggle("", isOn: .constant(false)).labelsHidden()
                    }
                }

                Group {
                    Text("More")
                    accountRow(icon: "info.circle", text: "Help Center")

                    Button {
                        appState.logout { result in
                            if case let .failure(error) = result {
                                logoutError = error.localizedDescription
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.right.square")
                                .foregroundStyle(.red)
                            Text("Log Out")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(AppDesign.text)
                        }
                    }
                }

                if let logoutError {
                    Text(logoutError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(AppDesign.text)
            .padding(20)
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject(AppState())
    }
}
