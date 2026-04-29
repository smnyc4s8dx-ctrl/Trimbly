import Foundation
import SwiftUI

enum OutputFormat: String, CaseIterable {
    case text = "text"
    case json = "json"
    case minimal = "minimal"
    case markdown = "markdown"

    var fileExtension: String {
        switch self {
        case .text: return "txt"
        case .json: return "json"
        case .minimal: return "min"
        case .markdown: return "md"
        }
    }
}

enum AIModel: String, CaseIterable {
    case openai = "OpenAI Model"
    case claude = "Claude"
    case claudeCodeCLI = "Claude Code CLI"
    case codellama = "CodeLlama"
    case gemini = "Gemini"
    case custom = "Custom"

    var contextWindow: Int {
        switch self {
        case .openai: return 128000
        case .claude: return 200000
        case .claudeCodeCLI: return 100000  // Conservative limit for CLI per-turn usage
        case .codellama: return 16384
        case .gemini: return 1000000
        case .custom: return 32000
        }
    }

    var tokenizer: TokenCounter.TokenizerType {
        switch self {
        case .openai: return .openai
        case .claude, .claudeCodeCLI: return .claude
        case .codellama, .gemini: return .llama
        case .custom: return .llama
        }
    }
}

enum ProgrammingLanguage: String, CaseIterable {
    case swift = "swift"
    case javascript = "js"
    case typescript = "ts"
    case python = "py"
    case java = "java"
    case csharp = "cs"
    case cpp = "cpp"
    case kotlin = "kt"
    case ruby = "rb"
    case php = "php"
    case rust = "rs"
    case go = "go"
    case objectivec = "m"
    case css = "css"
    case html = "html"
    case shell = "sh"
    case json = "json"
    case yaml = "yaml"
    case sql = "sql"
    case dockerfile = "dockerfile"
    case jupyter = "ipynb"
    case xml = "xml"
    case plist = "plist"
    case unknown = "unknown"

    static func detect(from ext: String) -> ProgrammingLanguage {
        switch ext.lowercased() {
            case "swift": return .swift
            case "js": return .javascript
            case "jsx": return .javascript
            case "ts": return .typescript
            case "tsx": return .typescript
            case "py": return .python
            case "java": return .java
            case "cs": return .csharp
            case "cpp", "cc", "cxx", "c++", "hpp", "hxx": return .cpp
            case "kt", "kts": return .kotlin
            case "rb": return .ruby
            case "php": return .php
            case "rs": return .rust
            case "go": return .go
            case "m", "mm": return .objectivec
            case "css", "scss", "sass", "less": return .css
            case "html", "htm": return .html
            case "vue": return .html
            case "svelte": return .html
            case "sh", "bash", "zsh", "fish": return .shell
            case "json": return .json
            case "yaml", "yml": return .yaml
            case "sql": return .sql
            case "dockerfile": return .dockerfile
            case "ipynb": return .jupyter
            case "xml", "storyboard", "xib": return .xml
            case "plist", "entitlements": return .plist
            default: return .unknown
        }
    }

    static func detectFromFileName(_ fileName: String) -> ProgrammingLanguage {
        let lowercaseName = fileName.lowercased()
        if lowercaseName == "dockerfile" || lowercaseName.hasPrefix("dockerfile.") {
            return .dockerfile
        }
        let components = fileName.components(separatedBy: ".")
        if let ext = components.last {
            return detect(from: ext)
        }
        return .unknown
    }

    var preservesWhitespace: Bool {
        switch self {
        case .python: return true
        case .yaml: return true
        case .unknown: return true
        default: return false
        }
    }
}

enum SemanticCompressionLevel: String, CaseIterable {
    case light = "Light (Zero Loss)"
    case medium = "Medium (Minimal Loss)"
    case aggressive = "Aggressive (Mild Loss)"
    case maximum = "Maximum (Overview)"

    var tokenReduction: String {
        switch self {
        case .light: return "40-60%"
        case .medium: return "60-75%"
        case .aggressive: return "75-90%"
        case .maximum: return "90-99%"
        }
    }

