import SwiftUI

/// An input field container styled according to the current theme
struct ThemedInputField<Content: View>: View {
    @Environment(\.theme) private var theme

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        theme.inputFieldStyle(content)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ThemedInputField {
            Text("/path/to/project")
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        ThemedInputField {
            TextField("Enter path...", text: .constant(""))
        }
    }
    .padding()
    .themed(ClassicTheme())
}
