import SwiftUI

struct MarketplaceView: View {
    @State private var query: String = ""

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Store")
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

                    Text("Coupons For You")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            couponCard()
                            couponCard()
                        }
                    }

                    HStack {
                        Text("Our Services")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Spacer()
                        Text("See All")
                            .foregroundStyle(.blue)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            chip("All", selected: true)
                            chip("Cat")
                            chip("Dog")
                            chip("Bird")
                        }
                    }

                    Text("Flash sale")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            productCard("Josera Mini Deluxe")
                            productCard("Josera Mini Deluxe")
                            productCard("Josera Mini Deluxe")
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func couponCard() -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.45))
                .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text("50% off up to 125 on Pets Toy")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("PT50")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
            }
        }
        .padding(12)
        .frame(width: 290, alignment: .leading)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func chip(_ title: String, selected: Bool = false) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(selected ? Color.white.opacity(0.8) : Color.gray.opacity(0.45))
                .frame(width: 28, height: 28)
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
        }
        .foregroundStyle(selected ? .white : AppDesign.muted)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(selected ? AppDesign.primary : Color.white.opacity(0.3))
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(AppDesign.line, lineWidth: selected ? 0 : 1)
        }
    }

    private func productCard(_ title: String) -> some View {
        NavigationLink(destination: ProductDetailView()) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.45))
                    .frame(height: 120)

                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)
                Text("100% Arabica Espresso.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)
                HStack {
                    Text("4.7")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppDesign.text)
                    Spacer()
                    Text("$20")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.primary)
                }
            }
            .padding(10)
            .frame(width: 170)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    NavigationStack {
        MarketplaceView()
    }
}
