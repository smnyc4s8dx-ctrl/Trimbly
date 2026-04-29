import SwiftUI

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any TrimbleTheme = ClassicTheme()
}

extension EnvironmentValues {
    /// The current theme for the view hierarchy
    var theme: any TrimbleTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Apply a theme to this view and its descendants
    func themed(_ theme: any TrimbleTheme) -> some View {
        environment(\.theme, theme)
    }
}
