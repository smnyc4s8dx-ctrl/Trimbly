import Foundation

class PythonOptimizer: LanguageOptimizer {

    // MARK: - Main Entry Point
    func optimizeCompression(_ code: String, options: CompressionOptions) -> CompressedResult {
        let originalTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        let processedContent = preserveLanguageSemantics(code, options: options)
        let compressedTokens = TokenCounter.countTokens(in: processedContent, using: options.tokenizerType)
        let semanticAccuracy = calculateSemanticAccuracy(options: options)
        let patterns = identifyCriticalPatterns(code)

        return CompressedResult(
            content: processedContent,
            originalTokens: originalTokens,
            compressedTokens: compressedTokens,
            semanticAccuracy: semanticAccuracy,
            preservedPatterns: patterns
        )
    }

    // MARK: - Core Compression Logic
    func preserveLanguageSemantics(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Step 1: Apply basic compression options first
        processed = applyBasicCompressionOptions(processed, options: options)

        // Step 2: Apply semantic level-specific compression
        processed = applySemanticLevelCompression(processed, options: options)

        // Step 3: Apply advanced compression options
        processed = applyAdvancedCompressionOptions(processed, options: options)

        return processed
    }

    // MARK: - Basic Compression Options
    private func applyBasicCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeComments {
            processed = removeLanguageComments(processed)
        }

        if options.removeWhitespace {
            processed = removeExcessWhitespace(processed, options: options)
        }

        if options.removeEmptyLines {
            processed = removeEmptyLines(processed, options: options)
        }

        if options.removeImports {
            processed = removeImportStatements(processed, options: options)
        }

        if options.removeDocumentation {
            processed = removeDocumentation(processed, options: options)
        }

        if options.removeDebugStatements {
            processed = removeDebugStatements(processed)
        }

