import SwiftUI
import Foundation
import UIKit

// GUARDRAIL:
// Do not change the established app color theme or typography family in this file during Phase 0.
// Required for MVP stability and demo consistency.
// If a requested change risks these areas, stop and log it in docs/issue_inventory.md.

enum AppDesign {
    static let bg = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let card = Color.white
    static let primary = Color(red: 0.91, green: 0.56, blue: 0.54)
    static let primaryDark = Color(red: 0.85, green: 0.48, blue: 0.46)
    static let text = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let muted = Color(red: 0.52, green: 0.52, blue: 0.54)
    static let line = Color(red: 0.86, green: 0.86, blue: 0.87)
}

struct AppBackground<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AppDesign.bg.ignoresSafeArea()
            content
        }
    }
}

struct AppLogoHeader: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppDesign.primary)
                    .frame(width: 88, height: 88)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(currentLanguage.text(english: "Pet Care", bangla: "পেট কেয়ার"))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .foregroundStyle(AppDesign.primary)
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }
}

struct FilledPrimaryButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(disabled ? AppDesign.primary.opacity(0.5) : AppDesign.primary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct OutlinedPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundStyle(AppDesign.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.clear)
            .overlay {
                Capsule()
                    .stroke(AppDesign.primary, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SocialActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppDesign.text)
            Text(title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppDesign.line, lineWidth: 1)
        }
    }
}

struct AppInputField<Accessory: View>: View {
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var fieldIdentifier: String?
    var accessory: Accessory

    init(title: String, text: Binding<String>, isSecure: Bool = false, fieldIdentifier: String? = nil, @ViewBuilder accessory: () -> Accessory = { EmptyView() }) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
        self.fieldIdentifier = fieldIdentifier
        self.accessory = accessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Group {
                if isSecure {
                    SecureField(placeholderText, text: $text)
                        .modifier(ConditionalAccessibilityIdentifier(identifier: fieldIdentifier))
                } else {
                    TextField(placeholderText, text: $text)
                        .modifier(ConditionalAccessibilityIdentifier(identifier: fieldIdentifier))
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppDesign.line, lineWidth: 1)
            }

            accessory
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private var placeholderText: String {
        currentLanguage.text(english: "Type your \(title.lowercased())", bangla: "আপনার \(title) লিখুন")
    }
}

private struct ConditionalAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier, !identifier.isEmpty {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

enum AppImageLibrary {
    static let onboardingHeroAssetName = "img_cat3"
    static let authHeroAssetName = "img_pet2"
    static let loginHeroAssetName = "img_cat2"
    static let signupHeroAssetName = "img_dog1"
    static let homeBannerAssetName = "img_cat2"
    static let userAvatarAssetName = "img_pet2"

    // Keep this list aligned with Assets.xcassets image set names.
    // Name-based validation is more stable than runtime decoding checks,
    // especially for newer formats like WebP.
    private static let knownImageAssets: Set<String> = [
        "img_black_sand_carbon_bentonite_cat_litter_10l_600x588",
        "img_cat1",
        "img_cat2",
        "img_cat3",
        "img_cuties_catz_dry_cat_food_tuna_flavour_png",
        "img_dog1",
        "img_felix_cat_food_sardine_in_jelly_70g_jpg",
        "img_felix_cat_food_tuna_in_jelly_70g_jpg",
        "img_felix_sensations_cat_food_salmontomato_in_jelly_70g_jpg",
        "img_heaven_bentonite_cat_litter_apple_5l",
        "img_paws_cat_litter_4_5l_jpg",
        "img_pedigree_adult_dog_food_beef_vegetables_3kg_jpg",
        "img_pedigree_adult_roasted_chicken_rice_vegetable_flavor_3kg_jpg",
        "img_pedigree_puppy_dry_food_nutri_defense_chicken_egg_and_milk_flavor_1_3kg_jpg",
        "img_pet_groom1",
        "img_pet_groom2",
        "img_pet_metro_adult_cat_food_tuna_and_chicken_recipe_1kg",
        "img_pet_vet1",
        "img_pet_vet2",
        "img_pet2",
        "img_prama_delicacy_snack_dog_treats_maguro_50gm",
        "img_prama_delicacy_snack_dog_treats_milk_70gm_600x600",
        "img_prostar_cat_food_adult_chicken_600x600_jpg",
        "img_reflex_plus_anti_hairball_cat_food_with_salmon_1_5kg",
        "img_wanpy_dog_pouch_tasty_meat_paste_lamb_carrot_and_pea_90gm_png",
        "img_wanpy_dog_wet_food_can_beef_375gm_600x600",
        "img_whiskas_pouch_tasty_mix_gravy_tuna_kanikama_carrots_cat_food_70gm"
    ]

