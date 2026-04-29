// MARK: - Trimble/Views/OutputConfigurationView.swift

import SwiftUI

struct OutputConfigurationView: View {
    @Environment(\.theme) private var theme
    @Binding var outputFormat: OutputFormat
    // ADDED: Bindings for the new advanced options
    @Binding var includeHierarchicalSummary: Bool
    @Binding var includeKnowledgeMapping: Bool
    @Binding var includeQaMetadata: Bool

    let onHelpRequested: (String) -> Void

    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader(
                    title: "Output Configuration",
                    icon: "square.and.arrow.down",
                    helpAction: { onHelpRequested("outputFormats") }
                )

                // Output Format Picker
                HStack {
                    Text("Output Format:")
                        .fontWeight(.medium)
                    Picker("", selection: $outputFormat) {
                        Text("Text").tag(OutputFormat.text)
                        Text("JSON").tag(OutputFormat.json)
                        Text("Markdown").tag(OutputFormat.markdown) // ADDED
                        Text("Minimal").tag(OutputFormat.minimal)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 300) // Adjusted width
                    Spacer()
                }

                // ADDED: New section for advanced output features
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Advanced Output Features")
                        .font(.headline)
                        .foregroundColor(theme.textSecondary)

                    Toggle(isOn: $includeHierarchicalSummary) {
                        VStack(alignment: .leading) {
                            Text("Include Hierarchical Summary")
                                .fontWeight(.medium)
                            Text("Prepend a file and dependency tree to the output.")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    .toggleStyle(.switch)

                    Toggle(isOn: $includeKnowledgeMapping) {
                        VStack(alignment: .leading) {
                            Text("Generate Knowledge Map")
                                .fontWeight(.medium)
                            Text("Adds structured metadata for AI knowledge base integration.")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    .toggleStyle(.switch)

                    Toggle(isOn: $includeQaMetadata) {
                        VStack(alignment: .leading) {
                            Text("Add Q&A Metadata")
                                .fontWeight(.medium)
                            Text("Includes metadata to improve AI's question-answering ability.")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
            }
        }
    }
}
