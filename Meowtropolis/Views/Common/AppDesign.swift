import SwiftUI
import Foundation
import UIKit

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
    static let onboardingHeroURL = URL(string: "https://loremflickr.com/1200/800/pets,home")
    static let authHeroURL = URL(string: "https://loremflickr.com/1000/600/cat,dog")
    static let adoptionBannerURL = URL(string: "https://loremflickr.com/1200/500/adopt,pet")
    static let userAvatarURL = URL(string: "https://loremflickr.com/300/300/pet,owner")

    static func serviceImageURL(for title: String) -> URL? {
        let key = title.lowercased()

        if key.contains("bath") || key.contains("dry") || key.contains("বাথ") || key.contains("ড্রাই") {
            return URL(string: "https://loremflickr.com/800/500/dog,bath")
        }

        if key.contains("hair") || key.contains("trim") || key.contains("groom") || key.contains("হেয়ার") || key.contains("ট্রিম") || key.contains("গ্রুম") {
            return URL(string: "https://loremflickr.com/800/500/pet,grooming")
        }

        if key.contains("checkup") || key.contains("vet") || key.contains("চেকআপ") || key.contains("ভেট") {
            return URL(string: "https://loremflickr.com/800/500/veterinary,pet")
        }

        if key.contains("profile") || key.contains("pet") || key.contains("প্রোফাইল") || key.contains("পেট") {
            return URL(string: "https://loremflickr.com/800/500/cat,dog,rabbit")
        }

        return URL(string: "https://loremflickr.com/800/500/pet,care")
    }

    static func groomingServiceImageURL(for serviceType: String) -> URL? {
        serviceImageURL(for: serviceType)
    }

    static func petImageURL(forBreed breed: String) -> URL? {
        let key = breed.lowercased()

        if key.contains("cat") || key.contains("kitten") || key.contains("feline") || key.contains("বিড়াল") {
            return URL(string: "https://loremflickr.com/700/500/cat,pet")
        }

        if key.contains("dog") || key.contains("puppy") || key.contains("canine") || key.contains("কুকুর") {
            return URL(string: "https://loremflickr.com/700/500/dog,pet")
        }

        if key.contains("rabbit") || key.contains("bunny") || key.contains("খরগোশ") {
            return URL(string: "https://loremflickr.com/700/500/rabbit,pet")
        }

        if key.contains("bird") || key.contains("parrot") || key.contains("পাখি") {
            return URL(string: "https://loremflickr.com/700/500/bird,pet")
        }

        if key.contains("fish") || key.contains("মাছ") {
            return URL(string: "https://loremflickr.com/700/500/fish,aquarium")
        }

        if key.contains("hamster") || key.contains("guinea") || key.contains("হ্যামস্টার") {
            return URL(string: "https://loremflickr.com/700/500/hamster,pet")
        }

        if key.contains("turtle") || key.contains("reptile") || key.contains("lizard") || key.contains("snake") {
            return URL(string: "https://loremflickr.com/700/500/reptile,pet")
        }

        return URL(string: "https://loremflickr.com/700/500/pets,animal")
    }

    static func productImageURL(for product: Product) -> URL? {
        let rawURL = product.imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rawURL.isEmpty, !rawURL.contains("images.meowtropolis.app"), let url = URL(string: rawURL) {
            return url
        }

        let key = "\(product.name) \(product.category)".lowercased()

        if key.contains("food") || key.contains("salmon") || key.contains("treat") {
            return URL(string: "https://loremflickr.com/800/600/pet,food")
        }

        if key.contains("toy") || key.contains("teaser") {
            return URL(string: "https://loremflickr.com/800/600/pet,toy")
        }

        if key.contains("harness") || key.contains("accessor") || key.contains("collar") {
            return URL(string: "https://loremflickr.com/800/600/pet,accessory")
        }

        if key.contains("groom") || key.contains("shampoo") {
            return URL(string: "https://loremflickr.com/800/600/pet,grooming")
        }

        return URL(string: "https://loremflickr.com/800/600/pet,products")
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
        switch self {
        case .englishUS:
            return "English (US)"
        case .bangla:
            return "Bangla"
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
