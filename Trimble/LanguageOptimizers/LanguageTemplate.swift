//  LanguageTemplate.swift
import Foundation

class TemplateOptimizer: LanguageOptimizer {

    // MARK: - Regex Cache (Recommended Pattern)
    // Pre-compile regexes for performance. Add language-specific patterns here:
    //
    // private static let regexCache: [String: NSRegularExpression] = {
    //     var cache: [String: NSRegularExpression] = [:]
    //     let patterns: [String: String] = [
    //         "functionSignatures": #"func\s+\w+[^{]*"#,
    //         "classDeclarations": #"class\s+\w+[^{]*"#,
    //     ]
    //     for (key, pattern) in patterns {
    //         cache[key] = try? NSRegularExpression(pattern: pattern, options: [])
    //     }
    //     return cache
    // }()
    //
    // private func extractWithRegex(_ code: String, key: String) -> [String] {
    //     guard let regex = Self.regexCache[key] else { return [] }
    //     let range = NSRange(code.startIndex..., in: code)
    //     let matches = regex.matches(in: code, options: [], range: range)
    //     return matches.compactMap { match in
    //         Range(match.range, in: code).map { String(code[$0]) }
    //     }
    // }

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

        // Remove single-line comments (adjust patterns for your language)
        processed = processed.replacingOccurrences(
            of: #"//.*$"#,
            with: "",
            options: [.regularExpression]
        )

        // Remove multi-line comments (adjust patterns for your language)
        processed = processed.replacingOccurrences(
            of: #"/\*[\s\S]*?\*/"#,
            with: "",
            options: .regularExpression
        )

        // Add language-specific comment patterns here
        // Example for Python:
        // processed = processed.replacingOccurrences(of: #"#.*$"#, with: "", options: [.regularExpression])

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Respect significant whitespace for languages like Python, YAML
        if options.preserveSignificantWhitespace && languagePreservesWhitespace() {
            // Only remove trailing whitespace
            processed = processed.replacingOccurrences(
                of: #"[ \t]+$"#,
                with: "",
                options: [.regularExpression]
            )
        } else {
            // Aggressive whitespace removal
            processed = processed.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .joined(separator: "\n")
        }

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Preserve critical imports if prioritizing public APIs
        if options.prioritizePublicAPIs {
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            // Remove remaining imports
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

        // Language-specific documentation patterns
        // Swift: /// comments
        // JavaScript: /** JSDoc */
        // Python: """docstrings"""
        // Add your language's documentation patterns here

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Common debug patterns (adjust for your language)
        let debugPatterns = [
            #"console\.log\([^)]*\);"#,        // JavaScript
            #"print\([^)]*\)"#,               // Python, Swift
            #"println!\([^)]*\)"#,            // Rust
            #"System\.out\.println\([^)]*\)"#, // Java
            #"NSLog\([^)]*\)"#,               // Objective-C
            #"Debug\.WriteLine\([^)]*\)"#,     // C#
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
        var processed = code

        // Only remove non-critical type annotations
        // Keep generic constraints, critical interfaces, etc.
        if !options.prioritizePublicAPIs {
            // Add language-specific type annotation removal patterns
            // Example for TypeScript: ": string", ": number", etc.
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate function bodies (adjust regex for your language)
        processed = processed.replacingOccurrences(
            of: getFunctionBodyPattern(),
            with: getFunctionTruncationReplacement(),
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenIdentifiers(_ code: String, options: CompressionOptions) -> String {
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        // Extract identifiers and create mapping
        let identifierPattern = getIdentifierPattern()

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    // Don't shorten critical identifiers
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
            processed = processed.replacingOccurrences(of: "\\b\(NSRegularExpression.escapedPattern(for: original))\\b", with: shortened, options: .regularExpression)
        }

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Add language-specific signature detection logic
            if isLanguageSignature(trimmed) ||
               isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        // Return high-level metrics and structure
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical language patterns
        // Add language-specific implementation
        return code
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - focus on architectural elements
        // Add language-specific implementation
        return code
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only public interfaces
        // Add language-specific implementation
        return code
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only signatures and structure
        // Add language-specific implementation
        return code
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        // Override in language-specific implementations
        // Return true for Python, YAML, etc.
        return false
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        // Language-specific critical import detection
        return []
    }

    private func removeStandardImports(_ code: String) -> String {
        // Language-specific import removal patterns
        return code
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating functions
        return []
    }

    private func getFunctionBodyPattern() -> String {
        // Return regex pattern for function bodies in your language
        return #"(\w+\s*\([^)]*\)\s*\{)[^}]*(\})"#
    }

    private func getFunctionTruncationReplacement() -> String {
        // Return replacement string for truncated functions
        return "$1 /* implementation */ $2"
    }

    private func getIdentifierPattern() -> String {
        // Return regex pattern for identifiers in your language
        return #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Determine if identifier should not be shortened
        if options.prioritizePublicAPIs {
            return isPublicIdentifier(identifier)
        }
        return isKeywordOrBuiltin(identifier)
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func isLanguageSignature(_ line: String) -> Bool {
        // Language-specific signature detection
        return false
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        // Language-specific critical declaration detection
        return false
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // Language-specific public identifier detection
        return false
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        // Language-specific keyword/builtin detection
        return false
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        // Prioritize important lines if specified
        if options.prioritizeTopLevel {
            return prioritizeTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        // Iteratively remove content until under token limit
        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        // Implementation for prioritizing top-level declarations
        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        // Implementation for reducing content to fit token limit
        return code
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return [
            "lines": lines.count,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        // Extract high-level structure information
        return [:]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        return "/* Structure overview: \(lines) lines */"
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.95
        case .aggressive: return 0.8
        case .maximum: return 0.60
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        // Decompose into per-pattern-type extraction methods for maintainability:
        //   var patterns: [CriticalPattern] = []
        //   patterns.append(contentsOf: extractDecorators(code).map { .decorator($0) })
        //   patterns.append(contentsOf: extractGenerics(code).map { .genericConstraint($0) })
        //   patterns.append(contentsOf: extractLifecycleMethods(code).map { .lifecycle($0) })
        //   return patterns
        return []
    }
}
