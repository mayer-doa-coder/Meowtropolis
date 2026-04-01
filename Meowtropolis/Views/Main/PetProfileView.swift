import SwiftUI

struct PetProfileView: View {
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.45))
                        .frame(height: 320)
                        .overlay(alignment: .topLeading) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(AppDesign.primary)
                                .padding(10)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .padding(16)
                        }

                    Text("Samoyed Willy")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    HStack(spacing: 8) {
                        tag("1 year", color: Color(red: 0.96, green: 0.90, blue: 0.76))
                        tag("Knows the commands", color: Color(red: 0.84, green: 0.78, blue: 0.98))
                        tag("23 kg", color: Color(red: 0.96, green: 0.81, blue: 0.86))
                    }

                    HStack(spacing: 10) {
                        stat("Weight", value: "3,5 kg")
                        stat("Height", value: "22 cm")
                        stat("Color", value: "Dark pink")
                    }

                    Text("The kindest Samoyed we've ever met. Loves to play with balls, is friends with other animals, and enjoys rain and puddles.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    Button("Sign Up") {}
                        .buttonStyle(FilledPrimaryButtonStyle())
                }
                .padding(20)
            }
        }
        .navigationTitle("Pet Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tag(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(AppDesign.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(Capsule())
    }

    private func stat(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.text)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        PetProfileView()
    }
}
