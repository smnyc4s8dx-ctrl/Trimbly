import SwiftUI

/// A statistics card with title, value, subtitle, and tint color
/// Styled according to the current theme
struct ThemedStatCard: View {
    @Environment(\.theme) private var theme

    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
                .fontWeight(.medium)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        return theme.statCardStyle(content, tint: color)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        ThemedStatCard(
            title: "Output Size",
            value: "45,230",
            subtitle: "tokens",
            color: .blue
        )

        ThemedStatCard(
            title: "Reduction",
            value: "67%",
            subtitle: "smaller",
            color: .green
        )

        ThemedStatCard(
            title: "Accuracy",
            value: "95%",
            subtitle: "preserved",
            color: .orange
        )
    }
    .padding()
    .themed(ClassicTheme())
}