    static func serviceImageAssetName(for title: String) -> String {
        let key = title.lowercased()

        if key.contains("bath") || key.contains("dry") || key.contains("hair") || key.contains("trim") || key.contains("groom") {
            return "img_pet_groom1"
        }

        if key.contains("checkup") || key.contains("vet") {
            return "img_pet_vet1"
        }

        if key.contains("profile") || key.contains("pet") {
            return "img_cat1"
        }

        return fallbackAssetName(for: key)
    }

    static func groomingServiceImageAssetName(for serviceType: String) -> String {
        let key = serviceType.lowercased()
        if key.contains("bath") {
            return "img_pet_groom2"
        }
        return "img_pet_groom1"
    }

    static func vetImageAssetName() -> String {
        "img_pet_vet2"
    }

    static func petImageAssetName(forBreed breed: String) -> String {
        let key = breed.lowercased()

        if key.contains("dog") || key.contains("puppy") || key.contains("canine") || key.contains("কুকুর") {
            return "img_dog1"
        }

        if key.contains("rabbit") || key.contains("bunny") || key.contains("খরগোশ") {
            return "img_pet2"
        }

        if key.contains("cat") || key.contains("kitten") || key.contains("feline") || key.contains("বিড়াল") {
            return "img_cat1"
        }

        return "img_pet2"
    }

    static func productImageAssetName(for product: Product) -> String {
        if let resolved = resolveExistingAssetName(from: product.imageURL) {
            return resolved
        }

        let key = "\(product.name) \(product.category)".lowercased()

        if key.contains("dog") {
            return hashedAssetName(for: key, fallbacks: [
                "img_dog1",
                "img_pedigree_adult_dog_food_beef_vegetables_3kg_jpg",
                "img_pedigree_adult_roasted_chicken_rice_vegetable_flavor_3kg_jpg",
                "img_wanpy_dog_wet_food_can_beef_375gm_600x600",
                "img_wanpy_dog_pouch_tasty_meat_paste_lamb_carrot_and_pea_90gm_png"
            ])
        }

        if key.contains("cat") {
            return hashedAssetName(for: key, fallbacks: [
                "img_cat1",
                "img_cat2",
                "img_cat3",
                "img_felix_cat_food_tuna_in_jelly_70g_jpg",
                "img_whiskas_pouch_tasty_mix_gravy_tuna_kanikama_carrots_cat_food_70gm"
            ])
        }

        return fallbackAssetName(for: key)
    }

    private static func fallbackAssetName(for key: String) -> String {
        let fallbacks = [
            "img_cat1",
            "img_dog1",
            "img_pet2",
            "img_cat2",
            "img_pet_groom1",
            "img_pet_vet1"
        ]
        return hashedAssetName(for: key, fallbacks: fallbacks)
    }

    static func resolveExistingAssetName(from rawKey: String?) -> String? {
        guard let rawKey else {
            return nil
        }

        let trimmed = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        let noImageSet = trimmed.replacingOccurrences(of: ".imageset", with: "")
        let noExt = removeKnownImageExtension(from: noImageSet)

        var candidates: [String] = [trimmed, noImageSet, noExt]
        if !noExt.hasPrefix("img_") {
            candidates.append("img_\(noExt)")
        }

        for candidate in candidates {
            if hasImageAsset(named: candidate) {
                return candidate
            }
        }

        return nil
    }

    static func hasImageAsset(named name: String) -> Bool {
        knownImageAssets.contains(name)
    }

    private static func removeKnownImageExtension(from value: String) -> String {
        let lower = value.lowercased()
        let extensions = [".png", ".jpg", ".jpeg", ".webp"]

        for ext in extensions where lower.hasSuffix(ext) {
            return String(value.dropLast(ext.count))
        }

        return value
    }

    private static func hashedAssetName(for key: String, fallbacks: [String]) -> String {
        let checksum = key.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return fallbacks[checksum % fallbacks.count]
    }

    static func profileImage(fromBase64 base64: String?) -> UIImage? {
        guard let base64,
              let data = Data(base64Encoded: base64),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

enum AppLanguage: String, CaseIterable {
    case englishUS = "en-US"
    case bangla = "bn-BD"

    static let storageKey = "appLanguageCode"

    var displayTitle: String {
        displayTitle(in: .englishUS)
    }

    func displayTitle(in language: AppLanguage) -> String {
        switch self {
        case .englishUS:
            return language.text(english: "English (US)", bangla: "ইংরেজি (ইউএস)")
        case .bangla:
            return language.text(english: "Bangla", bangla: "বাংলা")
        }
    }

    var takaSymbol: String {
        "৳"
    }

    func formatMoney(_ value: Double) -> String {
        String(format: "\(takaSymbol)%.2f", value)
    }

    func formatMoney(prefixEnglish: String, prefixBangla: String, value: Double) -> String {
        "\(text(english: prefixEnglish, bangla: prefixBangla)) \(formatMoney(value))"
    }

    func text(english: String, bangla: String) -> String {
        switch self {
        case .englishUS:
            return english
        case .bangla:
            return bangla
        }
    }

    static func from(code: String) -> AppLanguage {
        AppLanguage(rawValue: code) ?? .englishUS
    }
}
