import Foundation

class SemanticAnalyzer {
    private let smartAnalyzer = SmartFileAnalyzer()

    func analyzeCodeStructure(_ code: String, language: ProgrammingLanguage, tokenizer: TokenCounter.TokenizerType = .openai) -> CodeStructure {
        let imports = extractImports(from: code, language: language)
        let classDeclarations = extractClassDeclarations(from: code, language: language)
        let functionSignatures = extractFunctionSignatures(from: code, language: language)
        let publicAPIs = extractPublicAPIs(from: code, language: language)
        let metrics = calculateMetrics(for: code, language: language, tokenizer: tokenizer)
        let identifierMap = createIdentifierMap(from: code)
        let dependencies = extractDependencies(from: imports)
        let debugStatements = extractDebugStatements(from: code, language: language)
        let typeAnnotations = extractTypeAnnotations(from: code, language: language)

        return CodeStructure(
            imports: imports,
            classDeclarations: classDeclarations,
            functionSignatures: functionSignatures,
            publicAPIs: publicAPIs,
            codeMetrics: metrics,
            identifierMap: identifierMap,
            dependencies: dependencies,
            debugStatements: debugStatements,
            typeAnnotations: typeAnnotations
        )
    }

    func generateHierarchicalMap(
        from rootPath: String,
        fileContents: [String: String],
        compressionLevels: [String: String],
        excludedDirectories: [ExcludedDirectoryInfo],
        libraryDependencies: [LibraryDependency],
        tokenizer: TokenCounter.TokenizerType = .openai
    ) -> HierarchicalMap {
        let projectStructure = buildProjectStructure(
            from: rootPath,
            fileContents: fileContents,
            compressionLevels: compressionLevels,
            excludedDirectories: excludedDirectories,
            tokenizer: tokenizer
        )

        let dependencyGraph = analyzeDependencies(
            fileContents: fileContents,
            libraryDependencies: libraryDependencies,
            tokenizer: tokenizer
        )

        let fileMetrics = calculateAllFileMetrics(fileContents: fileContents, tokenizer: tokenizer)

        let summary = generateProjectSummary(
            structure: projectStructure,
            dependencies: dependencyGraph,
            metrics: fileMetrics,
            libraryDependencies: libraryDependencies
        )

        return HierarchicalMap(
            projectStructure: projectStructure,
            dependencyGraph: dependencyGraph,
            fileMetrics: fileMetrics,
            summary: summary,
            excludedDirectories: excludedDirectories
        )
    }

    private func buildProjectStructure(
        from rootPath: String,
        fileContents: [String: String],
        compressionLevels: [String: String],
        excludedDirectories: [ExcludedDirectoryInfo],
        tokenizer: TokenCounter.TokenizerType
    ) -> ProjectStructure {
        let directories = buildDirectoryTree(
            at: rootPath,
            fileContents: fileContents,
            compressionLevels: compressionLevels,
            depth: 0,
            tokenizer: tokenizer
        )

        let totalFiles = fileContents.count
        let totalDirectories = countDirectories(in: directories)

        return ProjectStructure(
            rootPath: rootPath,
            directories: directories,
            totalFiles: totalFiles,
            totalDirectories: totalDirectories,
            excludedDirectories: excludedDirectories
        )
    }

    private func buildDirectoryTree(
        at path: String,
        fileContents: [String: String],
        compressionLevels: [String: String],
        depth: Int,
        tokenizer: TokenCounter.TokenizerType
    ) -> [DirectoryNode] {
        var directories: [DirectoryNode] = []

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: path)
            var currentFiles: [FileNode] = []
            var subdirs: [DirectoryNode] = []

