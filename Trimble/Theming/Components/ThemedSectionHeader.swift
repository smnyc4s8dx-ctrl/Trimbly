import SwiftUI

/// A section header with icon, title, and optional help button
/// Styled according to the current theme
struct ThemedSectionHeader: View {
    @Environment(\.theme) private var theme

    let title: String
    let icon: String
    var tint: Color? = nil
    var helpAction: (() -> Void)? = nil

    private var effectiveTint: Color {
        tint ?? theme.primaryAccent
    }

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(effectiveTint)

            Spacer()

            if let helpAction {
                Button(action: helpAction) {
                    Image(systemName: "info.circle")
                        .foregroundColor(effectiveTint)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ThemedSectionHeader(
            title: "Source Selection",
            icon: "folder.badge.plus",
            helpAction: { print("Help tapped") }
        )

        ThemedSectionHeader(
            title: "No Help Button",
            icon: "gearshape"
        )
    }
    .padding()
    .themed(ClassicTheme())
}
