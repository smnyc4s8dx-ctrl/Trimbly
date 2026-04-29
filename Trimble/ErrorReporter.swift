//  ErrorReporter.swift
import Foundation
import SwiftUI

struct ErrorReport {
    let id: String
    let timestamp: Date
    let appVersion: String
    let systemInfo: SystemInfo
    let processingConfig: SanitizedProcessingConfig
    let errors: [SanitizedError]
    let performanceMetrics: PerformanceMetrics

    struct SystemInfo {
        let osVersion: String
        let architecture: String
        let memoryGB: Int
        let availableSpaceGB: Int
    }

    struct SanitizedProcessingConfig {
        let outputFormat: OutputFormat
        let compressionOptions: CompressionOptions
        let targetAIModel: AIModel
        let fileTypesProcessed: [String]
        let totalFilesAttempted: Int
        let totalDirectoriesScanned: Int
    }

    struct SanitizedError {
        let type: String
        let severity: ProcessingError.Severity
        let fileExtension: String
        let fileSizeCategory: String
        let errorCode: String
        let sanitizedDescription: String
    }

    struct PerformanceMetrics {
        let processingDurationSeconds: Double
        let memoryUsageMB: Int
        let tokensProcessedPerSecond: Double
        let averageFileProcessingTimeMs: Double
    }
}

@MainActor
class ErrorReporter: ObservableObject {
    @Published var currentReport: ErrorReport?
    @Published var showingReportSheet = false
    private var processingStartTime: Date?
    private var processedFileExtensions: Set<String> = []

    func startSession() {
        processingStartTime = Date()
        processedFileExtensions.removeAll()
        currentReport = nil
    }

    func recordFileProcessed(extension: String) {
        processedFileExtensions.insert(`extension`)
    }

    func generateReport(
        from processor: ContentProcessor,
        config: ProcessingConfiguration,
        errors: [ProcessingError]
    ) {
        let reportId = generateAnonymousID()

        let systemInfo = ErrorReport.SystemInfo(
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            architecture: ProcessInfo.processInfo.machineType,
            memoryGB: Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824),
            availableSpaceGB: getAvailableDiskSpace()
        )

        let sanitizedConfig = ErrorReport.SanitizedProcessingConfig(
            outputFormat: config.outputFormat,
            compressionOptions: config.compressionOptions,
            targetAIModel: config.targetAIModel,
            fileTypesProcessed: Array(processedFileExtensions),
            totalFilesAttempted: processor.filesProcessed,
            totalDirectoriesScanned: processor.dirsProcessed
        )

        let sanitizedErrors = errors.map { error in
            ErrorReport.SanitizedError(
                type: getErrorType(from: error.error),
                severity: error.severity,
                fileExtension: getFileExtension(from: error.fileName),
                fileSizeCategory: "unknown",
                errorCode: getErrorCode(from: error.error),
                sanitizedDescription: Self.sanitizeErrorDescription(error.error)
            )
        }

        let duration = processingStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let metrics = ErrorReport.PerformanceMetrics(
            processingDurationSeconds: duration,
            memoryUsageMB: getCurrentMemoryUsage(),
            tokensProcessedPerSecond: duration > 0 ? Double(processor.totalTokensProcessed) / duration : 0,
            averageFileProcessingTimeMs: processor.filesProcessed > 0 ? (duration * 1000) / Double(processor.filesProcessed) : 0
        )

