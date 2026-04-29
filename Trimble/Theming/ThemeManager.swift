import SwiftUI

/// Manages theme selection and persistence across the app
@MainActor
final class ThemeManager: ObservableObject {
    /// Currently active theme
    @Published var currentTheme: any TrimbleTheme

    /// Persisted theme selection
    @AppStorage("selectedThemeId") private var selectedThemeId: String = "classic"

    /// All available themes based on OS version
    static var availableThemes: [any TrimbleTheme] {
        var themes: [any TrimbleTheme] = [ClassicTheme()]

        // Liquid Glass requires macOS 26 (Tahoe)
        if #available(macOS 26.0, *) {
            themes.append(LiquidGlassTheme())
        }

        return themes
    }

    init() {
        // Load saved theme or default to Classic
        // Capture selectedThemeId value before closure to avoid initialization issues
        let savedId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? "classic"
        let savedTheme = Self.availableThemes.first { $0.id == savedId }
        currentTheme = savedTheme ?? ClassicTheme()
    }

    /// Select a new theme
    func selectTheme(_ theme: any TrimbleTheme) {
        currentTheme = theme
        selectedThemeId = theme.id
    }

    /// Select theme by ID
    func selectTheme(byId id: String) {
        if let theme = Self.availableThemes.first(where: { $0.id == id }) {
            selectTheme(theme)
        }
    }

    /// Check if a specific theme is available on this system
    func isThemeAvailable(_ themeId: String) -> Bool {
        Self.availableThemes.contains { $0.id == themeId }
    }
}
