import SwiftUI

struct PetBlog: Identifiable {
    let id: String
    let title: String
    let titleBangla: String
    let category: String
    let categoryBangla: String
    let readTimeMinutes: Int
    let excerpt: String
    let excerptBangla: String
    let content: String
    let contentBangla: String
    let imageAssetName: String
}

enum PetBlogRepository {
    static let all: [PetBlog] = [
        PetBlog(
            id: "blog_pet_food_transition",
            title: "How to Switch Your Pet to a New Food Safely",
            titleBangla: "পোষা প্রাণীকে নতুন খাবারে নিরাপদে কীভাবে অভ্যস্ত করবেন",
            category: "Nutrition",
            categoryBangla: "পুষ্টি",
            readTimeMinutes: 4,
            excerpt: "Use a 7-day transition so your pet avoids tummy issues and keeps appetite stable.",
            excerptBangla: "৭ দিনের ধাপে খাবার বদলালে পেটের সমস্যা কমে এবং ক্ষুধা স্থিতিশীল থাকে।",
            content: "Start by mixing 75% old food with 25% new food for two days. Then move to 50/50 for two days, and 25/75 for two days. On day seven, feed 100% new food. Keep fresh water available and watch stool consistency and appetite. If your pet shows vomiting or loose stool, slow the transition and consult your vet.",
            contentBangla: "প্রথম দুই দিন ৭৫% পুরোনো খাবারের সাথে ২৫% নতুন খাবার মিশিয়ে দিন। পরের দুই দিন ৫০/৫০ করুন, তারপর দুই দিন ২৫/৭৫ দিন। সপ্তম দিনে ১০০% নতুন খাবার দিন। সব সময় পরিষ্কার পানি দিন এবং পায়খানার অবস্থা ও ক্ষুধা লক্ষ্য করুন। বমি বা পাতলা পায়খানা হলে পরিবর্তনের গতি কমান এবং ভেটের সঙ্গে কথা বলুন।",
            imageAssetName: "img_pet_metro_adult_cat_food_tuna_and_chicken_recipe_1kg"
        ),
        PetBlog(
            id: "blog_pet_grooming_home",
            title: "At-Home Grooming Routine for Happier Pets",
            titleBangla: "ঘরে বসে গ্রুমিং রুটিনে পোষা প্রাণীকে রাখুন আরও স্বস্তিতে",
            category: "Grooming",
            categoryBangla: "গ্রুমিং",
            readTimeMinutes: 3,
            excerpt: "A simple weekly routine keeps coat, skin, and nails healthy between appointments.",
            excerptBangla: "সাপ্তাহিক সহজ রুটিনে অ্যাপয়েন্টমেন্টের মাঝেও লোম, ত্বক ও নখ ভালো থাকে।",
            content: "Brush your pet 3-4 times a week to reduce shedding and matting. Clean paws after outdoor walks and check ears for redness or odor. Trim nails every 2-4 weeks depending on growth. Use a gentle pet-safe shampoo during baths. Always reward your pet with treats after grooming to build a positive routine.",
            contentBangla: "সপ্তাহে ৩-৪ দিন ব্রাশ করলে ঝরে পড়া লোম ও জট কমে। বাইরে ঘোরার পর পা পরিষ্কার করুন এবং কানে লালচে ভাব বা গন্ধ আছে কি না দেখুন। নখের বৃদ্ধির ওপর নির্ভর করে ২-৪ সপ্তাহ পরপর নখ ট্রিম করুন। গোসলের সময় পেট-সেইফ মৃদু শ্যাম্পু ব্যবহার করুন। গ্রুমিং শেষে ট্রিট দিলে ভালো অভ্যাস তৈরি হয়।",
            imageAssetName: "img_pet_groom2"
        ),
        PetBlog(
            id: "blog_pet_warning_signs",
            title: "5 Early Health Warning Signs Pet Parents Should Not Ignore",
            titleBangla: "পোষা প্রাণীর ৫টি প্রাথমিক সতর্কসংকেত যা উপেক্ষা করা ঠিক নয়",
            category: "Health",
            categoryBangla: "স্বাস্থ্য",
            readTimeMinutes: 5,
            excerpt: "Spotting behavior and appetite changes early can prevent bigger health problems.",
            excerptBangla: "আচরণ ও ক্ষুধার পরিবর্তন আগে বুঝতে পারলে বড় স্বাস্থ্যঝুঁকি এড়ানো যায়।",
            content: "Watch for sudden loss of appetite, unusual tiredness, frequent scratching, coughing, or changes in bathroom habits. These signs can point to allergies, infections, or digestive issues. Keep a short daily note of symptoms and timeline. If signs continue for more than 24-48 hours, book a vet checkup quickly.",
            contentBangla: "হঠাৎ ক্ষুধা কমে যাওয়া, অস্বাভাবিক ক্লান্তি, ঘন ঘন চুলকানো, কাশি বা টয়লেটের অভ্যাসে পরিবর্তন দেখলে সতর্ক হোন। এগুলো অ্যালার্জি, সংক্রমণ বা হজমজনিত সমস্যার লক্ষণ হতে পারে। প্রতিদিন সংক্ষিপ্তভাবে লক্ষণ লিখে রাখুন। ২৪-৪৮ ঘণ্টার বেশি সমস্যা থাকলে দ্রুত ভেট চেকআপ নিন।",
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

                    Text(currentLanguage == .bangla ? blog.titleBangla : blog.title)
                        .font(TextStyles.title)
                        .foregroundStyle(AppDesign.text)

                    Text(readMetaText)
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)

                    Text(currentLanguage == .bangla ? blog.contentBangla : blog.content)
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

    private var readMetaText: String {
        if currentLanguage == .bangla {
            return "\(blog.categoryBangla) • \(blog.readTimeMinutes) মিনিট পড়া"
        }
        return "\(blog.category) • \(blog.readTimeMinutes) min read"
    }
}

struct PetBlogCardView: View {
    let blog: PetBlog
    var compact: Bool = true
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

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
                    Text(currentLanguage == .bangla ? blog.titleBangla : blog.title)
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.text)
                        .lineLimit(compact ? 2 : 3)

                    Text(currentLanguage == .bangla ? blog.excerptBangla : blog.excerpt)
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)
                        .lineLimit(compact ? 2 : 3)

                    Text(metaText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppDesign.primary)
                }
            }
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private var metaText: String {
        if currentLanguage == .bangla {
            return "\(blog.categoryBangla) • \(blog.readTimeMinutes) মিনিট"
        }
        return "\(blog.category) • \(blog.readTimeMinutes) min"
    }
}

#Preview {
    NavigationStack {
        PetBlogListView()
    }
}
