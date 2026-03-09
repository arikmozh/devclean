import SwiftUI

struct KnownService: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let category: SubCategory
    let defaultPrice: Decimal
    let defaultCycle: BillingCycle

    var color: Color { Color(hex: colorHex) }
}

extension KnownService {
    static let all: [KnownService] = [
        // Streaming
        KnownService(name: "Netflix", icon: "play.tv", colorHex: "E50914", category: .streaming, defaultPrice: 15.49, defaultCycle: .monthly),
        KnownService(name: "Disney+", icon: "sparkles.tv", colorHex: "113CCF", category: .streaming, defaultPrice: 7.99, defaultCycle: .monthly),
        KnownService(name: "HBO Max", icon: "play.rectangle", colorHex: "5822B4", category: .streaming, defaultPrice: 15.99, defaultCycle: .monthly),
        KnownService(name: "Hulu", icon: "play.display", colorHex: "1CE783", category: .streaming, defaultPrice: 7.99, defaultCycle: .monthly),
        KnownService(name: "Amazon Prime", icon: "shippingbox", colorHex: "00A8E1", category: .streaming, defaultPrice: 14.99, defaultCycle: .monthly),
        KnownService(name: "Apple TV+", icon: "appletv", colorHex: "2D2D2D", category: .streaming, defaultPrice: 9.99, defaultCycle: .monthly),
        KnownService(name: "Crunchyroll", icon: "play.circle", colorHex: "F47521", category: .streaming, defaultPrice: 7.99, defaultCycle: .monthly),
        KnownService(name: "YouTube Premium", icon: "play.rectangle.fill", colorHex: "FF0000", category: .streaming, defaultPrice: 13.99, defaultCycle: .monthly),

        // Music
        KnownService(name: "Spotify", icon: "music.note", colorHex: "1DB954", category: .music, defaultPrice: 10.99, defaultCycle: .monthly),
        KnownService(name: "Apple Music", icon: "music.quarternote.3", colorHex: "FA2D48", category: .music, defaultPrice: 10.99, defaultCycle: .monthly),
        KnownService(name: "Audible", icon: "headphones", colorHex: "F8991C", category: .music, defaultPrice: 14.95, defaultCycle: .monthly),

        // Productivity
        KnownService(name: "Microsoft 365", icon: "m.square", colorHex: "D83B01", category: .productivity, defaultPrice: 6.99, defaultCycle: .monthly),
        KnownService(name: "Notion", icon: "doc.text", colorHex: "2D2D2D", category: .productivity, defaultPrice: 8.00, defaultCycle: .monthly),
        KnownService(name: "Todoist", icon: "checklist", colorHex: "E44332", category: .productivity, defaultPrice: 4.00, defaultCycle: .monthly),
        KnownService(name: "Figma", icon: "pencil.and.ruler", colorHex: "A259FF", category: .productivity, defaultPrice: 12.00, defaultCycle: .monthly),
        KnownService(name: "Slack", icon: "number", colorHex: "4A154B", category: .productivity, defaultPrice: 8.75, defaultCycle: .monthly),
        KnownService(name: "Zoom", icon: "video", colorHex: "2D8CFF", category: .productivity, defaultPrice: 13.33, defaultCycle: .monthly),
        KnownService(name: "1Password", icon: "key", colorHex: "0572EC", category: .productivity, defaultPrice: 2.99, defaultCycle: .monthly),
        KnownService(name: "Linear", icon: "line.3.horizontal", colorHex: "5E6AD2", category: .productivity, defaultPrice: 8.00, defaultCycle: .monthly),

        // Cloud
        KnownService(name: "iCloud+", icon: "icloud", colorHex: "3693F3", category: .cloud, defaultPrice: 2.99, defaultCycle: .monthly),
        KnownService(name: "Google One", icon: "g.circle", colorHex: "4285F4", category: .cloud, defaultPrice: 2.99, defaultCycle: .monthly),
        KnownService(name: "Dropbox", icon: "shippingbox", colorHex: "0061FF", category: .cloud, defaultPrice: 11.99, defaultCycle: .monthly),

        // AI
        KnownService(name: "ChatGPT Plus", icon: "brain.head.profile", colorHex: "10A37F", category: .ai, defaultPrice: 20.00, defaultCycle: .monthly),
        KnownService(name: "Claude Pro", icon: "brain", colorHex: "D4A574", category: .ai, defaultPrice: 20.00, defaultCycle: .monthly),
        KnownService(name: "GitHub Copilot", icon: "chevron.left.forwardslash.chevron.right", colorHex: "2B3137", category: .ai, defaultPrice: 10.00, defaultCycle: .monthly),
        KnownService(name: "Midjourney", icon: "paintbrush", colorHex: "2D2D2D", category: .ai, defaultPrice: 10.00, defaultCycle: .monthly),

        // Gaming
        KnownService(name: "PlayStation Plus", icon: "gamecontroller", colorHex: "003087", category: .gaming, defaultPrice: 59.99, defaultCycle: .yearly),
        KnownService(name: "Xbox Game Pass", icon: "gamecontroller.fill", colorHex: "107C10", category: .gaming, defaultPrice: 14.99, defaultCycle: .monthly),
        KnownService(name: "Nintendo Switch Online", icon: "logo.nintendo.switch", colorHex: "E60012", category: .gaming, defaultPrice: 3.99, defaultCycle: .monthly),
        KnownService(name: "Apple Arcade", icon: "arcade.stick", colorHex: "007AFF", category: .gaming, defaultPrice: 6.99, defaultCycle: .monthly),

        // Health & Fitness
        KnownService(name: "Headspace", icon: "brain.filled.head.profile", colorHex: "F47D31", category: .health, defaultPrice: 12.99, defaultCycle: .monthly),
        KnownService(name: "Calm", icon: "leaf", colorHex: "5AACBC", category: .health, defaultPrice: 14.99, defaultCycle: .monthly),
        KnownService(name: "Strava", icon: "figure.run", colorHex: "FC4C02", category: .fitness, defaultPrice: 7.99, defaultCycle: .monthly),
        KnownService(name: "Apple Fitness+", icon: "figure.cooldown", colorHex: "65DC65", category: .fitness, defaultPrice: 9.99, defaultCycle: .monthly),

        // VPN
        KnownService(name: "NordVPN", icon: "lock.shield", colorHex: "4687FF", category: .vpn, defaultPrice: 12.99, defaultCycle: .monthly),
        KnownService(name: "ExpressVPN", icon: "shield.checkered", colorHex: "DA3940", category: .vpn, defaultPrice: 12.95, defaultCycle: .monthly),

        // Education
        KnownService(name: "Duolingo", icon: "character.book.closed", colorHex: "58CC02", category: .education, defaultPrice: 6.99, defaultCycle: .monthly),
        KnownService(name: "Skillshare", icon: "paintpalette", colorHex: "00FF84", category: .education, defaultPrice: 13.99, defaultCycle: .monthly),

        // News & Reading
        KnownService(name: "Medium", icon: "text.book.closed", colorHex: "2D2D2D", category: .news, defaultPrice: 5.00, defaultCycle: .monthly),
        KnownService(name: "Substack", icon: "envelope.open", colorHex: "FF6719", category: .news, defaultPrice: 5.00, defaultCycle: .monthly),
        KnownService(name: "LinkedIn Premium", icon: "person.crop.rectangle", colorHex: "0A66C2", category: .social, defaultPrice: 29.99, defaultCycle: .monthly),

        // Finance
        KnownService(name: "Patreon", icon: "heart.circle", colorHex: "FF424D", category: .finance, defaultPrice: 5.00, defaultCycle: .monthly),
    ]

    static func find(_ name: String) -> KnownService? {
        all.first { $0.name.lowercased() == name.lowercased() }
    }

    static func search(_ query: String) -> [KnownService] {
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
