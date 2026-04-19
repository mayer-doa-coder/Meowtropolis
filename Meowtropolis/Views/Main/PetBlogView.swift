import SwiftUI

struct PetBlog: Identifiable {
    let id: String
    let title: String
    let category: String
    let readTimeMinutes: Int
    let excerpt: String
    let content: String
    let imageAssetName: String
}

enum PetBlogRepository {
    static let all: [PetBlog] = [
        PetBlog(
            id: "blog_pet_food_transition",
            title: "How to Switch Your Pet to a New Food Safely",
            category: "Nutrition",
            readTimeMinutes: 4,
            excerpt: "Use a 7-day transition so your pet avoids tummy issues and keeps appetite stable.",
            content: "Start by mixing 75% old food with 25% new food for two days. Then move to 50/50 for two days, and 25/75 for two days. On day seven, feed 100% new food. Keep fresh water available and watch stool consistency and appetite. If your pet shows vomiting or loose stool, slow the transition and consult your vet.",
            imageAssetName: "img_pet_metro_adult_cat_food_tuna_and_chicken_recipe_1kg"
        ),
        PetBlog(
            id: "blog_pet_grooming_home",
            title: "At-Home Grooming Routine for Happier Pets",
            category: "Grooming",
            readTimeMinutes: 3,
            excerpt: "A simple weekly routine keeps coat, skin, and nails healthy between appointments.",
            content: "Brush your pet 3-4 times a week to reduce shedding and matting. Clean paws after outdoor walks and check ears for redness or odor. Trim nails every 2-4 weeks depending on growth. Use a gentle pet-safe shampoo during baths. Always reward your pet with treats after grooming to build a positive routine.",
            imageAssetName: "img_pet_groom2"
        ),
        PetBlog(
            id: "blog_pet_warning_signs",
            title: "5 Early Health Warning Signs Pet Parents Should Not Ignore",
            category: "Health",
            readTimeMinutes: 5,
            excerpt: "Spotting behavior and appetite changes early can prevent bigger health problems.",
            content: "Watch for sudden loss of appetite, unusual tiredness, frequent scratching, coughing, or changes in bathroom habits. These signs can point to allergies, infections, or digestive issues. Keep a short daily note of symptoms and timeline. If signs continue for more than 24-48 hours, book a vet checkup quickly.",
            imageAssetName: "img_pet_vet1"
        )
    ]

    static var featured: [PetBlog] {
        Array(all.prefix(3))
    }
}

struct PetBlogListView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(PetBlogRepository.all) { blog in
                        NavigationLink(destination: PetBlogDetailView(blog: blog)) {
                            PetBlogCardView(blog: blog, compact: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(text("Pet Blogs", "পোষা প্রাণী ব্লগ"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .pets,
                action: "Viewed pet blogs"
            )
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

struct PetBlogDetailView: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue
    let blog: PetBlog

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.gray.opacity(0.25))

                        AppPlaceholderImageView(assetName: blog.imageAssetName, cornerRadius: 14, iconSize: 28)
                    }
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text(blog.title)
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    Text("\(blog.category) • \(blog.readTimeMinutes) min read")
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)

                    Text(blog.content)
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.text)
                        .lineSpacing(4)
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(text("Blog", "ব্লগ"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .pets,
                action: "Opened pet blog",
                details: blog.id
            )
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

struct PetBlogCardView: View {
    let blog: PetBlog
    var compact: Bool = true

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))

                    AppPlaceholderImageView(assetName: blog.imageAssetName, cornerRadius: 10, iconSize: 20)
                }
                .frame(width: compact ? 92 : 110, height: compact ? 92 : 110)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    Text(blog.title)
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.text)
                        .lineLimit(compact ? 2 : 3)

                    Text(blog.excerpt)
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)
                        .lineLimit(compact ? 2 : 3)

                    Text("\(blog.category) • \(blog.readTimeMinutes) min")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppDesign.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PetBlogListView()
    }
}
