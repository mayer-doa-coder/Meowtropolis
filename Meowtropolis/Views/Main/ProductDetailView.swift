import SwiftUI

struct ProductDetailView: View {
    @State private var quantity: Int = 1

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.45))
                    .frame(height: 360)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Josi Dog Master Mix - 900g")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Text("Brand: Josera")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    Text("4.4 (99+)")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    Text("About")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)
                        .padding(.top, 8)

                    Text("Brighten your pet's bowl with a complete and balanced meal packed with vitamins and protein for adult dogs of all sizes.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    HStack {
                        Text("Quantity")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()

                        Button {
                            quantity = max(1, quantity - 1)
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: 28, height: 28)
                        }

                        Text(String(format: "%02d", quantity))
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .frame(minWidth: 40)

                        Button {
                            quantity += 1
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white)
                                .background(AppDesign.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    Button("Add to Cart") {}
                        .buttonStyle(FilledPrimaryButtonStyle())
                        .padding(.top, 8)
                }
                .padding(20)

                Spacer()
            }
        }
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView()
    }
}