    var semanticLoss: String {
        switch self {
        case .light: return "0%"
        case .medium: return "<5%"
        case .aggressive: return "10-20%"
        case .maximum: return "70-80%"
        }
    }

    var description: String {
        switch self {
        case .light: return "Remove pure token waste"
        case .medium: return "Remove human-oriented docs"
        case .aggressive: return "Structure focus"
        case .maximum: return "Overview only"
        }
    }

    var color: Color {
        switch self {
        case .light: return .green
        case .medium: return .blue
        case .aggressive: return .orange
        case .maximum: return .red
        }
    }

    var icon: String {
        switch self {
        case .light: return "leaf"
        case .medium: return "scale.3d"
        case .aggressive: return "bolt"
        case .maximum: return "eye"
        }
    }
}

enum FileCategory {
    case normalCompression
    case alwaysInclude
    case excludeWithReference
    case autoExclude
}

struct CompressionOptions: Equatable {
    var semanticLevel: SemanticCompressionLevel = .medium
    var tokenizerType: TokenCounter.TokenizerType = .openai
    var removeComments: Bool = true
    var removeWhitespace: Bool = true
    var removeImports: Bool = true
    var removeEmptyLines: Bool = true
    var removeDocumentation: Bool = false
    var removeTypeAnnotations: Bool = false
    var removeDebugStatements: Bool = false
    var truncateFunctions: Bool = false
    var shortenIdentifiers: Bool = false
    var simplifyExpressions: Bool = false
    var structureOnly: Bool = false
    var signaturesOnly: Bool = false
    var smartAutoExclusion: Bool = true
    var prioritizePublicAPIs: Bool = true
    var keepMainFunctions: Bool = true
    var preserveSignificantWhitespace: Bool = true
    var skipLibraryFolders: Bool = true
    var skipLocalizationFiles: Bool = true
    var skipTestFiles: Bool = false
    var skipConfigFiles: Bool = false
    var skipDocumentationFiles: Bool = true
    var respectGitignore: Bool = true
    var skipXcodeUserData: Bool = false
    var skipBuildArtifacts: Bool = false
    var skipBackupFiles: Bool = false
    var skipTemporaryFiles: Bool = false
    var skipAssetCatalogs: Bool = false
    var maxLinesPerFile: Int? = nil
    var maxTokensPerFile: Int? = nil
    var preserveStructure: Bool = true
    var prioritizeTopLevel: Bool = true
    var compressionStrategy: CompressionStrategy = .balanced
    var targetFiles: Set<String> = []
    var targetDirectories: Set<String> = []

    static let light: CompressionOptions = {
        var opts = CompressionOptions()
        opts.semanticLevel = .light
        opts.applySemanticLevel()
        return opts
    }()

    static let medium: CompressionOptions = {
        var opts = CompressionOptions()
        opts.semanticLevel = .medium
        opts.applySemanticLevel()
        return opts
    }()

    static let aggressive: CompressionOptions = {
        var opts = CompressionOptions()
        opts.semanticLevel = .aggressive
        opts.applySemanticLevel()
        return opts
    }()

    static let maximum: CompressionOptions = {
        var opts = CompressionOptions()
        opts.semanticLevel = .maximum
        opts.applySemanticLevel()
        return opts
    }()
}

enum CompressionStrategy: String, CaseIterable {
    case minimal = "Minimal"
    case balanced = "Balanced"
    case aggressive = "Aggressive"
    case preserve = "Preserve"

    func apply(to options: inout CompressionOptions) {
        switch self {
        case .minimal:
            options.semanticLevel = .maximum
        case .balanced:
            options.semanticLevel = .medium
        case .aggressive:
            options.semanticLevel = .aggressive
        case .preserve:
            options.semanticLevel = .light
        }
        options.applySemanticLevel()
    }
}

struct ExcludedDirectoryInfo {
    let name: String
    let fileCount: Int
    let totalSize: String
    let primaryPackages: [String]
    let category: ExclusionCategory
}

enum ExclusionCategory: String {
    case dependencies = "Dependencies"
    case buildArtifacts = "Build Artifacts"
    case versionControl = "Version Control"
    case media = "Media Files"
    case cache = "Cache Files"
}

