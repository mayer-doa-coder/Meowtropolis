import SwiftUI

struct GroomingView: View {
    @State private var query: String = ""

    var body: some View {
        AppBackground {
            VStack(spacing: 16) {
                Text("Search")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppDesign.muted)
                    TextField("Search here", text: $query)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        petCard(name: "Gary", age: "3 years", breed: "Yorkshire Terrier")
                        petCard(name: "Peach", age: "3 years", breed: "Half-breed")
                        petCard(name: "Whitney", age: "2 months", breed: "British Longhair")
                        petCard(name: "Buggy", age: "4 months", breed: "Yorkshire Terrier")
                        petCard(name: "Kiwi", age: "1 years", breed: "Samoyed")
                        petCard(name: "Stitch", age: "1.5 years", breed: "European cat")
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func petCard(name: String, age: String, breed: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.45))
                .frame(height: 120)
            HStack {
                Text(name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)
                Spacer()
                Text(age)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }
            Text(breed)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)
        }
        .padding(8)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        GroomingView()
    }
}
