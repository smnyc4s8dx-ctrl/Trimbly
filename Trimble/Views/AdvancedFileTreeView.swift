import SwiftUI

struct AdvancedFileTreeView: View {
    struct CompressionLevelLegend: View {
        var body: some View {
            HStack(spacing: 16) {
                ForEach(FileTreeManager.CompressionLevel.allCases, id: \.self) { level in
                    HStack(spacing: 4) {
                        Image(systemName: level.icon)
                            .foregroundColor(level.color)
                            .font(.caption)
                        Text(level.rawValue)
                            .font(.caption2)
                            .foregroundColor(level.color)
                    }
                }
            }
        }
    }

    struct FileTreeNodeView: View {
        @Environment(\.theme) private var theme
        @ObservedObject var node: FileTreeManager.FileTreeNode
        @ObservedObject var fileTreeManager: FileTreeManager
        let depth: Int

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Indentation
                    ForEach(0..<depth, id: \.self) { _ in
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(.secondary.opacity(0.3))
                            .padding(.trailing, 12)
                    }

                    // Chevron button (fixed logic)
                    if node.shouldShowChevron {
                        Button(action: {
                            node.toggleExpansion(fileTreeManager: fileTreeManager)
                        }) {
                            if node.isLoading {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .frame(width: 12, height: 12)
                            } else {
                                Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.secondary)
                                    .frame(width: 12)
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Spacer().frame(width: 12)
                    }

                    // Selection checkbox
                    Toggle("", isOn: $node.isSelected)
                        .toggleStyle(.checkbox)
                        .scaleEffect(0.8)

                    HStack(spacing: 8) {
                        Image(systemName: node.isDirectory ? "folder.fill" : "doc.text.fill")
                            .foregroundColor(node.isDirectory ? .blue : .secondary)
                            .frame(width: 16)

                        Text(node.name)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .foregroundColor(node.isSelected ? .primary : .secondary)

                        Spacer()

                        if node.isSelected {
                            Menu {
                                ForEach(FileTreeManager.CompressionLevel.allCases, id: \.self) { level in
                                    Button(action: {
                                        node.compressionLevel = level
                                        fileTreeManager.setCompressionLevel(level, for: node.path)
                                    }) {
                                        Label(level.rawValue, systemImage: level.icon)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: node.compressionLevel.icon)
                                        .foregroundColor(node.compressionLevel.color)
                                        .font(.caption)
                                    Text(node.compressionLevel.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(node.compressionLevel.color)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(node.compressionLevel.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Children (only show when expanded)
                if node.isExpanded {
                    ForEach(node.children) { child in
                        FileTreeNodeView(
                            node: child,
                            fileTreeManager: fileTreeManager,
                            depth: depth + 1
                        )
                    }
                }
            }
        }
    }

    @Environment(\.theme) private var theme
    @ObservedObject var fileTreeManager: FileTreeManager
    let selectedPath: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("File Selection & Compression Levels")
                    .font(.headline)
                    .foregroundColor(theme.primaryAccent)

                Spacer()

                HStack(spacing: 8) {
                    Button("Select All") {
                        fileTreeManager.selectAllFiles()
                    }
                    .buttonStyle(theme.secondaryButtonStyle())
                    .controlSize(.small)

                    Button("Deselect All") {
                        fileTreeManager.deselectAllFiles()
                    }
                    .buttonStyle(theme.secondaryButtonStyle())
                    .controlSize(.small)
                }
            }

            CompressionLevelLegend()

            if let rootNode = fileTreeManager.rootNode {
                ScrollView(.vertical) {
                    FileTreeNodeView(
                        node: rootNode,
                        fileTreeManager: fileTreeManager,
                        depth: 0
                    )
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 400)
                .background(theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
            } else if fileTreeManager.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading file tree...")
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            } else {
                ContentUnavailableView(
                    "No Files Selected",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Select a folder to see the file tree")
                )
                .frame(height: 200)
            }
        }
    }
}
