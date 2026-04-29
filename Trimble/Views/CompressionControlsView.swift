import SwiftUI

struct CompressionControlsView: View {
    @Environment(\.theme) private var theme

    struct SemanticLevelSelector: View {
        @Environment(\.theme) private var theme
        @Binding var compressionOptions: CompressionOptions
        @Binding var viewMode: ViewMode
        @Binding var includeHierarchicalSummary: Bool
        @Binding var includeKnowledgeMapping: Bool
        @Binding var includeQaMetadata: Bool
        let onHelpRequested: (String) -> Void
        let fileTreeManager: FileTreeManager

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Semantic Compression Level")
                        .font(.headline)
                        .foregroundColor(theme.primaryAccent)
                    Spacer()
                    Button(action: { onHelpRequested("semanticLevels") }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(theme.primaryAccent)
                    }
                    .buttonStyle(.plain)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(180)), count: 4), spacing: 8) {
                    ForEach(SemanticCompressionLevel.allCases, id: \.self) { level in
                        SemanticLevelCard(
                            level: level,
                            isSelected: compressionOptions.semanticLevel == level,
                            onSelect: {
                                compressionOptions.semanticLevel = level
                                compressionOptions.applySemanticLevel()

                                switch level {
                                case .light, .medium:
                                    includeHierarchicalSummary = true
                                    includeKnowledgeMapping = false
                                    includeQaMetadata = false
                                case .aggressive:
                                    includeHierarchicalSummary = true
                                    includeKnowledgeMapping = true
                                    includeQaMetadata = false
                                    viewMode = .advanced
                                    fileTreeManager.deselectAllFiles()
                                case .maximum:
                                    includeHierarchicalSummary = true
                                    includeKnowledgeMapping = true
                                    includeQaMetadata = true
                                    viewMode = .advanced
                                    fileTreeManager.deselectAllFiles()
                                }

                                fileTreeManager.applyCompressionPreset(level)
                            }
                        )
                    }
                }

                if let currentLevel = SemanticCompressionLevel.allCases.first(where: { $0 == compressionOptions.semanticLevel }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Token Reduction: \(currentLevel.tokenReduction)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Semantic Loss: \(currentLevel.semanticLoss)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Smart Auto-Exclusion")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Toggle("", isOn: $compressionOptions.smartAutoExclusion)
                                .toggleStyle(.switch)
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(12)
                    .background(currentLevel.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
                }
            }
        }
    }

    struct SemanticLevelCard: View {
        @Environment(\.theme) private var theme
        let level: SemanticCompressionLevel
        let isSelected: Bool
        let onSelect: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundColor(level.color)

                Text(level.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(level.color)

                Text(level.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(12)
            .background(isSelected ? level.color.opacity(0.2) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: theme.inputCornerRadius)
                    .stroke(isSelected ? level.color : theme.textSecondary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
        }
    }

    @Binding var viewMode: ViewMode
    @Binding var compressionOptions: CompressionOptions
    @Binding var includeHierarchicalSummary: Bool
    @Binding var includeKnowledgeMapping: Bool
    @Binding var includeQaMetadata: Bool
    @ObservedObject var fileTreeManager: FileTreeManager
    let selectedPath: String
    let onHelpRequested: (String) -> Void

    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ThemedSectionHeader(
                        title: "Semantic Compression Controls",
                        icon: "brain.head.profile"
                    )
                    Spacer()
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 400)
                }

                SemanticLevelSelector(
                    compressionOptions: $compressionOptions,
                    viewMode: $viewMode,
                    includeHierarchicalSummary: $includeHierarchicalSummary,
                    includeKnowledgeMapping: $includeKnowledgeMapping,
                    includeQaMetadata: $includeQaMetadata,
                    onHelpRequested: onHelpRequested,
                    fileTreeManager: fileTreeManager
                )

                if viewMode == .advanced {
                    AdvancedFileTreeView(
                        fileTreeManager: fileTreeManager,
                        selectedPath: selectedPath
                    )
                }
            }
        }
    }
}
