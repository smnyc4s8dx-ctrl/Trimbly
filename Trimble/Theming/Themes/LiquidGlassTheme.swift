import SwiftUI

/// Liquid Glass theme for macOS Tahoe (26.0+)
/// Design philosophy: Floating translucent panels, soft colors, depth through subtle shadows
/// Creates an airy, modern aesthetic distinct from the Classic theme
@available(macOS 26.0, *)
struct LiquidGlassTheme: TrimbleTheme {
    // MARK: - Identity

    let name = "Liquid Glass"
    let id = "liquid_glass"

    // MARK: - Colors
    // Softer, desaturated palette that works with translucency

    var primaryAccent: Color { Color.accentColor }
    var secondaryAccent: Color { Color(red: 0.4, green: 0.6, blue: 0.9) } // Soft blue
    var background: Color { Color(.windowBackgroundColor) }
    var secondaryBackground: Color { Color.white.opacity(0.05) }
    var success: Color { Color(red: 0.3, green: 0.75, blue: 0.5) } // Soft mint green
    var warning: Color { Color(red: 0.95, green: 0.75, blue: 0.35) } // Soft amber
    var danger: Color { Color(red: 0.9, green: 0.4, blue: 0.4) } // Soft coral
    var textPrimary: Color { .primary }
    var textSecondary: Color { .secondary }

    // MARK: - Spacing & Sizing
    // More generous spacing for an airy feel

    var cardPadding: CGFloat { 24 }
    var cardCornerRadius: CGFloat { 20 }
    var sectionSpacing: CGFloat { 24 }
    var elementSpacing: CGFloat { 14 }
    var inputCornerRadius: CGFloat { 12 }

    // MARK: - Component Styling

    /// Floating glass card with subtle shadow for depth
    func cardStyle<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(cardPadding)
                .background {
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                }
        )
    }

    /// Input field with glass inset effect
    func inputFieldStyle<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .fill(.black.opacity(0.05))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
        )
    }

    /// Stat card with subtle glass background and colored accent border
    /// The value text carries the color, not the entire background
    func statCardStyle<Content: View>(_ content: Content, tint: Color) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [tint.opacity(0.6), tint.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
        )
    }

    /// Alert with subtle tinted border and icon area, not harsh background
    func alertStyle<Content: View>(_ content: Content, severity: AlertSeverity) -> AnyView {
        let color = severity.color(for: self)
        return AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .strokeBorder(color.opacity(0.5), lineWidth: 1.5)
                }
        )
    }

    /// Progress container with subtle tinted glass
    func progressContainerStyle<Content: View>(_ content: Content, tint: Color) -> AnyView {
        AnyView(
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: inputCornerRadius)
                        .strokeBorder(tint.opacity(0.3), lineWidth: 1)
                }
        )
    }

    // MARK: - Button Styles

    /// Primary button - pill-shaped with accent color
    func primaryButtonStyle() -> AnyButtonStyle {
        AnyButtonStyle { configuration in
            AnyView(
                configuration.label
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            )
        }
    }

    /// Secondary button - glass pill with subtle border
    func secondaryButtonStyle() -> AnyButtonStyle {
        AnyButtonStyle { configuration in
            AnyView(
                configuration.label
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    }
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            )
        }
    }

    // MARK: - Window Background

    /// Subtle gradient background that works with glass panels
    func windowBackground() -> AnyView {
        AnyView(
            ZStack {
                Color(.windowBackgroundColor)
                // Subtle gradient overlay for depth
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.03),
                        Color.clear,
                        Color.black.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }
}

// MARK: - Preview

@available(macOS 26.0, *)
#Preview("Liquid Glass Theme") {
    VStack(spacing: 20) {
        Text("Liquid Glass Theme Preview")
            .font(.title)
            .fontWeight(.bold)

        // Simulated stat cards
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Output Size")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("96,760")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.3, green: 0.6, blue: 0.9))
                Text("tokens")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1.5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Reduction")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("59%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.3, green: 0.75, blue: 0.5))
                Text("smaller")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.green.opacity(0.4), lineWidth: 1.5)
            }
        }

        HStack(spacing: 12) {
            Button("Primary Action") { }
                .buttonStyle(LiquidGlassTheme().primaryButtonStyle())

            Button("Secondary") { }
                .buttonStyle(LiquidGlassTheme().secondaryButtonStyle())
        }
    }
    .padding(30)
    .frame(width: 500)
    .background(Color(.windowBackgroundColor))
}