        currentReport = ErrorReport(
            id: reportId,
            timestamp: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            systemInfo: systemInfo,
            processingConfig: sanitizedConfig,
            errors: sanitizedErrors,
            performanceMetrics: metrics
        )
    }

    private func generateAnonymousID() -> String {
        let uuid = UUID().uuidString
        let hash = uuid.hash
        return "TR-\(String(format: "%08X", hash))"
    }

    private func getAvailableDiskSpace() -> Int {
        do {
            let homeURL = FileManager.default.homeDirectoryForCurrentUser
            let values = try homeURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let capacity = values.volumeAvailableCapacity {
                return Int(capacity / 1_073_741_824)
            }
        } catch { }
        return 0
    }

    private func getCurrentMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(info.resident_size / 1_048_576)
        }
        return 0
    }

    private func getErrorType(from description: String) -> String {
        if description.contains("permission") || description.contains("access") {
            return "PermissionError"
        } else if description.contains("memory") || description.contains("Memory") {
            return "MemoryError"
        } else if description.contains("encoding") || description.contains("UTF") {
            return "EncodingError"
        } else if description.contains("too large") || description.contains("size") {
            return "FileSizeError"
        } else {
            return "UnknownError"
        }
    }

    private func getFileExtension(from fileName: String) -> String {
        return URL(fileURLWithPath: fileName).pathExtension.lowercased()
    }

    private func getErrorCode(from description: String) -> String {
        let pattern = "Error Domain=.*Code=(\\d+)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: description, range: NSRange(description.startIndex..., in: description)),
           let range = Range(match.range(at: 1), in: description) {
            return String(description[range])
        }
        return "unknown"
    }

    static func sanitizeErrorDescription(_ description: String) -> String {
        var sanitized = description

        sanitized = sanitized.replacingOccurrences(
            of: "/Users/[^/\\s]+",
            with: "/Users/[USER]",
            options: .regularExpression
        )

        sanitized = sanitized.replacingOccurrences(
            of: "(['\"])[^'\"]*\\.([a-zA-Z0-9]+)(['\"])",
            with: "$1[FILE].$2$3",
            options: .regularExpression
        )

        sanitized = sanitized.replacingOccurrences(
            of: "/[^\\s]*",
            with: "[PATH]",
            options: .regularExpression
        )

        return sanitized
    }

    func exportReportAsText() -> String {
        guard let report = currentReport else { return "No report available" }

        return """
        Trimbly Error Report - \(report.id)
        Generated: \(DateFormatter.localizedString(from: report.timestamp, dateStyle: .medium, timeStyle: .medium))
        
        === SYSTEM INFO ===
        App Version: \(report.appVersion)
        OS: \(report.systemInfo.osVersion)
        Architecture: \(report.systemInfo.architecture)
        Memory: \(report.systemInfo.memoryGB) GB
        Available Space: \(report.systemInfo.availableSpaceGB) GB
        
        === PROCESSING CONFIG ===
        Target Model: \(report.processingConfig.targetAIModel.rawValue)
        Output Format: \(report.processingConfig.outputFormat.rawValue)
        Files Attempted: \(report.processingConfig.totalFilesAttempted)
        Directories Scanned: \(report.processingConfig.totalDirectoriesScanned)
        File Types: \(report.processingConfig.fileTypesProcessed.joined(separator: ", "))
        
        Compression Options:
        - Remove Comments: \(report.processingConfig.compressionOptions.removeComments)
        - Remove Whitespace: \(report.processingConfig.compressionOptions.removeWhitespace)
        - Remove Documentation: \(report.processingConfig.compressionOptions.removeDocumentation)
        - Signatures Only: \(report.processingConfig.compressionOptions.signaturesOnly)
        - Structure Only: \(report.processingConfig.compressionOptions.structureOnly)
        - Skip Library Folders: \(report.processingConfig.compressionOptions.skipLibraryFolders)
        - Skip Localization: \(report.processingConfig.compressionOptions.skipLocalizationFiles)
        - Skip Documentation Files: \(report.processingConfig.compressionOptions.skipDocumentationFiles)
        - Max Lines: \(report.processingConfig.compressionOptions.maxLinesPerFile?.description ?? "No limit")
        - Max Tokens: \(report.processingConfig.compressionOptions.maxTokensPerFile?.description ?? "No limit")
        
        === PERFORMANCE ===
        Duration: \(String(format: "%.2f", report.performanceMetrics.processingDurationSeconds))s
        Memory Usage: \(report.performanceMetrics.memoryUsageMB) MB
        Tokens/Second: \(String(format: "%.0f", report.performanceMetrics.tokensProcessedPerSecond))
        Avg File Time: \(String(format: "%.2f", report.performanceMetrics.averageFileProcessingTimeMs))ms
        
        === ERRORS (\(report.errors.count)) ===
        \(report.errors.map { error in
            """
            Type: \(error.type) | Severity: \(error.severity) | Extension: .\(error.fileExtension)
            Size: \(error.fileSizeCategory) | Code: \(error.errorCode)
            Description: \(error.sanitizedDescription)
            """
        }.joined(separator: "\n\n"))
        
        === INSTRUCTIONS ===
        This report contains no personal data, file contents, or file paths.
        You can safely share this report for debugging assistance.
        Report ID: \(report.id)
        """
    }
}
