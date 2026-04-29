import SwiftUI

struct SourceSelectionView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedPath: String
    @Binding var targetAIModel: AIModel
    @Binding var tokenBudget: Int?
    let onPathSelected: (String) -> Void
    let onHelpRequested: (String) -> Void

    private let numberFormatter: NumberFormatter

    init(
        selectedPath: Binding<String>,
        targetAIModel: Binding<AIModel>,
        tokenBudget: Binding<Int?>,
        onPathSelected: @escaping (String) -> Void,
        onHelpRequested: @escaping (String) -> Void
    ) {
        self._selectedPath = selectedPath
        self._targetAIModel = targetAIModel
        self._tokenBudget = tokenBudget
        self.onPathSelected = onPathSelected
        self.onHelpRequested = onHelpRequested

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        self.numberFormatter = formatter
    }

    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader(
                    title: "Source Selection",
                    icon: "folder.badge.plus",
                    helpAction: { onHelpRequested("sourceSelection") }
                )

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected Path:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(theme.textSecondary)

                        HStack {
                            ThemedInputField {
                                Text(selectedPath.isEmpty ? "No file or folder selected" : selectedPath)
                                    .foregroundColor(selectedPath.isEmpty ? theme.textSecondary : theme.textPrimary)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button("Browse...") {
                                showFilePicker()
                            }
                            .buttonStyle(theme.primaryButtonStyle())
                            .controlSize(.large)
                        }
                    }

                    Divider()

                    HStack {
                        Picker("Target AI Model:", selection: $targetAIModel) {
                            ForEach(AIModel.allCases, id: \.self) { model in
                                Text(model.rawValue).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }

                    if targetAIModel == .custom {
                        HStack {
                            Text("Token Budget:")
                                .fontWeight(.medium)

                            TextField("e.g. 128000", value: $tokenBudget, formatter: numberFormatter)
                                .textFieldStyle(.roundedBorder)
                                .background(RoundedRectangle(cornerRadius: 6).fill(theme.secondaryAccent.opacity(0.1)))
                        }
                        .padding(.top, 4)
                        .animation(.easeInOut, value: targetAIModel)
                    }
                }
            }
        }
    }

    private func showFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            if let url = panel.url {
                onPathSelected(url.path)
            }
        }
    }
}
