import SwiftUI
import Foundation

enum ViewMode: String, CaseIterable {
    case simple = "Simple"
    case advanced = "Advanced"
}

struct ContentView: View {
    @StateObject private var processor = ContentProcessor()
    @StateObject private var fileTreeManager = FileTreeManager()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedPath: String = ""
    @State private var outputFormat: OutputFormat = .text
    @State private var compressionOptions = CompressionOptions.medium
    @State private var targetAIModel: AIModel = .claude
    @State private var tokenBudget: Int? = nil
    @State private var includeHierarchicalSummary: Bool = false
    @State private var includeKnowledgeMapping: Bool = false
    @State private var includeQaMetadata: Bool = false
    @State private var viewMode: ViewMode = .simple
    @State private var isProcessing: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingHelp: Bool = false
    @State private var showingErrorReport: Bool = false
    @State private var selectedHelpTopic: String = "semanticLevels"

    var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    HeaderView()

                    SourceSelectionView(
                        selectedPath: $selectedPath,
                        targetAIModel: $targetAIModel,
                        tokenBudget: $tokenBudget,
                        onPathSelected: { path in
                            selectedPath = path
                            Task {
                                await fileTreeManager.loadFileTree(at: path)
                            }
                        },
                        onHelpRequested: { topic in
                            selectedHelpTopic = topic
                            showingHelp = true
                        }
                    )

                    if !selectedPath.isEmpty {
                        PreviewPanelView(
                             processor: processor,
                             targetModel: targetAIModel,
                             tokenBudget: tokenBudget
                        )

                        CompressionControlsView(
                            viewMode: $viewMode,
                            compressionOptions: $compressionOptions,
                            includeHierarchicalSummary: $includeHierarchicalSummary,
                            includeKnowledgeMapping: $includeKnowledgeMapping,
                            includeQaMetadata: $includeQaMetadata,
                            fileTreeManager: fileTreeManager,
                            selectedPath: selectedPath,
                            onHelpRequested: { topic in
                                selectedHelpTopic = topic
                                showingHelp = true
                            }
                        )

                        OutputConfigurationView(
                            outputFormat: $outputFormat,
                            includeHierarchicalSummary: $includeHierarchicalSummary,
                            includeKnowledgeMapping: $includeKnowledgeMapping,
                            includeQaMetadata: $includeQaMetadata,
                            onHelpRequested: { topic in
                                selectedHelpTopic = topic
                                showingHelp = true
                            }
                        )

                        if !processor.processingErrors.isEmpty {
                            ErrorDisplayView(errors: processor.processingErrors)
                        }

                        if isProcessing {
                            ProcessingStatusView(processor: processor)
                        }

                        ActionButtonsView(
                            isProcessing: isProcessing,
                            hasErrors: !processor.processingErrors.isEmpty,
                            canProcess: !selectedPath.isEmpty,
                            onStartProcessing: startProcessing,
                            onCancel: {
                                processor.cancel()
                                isProcessing = false
                            },
                            onShowHelp: {
                                selectedHelpTopic = "semanticLevels"
                                showingHelp = true
                            },
                            onShowErrorReport: {
                                generateErrorReport()
                                showingErrorReport = true
                            }
                        )
                    }
                }
                .padding(24)
            }
        .background(themeManager.currentTheme.windowBackground())
        .frame(minWidth: 700, minHeight: 600)
        .frame(idealWidth: 1000, idealHeight: 1200)
        .themed(themeManager.currentTheme)
        .environmentObject(themeManager)
        .alert("Processing Complete", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingHelp) {
            HelpView(topic: selectedHelpTopic)
        }
        .sheet(isPresented: $showingErrorReport) {
            ErrorReportView(reporter: processor.errorReporter)
        }
        .onChange(of: compressionOptions) { updatePreview() }
        .onChange(of: targetAIModel) { updatePreview() }
        .onChange(of: selectedPath) { updatePreview() }
        .onChange(of: tokenBudget) { updatePreview() }
        .onChange(of: includeHierarchicalSummary) { updatePreview() }
        .onChange(of: includeKnowledgeMapping) { updatePreview() }
        .onChange(of: includeQaMetadata) { updatePreview() }
        .onChange(of: fileTreeManager.selectionChangeNotifier) { updatePreview() }
    }

    func updatePreview() {
        guard !selectedPath.isEmpty else { return }

        Task {
            let config = ProcessingConfiguration(
                sourcePath: selectedPath,
                outputFileName: generateDefaultName(),
                outputFormat: outputFormat,
                compressionOptions: compressionOptions,
                knowledgeMapping: false,
                hierarchicalSummary: false,
                qaMetadata: false,
                createDuplicate: false,
                duplicateSuffix: "_compressed",
                targetAIModel: targetAIModel,
                tokenBudget: tokenBudget
            )

            await processor.generatePreview(configuration: config, fileTreeManager: fileTreeManager)
        }
    }

    func startProcessing() {
        isProcessing = true
        processor.process(configuration: createProcessingConfiguration(), fileTreeManager: fileTreeManager) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let path):
                    alertMessage = "Content processed successfully!\nSaved to: \(path)"
                case .failure(let error):
                    alertMessage = "Processing failed: \(ErrorReporter.sanitizeErrorDescription(error.localizedDescription))"
                }
                showingAlert = true
            }
        }
    }

    func createProcessingConfiguration() -> ProcessingConfiguration {
        return ProcessingConfiguration(
            sourcePath: selectedPath,
            outputFileName: generateDefaultName(),
            outputFormat: outputFormat,
            compressionOptions: compressionOptions,
            knowledgeMapping: includeKnowledgeMapping,
            hierarchicalSummary: includeHierarchicalSummary,
            qaMetadata: includeQaMetadata,
            createDuplicate: false,
            duplicateSuffix: "_compressed",
            targetAIModel: targetAIModel,
            tokenBudget: tokenBudget
        )
    }

    func generateErrorReport() {
        processor.errorReporter.generateReport(from: processor, config: createProcessingConfiguration(), errors: processor.processingErrors)
    }

    func generateDefaultName() -> String {
        let folderName = URL(fileURLWithPath: selectedPath).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            .replacingOccurrences(of: "/", with: "-")
        return "\(folderName)_compressed_\(timestamp)"
    }
}
