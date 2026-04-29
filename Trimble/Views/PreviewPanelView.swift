import SwiftUI

struct PreviewPanelView: View {
    @Environment(\.theme) private var theme

    struct ExcludedDirectoryCard: View {
        @Environment(\.theme) private var theme
        let directory: ExcludedDirectoryInfo

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: "folder.badge.minus")
                    .foregroundColor(theme.textSecondary)
                    .font(.caption)

                VStack(alignment: .leading, spacing: 2) {
                    Text(directory.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text("\(directory.fileCount) files • \(directory.totalSize)")
                        .font(.caption2)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(8)
            .background(theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
        }
    }

    struct LiveProgressView: View {
        @Environment(\.theme) private var theme
        let progress: TokenProcessingProgress

        var body: some View {
            ThemedProgressContainer(tint: theme.primaryAccent) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Token Processing")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(theme.primaryAccent)

                            if !progress.currentFile.isEmpty {
                                Text("Processing: \(progress.currentFile)")
                                    .font(.caption2)
                                    .foregroundColor(theme.textSecondary)
                                    .lineLimit(1)
                                    .animation(.easeInOut, value: progress.currentFile)
                            }
                        }
                        Spacer()
                        Text("\(progress.filesProcessed) / \(progress.filesDiscovered)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(theme.primaryAccent)
                    }

                    ProgressView(
                        value: Double(progress.filesProcessed),
                        total: Double(Swift.max(progress.filesDiscovered, 1))
                    )
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.primaryAccent))
                    .frame(height: 6)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rate: \(String(format: "%.1f", progress.processingRate)) files/sec")
                                .font(.caption2)
                                .foregroundColor(theme.textSecondary)
                            Text("Reduction: \(String(format: "%.0f%%", (progress.averageCompressionRatio - 1) * 100))")
                                .font(.caption2)
                                .foregroundColor(theme.success)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(formatTokens(progress.totalTokensProcessed)) tokens")
                                .font(.caption2)
                                .foregroundColor(theme.textSecondary)
                            Text("\(formatTokens(progress.totalTokensSaved)) saved")
                                .font(.caption2)
                                .foregroundColor(theme.success)
                        }
                    }
                }
            }
        }

        private func formatTokens(_ count: Int) -> String {
            if count >= 1000000 {
                return String(format: "%.1fM", Double(count) / 1000000)
            } else if count >= 1000 {
                return String(format: "%.1fK", Double(count) / 1000)
            } else {
                return "\(count)"
            }
        }
    }

    @ObservedObject var processor: ContentProcessor
    let targetModel: AIModel
    let tokenBudget: Int?

    private var contextWindow: Int {
        return tokenBudget ?? targetModel.contextWindow
    }

    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader(
                    title: "Smart Compression Preview",
                    icon: "eye.circle"
                )

                if processor.isTokenProcessingActive {
                    LiveProgressView(progress: processor.tokenProcessingProgress)
                }

                if let preview = processor.livePreview {
                    VStack(spacing: 16) {
                        HStack {
                            ThemedStatCard(
                                title: "Output Size",
                                value: formatNumber(preview.estimatedTokens),
                                subtitle: "tokens",
                                color: theme.primaryAccent
                            )

                            ThemedStatCard(
                                title: "Reduction",
                                value: formatReductionPercentage(preview.compressionRatio),
                                subtitle: "smaller",
                                color: theme.success
                            )

                            ThemedStatCard(
                                title: "Accuracy",
                                value: "\(String(format: "%.0f%%", preview.semanticAccuracy * 100))",
                                subtitle: "preserved",
                                color: preview.semanticAccuracy > 0.9 ? theme.success :
                                       preview.semanticAccuracy > 0.7 ? theme.warning : theme.danger
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Context Usage")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(formatNumber(preview.estimatedTokens)) / \(formatNumber(contextWindow))")
                                    .font(.caption)
                                    .foregroundColor(theme.textSecondary)
                            }

                            let progress = Swift.min(Double(preview.estimatedTokens), Double(contextWindow))
                            let percentage = (progress / Double(contextWindow)) * 100

                            ProgressView(value: progress, total: Double(contextWindow))
                                .progressViewStyle(LinearProgressViewStyle(tint: preview.fitsInContext ? theme.success : theme.warning))
                                .frame(height: 8)

                            Text("\(String(format: "%.1f%%", percentage)) of context window")
                                .font(.caption2)
                                .foregroundColor(theme.textSecondary)
                        }

                        if !preview.excludedDirectories.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Auto-Excluded Directories")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.primaryAccent)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    ForEach(preview.excludedDirectories.prefix(4), id: \.name) { dir in
                                        ExcludedDirectoryCard(directory: dir)
                                    }
                                }

                                if preview.excludedDirectories.count > 4 {
                                    Text("+ \(preview.excludedDirectories.count - 4) more excluded")
                                        .font(.caption2)
                                        .foregroundColor(theme.textSecondary)
                                }
                            }
                            .padding(12)
                            .background(theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
                        }

                        if targetModel == .claude && preview.estimatedTokens > 50000 {
                            ThemedAlertBox(
                                title: "May exceed Claude's project knowledge limits",
                                message: "Consider using Maximum compression level",
                                severity: .warning
                            )
                        }
                    }
                } else {
                    ThemedProgressContainer(tint: theme.primaryAccent) {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Analyzing content with semantic intelligence...")
                                .font(.subheadline)
                                .foregroundColor(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }

    private func formatReductionPercentage(_ compressionRatio: Double) -> String {
        let percentage = max(0, (1 - (1 / compressionRatio)) * 100)
        return "\(String(format: "%.0f%%", percentage))"
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
