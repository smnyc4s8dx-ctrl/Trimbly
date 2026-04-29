import SwiftUI

/// Classic theme matching Trimbly's original appearance
/// Uses shadows, gradients, and opaque backgrounds
struct ClassicTheme: TrimbleTheme {
    // MARK: - Identity

    let name = "Classic"
    let id = "classic"

    // MARK: - Colors

    var primaryAccent: Color { Color.accentColor }
    var secondaryAccent: Color { Color.blue }
    var background: Color { Color(.windowBackgroundColor) }
    var secondaryBackground: Color { Color(.underPageBackgroundColor) }
    var success: Color { .green }
    var warning: Color { .orange }
    var danger: Color { .red }
    var textPrimary: Color { .primary }
    var textSecondary: Color { .secondary }

    // MARK: - Spacing & Sizing

    var cardPadding: CGFloat { 20 }
    var cardCornerRadius: CGFloat { 16 }
    var sectionSpacing: CGFloat { 24 }
    var elementSpacing: CGFloat { 12 }
    var inputCornerRadius: CGFloat { 8 }

    // MARK: - Component Styling

    func cardStyle<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(cardPadding)
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }

    func inputFieldStyle<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
        )
    }

    func statCardStyle<Content: View>(_ content: Content, tint: Color) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(tint.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
        )
    }

    func alertStyle<Content: View>(_ content: Content, severity: AlertSeverity) -> AnyView {
        let color = severity.color(for: self)
        return AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                }
        )
    }

    func progressContainerStyle<Content: View>(_ content: Content, tint: Color) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(tint.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
                .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Button Styles

    func primaryButtonStyle() -> AnyButtonStyle {
        AnyButtonStyle { configuration in
            AnyView(
                configuration.label
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
        }
    }

    func secondaryButtonStyle() -> AnyButtonStyle {
        AnyButtonStyle { configuration in
            AnyView(
                configuration.label
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
        }
    }

    // MARK: - Window Background

    func windowBackground() -> AnyView {
        AnyView(
            LinearGradient(
                colors: [background, secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