        return processed
    }

    // MARK: - Semantic Level Compression
    private func applySemanticLevelCompression(_ code: String, options: CompressionOptions) -> String {
        switch options.semanticLevel {
        case .light:
            return preserveLanguageKeyPatterns(code, options: options)
        case .medium:
            return preserveLanguageArchitecture(code, options: options)
        case .aggressive:
            return preserveLanguagePublicAPIs(code, options: options)
        case .maximum:
            return extractLanguageSignatures(code, options: options)
        }
    }

    // MARK: - Advanced Compression Options
    private func applyAdvancedCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeTypeAnnotations {
            processed = removeTypeAnnotations(processed, options: options)
        }

        if options.truncateFunctions {
            processed = truncateFunctionBodies(processed, options: options)
        }

        if options.shortenIdentifiers {
            processed = shortenIdentifiers(processed, options: options)
        }

        if options.signaturesOnly {
            processed = extractSignaturesOnly(processed, options: options)
        }

        if options.structureOnly {
            processed = extractStructureOnly(processed, options: options)
        }

        // Apply file size limits if specified
        if let maxLines = options.maxLinesPerFile {
            processed = limitFileLines(processed, maxLines: maxLines, options: options)
        }

        if let maxTokens = options.maxTokensPerFile {
            processed = limitFileTokens(processed, maxTokens: maxTokens, options: options)
        }

        return processed
    }

    // MARK: - Language-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Remove Python single-line comments, but preserve shebang and encoding
        let lines = processed.components(separatedBy: .newlines)
        let filteredLines = lines.enumerated().compactMap { index, line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep shebang and encoding declarations
            if index == 0 && trimmed.hasPrefix("#!") {
                return line
            }
            if index <= 2 && (trimmed.contains("coding:") || trimmed.contains("encoding:")) {
                return line
            }

            // Remove other comments
            if let hashIndex = line.firstIndex(of: "#") {
                let beforeHash = String(line[..<hashIndex]).trimmingCharacters(in: .whitespaces)
                return beforeHash.isEmpty ? nil : beforeHash
            }

            return line.isEmpty ? nil : line
        }

        return filteredLines.joined(separator: "\n")
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        // Python preserves significant whitespace - only remove trailing whitespace
        if options.preserveSignificantWhitespace || languagePreservesWhitespace() {
            return code.components(separatedBy: .newlines)
                .map { $0.replacingOccurrences(of: #"\s+$"#, with: "", options: .regularExpression) }
                .joined(separator: "\n")
        } else {
            // Still preserve Python indentation structure
            return preservePythonWhitespace(code)
        }
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.prioritizePublicAPIs {
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "# PRESERVED_IMPORT_\(index)"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            processed = removeStandardImports(processed)

            for (placeholder, importStatement) in preservedImports {
                processed = processed.replacingOccurrences(of: placeholder, with: importStatement)
            }
        } else {
            processed = removeStandardImports(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        return compressPythonDocstrings(code)
    }

    private func removeDebugStatements(_ code: String) -> String {
        let debugPatterns = [
            #"print\([^)]*\)"#,
            #"pprint\([^)]*\)"#,
            #"logging\.debug\([^)]*\)"#,
            #"logger\.debug\([^)]*\)"#,
            #"breakpoint\(\)"#,
            #"pdb\.set_trace\(\)"#,
            #"ipdb\.set_trace\(\)"#
        ]

        var processed = code
        for pattern in debugPatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeTypeAnnotations(_ code: String, options: CompressionOptions) -> String {
        if options.prioritizePublicAPIs {
            return code // Keep type annotations for public APIs
        }

        let typePatterns = [
            #":\s*int\b"#,
            #":\s*str\b"#,
            #":\s*float\b"#,
            #":\s*bool\b"#,
            #":\s*list\b"#,
            #":\s*dict\b"#
        ]

        var processed = code
        for pattern in typePatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        var processed = code
        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "# PRESERVED_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = compressPythonMethodBodies(processed)

        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenIdentifiers(_ code: String, options: CompressionOptions) -> String {
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        let identifierPattern = getIdentifierPattern()

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    if !isCriticalIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = generateShortIdentifier(counter)
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in identifier shortening: \(error)")
        }

        for (original, shortened) in identifierMap {
            processed = processed.replacingOccurrences(
                of: "\\b\(NSRegularExpression.escapedPattern(for: original))\\b",
                with: shortened,
                options: .regularExpression
            )
        }

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        return extractPythonSignaturesAndDecorators(code)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)
        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        return preservePythonFeatures(code)
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        return preservePythonArchitecture(code)
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract public elements
        let decorators = extractDecorators(code)
        let publicFunctions = extractPublicFunctions(code)
        let classes = extractClasses(code)
        let constants = extractConstants(code)

        // Preserve only public elements
        var preservedPatterns: [String: String] = [:]
        var counter = 0

        let publicElements = decorators.filter { isPublicDecorator($0) } +
                           publicFunctions + classes + constants

        for element in publicElements {
            let placeholder = "# PUBLIC_\(counter)"
            preservedPatterns[placeholder] = element
            processed = processed.replacingOccurrences(of: element, with: placeholder)
            counter += 1
        }

        // Aggressive compression
        processed = compressPythonMethodBodies(processed)
        processed = compressPythonDocstrings(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        return extractPythonSignaturesAndDecorators(code)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return true // Python preserves indentation
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let criticalPatterns = [
            #"from\s+__future__\s+import\s+[^\n]+"#,
            #"import\s+(?:os|sys|typing|abc|dataclasses)\b[^\n]*"#,
            #"from\s+typing\s+import\s+[^\n]+"#,
            #"import\s+(?:pandas|numpy|sklearn|tensorflow|torch)\b[^\n]*"#,
            #"from\s+(?:django|flask|fastapi)\s+[^\n]+"#
        ]

        var imports: [String] = []
        for pattern in criticalPatterns {
            imports.append(contentsOf: code.matches(of: pattern))
        }
        return imports
    }

    private func removeStandardImports(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.hasPrefix("import ") && !trimmed.hasPrefix("from ")
        }
        return filteredLines.joined(separator: "\n")
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract critical patterns within function bodies
        let patterns = extractDecorators(code) +
                      extractAsyncPatterns(code) +
                      extractDataSciencePatterns(code) +
                      extractContextManagers(code)

        return patterns.filter { isCriticalPattern($0) }
    }

    private func getFunctionBodyPattern() -> String {
        return #"(def\s+\w+\([^)]*\):)[^}]*?(?=\n\w|\nclass|\ndef|\n$|\Z)"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1\n    # implementation"
    }

    private func getIdentifierPattern() -> String {
        return #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return isPublicIdentifier(identifier)
        }
        return isKeywordOrBuiltin(identifier)
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func isLanguageSignature(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("def ") ||
               trimmed.hasPrefix("async def ") ||
               trimmed.hasPrefix("class ") ||
               trimmed.hasPrefix("@")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("def ") ||
               trimmed.hasPrefix("class ") ||
               trimmed.hasPrefix("@") ||
               isConstantAssignment(trimmed)
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        return !identifier.hasPrefix("_") || identifier.hasPrefix("__") && identifier.hasSuffix("__")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let pythonKeywords = [
            "and", "as", "assert", "break", "class", "continue", "def", "del",
            "elif", "else", "except", "exec", "finally", "for", "from", "global",
            "if", "import", "in", "is", "lambda", "not", "or", "pass", "print",
            "raise", "return", "try", "while", "with", "yield", "async", "await"
        ]

        let pythonBuiltins = [
            "abs", "all", "any", "bin", "bool", "bytearray", "bytes", "callable",
            "chr", "classmethod", "compile", "complex", "delattr", "dict", "dir",
            "divmod", "enumerate", "eval", "exec", "filter", "float", "format",
            "frozenset", "getattr", "globals", "hasattr", "hash", "help", "hex",
            "id", "input", "int", "isinstance", "issubclass", "iter", "len",
            "list", "locals", "map", "max", "memoryview", "min", "next", "object",
            "oct", "open", "ord", "pow", "print", "property", "range", "repr",
            "reversed", "round", "set", "setattr", "slice", "sorted", "staticmethod",
            "str", "sum", "super", "tuple", "type", "vars", "zip"
        ]

        return pythonKeywords.contains(identifier) || pythonBuiltins.contains(identifier)
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        var result: [String] = []
        var importLines: [String] = []
        var classLines: [String] = []
        var functionLines: [String] = []
        var decoratorLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") || trimmed.hasPrefix("from ") {
                importLines.append(line)
            } else if trimmed.hasPrefix("@") {
                decoratorLines.append(line)
            } else if trimmed.hasPrefix("class ") {
                classLines.append(line)
            } else if trimmed.hasPrefix("def ") || trimmed.hasPrefix("async def ") {
                functionLines.append(line)
            } else if result.count < maxLines {
                result.append(line)
            }
        }

        let prioritized = importLines + decoratorLines + classLines + functionLines + result
        return Array(prioritized.prefix(maxLines)).joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // Progressive reduction steps
        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = removeDocumentation(processed, options: options)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = truncateFunctionBodies(processed, options: options)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = extractSignaturesOnly(processed, options: options)
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        let functionCount = code.matches(of: #"def\s+\w+"#).count
        let classCount = code.matches(of: #"class\s+\w+"#).count
        let importCount = code.matches(of: #"^(?:import|from)\s+"#).count

        return [
            "lines": nonEmptyLines.count,
            "functions": functionCount,
            "classes": classCount,
            "imports": importCount,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        let decorators = extractDecorators(code)
        let asyncPatterns = extractAsyncPatterns(code)
        let dataScience = extractDataSciencePatterns(code)
        let frameworks = extractFrameworkPatterns(code)

        return [
            "decorators": decorators.count,
            "async_functions": asyncPatterns.count,
            "data_science_patterns": dataScience.count,
            "framework_patterns": frameworks.count
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let functions = metrics["functions"] as? Int ?? 0
        let classes = metrics["classes"] as? Int ?? 0
        let decorators = structure["decorators"] as? Int ?? 0
        let asyncFunctions = structure["async_functions"] as? Int ?? 0

        return """
        # Python Project Structure
        Lines: \(lines)
        Functions: \(functions)
        Classes: \(classes)
        Decorators: \(decorators)
        Async Functions: \(asyncFunctions)
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.92
        case .aggressive: return 0.85
        case .maximum: return 0.63
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let decorators = extractDecorators(code)
        patterns.append(contentsOf: decorators.map { .decorator($0) })

        let comprehensions = extractComprehensions(code)
        patterns.append(contentsOf: comprehensions.map { .macro($0) })

        let contextManagers = extractContextManagers(code)
        patterns.append(contentsOf: contextManagers.map { .lifecycle($0) })

        let asyncPatterns = extractAsyncPatterns(code)
        patterns.append(contentsOf: asyncPatterns.map { .lifecycle($0) })

        let dataScience = extractDataSciencePatterns(code)
        patterns.append(contentsOf: dataScience.map { .macro($0) })

        let frameworks = extractFrameworkPatterns(code)
        patterns.append(contentsOf: frameworks.map { .interface($0) })

        return patterns
    }

    // MARK: - Enhanced Pattern Extraction (Original Python-specific methods)

    private func extractDecorators(_ code: String) -> [String] {
        let patterns = [
            #"@\w+(?:\([^)]*\))?"#,
            #"@property"#,
            #"@staticmethod"#,
            #"@classmethod"#,
            #"@functools\.wraps\([^)]+\)"#,
            #"@functools\.lru_cache\([^)]*\)"#,
            #"@dataclass(?:\([^)]*\))?"#,
            #"@app\.route\([^)]+\)"#,
            #"@api\.route\([^)]+\)"#,
            #"@login_required"#,
            #"@require_http_methods\([^)]+\)"#,
            #"@transaction\.atomic"#,
            #"@cache\.memoize\([^)]*\)"#,
            #"@pytest\.fixture(?:\([^)]*\))?"#,
            #"@pytest\.mark\.\w+(?:\([^)]*\))?"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractComprehensions(_ code: String) -> [String] {
        let patterns = [
            #"\[[^\]]*for\s+\w+\s+in[^\]]*\]"#,
            #"\{[^}]*for\s+\w+\s+in[^}]*\}"#,
            #"\([^)]*for\s+\w+\s+in[^)]*\)"#,
            #"\[[^\]]*for\s+\w+\s+in[^\]]*if[^\]]*\]"#,
            #"\{[^}]*:\s*[^}]*for\s+\w+\s+in[^}]*\}"#,
            #"\{[^}]*for\s+\w+\s+in[^}]*if[^}]*\}"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractContextManagers(_ code: String) -> [String] {
        let patterns = [
            #"with\s+[^:]+:"#,
            #"with\s+open\([^)]+\)\s+as\s+\w+:"#,
            #"with\s+\w+\([^)]*\)\s+as\s+\w+:"#,
            #"with\s+[\w.]+\([^)]*\):"#,
            #"async\s+with\s+[^:]+:"#,
            #"@contextmanager"#,
            #"@asynccontextmanager"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractAsyncPatterns(_ code: String) -> [String] {
        let patterns = [
            #"async\s+def\s+\w+\([^)]*\):"#,
            #"await\s+[^\n]+"#,
            #"async\s+for\s+\w+\s+in\s+[^:]+"#,
            #"async\s+with\s+[^:]+"#,
            #"asyncio\.\w+\([^)]*\)"#,
            #"create_task\([^)]+\)"#,
            #"gather\([^)]+\)"#,
            #"ensure_future\([^)]+\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractDataSciencePatterns(_ code: String) -> [String] {
        let patterns = [
            // Pandas patterns
            #"pd\.read_(?:csv|json|excel|sql|parquet|feather)\([^)]+\)"#,
            #"\.(?:groupby|merge|join|concat|pivot_table)\([^)]+\)"#,
            #"\.(?:apply|map|filter|transform)\([^)]+\)"#,
            #"\.(?:fillna|dropna|isna|notna)\([^)]*\)"#,
            #"\.(?:loc|iloc)\[[^\]]+\]"#,

            // NumPy patterns
            #"np\.(?:array|zeros|ones|full|empty|arange|linspace)\([^)]+\)"#,
            #"np\.(?:mean|std|var|sum|min|max|median)\([^)]+\)"#,
            #"np\.(?:dot|matmul|cross|outer)\([^)]+\)"#,
            #"np\.(?:reshape|transpose|flatten)\([^)]*\)"#,

            // Scikit-learn patterns
            #"sklearn\.\w+\.\w+\([^)]*\)"#,
            #"\.fit\([^)]+\)"#,
            #"\.predict\([^)]+\)"#,
            #"\.transform\([^)]+\)"#,
            #"\.fit_transform\([^)]+\)"#,
            #"train_test_split\([^)]+\)"#,
            #"cross_val_score\([^)]+\)"#,
            #"GridSearchCV\([^)]+\)"#,

            // Matplotlib/Seaborn patterns
            #"plt\.(?:plot|scatter|bar|hist|boxplot|show|savefig)\([^)]*\)"#,
            #"sns\.(?:scatterplot|barplot|histplot|boxplot|heatmap)\([^)]*\)"#,

            // TensorFlow/PyTorch patterns
            #"tf\.(?:keras|layers|optimizers)\.\w+\([^)]*\)"#,
            #"torch\.(?:nn|optim|tensor)\.\w+\([^)]*\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractFrameworkPatterns(_ code: String) -> [String] {
        let patterns = [
            // Django patterns
            #"models\.\w+\([^)]*\)"#,
            #"forms\.\w+\([^)]*\)"#,
            #"views\.\w+\([^)]*\)"#,
            #"serializers\.\w+\([^)]*\)"#,
            #"@require_(?:GET|POST|PUT|DELETE)"#,
            #"@login_required"#,
            #"@staff_member_required"#,
            #"@permission_required\([^)]+\)"#,
            #"Q\([^)]+\)"#,
            #"F\([^)]+\)"#,

            // Flask patterns
            #"@app\.route\([^)]+\)"#,
            #"@bp\.route\([^)]+\)"#,
            #"request\.\w+"#,
            #"session\[[^\]]+\]"#,
            #"flash\([^)]+\)"#,
            #"render_template\([^)]+\)"#,
            #"redirect\([^)]+\)"#,
            #"url_for\([^)]+\)"#,

            // FastAPI patterns
            #"@app\.(?:get|post|put|delete|patch)\([^)]+\)"#,
            #"@router\.(?:get|post|put|delete|patch)\([^)]+\)"#,
            #"Depends\([^)]+\)"#,
            #"HTTPException\([^)]+\)"#,
            #"BackgroundTasks"#,

            // SQLAlchemy patterns
            #"Column\([^)]+\)"#,
            #"relationship\([^)]+\)"#,
            #"backref\([^)]+\)"#,
            #"ForeignKey\([^)]+\)"#,
            #"db\.session\.\w+\([^)]*\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // Additional helper methods for the new structure
    private func extractPublicFunctions(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return (trimmed.hasPrefix("def ") || trimmed.hasPrefix("async def ")) &&
                   !trimmed.contains("def _") // Not private
        }
    }

    private func extractClasses(_ code: String) -> [String] {
        return code.matches(of: #"class\s+\w+[^:]*:"#)
    }

    private func extractConstants(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            isConstantAssignment(line.trimmingCharacters(in: .whitespaces))
        }
    }

    private func isPublicDecorator(_ decorator: String) -> Bool {
        let publicDecorators = [
            "@property", "@staticmethod", "@classmethod",
            "@app.route", "@api.route", "@dataclass"
        ]
        return publicDecorators.contains { decorator.contains($0) }
    }

    private func isCriticalPattern(_ pattern: String) -> Bool {
        let criticalKeywords = [
            "@app.route", "@api.route", "@property", "@staticmethod", "@classmethod",
            "async def", "await", "with", "for", "in", "if",
            "def __init__", "def __str__", "def __repr__",
            "pd.read_", ".fit(", ".predict(", ".transform("
        ]

        return criticalKeywords.contains { pattern.contains($0) }
    }

    private func isArchitecturalPattern(_ pattern: String) -> Bool {
        let architecturalKeywords = [
            "class", "def", "@", "import", "from", "async", "with"
        ]

        return architecturalKeywords.contains { pattern.contains($0) }
    }

    private func isFrameworkPattern(_ pattern: String) -> Bool {
        let frameworkKeywords = [
            "Django", "Flask", "FastAPI", "SQLAlchemy", "pandas", "numpy",
            "sklearn", "tensorflow", "torch", "matplotlib", "seaborn"
        ]

        return frameworkKeywords.contains { pattern.lowercased().contains($0.lowercased()) }
    }

    private func isDataSciencePattern(_ pattern: String) -> Bool {
        let dataScienceKeywords = [
            "pd.", "np.", "plt.", "sns.", "sklearn.", "tf.", "torch."
        ]

        return dataScienceKeywords.contains { pattern.contains($0) }
    }

    private func preservePythonWhitespace(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        return lines.compactMap { line in
            let trimmedEnd = line.replacingOccurrences(of: #"\s+$"#, with: "", options: .regularExpression)
            return trimmedEnd.isEmpty ? nil : trimmedEnd
        }.joined(separator: "\n")
    }

    private func preservePythonFeatures(_ code: String) -> String {
        var processed = code

        // Extract all patterns and preserve most of them
        let decorators = extractDecorators(code)
        let comprehensions = extractComprehensions(code)
        let contextManagers = extractContextManagers(code)
        let asyncPatterns = extractAsyncPatterns(code)
        let dataScience = extractDataSciencePatterns(code)
        let frameworks = extractFrameworkPatterns(code)

        // Create placeholder maps
        var preservedPatterns: [String: String] = [:]
        var placeholderCounter = 0

        // Preserve all critical patterns
        let allPatterns = decorators + comprehensions + contextManagers + asyncPatterns +
                         dataScience + frameworks

        for pattern in allPatterns {
            let placeholder = "# PRESERVED_\(placeholderCounter)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            placeholderCounter += 1
        }

        // Apply whitespace preservation and comment removal
        processed = preservePythonWhitespace(processed)
        processed = removeRedundantComments(processed)

        // Restore all preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preservePythonArchitecture(_ code: String) -> String {
        var processed = code

        // Extract patterns and classify them
        let decorators = extractDecorators(code)
        let comprehensions = extractComprehensions(code)
        let contextManagers = extractContextManagers(code)
        let asyncPatterns = extractAsyncPatterns(code)
        let dataScience = extractDataSciencePatterns(code)
        let frameworks = extractFrameworkPatterns(code)

        // Preserve only critical and architectural patterns
        var preservedPatterns: [String: String] = [:]
        var placeholderCounter = 0

        let allPatterns = decorators + comprehensions + contextManagers + asyncPatterns +
                         dataScience + frameworks

        for pattern in allPatterns {
            if isCriticalPattern(pattern) || isArchitecturalPattern(pattern) ||
               isFrameworkPattern(pattern) || isDataSciencePattern(pattern) {
                let placeholder = "# PRESERVED_\(placeholderCounter)"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
                placeholderCounter += 1
            }
        }

        // Compress method bodies while preserving structure
        processed = compressPythonMethodBodies(processed)

        // Remove docstrings in aggressive mode
        processed = compressPythonDocstrings(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressPythonDocstrings(_ code: String) -> String {
        var processed = code

        // Remove triple-quoted docstrings but preserve critical ones
        let criticalDocstrings = [
            #"\"\"\".*(?:Args|Arguments|Parameters|Returns|Yields|Raises|Example|Examples|Note|Warning).*\"\"\""#
        ]

        var preservedDocs: [String: String] = [:]
        var docCounter = 0

        // Preserve critical docstrings
        for pattern in criticalDocstrings {
            let matches = processed.matches(of: pattern)
            for match in matches {
                let placeholder = "# DOCSTRING_\(docCounter)"
                preservedDocs[placeholder] = match
                processed = processed.replacingOccurrences(of: match, with: placeholder)
                docCounter += 1
            }
        }

        // Remove other docstrings
        processed = processed.replacingOccurrences(
            of: #"\"\"\"[^\"]*\"\"\""#,
            with: "",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"'''[^']*'''"#,
            with: "",
            options: .regularExpression
        )

        // Restore critical docstrings
        for (placeholder, docstring) in preservedDocs {
            processed = processed.replacingOccurrences(of: placeholder, with: docstring)
        }

        return processed
    }

    private func compressPythonMethodBodies(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []
        var inMethod = false
        var methodIndent = 0
        var currentIndent = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            currentIndent = line.count - line.trimmingCharacters(in: .whitespaces).count

            // Detect method/function start
            if trimmed.hasPrefix("def ") || trimmed.hasPrefix("async def ") {
                result.append(line)
                inMethod = true
                methodIndent = currentIndent
                continue
            }

            // Detect method end
            if inMethod && currentIndent <= methodIndent && !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                inMethod = false
            }

            if inMethod {
                // Preserve critical patterns in method bodies
                if trimmed.hasPrefix("if ") || trimmed.hasPrefix("elif ") || trimmed.hasPrefix("else:") ||
                   trimmed.hasPrefix("for ") || trimmed.hasPrefix("while ") ||
                   trimmed.hasPrefix("try:") || trimmed.hasPrefix("except ") || trimmed.hasPrefix("finally:") ||
                   trimmed.hasPrefix("with ") || trimmed.hasPrefix("async with ") ||
                   trimmed.hasPrefix("return ") || trimmed.hasPrefix("yield ") ||
                   trimmed.hasPrefix("raise ") || trimmed.hasPrefix("assert ") ||
                   trimmed.hasPrefix("await ") || trimmed.contains("=") ||
                   isCriticalPattern(trimmed) || isDataSciencePattern(trimmed) {
                    result.append(line)
                }
                // Skip implementation details but keep structure
            } else {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractPythonSignaturesAndDecorators(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep imports
            if trimmed.hasPrefix("import ") || trimmed.hasPrefix("from ") {
                result.append(line)
            }
            // Keep class definitions
            else if trimmed.hasPrefix("class ") {
                result.append(line)
            }
            // Keep function signatures
            else if trimmed.hasPrefix("def ") || trimmed.hasPrefix("async def ") {
                result.append(line)
            }
            // Keep decorators
            else if trimmed.hasPrefix("@") {
                result.append(line)
            }
            // Keep critical assignments and constants
            else if trimmed.contains(" = ") &&
                    (isConstantAssignment(trimmed) || // Constants
                     trimmed.contains("CONFIG") || trimmed.contains("SETTINGS") ||
                     isDataSciencePattern(trimmed) || isFrameworkPattern(trimmed)) {
                result.append(line)
            }
            // Keep framework patterns
            else if isFrameworkPattern(trimmed) || isDataSciencePattern(trimmed) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func isConstantAssignment(_ line: String) -> Bool {
        // Check if the line looks like a constant assignment (all uppercase variable)
        let components = line.components(separatedBy: " = ")
        guard let variablePart = components.first else { return false }
        let variableName = variablePart.trimmingCharacters(in: .whitespaces)

        // Check if variable name is all uppercase (Python constant convention)
        return variableName == variableName.uppercased() &&
               variableName.allSatisfy { $0.isLetter || $0 == "_" || $0.isNumber }
    }

    private func removeRedundantComments(_ code: String) -> String {
        var processed = code.replacingOccurrences(
            of: #"#\s*TODO[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"#\s*FIXME[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"#\s*XXX[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
        return processed
    }
}
