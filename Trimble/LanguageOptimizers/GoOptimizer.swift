import Foundation

class GoOptimizer: LanguageOptimizer {

    // MARK: - Main Entry Point
    func optimizeCompression(_ code: String, options: CompressionOptions) -> CompressedResult {
        let originalTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        let processedContent = preserveLanguageSemantics(code, options: options)
        let compressedTokens = TokenCounter.countTokens(in: processedContent, using: options.tokenizerType)
        let semanticAccuracy = calculateGoSemanticAccuracy(options: options)
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
            return preserveGoStructure(code, options: options)
        case .medium:
            return preserveGoInterfaces(code, options: options)
        case .aggressive:
            return preserveGoArchitecture(code, options: options)
        case .maximum:
            return extractGoSignatures(code, options: options)
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

    // MARK: - Go-Specific Language Implementation

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Preserve important Go comments (build tags, go:generate, etc.)
        processed = processed.replacingOccurrences(
            of: #"//(?!\s*(?:go:build|go:generate|\+build|TODO|FIXME|NOTE|HACK))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line comments but preserve important ones
        processed = processed.replacingOccurrences(
            of: #"/\*(?!.*(?:\+build|go:))[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Go doesn't have significant whitespace like Python
        processed = processed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.prioritizePublicAPIs {
            // Preserve critical imports
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            // Remove standard imports
            processed = removeStandardImports(processed)

            // Restore critical imports
            for (placeholder, importStatement) in preservedImports {
                processed = processed.replacingOccurrences(of: placeholder, with: importStatement)
            }
        } else {
            processed = removeStandardImports(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove Go doc comments but preserve package comments
        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #"//\s*[A-Z][a-zA-Z0-9_]*\s+[^\n]+\n"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        let debugPatterns = [
            #"fmt\.Print[fl]?n?\([^)]*\)"#,
            #"log\.Print[fl]?n?\([^)]*\)"#,
            #"panic\([^)]*\)"#
        ]

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
        // Go type annotations are generally critical, only remove in very specific cases
        return code
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        return compressGoFunctionBodies(code, options: options)
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

        // Apply identifier mapping
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
        return extractGoSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code)
        let structure = extractGoStructure(code, options: options)
        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveGoStructure(_ code: String, options: CompressionOptions) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveGoInterfaces(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve Go features
        let interfaces = extractInterfaces(code)
        let errorHandling = extractErrorHandling(code)
        let goroutines = extractGoroutines(code)
        let structs = extractStructs(code)
        let methods = extractMethods(code)

        // Preserve critical patterns with placeholders
        processed = preservePatternsWithPlaceholders(
            code: processed,
            patterns: [
                ("INTERFACE", interfaces.filter { isCriticalInterface($0) }),
                ("ERROR", errorHandling.filter { isCriticalErrorHandling($0) }),
                ("GOROUTINE", goroutines.filter { isCriticalGoroutine($0) }),
                ("STRUCT", structs.filter { isCriticalStruct($0) }),
                ("METHOD", methods.filter { isCriticalMethod($0) })
            ]
        )

        return processed
    }

    private func preserveGoArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract patterns for architectural preservation
        let interfaces = extractInterfaces(code)
        let errorHandling = extractErrorHandling(code)
        let goroutines = extractGoroutines(code)
        let buildTags = extractBuildTags(code)
        let channelOps = extractChannelOperations(code)
        let contextPatterns = extractContextPatterns(code)

        // Preserve only architecturally significant patterns
        var preservedPatterns: [(String, [String])] = []

        // All interfaces, error handling, and goroutines are architectural
        preservedPatterns.append(("INTERFACE", interfaces))
        preservedPatterns.append(("ERROR", errorHandling))
        preservedPatterns.append(("GOROUTINE", goroutines))

        // Build tags, channels, and context are always architectural
        preservedPatterns.append(("BUILD_TAG", buildTags))
        preservedPatterns.append(("CHANNEL", channelOps))
        preservedPatterns.append(("CONTEXT", contextPatterns))

        // Apply preservation with placeholders
        processed = preservePatternsWithPlaceholders(code: processed, patterns: preservedPatterns)

        // Compress implementations while preserving architectural patterns
        processed = compressGoFunctionBodies(processed, options: options)

        return processed
    }

    private func extractGoSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("package ") || trimmed.hasPrefix("import ") ||
               trimmed.hasPrefix("\"") {
                result.append(line)
            }
            else if trimmed.hasPrefix("type ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("func ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("const ") || trimmed.hasPrefix("var ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("//go:build") || trimmed.hasPrefix("// +build") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Pattern Recognition and Critical Patterns

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let interfaces = extractInterfaces(code)
        patterns.append(contentsOf: interfaces.map { .interface($0) })

        let errorHandling = extractErrorHandling(code)
        patterns.append(contentsOf: errorHandling.map { .lifecycle($0) })

        let goroutines = extractGoroutines(code)
        patterns.append(contentsOf: goroutines.map { .lifecycle($0) })

        return patterns
    }

    private func extractInterfaces(_ code: String) -> [String] {
        let pattern = #"type\s+\w+\s+interface\s*\{[^}]*\}"#
        return code.matches(of: pattern)
    }

    private func extractErrorHandling(_ code: String) -> [String] {
        let patterns = [
            #"if\s+err\s*!=\s*nil\s*\{[^}]*\}"#,
            #"return\s+[^,]*,\s*err"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractGoroutines(_ code: String) -> [String] {
        let patterns = [
            #"go\s+\w+\([^)]*\)"#,
            #"select\s*\{[^}]*\}"#,
            #"<-\s*\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractStructs(_ code: String) -> [String] {
        let pattern = #"type\s+\w+\s+struct\s*\{[^}]*\}"#
        return code.matches(of: pattern)
    }

    private func extractMethods(_ code: String) -> [String] {
        let pattern = #"func\s*\([^)]+\)\s*\w+\([^)]*\)"#
        return code.matches(of: pattern)
    }

    private func extractBuildTags(_ code: String) -> [String] {
        let patterns = [
            #"//go:build\s+[^\n]+"#,
            #"// \+build\s+[^\n]+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractChannelOperations(_ code: String) -> [String] {
        let patterns = [
            #"make\(chan\s+[^)]+\)"#,
            #"<-\s*\w+"#,
            #"\w+\s*<-\s*[^;\n]+"#,
            #"close\(\w+\)"#,
            #"range\s+\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractContextPatterns(_ code: String) -> [String] {
        let patterns = [
            #"context\.Context"#,
            #"context\.Background\(\)"#,
            #"context\.TODO\(\)"#,
            #"context\.WithCancel\([^)]+\)"#,
            #"context\.WithTimeout\([^)]+\)"#,
            #"context\.WithDeadline\([^)]+\)"#,
            #"context\.WithValue\([^)]+\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // Go doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let criticalPackages = ["context", "sync", "unsafe", "reflect"]
        let lines = code.components(separatedBy: .newlines)

        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") {
                return criticalPackages.contains { package in
                    trimmed.contains("\"\(package)\"")
                }
            }
            return false
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"import\s+(\"[^\"]+\"|[a-zA-Z_][a-zA-Z0-9_]*)\s*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func getIdentifierPattern() -> String {
        return #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Go keywords and built-ins
        let goKeywords = ["break", "case", "chan", "const", "continue", "default", "defer", "else",
                         "fallthrough", "for", "func", "go", "goto", "if", "import", "interface",
                         "map", "package", "range", "return", "select", "struct", "switch", "type", "var"]

        let goBuiltins = ["append", "cap", "close", "complex", "copy", "delete", "imag", "len",
                         "make", "new", "panic", "print", "println", "real", "recover"]

        if goKeywords.contains(identifier) || goBuiltins.contains(identifier) {
            return true
        }

        if options.prioritizePublicAPIs {
            return isPublicIdentifier(identifier)
        }

        return false
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In Go, exported identifiers start with uppercase
        return identifier.first?.isUppercase == true
    }

    // MARK: - Pattern Classification

    private func isCriticalInterface(_ iface: String) -> Bool {
        // All interfaces are critical in Go's design philosophy
        return true
    }

    private func isCriticalErrorHandling(_ errorPattern: String) -> Bool {
        // All error handling is critical in Go
        return true
    }

    private func isCriticalGoroutine(_ goroutine: String) -> Bool {
        // All concurrency patterns are architecturally significant
        return true
    }

    private func isCriticalStruct(_ structDef: String) -> Bool {
        // Structs with embedded types or tags are more critical
        return structDef.contains("embed") ||
               structDef.contains("`") ||  // struct tags
               structDef.contains("*") ||  // embedded pointers
               structDef.count > 100       // complex structs
    }

    private func isCriticalMethod(_ method: String) -> Bool {
        // Methods with pointer receivers or interfaces are critical
        return method.contains("*") ||
               method.contains("interface") ||
               method.contains("error") ||
               method.contains("context.Context")
    }

    // MARK: - Compression Helpers

    private func preservePatternsWithPlaceholders(code: String, patterns: [(String, [String])]) -> String {
        var processed = code
        var preservedPatterns: [String: String] = [:]

        // Replace patterns with placeholders
        for (patternType, patternList) in patterns {
            for (index, pattern) in patternList.enumerated() {
                let placeholder = "/* \(patternType)_\(index) */"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            }
        }

        // Apply compression to non-preserved parts
        processed = removeLanguageComments(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressGoFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let errorHandling = extractErrorHandling(code)
        let goroutines = extractGoroutines(code)
        let channelOps = extractChannelOperations(code)
        let contextPatterns = extractContextPatterns(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve all error handling patterns
        for (index, error) in errorHandling.enumerated() {
            let placeholder = "/* ERROR_\(index) */"
            preservedPatterns[placeholder] = error
            processed = processed.replacingOccurrences(of: error, with: placeholder)
        }

        // Preserve all goroutines and channel operations
        for (index, goroutine) in goroutines.enumerated() {
            let placeholder = "/* GOROUTINE_\(index) */"
            preservedPatterns[placeholder] = goroutine
            processed = processed.replacingOccurrences(of: goroutine, with: placeholder)
        }

        // Preserve channel operations
        for (index, channel) in channelOps.enumerated() {
            let placeholder = "/* CHANNEL_\(index) */"
            preservedPatterns[placeholder] = channel
            processed = processed.replacingOccurrences(of: channel, with: placeholder)
        }

        // Preserve context patterns
        for (index, context) in contextPatterns.enumerated() {
            let placeholder = "/* CONTEXT_\(index) */"
            preservedPatterns[placeholder] = context
            processed = processed.replacingOccurrences(of: context, with: placeholder)
        }

        // Compress function bodies while preserving signatures
        processed = processed.replacingOccurrences(
            of: #"(func[^{]*\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
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
        var prioritized: [String] = []
        var remaining: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("package ") || trimmed.hasPrefix("import ") ||
               trimmed.hasPrefix("type ") || trimmed.hasPrefix("func ") ||
               trimmed.hasPrefix("const ") || trimmed.hasPrefix("var ") {
                prioritized.append(line)
            } else {
                remaining.append(line)
            }
        }

        let remainingSlots = maxLines - prioritized.count
        if remainingSlots > 0 {
            prioritized.append(contentsOf: Array(remaining.prefix(remainingSlots)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        // Start with signature extraction if we're way over
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens > maxTokens * 2 {
            return extractGoSignatures(code, options: options)
        }

        // Otherwise, progressively remove content
        return compressGoFunctionBodies(code, options: options)
    }

    private func calculateCodeMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let functions = extractMethods(code).count + code.components(separatedBy: "func ").count - 1
        let interfaces = extractInterfaces(code).count
        let structs = extractStructs(code).count

        return [
            "lines": lines.count,
            "functions": functions,
            "interfaces": interfaces,
            "structs": structs,
            "goroutines": extractGoroutines(code).count,
            "errors": extractErrorHandling(code).count
        ]
    }

    private func extractGoStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "interfaces": extractInterfaces(code),
            "structs": extractStructs(code),
            "functions": extractMethods(code),
            "packages": code.components(separatedBy: "package ").count - 1
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let functions = metrics["functions"] as? Int ?? 0
        let interfaces = metrics["interfaces"] as? Int ?? 0
        let structs = metrics["structs"] as? Int ?? 0
        let goroutines = metrics["goroutines"] as? Int ?? 0

        return """
        /* Go Structure Overview
         * Lines: \(lines)
         * Functions: \(functions)
         * Interfaces: \(interfaces)
         * Structs: \(structs)
         * Goroutines: \(goroutines)
         */
        """
    }

    private func calculateGoSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.96
        case .medium: return 0.88
        case .aggressive: return 0.82
        case .maximum: return 0.61
        }
    }
}
