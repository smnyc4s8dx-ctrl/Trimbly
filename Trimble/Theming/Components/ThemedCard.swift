import SwiftUI

/// A card container styled according to the current theme
struct ThemedCard<Content: View>: View {
    @Environment(\.theme) private var theme

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        theme.cardStyle(content)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ThemedCard {
            VStack(alignment: .leading) {
                Text("Classic Theme Card")
                    .font(.headline)
                Text("This card uses shadows and solid background")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .themed(ClassicTheme())
}
