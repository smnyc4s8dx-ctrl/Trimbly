import SwiftUI

/// An alert/notification box styled according to the current theme
struct ThemedAlert<Content: View>: View {
    @Environment(\.theme) private var theme

    let severity: AlertSeverity
    let content: Content

    init(severity: AlertSeverity = .info, @ViewBuilder content: () -> Content) {
        self.severity = severity
        self.content = content()
    }

    var body: some View {
        theme.alertStyle(content, severity: severity)
    }
}

/// Convenience alert with icon, title, and message
struct ThemedAlertBox: View {
    @Environment(\.theme) private var theme

    let icon: String
    let title: String
    let message: String
    let severity: AlertSeverity

    init(
        icon: String = "exclamationmark.triangle.fill",
        title: String,
        message: String,
        severity: AlertSeverity = .warning
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.severity = severity
    }

    var body: some View {
        ThemedAlert(severity: severity) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(severity.color(for: theme))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(message)
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        ThemedAlertBox(
            title: "May exceed context limits",
            message: "Consider using Maximum compression",
            severity: .warning
        )

        ThemedAlertBox(
            icon: "info.circle.fill",
            title: "Processing complete",
            message: "All files have been compressed",
            severity: .info
        )

        ThemedAlertBox(
            icon: "xmark.circle.fill",
            title: "Error occurred",
            message: "Could not read file",
            severity: .error
        )
    }
    .padding()
    .themed(ClassicTheme())
}
