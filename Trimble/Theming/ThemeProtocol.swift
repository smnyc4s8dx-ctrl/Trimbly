import SwiftUI

/// Protocol defining what every Trimbly theme must provide
/// Themes are interchangeable UI skins that don't affect core functionality
protocol TrimbleTheme {
    // MARK: - Identity

    /// Human-readable theme name
    var name: String { get }

    /// Unique identifier for persistence
    var id: String { get }

    // MARK: - Colors

    var primaryAccent: Color { get }
    var secondaryAccent: Color { get }
    var background: Color { get }
    var secondaryBackground: Color { get }
    var success: Color { get }
    var warning: Color { get }
    var danger: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }

    // MARK: - Spacing & Sizing

    var cardPadding: CGFloat { get }
    var cardCornerRadius: CGFloat { get }
    var sectionSpacing: CGFloat { get }
    var elementSpacing: CGFloat { get }
    var inputCornerRadius: CGFloat { get }

    // MARK: - Component Styling

    /// Apply card styling to content
    func cardStyle<Content: View>(_ content: Content) -> AnyView

    /// Apply input field styling to content
    func inputFieldStyle<Content: View>(_ content: Content) -> AnyView

    /// Apply stat card styling with tint color
    func statCardStyle<Content: View>(_ content: Content, tint: Color) -> AnyView

    /// Apply alert/warning box styling
    func alertStyle<Content: View>(_ content: Content, severity: AlertSeverity) -> AnyView

    /// Apply progress container styling
    func progressContainerStyle<Content: View>(_ content: Content, tint: Color) -> AnyView

    // MARK: - Button Styles

    func primaryButtonStyle() -> AnyButtonStyle
    func secondaryButtonStyle() -> AnyButtonStyle

    // MARK: - Window Background

    func windowBackground() -> AnyView
}

// MARK: - Alert Severity

enum AlertSeverity {
    case info
    case warning
    case error

    func color(for theme: any TrimbleTheme) -> Color {
        switch self {
        case .info: return theme.primaryAccent
        case .warning: return theme.warning
        case .error: return theme.danger
        }
    }
}

// MARK: - Default Implementations

extension TrimbleTheme {
    var inputCornerRadius: CGFloat { 8 }

    func alertStyle<Content: View>(_ content: Content, severity: AlertSeverity) -> AnyView {
        let color = severity.color(for: self)
        return AnyView(
            content
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
        )
    }

    func progressContainerStyle<Content: View>(_ content: Content, tint: Color) -> AnyView {
        AnyView(
            content
                .padding(12)
                .background(tint.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
        )
    }
}

// MARK: - Type-Erased Button Style

/// Type-erased button style for protocol requirements
struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init(_ makeBody: @escaping (Configuration) -> AnyView) {
        _makeBody = makeBody
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - Standard Button Styles

/// Primary button style (prominent)
struct PrimaryButtonStyleWrapper: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

/// Secondary button style (bordered)
struct SecondaryButtonStyleWrapper: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
