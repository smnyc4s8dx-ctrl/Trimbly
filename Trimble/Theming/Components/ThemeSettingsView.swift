import SwiftUI

/// A view for selecting and previewing themes
struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Appearance")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            // Theme Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ThemeManager.availableThemes, id: \.id) { availableTheme in
                    ThemePreviewCard(
                        theme: availableTheme,
                        isSelected: themeManager.currentTheme.id == availableTheme.id,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.selectTheme(availableTheme)
                            }
                        }
                    )
                }
            }

            Spacer()

            // Info footer
            Text("Liquid Glass theme requires macOS Tahoe (26.0) or later")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .opacity(ThemeManager.availableThemes.count > 1 ? 0 : 1)
        }
        .padding(24)
        .frame(width: 400, height: 350)
    }
}

/// A preview card for a single theme
struct ThemePreviewCard: View {
    let theme: any TrimbleTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Mini preview
            VStack(spacing: 8) {
                // Fake header bar
                HStack {
                    Circle()
                        .fill(theme.primaryAccent)
                        .frame(width: 8, height: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textSecondary.opacity(0.3))
                        .frame(width: 40, height: 4)
                    Spacer()
                }

                // Fake content cards
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill([theme.primaryAccent, theme.success, theme.warning][i].opacity(0.2))
                            .frame(height: 24)
                    }
                }

                // Fake button
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.primaryAccent)
                    .frame(width: 60, height: 16)
            }
            .padding(12)
            .background(theme.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Theme name
            Text(theme.name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .padding(12)
        .background(isSelected ? theme.primaryAccent.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? theme.primaryAccent : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Compact Theme Picker (for toolbar/header)

/// A compact button that shows the current theme and opens the theme picker
struct ThemePickerButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.theme) private var theme
    @State private var showingThemeSettings = false

    var body: some View {
        Button(action: { showingThemeSettings = true }) {
            HStack(spacing: 4) {
                Image(systemName: "paintbrush")
                    .font(.caption)
                Text(themeManager.currentTheme.name)
                    .font(.caption)
            }
            .foregroundColor(theme.primaryAccent)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingThemeSettings) {
            ThemeSettingsView()
                .themed(themeManager.currentTheme)
                .environmentObject(themeManager)
        }
    }
}

// MARK: - Preview

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager())
        .themed(ClassicTheme())
}
