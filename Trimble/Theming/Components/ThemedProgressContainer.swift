import SwiftUI

/// A container for progress indicators styled according to the current theme
struct ThemedProgressContainer<Content: View>: View {
    @Environment(\.theme) private var theme

    let tint: Color
    let content: Content

    init(tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.tint = tint ?? Color.accentColor
        self.content = content()
    }

    var body: some View {
        theme.progressContainerStyle(content, tint: tint)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ThemedProgressContainer(tint: .blue) {
            VStack(spacing: 8) {
                HStack {
                    Text("Processing files...")
                        .font(.caption)
                    Spacer()
                    Text("45 / 120")
                        .font(.caption)
                }

                ProgressView(value: 0.375)
            }
        }

        ThemedProgressContainer(tint: .green) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Analyzing content...")
                    .font(.subheadline)
                Spacer()
            }
        }
    }
    .padding()
    .themed(ClassicTheme())
}
