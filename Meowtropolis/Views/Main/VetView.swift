import SwiftUI

struct VetView: View {
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Services")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    HStack {
                        Text("Near You")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Spacer()
                        Text("See All")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.blue)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            nearbyCard("Banfield Pet Hospital", location: "Los Angeles, CA")
                            nearbyCard("VCA Animal Hospital", location: "Brooklyn, NY")
                        }
                    }

                    HStack {
                        Text("Your tricks")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.blue)
                    }

                    trickCard("Canine Good Citizen Test", author: "By Baron Fuzzypaws", rating: "4.8 (220)")
                    trickCard("Theraphy Dogs", author: "By Duke Fuzzington", rating: "5.0 (500)")
                    trickCard("Socialization", author: "By Baron Fuzzypaws", rating: "4.9 (440)")
                    trickCard("Specialty Classes & Workshops", author: "By Duke Fuzzington", rating: "5.0 (500)")
                }
                .padding(20)
            }
        }
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func nearbyCard(_ title: String, location: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.45))
                .frame(width: 220, height: 110)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)
            Text(location)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func trickCard(_ title: String, author: String, rating: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.45))
                .frame(width: 90, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppDesign.text)
                Text(author)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.text)
                Text(rating)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        VetView()
    }
}