struct ProcessingConfiguration {
    let sourcePath: String
    let outputFileName: String
    let outputFormat: OutputFormat
    let compressionOptions: CompressionOptions
    let knowledgeMapping: Bool
    let hierarchicalSummary: Bool
    let qaMetadata: Bool
    let createDuplicate: Bool
    let duplicateSuffix: String
    let targetAIModel: AIModel
    let tokenBudget: Int?

    // Performance settings
    let maxProcessingTime: TimeInterval
    let maxMemoryUsage: Int
    let batchSize: Int
    let maxConcurrentFiles: Int

    init(sourcePath: String,
         outputFileName: String,
         outputFormat: OutputFormat,
         compressionOptions: CompressionOptions,
         knowledgeMapping: Bool,
         hierarchicalSummary: Bool,
         qaMetadata: Bool,
         createDuplicate: Bool,
         duplicateSuffix: String,
         targetAIModel: AIModel,
         tokenBudget: Int?) {

        self.sourcePath = sourcePath
        self.outputFileName = outputFileName
        self.outputFormat = outputFormat
        self.compressionOptions = compressionOptions
        self.knowledgeMapping = knowledgeMapping
        self.hierarchicalSummary = hierarchicalSummary
        self.qaMetadata = qaMetadata
        self.createDuplicate = createDuplicate
        self.duplicateSuffix = duplicateSuffix
        self.targetAIModel = targetAIModel
        self.tokenBudget = tokenBudget

        // Performance defaults
        self.maxProcessingTime = 600 // 10 minutes
        self.maxMemoryUsage = 300_000_000 // 300MB
        self.batchSize = 8
        self.maxConcurrentFiles = min(ProcessInfo.processInfo.processorCount, 4)
    }
}

struct CompressedCode {
    let content: String
    let originalTokens: Int
    let compressedTokens: Int
    let compressionRatio: Double
    let tokensRemoved: Int
    let semanticAccuracy: Double
}

struct CancellationError: LocalizedError {
    var errorDescription: String? { "Operation was cancelled" }
}

struct CompressionPreview {
    let estimatedTokens: Int
    let estimatedFileSize: String
    let compressionRatio: Double
    let worstCaseTokens: Int
    let fitsInContext: Bool
    let breakdown: [String: Int]
    let semanticAccuracy: Double
    let excludedDirectories: [ExcludedDirectoryInfo]
}

struct ProcessingError: Identifiable {
    let id = UUID()
    let fileName: String
    let error: String
    let severity: Severity

    enum Severity {
        case warning, error, critical
        var color: Color {
            switch self {
            case .warning: return .orange
            case .error: return .red
            case .critical: return .purple
            }
        }
    }
}

struct CodeStructure {
    let imports: [String]
    let classDeclarations: [String]
    let functionSignatures: [String]
    let publicAPIs: [String]
    let codeMetrics: CodeMetrics
    let identifierMap: [String: String]
    let dependencies: [String]
    let debugStatements: [String]
    let typeAnnotations: [String]
}

struct XcodeProjectStructure {
    let targets: [String]
    let buildConfigurations: [String]
    let dependencies: [String]
}

struct CodeMetrics {
    let linesOfCode: Int
    let cyclomaticComplexity: Int
    let tokenCount: Int
    let importCount: Int
    let functionCount: Int
    let classCount: Int
}

struct HierarchicalMap {
    let projectStructure: ProjectStructure
    let dependencyGraph: DependencyGraph
    let fileMetrics: [String: FileMetrics]
    let summary: ProjectSummary
    let excludedDirectories: [ExcludedDirectoryInfo]
}

struct ProjectStructure {
    let rootPath: String
    let directories: [DirectoryNode]
    let totalFiles: Int
    let totalDirectories: Int
    let excludedDirectories: [ExcludedDirectoryInfo]
}

struct DirectoryNode {
    let name: String
    let path: String
    let files: [FileNode]
    let subdirectories: [DirectoryNode]
    let depth: Int
    let category: FileCategory
}

struct FileNode {
    let name: String
    let path: String
    let language: ProgrammingLanguage
    let size: Int
    let compressionLevel: String
    let metrics: FileMetrics
    let category: FileCategory
}

