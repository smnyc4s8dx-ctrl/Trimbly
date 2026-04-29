import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TokenProcessingProgress {
    var filesDiscovered: Int = 0
    var filesProcessed: Int = 0
    var totalTokensProcessed: Int = 0
    var totalTokensSaved: Int = 0
    var currentFile: String = ""
    var estimatedCompletion: Double = 0.0
    var processingRate: Double = 0.0
    var averageCompressionRatio: Double = 1.0
}

struct TokenResult {
    let fileName: String
    let filePath: String
    let originalTokens: Int
    let compressedTokens: Int
    let tokensSaved: Int
    let processingTime: TimeInterval
    let fileSize: Int
}

actor TokenProcessingQueue {
    private var pendingFiles: [String] = []
    private var completedResults: [TokenResult] = []

    func enqueue(_ files: [String]) {
        pendingFiles.append(contentsOf: files)
    }

    func processNext() async -> String? {
        guard !pendingFiles.isEmpty else { return nil }
        return pendingFiles.removeFirst()
    }

    func addResult(_ result: TokenResult) {
        completedResults.append(result)
    }

    func getAllResults() -> [TokenResult] {
        return completedResults
    }

    func getAggregateStats() -> (totalOriginal: Int, totalCompressed: Int, totalSaved: Int, avgRatio: Double) {
        let totalOriginal = completedResults.reduce(0) { $0 + $1.originalTokens }
        let totalCompressed = completedResults.reduce(0) { $0 + $1.compressedTokens }
        let totalSaved = completedResults.reduce(0) { $0 + $1.tokensSaved }
        let avgRatio = totalOriginal > 0 ? Double(totalOriginal) / Double(Swift.max(totalCompressed, 1)) : 1.0
        return (totalOriginal, totalCompressed, totalSaved, avgRatio)
    }

    func getPendingCount() -> Int {
        return pendingFiles.count
    }

    func clearResults() {
        pendingFiles.removeAll()
        completedResults.removeAll()
    }
}

@MainActor
class ContentProcessor: ObservableObject {
    @Published var filesProcessed: Int = 0
    @Published var dirsProcessed: Int = 0
    @Published var totalTokensProcessed: Int = 0
    @Published var totalTokensSaved: Int = 0
    @Published var livePreview: CompressionPreview?
    @Published var processingErrors: [ProcessingError] = []
    @Published var errorReporter = ErrorReporter()
    @Published var currentFileName: String = ""
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var tokenProcessingProgress = TokenProcessingProgress()
    @Published var isTokenProcessingActive = false

    private let compressionEngine = CompressionEngine()
    private let fileProcessor = FileProcessor()
    private let gitIgnoreParser = GitIgnoreParser()
    private let tokenQueue = TokenProcessingQueue()
    private var excludedDirectories: [ExcludedDirectoryInfo] = []
    private var isCancelled = false
    private var processingTask: Task<Void, Never>?
    private var tokenProcessingTask: Task<Void, Never>?
    private var previewUpdateTask: Task<Void, Never>?

    func generatePreview(configuration: ProcessingConfiguration, fileTreeManager: FileTreeManager? = nil) async {
        guard !configuration.sourcePath.isEmpty else {
            livePreview = nil
            return
        }

        isCancelled = false
        cancel()

        await tokenQueue.clearResults()

        await Task.detached {
            await self.gitIgnoreParser.loadGitIgnore(from: configuration.sourcePath)
        }.value

        fileProcessor.gitIgnoreParser = gitIgnoreParser
        fileProcessor.projectRootPath = configuration.sourcePath

        excludedDirectories = await Task.detached {
            return await self.fileProcessor.getExcludedDirectories(
                at: configuration.sourcePath,
                configuration: configuration
            )
        }.value

        tokenProcessingProgress = TokenProcessingProgress()
        isTokenProcessingActive = true
        livePreview = createInitialPreview(configuration: configuration)

        startProgressiveTokenProcessing(configuration: configuration, fileTreeManager: fileTreeManager)
    }

    private func createInitialPreview(configuration: ProcessingConfiguration) -> CompressionPreview {
        return CompressionPreview(
            estimatedTokens: 0,
            estimatedFileSize: "Calculating...",
            compressionRatio: 1.0,
            worstCaseTokens: 0,
            fitsInContext: true,
            breakdown: [:],
            semanticAccuracy: calculateSemanticAccuracy(from: configuration.compressionOptions.semanticLevel),
            excludedDirectories: excludedDirectories
        )
    }

