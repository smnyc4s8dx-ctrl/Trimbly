// ProcessingStatusView.swift
import SwiftUI

struct ProcessingStatusView: View {
    @Environment(\.theme) private var theme
    @ObservedObject var processor: ContentProcessor

    var body: some View {
        ThemedCard {
            VStack(spacing: 16) {
                ThemedSectionHeader(
                    title: "Processing Status",
                    icon: "gear"
                )

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryAccent))
                    .scaleEffect(1.2)

                if !processor.currentFileName.isEmpty {
                    Text("Processing: \(processor.currentFileName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Text("Processing with AI-optimized compression...")
                    .foregroundColor(theme.textSecondary)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Files: \(processor.filesProcessed)")
                        Text("Directories: \(processor.dirsProcessed)")
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Tokens: \(processor.totalTokensProcessed)")
                        Text("Saved: \(processor.totalTokensSaved)")
                    }
                }
                .font(.caption)
                .foregroundColor(theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