            for item in items {
                let itemPath = (path as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false

                if FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    let category = smartAnalyzer.categorizeFile(path: itemPath)

                    if isDirectory.boolValue {
                        let subDirNodes = buildDirectoryTree(
                            at: itemPath,
                            fileContents: fileContents,
                            compressionLevels: compressionLevels,
                            depth: depth + 1,
                            tokenizer: tokenizer
                        )

                        if !subDirNodes.isEmpty || category == .excludeWithReference {
                            subdirs.append(contentsOf: subDirNodes)
                        }
                    } else if fileContents[itemPath] != nil {
                        let fileNode = createFileNode(
                            path: itemPath,
                            content: fileContents[itemPath]!,
                            compressionLevel: compressionLevels[itemPath] ?? "medium",
                            category: category,
                            tokenizer: tokenizer
                        )
                        currentFiles.append(fileNode)
                    }
                }
            }

            if !currentFiles.isEmpty || !subdirs.isEmpty {
                let dirCategory = smartAnalyzer.categorizeFile(path: path)
                let dirNode = DirectoryNode(
                    name: URL(fileURLWithPath: path).lastPathComponent,
                    path: path,
                    files: currentFiles,
                    subdirectories: subdirs,
                    depth: depth,
                    category: dirCategory
                )
                directories.append(dirNode)
            }
        } catch {
            print("Error reading directory \(path): \(error)")
        }

        return directories
    }

    private func createFileNode(
        path: String,
        content: String,
        compressionLevel: String,
        category: FileCategory,
        tokenizer: TokenCounter.TokenizerType
    ) -> FileNode {
        let fileName = URL(fileURLWithPath: path).lastPathComponent
        let language = ProgrammingLanguage.detectFromFileName(fileName)
        let size = content.count
        let metrics = calculateMetrics(for: content, language: language, tokenizer: tokenizer)

        return FileNode(
            name: fileName,
            path: path,
            language: language,
            size: size,
            compressionLevel: compressionLevel,
            metrics: FileMetrics(
                linesOfCode: metrics.linesOfCode,
                functions: metrics.functionCount,
                classes: metrics.classCount,
                interfaces: countInterfaces(in: extractClassDeclarations(from: content, language: language)),
                complexity: metrics.cyclomaticComplexity,
                tokenCount: metrics.tokenCount
            ),
            category: category
        )
    }

    private func analyzeDependencies(
        fileContents: [String: String],
        libraryDependencies: [LibraryDependency],
        tokenizer: TokenCounter.TokenizerType
    ) -> DependencyGraph {
        var internalDeps: [Dependency] = []
        var externalDeps: [Dependency] = []
        var allDeps: [String: Set<String>] = [:]

        for (filePath, content) in fileContents {
            let fileName = URL(fileURLWithPath: filePath).lastPathComponent
            let language = ProgrammingLanguage.detectFromFileName(fileName)
            let imports = extractImports(from: content, language: language)

            for importLine in imports {
                let dependency = extractDependencyName(from: importLine, language: language)
                let depType = getDependencyType(from: importLine, language: language)

                if isInternalDependency(dependency, fileContents: fileContents) {
                    internalDeps.append(Dependency(from: fileName, to: dependency, type: depType))
                } else {
                    externalDeps.append(Dependency(from: fileName, to: dependency, type: depType))
                }

                allDeps[fileName, default: Set()].insert(dependency)
            }
        }

        let circularDeps = detectCircularDependencies(dependencies: allDeps)

        return DependencyGraph(
            internalDeps: internalDeps,
            externalDeps: externalDeps,
            circular: circularDeps,
            libraryDeps: libraryDependencies
        )
    }

    private func calculateMetrics(for code: String, language: ProgrammingLanguage, tokenizer: TokenCounter.TokenizerType) -> CodeMetrics {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let imports = extractImports(from: code, language: language)
        let functions = extractFunctionSignatures(from: code, language: language)
        let classes = extractClassDeclarations(from: code, language: language)

        let complexityKeywords = ["if", "else", "for", "while", "switch", "case", "catch", "&&", "||"]
        let complexity = complexityKeywords.reduce(0) { total, keyword in
            total + code.components(separatedBy: keyword).count - 1
        }

        let tokenCount = TokenCounter.countTokens(in: code, using: tokenizer)

        return CodeMetrics(
            linesOfCode: nonEmptyLines.count,
            cyclomaticComplexity: complexity,
            tokenCount: tokenCount,
            importCount: imports.count,
            functionCount: functions.count,
            classCount: classes.count
        )
    }

    private func calculateAllFileMetrics(fileContents: [String: String], tokenizer: TokenCounter.TokenizerType) -> [String: FileMetrics] {
        var metrics: [String: FileMetrics] = [:]

        for (filePath, content) in fileContents {
            let fileName = URL(fileURLWithPath: filePath).lastPathComponent
            let language = ProgrammingLanguage.detectFromFileName(fileName)
            let codeMetrics = calculateMetrics(for: content, language: language, tokenizer: tokenizer)

            metrics[filePath] = FileMetrics(
                linesOfCode: codeMetrics.linesOfCode,
                functions: codeMetrics.functionCount,
                classes: codeMetrics.classCount,
                interfaces: countInterfaces(in: extractClassDeclarations(from: content, language: language)),
                complexity: codeMetrics.cyclomaticComplexity,
                tokenCount: codeMetrics.tokenCount
            )
        }

        return metrics
    }

    // MARK: - Helper methods (unchanged implementations)

    private func extractDebugStatements(from code: String, language: ProgrammingLanguage) -> [String] {
        let debugPatterns: [String] = {
            switch language {
            case .swift:
                return ["print\\(", "debugPrint\\(", "NSLog\\(", "os_log\\("]
            case .javascript, .typescript:
                return ["console\\.log\\(", "console\\.error\\(", "console\\.warn\\(", "debugger"]
            case .python:
                return ["print\\(", "pprint\\(", "logging\\.", "pdb\\."]
            default:
                return ["print", "log", "debug", "console"]
            }
        }()

        var statements: [String] = []
        let lines = code.components(separatedBy: .newlines)

        for line in lines {
            for pattern in debugPatterns {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    statements.append(line.trimmingCharacters(in: .whitespaces))
                    break
                }
            }
        }

        return statements
    }

    private func extractTypeAnnotations(from code: String, language: ProgrammingLanguage) -> [String] {
        var annotations: [String] = []

        switch language {
        case .typescript:
            let pattern = ":\\s*[A-Za-z<>\\[\\]|&]+"
            annotations = code.matches(of: pattern)
        case .python:
            let pattern = ":\\s*[A-Za-z\\[\\],\\s]+"
            annotations = code.matches(of: pattern)
        case .swift:
            let pattern = ":\\s*[A-Za-z<>\\[\\]?!]+"
            annotations = code.matches(of: pattern)
        default:
            break
        }

        return annotations
    }

    private func extractImports(from code: String, language: ProgrammingLanguage) -> [String] {
        let patterns: [String] = {
            switch language {
            case .swift:
                return ["^import\\s+\\w+"]
            case .javascript, .typescript:
                return ["^import\\s+.*from\\s+['\"].*['\"]", "^const\\s+.*=\\s+require\\("]
            case .python:
                return ["^import\\s+\\w+", "^from\\s+\\w+\\s+import"]
            case .java:
                return ["^import\\s+[\\w\\.]+;"]
            default:
                return ["^#include", "^import", "^using"]
            }
        }()

        let lines = code.components(separatedBy: .newlines)
        return extractMatchingLines(from: lines, patterns: patterns)
    }

    private func extractClassDeclarations(from code: String, language: ProgrammingLanguage) -> [String] {
        let patterns: [String] = {
            switch language {
            case .swift:
                return ["^class\\s+\\w+", "^struct\\s+\\w+", "^enum\\s+\\w+", "^protocol\\s+\\w+"]
            case .javascript, .typescript:
                return ["^class\\s+\\w+", "^interface\\s+\\w+", "^type\\s+\\w+"]
            case .python:
                return ["^class\\s+\\w+"]
            case .java:
                return ["^public\\s+class\\s+\\w+", "^class\\s+\\w+", "^interface\\s+\\w+"]
            default:
                return ["^class\\s+\\w+", "^struct\\s+\\w+"]
            }
        }()

        let lines = code.components(separatedBy: .newlines)
        return extractMatchingLines(from: lines, patterns: patterns)
    }

    private func extractFunctionSignatures(from code: String, language: ProgrammingLanguage) -> [String] {
        let patterns: [String] = {
            switch language {
            case .swift:
                return ["^\\s*func\\s+\\w+", "^\\s*init\\(", "^\\s*deinit"]
            case .javascript, .typescript:
                return ["^\\s*function\\s+\\w+", "^\\s*\\w+\\s*\\(", "^\\s*const\\s+\\w+\\s*=\\s*\\("]
            case .python:
                return ["^\\s*def\\s+\\w+", "^\\s*async\\s+def\\s+\\w+"]
            case .java:
                return ["^\\s*public\\s+.*\\s+\\w+\\(", "^\\s*private\\s+.*\\s+\\w+\\("]
            default:
                return ["^\\s*\\w+.*\\("]
            }
        }()

        let lines = code.components(separatedBy: .newlines)
        return extractMatchingLines(from: lines, patterns: patterns)
    }

    private func extractPublicAPIs(from code: String, language: ProgrammingLanguage) -> [String] {
        let lines = code.components(separatedBy: .newlines)

        let publicKeywords: [String] = {
            switch language {
            case .swift:
                return ["public", "open"]
            case .typescript:
                return ["export"]
            case .python:
                return lines.filter { !$0.hasPrefix("_") && ($0.contains("def ") || $0.contains("class ")) }
                    .map { _ in "public" }
            case .java, .csharp:
                return ["public"]
            case .xml:
                return lines.filter { $0.contains("customClass=") || $0.contains("storyboardIdentifier=") }
                    .map { _ in "public" }
            case .plist:
                return lines.filter { $0.contains("<key>") && !$0.contains("CFBundle") }
                    .map { _ in "public" }
            default:
                return []
            }
        }()

        return lines.filter { line in
            publicKeywords.contains { keyword in
                line.trimmingCharacters(in: .whitespaces).hasPrefix(keyword)
            }
        }
    }

    private func createIdentifierMap(from code: String) -> [String: String] {
        var identifierMap: [String: String] = [:]
        var counter = 1

        let identifierPattern = "\\b[a-zA-Z_][a-zA-Z0-9_]{3,}\\b"

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    if identifierMap[identifier] == nil && !containsDomainConcept(identifier) {
                        identifierMap[identifier] = "v\(counter)"
                        counter += 1
                    }
                }
            }
        } catch {
            print("Regex error: \(error)")
        }

        return identifierMap
    }

    private func containsDomainConcept(_ identifier: String) -> Bool {
        let domainTerms = ["String", "Array", "Dictionary", "Int", "Double", "Bool", "Data", "URL", "Date", "Color", "View", "Controller", "Manager", "Service", "Handler", "Delegate", "Protocol", "Interface"]
        return domainTerms.contains { identifier.localizedCaseInsensitiveContains($0) }
    }

    private func extractDependencies(from imports: [String]) -> [String] {
        return imports.compactMap { importLine in
            let components = importLine.components(separatedBy: .whitespaces)
            return components.count > 1 ? components[1] : nil
        }
    }

    private func extractMatchingLines(from lines: [String], patterns: [String]) -> [String] {
        return lines.compactMap { line in
            for pattern in patterns {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    return line.trimmingCharacters(in: .whitespaces)
                }
            }
            return nil
        }
    }

    private func detectCircularDependencies(dependencies: [String: Set<String>]) -> [CircularDependency] {
        var cycles: [CircularDependency] = []
        var visited: Set<String> = []
        var recursionStack: Set<String> = []

        func dfs(_ node: String, path: [String]) -> Bool {
            if recursionStack.contains(node) {
                if let cycleStart = path.firstIndex(of: node) {
                    let cycle = Array(path[cycleStart...]) + [node]
                    cycles.append(CircularDependency(cycle: cycle, severity: "medium"))
                    return true
                }
            }

            if visited.contains(node) { return false }

            visited.insert(node)
            recursionStack.insert(node)

            if let deps = dependencies[node] {
                for dep in deps {
                    if dfs(dep, path: path + [node]) {
                        break
                    }
                }
            }

            recursionStack.remove(node)
            return false
        }

        for node in dependencies.keys {
            if !visited.contains(node) {
                _ = dfs(node, path: [])
            }
        }

        return cycles
    }

    private func generateProjectSummary(
        structure: ProjectStructure,
        dependencies: DependencyGraph,
        metrics: [String: FileMetrics],
        libraryDependencies: [LibraryDependency]
    ) -> ProjectSummary {
        var languages: [String: Int] = [:]
        var totalLOC = 0
        var totalFunctions = 0
        var totalClasses = 0

        func countLanguagesInDir(_ dir: DirectoryNode) {
            for file in dir.files {
                let lang = file.language.rawValue
                languages[lang, default: 0] += 1
                totalLOC += file.metrics.linesOfCode
                totalFunctions += file.metrics.functions
                totalClasses += file.metrics.classes
            }
            for subdir in dir.subdirectories {
                countLanguagesInDir(subdir)
            }
        }

        for dir in structure.directories {
            countLanguagesInDir(dir)
        }

        let keyModules = identifyKeyModules(dependencies: dependencies, metrics: metrics)

        return ProjectSummary(
            languages: languages,
            totalLinesOfCode: totalLOC,
            totalFunctions: totalFunctions,
            totalClasses: totalClasses,
            compressionRatio: 1.0,
            keyModules: keyModules,
            libraryDependencies: libraryDependencies
        )
    }

    private func identifyKeyModules(dependencies: DependencyGraph, metrics: [String: FileMetrics]) -> [String] {
        var moduleImportance: [String: Int] = [:]

        for dep in dependencies.internalDeps {
            moduleImportance[dep.to, default: 0] += 1
        }

        for (fileName, metric) in metrics {
            let baseScore = moduleImportance[fileName, default: 0]
            let complexityBonus = metric.complexity > 10 ? 2 : 0
            let functionBonus = metric.functions > 5 ? 1 : 0
            moduleImportance[fileName] = baseScore + complexityBonus + functionBonus
        }

        return moduleImportance
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }

    private func countDirectories(in directories: [DirectoryNode]) -> Int {
        return directories.count + directories.reduce(0) { total, dir in
            total + countDirectories(in: dir.subdirectories)
        }
    }

    private func countInterfaces(in classDeclarations: [String]) -> Int {
        return classDeclarations.filter { $0.contains("interface") || $0.contains("protocol") }.count
    }

    private func extractDependencyName(from importLine: String, language: ProgrammingLanguage) -> String {
        switch language {
        case .swift:
            return importLine.replacingOccurrences(of: "import ", with: "")
                .trimmingCharacters(in: .whitespaces)
        default:
            return importLine.components(separatedBy: .whitespaces).last ?? ""
        }
    }

    private func getDependencyType(from importLine: String, language: ProgrammingLanguage) -> DependencyType {
        switch language {
        case .swift, .python, .javascript, .typescript:
            return .importStmt
        case .cpp:
            return .include
        default:
            return .reference
        }
    }

    private func isInternalDependency(_ dependency: String, fileContents: [String: String]) -> Bool {
        for filePath in fileContents.keys {
            if URL(fileURLWithPath: filePath).lastPathComponent.contains(dependency) {
                return true
            }
        }
        return false
    }
}