    private func startProgressiveTokenProcessing(configuration: ProcessingConfiguration, fileTreeManager: FileTreeManager? = nil) {
        tokenProcessingTask = Task.detached { [weak self] in
            await self?.processTokensProgressively(configuration: configuration, fileTreeManager: fileTreeManager)
        }

        previewUpdateTask = Task { [weak self] in
            await self?.updatePreviewPeriodically(configuration: configuration)
        }
    }

    private func processTokensProgressively(configuration: ProcessingConfiguration, fileTreeManager: FileTreeManager? = nil) async {
        do {
            let allFiles = try fileProcessor.getAllFiles(at: configuration.sourcePath, configuration: configuration)  // Remove 'await'
            let filteredFiles = await filterFilesByTreeSelections(files: allFiles, fileTreeManager: fileTreeManager)  // Remove 'await'

            let batches = filteredFiles.chunked(into: 25)

            for batch in batches {
                if Task.isCancelled { break }

                await tokenQueue.enqueue(batch)

                await MainActor.run {
                    self.tokenProcessingProgress.filesDiscovered += batch.count
                }

                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        } catch {
            await MainActor.run {
                self.processingErrors.append(ProcessingError(
                    fileName: "File Discovery",
                    error: "Failed to discover files: \(ErrorReporter.sanitizeErrorDescription(error.localizedDescription))",
                    severity: .error
                ))
            }
        }

        while await tokenQueue.getPendingCount() > 0 {
            if Task.isCancelled { break }

            if let filePath = await tokenQueue.processNext() {
                let result = await processFileTokens(file: filePath, configuration: configuration)
                await tokenQueue.addResult(result)

                await MainActor.run {
                    self.tokenProcessingProgress.filesProcessed += 1
                    self.tokenProcessingProgress.totalTokensProcessed += result.originalTokens
                    self.tokenProcessingProgress.totalTokensSaved += result.tokensSaved
                    self.tokenProcessingProgress.currentFile = result.fileName

                    if self.tokenProcessingProgress.filesDiscovered > 0 {
                        self.tokenProcessingProgress.estimatedCompletion = Double(self.tokenProcessingProgress.filesProcessed) / Double(self.tokenProcessingProgress.filesDiscovered)
                    }
                }
            }
        }

        await MainActor.run {
            self.isTokenProcessingActive = false
        }
    }

    private func filterFilesByTreeSelections(files: [String], fileTreeManager: FileTreeManager?) async -> [String] {
        guard let fileTreeManager = fileTreeManager else {
            return files.filter { fileProcessor.isTextFile(path: $0) }
        }

        return await MainActor.run {
            return files.filter { filePath in
                guard fileProcessor.isTextFile(path: filePath) else { return false }
                return isFileSelected(filePath: filePath, in: fileTreeManager)
            }
        }
    }

    private func isFileSelected(filePath: String, in fileTreeManager: FileTreeManager) -> Bool {
        guard let rootNode = fileTreeManager.rootNode else { return true }
        return checkNodeSelection(for: filePath, node: rootNode)
    }

    private func checkNodeSelection(for filePath: String, node: FileTreeManager.FileTreeNode) -> Bool {
        if node.path == filePath {
            return node.isSelected
        }

        if filePath.hasPrefix(node.path + "/") {
            if !node.isSelected {
                return false
            }

            for child in node.children {
                if filePath.hasPrefix(child.path) {
                    return checkNodeSelection(for: filePath, node: child)
                }
            }

            return true
        }

        return false
    }

    private func processFileTokens(file: String, configuration: ProcessingConfiguration) async -> TokenResult {
        let startTime = Date()
        let fileName = URL(fileURLWithPath: file).lastPathComponent

        do {
            let content = try String(contentsOfFile: file)
            let language = ProgrammingLanguage.detectFromFileName(fileName)

            var adjustedOptions = configuration.compressionOptions
            adjustedOptions.tokenizerType = configuration.targetAIModel.tokenizer
            let compressed = compressionEngine.compressContent(
                content: content,
                language: language,
                options: adjustedOptions
            )

            return TokenResult(
                fileName: fileName,
                filePath: file,
                originalTokens: compressed.originalTokens,      // Now consistent tokenizer
                compressedTokens: compressed.compressedTokens,  // Now consistent tokenizer
                tokensSaved: compressed.tokensRemoved,          // Now correct math
                processingTime: Date().timeIntervalSince(startTime),
                fileSize: content.count
            )
        } catch {
            return TokenResult(
                fileName: fileName,
                filePath: file,
                originalTokens: 0,
                compressedTokens: 0,
                tokensSaved: 0,
                processingTime: Date().timeIntervalSince(startTime),
                fileSize: 0
            )
        }
    }

    private func updatePreviewPeriodically(configuration: ProcessingConfiguration) async {
        let startTime = Date()

        while !Task.isCancelled {
            let isStillProcessing = await MainActor.run { self.isTokenProcessingActive }
            if !isStillProcessing { break }

            try? await Task.sleep(nanoseconds: 500_000_000)

            let stats = await tokenQueue.getAggregateStats()
            let elapsedTime = Date().timeIntervalSince(startTime)

            let currentProgress = await MainActor.run { self.tokenProcessingProgress }
            let processingRate = elapsedTime > 0 ? Double(currentProgress.filesProcessed) / elapsedTime : 0

            // Add overhead for file path headers, report metadata, and hierarchical summary
            let perFileOverhead = 13 // average tokens for "## path/to/file.swift\n"
            let headerOverhead = 200 // report metadata header
            let hierarchicalOverhead = configuration.hierarchicalSummary ? 3000 : 0
            let estimatedTotal = stats.totalCompressed + (currentProgress.filesProcessed * perFileOverhead) + headerOverhead + hierarchicalOverhead

            let updatedPreview = CompressionPreview(
                estimatedTokens: estimatedTotal,
                estimatedFileSize: formatFileSize(stats.totalCompressed * 4),
                compressionRatio: stats.avgRatio,
                worstCaseTokens: stats.totalOriginal,
                fitsInContext: stats.totalCompressed < configuration.targetAIModel.contextWindow,
                breakdown: [:],
                semanticAccuracy: calculateSemanticAccuracy(from: configuration.compressionOptions.semanticLevel),
                excludedDirectories: excludedDirectories
            )

            await MainActor.run {
                self.livePreview = updatedPreview
                self.tokenProcessingProgress.processingRate = processingRate
                self.tokenProcessingProgress.averageCompressionRatio = stats.avgRatio
            }

            let progressCheck = await MainActor.run { self.tokenProcessingProgress }
            if progressCheck.filesProcessed >= progressCheck.filesDiscovered &&
               progressCheck.filesDiscovered > 0 {
                break
            }
        }
    }

    private func calculateSemanticAccuracy(from level: SemanticCompressionLevel) -> Double {
        switch level {
        case .light: return 1.0
        case .medium: return 0.95
        case .aggressive: return 0.85
        case .maximum: return 0.3
        }
    }

    private func formatFileSize(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    func process(configuration: ProcessingConfiguration, fileTreeManager: FileTreeManager? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        isCancelled = false
        processingTask = Task {
            do {
                let outputContent = try await processAllFiles(configuration: configuration, fileTreeManager: fileTreeManager)

                let hasErrors = await MainActor.run { !self.processingErrors.isEmpty }
                if hasErrors {
                    await MainActor.run {
                        self.errorReporter.generateReport(from: self, config: configuration, errors: self.processingErrors)
                    }
                }

                await showSaveDialog(content: outputContent, configuration: configuration, completion: completion)
            } catch {
                let hasErrors = await MainActor.run { !self.processingErrors.isEmpty }
                if hasErrors {
                    await MainActor.run {
                        self.errorReporter.generateReport(from: self, config: configuration, errors: self.processingErrors)
                    }
                }
                completion(.failure(error))
            }
        }
    }

    private func processAllFiles(configuration: ProcessingConfiguration, fileTreeManager: FileTreeManager? = nil) async throws -> String {
        // Ensure gitignore parser is wired for file processing
        if fileProcessor.gitIgnoreParser == nil {
            gitIgnoreParser.loadGitIgnore(from: configuration.sourcePath)
            fileProcessor.gitIgnoreParser = gitIgnoreParser
            fileProcessor.projectRootPath = configuration.sourcePath
        }

        let allFiles = try fileProcessor.getAllFiles(at: configuration.sourcePath, configuration: configuration)
        let selectedFiles = await filterFilesByTreeSelections(files: allFiles, fileTreeManager: fileTreeManager)

        var processedContent: [String] = []
        var allResults: [TokenResult] = []

        for (index, filePath) in selectedFiles.enumerated() {
            if Task.isCancelled {
                throw CancellationError()
            }

            let fileName = URL(fileURLWithPath: filePath).lastPathComponent

            await MainActor.run {
                self.filesProcessed = index + 1
                self.currentFileName = fileName
            }

            do {
                let content = try String(contentsOfFile: filePath)
                let language = ProgrammingLanguage.detectFromFileName(fileName)

                var adjustedOptions = configuration.compressionOptions
                adjustedOptions.tokenizerType = configuration.targetAIModel.tokenizer
                let compressed = compressionEngine.compressContent(
                    content: content,
                    language: language,
                    options: adjustedOptions
                )

                let relativePath = filePath.replacingOccurrences(of: configuration.sourcePath + "/", with: "")
                processedContent.append("## \(relativePath)\n\(compressed.content)\n")

                allResults.append(TokenResult(
                    fileName: fileName,
                    filePath: filePath,
                    originalTokens: compressed.originalTokens,
                    compressedTokens: compressed.compressedTokens,
                    tokensSaved: compressed.tokensRemoved,
                    processingTime: 0,
                    fileSize: content.count
                ))

                await MainActor.run {
                    self.totalTokensProcessed += compressed.originalTokens
                    self.totalTokensSaved += compressed.tokensRemoved
                }

            } catch {
                await MainActor.run {
                    self.processingErrors.append(ProcessingError(
                        fileName: fileName,
                        error: ErrorReporter.sanitizeErrorDescription(error.localizedDescription),
                        severity: .error
                    ))
                }
            }
        }

        // Generate hierarchical summary using ALL files (not just selected)
        if configuration.hierarchicalSummary {
            let hierarchicalMap = await generateHierarchicalSummary(
                allFiles: allFiles,  // Use ALL files here
                selectedFiles: selectedFiles,  // But note which were selected
                configuration: configuration
            )
            processedContent.insert(hierarchicalMap, at: 0)
        }

        return generateFinalOutput(
            content: processedContent.joined(separator: "\n"),
            results: allResults,
            configuration: configuration
        )
    }

    private func generateHierarchicalSummary(
        allFiles: [String],
        selectedFiles: [String],
        configuration: ProcessingConfiguration
    ) async -> String {

        var fileContents: [String: String] = [:]
        for filePath in allFiles {
            do {
                if fileProcessor.isTextFile(path: filePath) {
                    let content = try String(contentsOfFile: filePath)
                    fileContents[filePath] = content
                }
            } catch {
                // Skip files that can't be read, but don't stop processing
                continue
            }
        }

        let excludedDirectories = fileProcessor.getExcludedDirectories(
            at: configuration.sourcePath,
            configuration: configuration
        )

        let libraryDependencies = SmartFileAnalyzer().extractLibraryDependencies(
            from: configuration.sourcePath
        )

        let hierarchicalMap = compressionEngine.semanticAnalyzer.generateHierarchicalMap(
            from: configuration.sourcePath,
            fileContents: fileContents,
            compressionLevels: [:],
            excludedDirectories: excludedDirectories,
            libraryDependencies: libraryDependencies,
            tokenizer: configuration.targetAIModel.tokenizer
        )

        return formatHierarchicalSummary(hierarchicalMap, selectedFileCount: selectedFiles.count)
    }

    private func formatHierarchicalSummary(_ map: HierarchicalMap, selectedFileCount: Int) -> String {
        return """
        # Project Hierarchical Summary
        
        ## Project Overview
        - **Total Files Analyzed**: \(map.projectStructure.totalFiles)
        - **Files Selected for Processing**: \(selectedFileCount)
        - **Total Directories**: \(map.projectStructure.totalDirectories)
        - **Languages**: \(map.summary.languages.map { "\($0.key): \($0.value) files" }.joined(separator: ", "))
        
        ## Key Modules
        \(map.summary.keyModules.map { "- \($0.replacingOccurrences(of: map.projectStructure.rootPath + "/", with: ""))" }.joined(separator: "\n"))
        
        ## Library Dependencies
        \(map.dependencyGraph.libraryDeps.map { "- \($0.name) (\($0.source.rawValue))" }.joined(separator: "\n"))
        
        ## Excluded Directories
        \(map.projectStructure.excludedDirectories.map { "- \($0.name): \($0.fileCount) files, \($0.totalSize)" }.joined(separator: "\n"))
        
        ---
        
        """
    }

    func cancel() {
        isCancelled = true
        processingTask?.cancel()
        tokenProcessingTask?.cancel()
        previewUpdateTask?.cancel()

        processingTask = nil
        tokenProcessingTask = nil
        previewUpdateTask = nil
    }

    private func generateFinalOutput(content: String, results: [TokenResult], configuration: ProcessingConfiguration) -> String {
        let totalOriginal = results.reduce(0) { $0 + $1.originalTokens }
        let totalCompressed = results.reduce(0) { $0 + $1.compressedTokens }
        let totalSaved = results.reduce(0) { $0 + $1.tokensSaved }
        let compressionRatio = totalOriginal > 0 ? Double(totalOriginal) / Double(Swift.max(totalCompressed, 1)) : 1.0

        switch configuration.outputFormat {
        case .text:
            let header = """
            # Trimble Compression Report
            Generated: \(Date())
            
            ## Compression Summary
            - Original Tokens: \(totalOriginal)
            - Compressed Tokens: \(totalCompressed)
            - Tokens Saved: \(totalSaved)
            - Compression Ratio: \(String(format: "%.2f", compressionRatio))x
            - Files Processed: \(results.count)
            - Target Model: \(configuration.targetAIModel.rawValue)
            - Semantic Level: \(configuration.compressionOptions.semanticLevel.rawValue)
            
            ---
            
            """
            return header + content

        case .markdown:
                let header = """
                # Trimble Compression Report
                * **Generated**: \(Date())
                * **Files Processed**: \(results.count)
                * **Target Model**: `\(configuration.targetAIModel.rawValue)`
                * **Semantic Level**: `\(configuration.compressionOptions.semanticLevel.rawValue)`

                ## Compression Summary
                | Metric                | Value                               |
                | --------------------- | ----------------------------------- |
                | Original Tokens       | \(totalOriginal)                    |
                | Compressed Tokens     | \(totalCompressed)                  |
                | Tokens Saved          | \(totalSaved)                       |
                | Compression Ratio     | \(String(format: "%.2f", compressionRatio))x |
                
                ---
                
                """
                return header + content

        case .json:
            let jsonOutput: [String: Any] = [
                "metadata": [
                    "generated": ISO8601DateFormatter().string(from: Date()),
                    "totalOriginalTokens": totalOriginal,
                    "totalCompressedTokens": totalCompressed,
                    "tokensSaved": totalSaved,
                    "compressionRatio": compressionRatio,
                    "filesProcessed": results.count,
                    "targetModel": configuration.targetAIModel.rawValue,
                    "semanticLevel": configuration.compressionOptions.semanticLevel.rawValue
                ],
                "content": content
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonOutput, options: .prettyPrinted)
            return String(data: jsonData ?? Data(), encoding: .utf8) ?? content

        case .minimal:
            return content
        }
    }

    private func showSaveDialog(content: String, configuration: ProcessingConfiguration, completion: @escaping (Result<String, Error>) -> Void) async {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "\(configuration.outputFileName).\(configuration.outputFormat.fileExtension)"
        savePanel.allowedContentTypes = [UTType.plainText]
        savePanel.title = "Save Compressed Content"
        savePanel.message = "Choose where to save your compressed content"

        if savePanel.runModal() == .OK {  // Remove 'await' here
            guard let url = savePanel.url else {
                completion(.failure(NSError(domain: "SaveError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid save location"])))
                return
            }

            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
                completion(.success(url.path))
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(NSError(domain: "UserCancelled", code: 0, userInfo: [NSLocalizedDescriptionKey: "Save cancelled by user"])))
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