struct DependencyGraph {
    let internalDeps: [Dependency]
    let externalDeps: [Dependency]
    let circular: [CircularDependency]
    let libraryDeps: [LibraryDependency]
}

struct LibraryDependency {
    let name: String
    let version: String?
    let source: DependencySource
}

enum DependencySource: String {
    case npm = "npm"
    case cocoapods = "CocoaPods"
    case swift_package = "Swift Package"
    case python_pip = "pip"
    case ruby_gem = "Ruby Gem"
    case go_module = "Go Module"
    case rust_crate = "Rust Crate"
    case maven = "Maven"
}

struct Dependency {
    let from: String
    let to: String
    let type: DependencyType
}

struct CircularDependency {
    let cycle: [String]
    let severity: String
}

enum DependencyType: String {
    case importStmt = "import"
    case include = "include"
    case require = "require"
    case reference = "reference"
}

struct FileMetrics {
    let linesOfCode: Int
    let functions: Int
    let classes: Int
    let interfaces: Int
    let complexity: Int
    let tokenCount: Int
}

struct ProjectSummary {
    let languages: [String: Int]
    let totalLinesOfCode: Int
    let totalFunctions: Int
    let totalClasses: Int
    let compressionRatio: Double
    let keyModules: [String]
    let libraryDependencies: [LibraryDependency]
}

extension CompressionOptions {
    mutating func applySemanticLevel() {
        switch semanticLevel {
        case .light:
            removeComments = true
            removeWhitespace = true
            removeImports = false
            removeEmptyLines = true
            removeDocumentation = false
            removeTypeAnnotations = false
            removeDebugStatements = false
            truncateFunctions = false
            shortenIdentifiers = false
            simplifyExpressions = false
            structureOnly = false
            signaturesOnly = false
            skipTestFiles = false
            skipConfigFiles = false
            skipDocumentationFiles = false
            skipXcodeUserData = false
            skipBuildArtifacts = true
            skipBackupFiles = true
            skipTemporaryFiles = true
            skipAssetCatalogs = false
            maxLinesPerFile = nil
            maxTokensPerFile = nil
        case .medium:
            removeComments = true
            removeWhitespace = true
            removeImports = true
            removeEmptyLines = true
            removeDocumentation = true
            removeTypeAnnotations = false
            removeDebugStatements = true
            truncateFunctions = false
            shortenIdentifiers = false
            simplifyExpressions = false
            structureOnly = false
            signaturesOnly = false
            skipTestFiles = true
            skipConfigFiles = true
            skipDocumentationFiles = true
            skipXcodeUserData = true
            skipBuildArtifacts = true
            skipBackupFiles = true
            skipTemporaryFiles = true
            skipAssetCatalogs = true
            maxLinesPerFile = 500
            maxTokensPerFile = 1000
        case .aggressive:
            removeComments = true
            removeWhitespace = true
            removeImports = true
            removeEmptyLines = true
            removeDocumentation = true
            removeTypeAnnotations = true
            removeDebugStatements = true
            truncateFunctions = true
            shortenIdentifiers = true
            simplifyExpressions = false
            structureOnly = false
            signaturesOnly = false
            skipTestFiles = true
            skipConfigFiles = false
            skipDocumentationFiles = true
            skipXcodeUserData = true
            skipBuildArtifacts = true
            skipBackupFiles = true
            skipTemporaryFiles = true
            skipAssetCatalogs = true
            maxLinesPerFile = 100
            maxTokensPerFile = 2000
        case .maximum:
            removeComments = true
            removeWhitespace = true
            removeImports = true
            removeEmptyLines = true
            removeDocumentation = true
            removeTypeAnnotations = true
            removeDebugStatements = true
            truncateFunctions = true
            shortenIdentifiers = true
            simplifyExpressions = false
            structureOnly = true
            signaturesOnly = true
            skipTestFiles = true
            skipConfigFiles = true
            skipDocumentationFiles = true
            skipXcodeUserData = true
            skipBuildArtifacts = true
            skipBackupFiles = true
            skipTemporaryFiles = true
            skipAssetCatalogs = true
            maxLinesPerFile = 30
            maxTokensPerFile = 500
        }
    }
}
