//  CSharpOptimizer.swift
import Foundation

class CSharpOptimizer: LanguageOptimizer {

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
        return compressCSharpComments(code)
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        return removeRedundantWhitespace(code)
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

        // Remove XML documentation comments
        processed = processed.replacingOccurrences(
            of: #"/// <[^>]*>[^<]*</[^>]*>"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line documentation
        processed = processed.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // C#-specific debug patterns
        let debugPatterns = [
            #"Console\.WriteLine\([^)]*\);"#,
            #"Debug\.WriteLine\([^)]*\);"#,
            #"Trace\.WriteLine\([^)]*\);"#,
            #"System\.Diagnostics\.Debug\.WriteLine\([^)]*\);"#,
            #"Console\.Write\([^)]*\);"#
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

        // Only remove non-critical type annotations for C#
        if !options.prioritizePublicAPIs {
            // Remove simple type annotations but preserve generics and constraints
            processed = processed.replacingOccurrences(
                of: #":\s*(?:int|string|bool|double|float|decimal)\b"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        return compressCSharpMethodBodies(code)
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
        return extractCSharpSignatures(code)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)
        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        return preserveCSharpStructure(code)
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        return preserveCSharpFeatures(code)
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        return preserveCSharpArchitecture(code)
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        return extractCSharpSignatures(code)
    }

    // MARK: - C#-Specific Pattern Extraction

    private func extractAttributes(_ code: String) -> [String] {
        let patterns = [
            #"\[[^\]]+\]"#,
            #"\[assembly:\s*[^\]]+\]"#,
            #"\[return:\s*[^\]]+\]"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractProperties(_ code: String) -> [String] {
        let patterns = [
            #"(?:public|private|protected|internal)\s+(?:static\s+)?(?:virtual\s+|override\s+|abstract\s+)?\w+\s+\w+\s*\{\s*get[^}]*\}(?:\s*\{\s*set[^}]*\})?"#,
            #"(?:public|private|protected|internal)\s+(?:static\s+)?\w+\s+\w+\s*=>[^;]+;"#,
            #"(?:public|private|protected|internal)\s+(?:static\s+)?\w+\s+\w+\s*\{\s*get;\s*(?:set;)?\s*\}"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractLinqExpressions(_ code: String) -> [String] {
        let patterns = [
            #"\.Where\s*\([^)]+\)"#,
            #"\.Select\s*\([^)]+\)"#,
            #"\.OrderBy\s*\([^)]+\)"#,
            #"\.GroupBy\s*\([^)]+\)"#,
            #"\.Join\s*\([^)]+\)"#,
            #"\.FirstOrDefault\s*\([^)]*\)"#,
            #"\.SingleOrDefault\s*\([^)]*\)"#,
            #"\.Any\s*\([^)]*\)"#,
            #"\.All\s*\([^)]+\)"#,
            #"from\s+\w+\s+in\s+[^;]+;"#,
            #"let\s+\w+\s*=\s*[^;]+;"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractAsyncPatterns(_ code: String) -> [String] {
        let patterns = [
            #"async\s+\w+\s+\w+\s*\([^)]*\)"#,
            #"await\s+[^;]+;"#,
            #"Task\.Run\s*\([^)]+\)"#,
            #"Task\.FromResult\s*\([^)]+\)"#,
            #"ConfigureAwait\s*\(false\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractGenerics(_ code: String) -> [String] {
        let patterns = [
            #"<[^>]*where\s+[^>]+>"#,
            #"<[^>]*:\s*[^>]+>"#,
            #"class\s+\w+<[^>]+>"#,
            #"interface\s+\w+<[^>]+>"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractFrameworkPatterns(_ code: String) -> [String] {
        let patterns = [
            #"\[HttpGet\]"#,
            #"\[HttpPost\]"#,
            #"\[Route\([^)]+\)\]"#,
            #"\[Authorize\([^)]*\)\]"#,
            #"\[ApiController\]"#,
            #"\[JsonProperty\([^)]+\)\]"#,
            #"\[Required\]"#,
            #"\[DataMember\]"#,
            #"\[Test\]"#,
            #"\[SetUp\]"#,
            #"\[TearDown\]"#,
            #"\.ConfigureServices\([^)]+\)"#,
            #"\.Configure\([^)]+\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Smart Pattern Classification

    private func isCriticalPattern(_ pattern: String) -> Bool {
        let criticalKeywords = [
            "HttpGet", "HttpPost", "Route", "Authorize", "ApiController",
            "Required", "DataMember", "async", "await", "Task",
            "Where", "Select", "OrderBy", "GroupBy"
        ]

        return criticalKeywords.contains { pattern.contains($0) }
    }

    private func isArchitecturalPattern(_ pattern: String) -> Bool {
        let architecturalKeywords = [
            "public", "private", "protected", "internal", "abstract", "virtual",
            "override", "interface", "class", "struct", "enum"
        ]

        return architecturalKeywords.contains { pattern.contains($0) }
    }

    private func isDecorativePattern(_ pattern: String) -> Bool {
        let decorativeKeywords = [
            "JsonProperty", "Description", "Display", "Category"
        ]

        return decorativeKeywords.contains { pattern.contains($0) }
    }

    // MARK: - C#-Specific Compression Methods

    private func preserveCSharpStructure(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveCSharpFeatures(_ code: String) -> String {
        var processed = code

        // Extract all patterns but preserve them all in medium level
        let attributes = extractAttributes(code)
        let properties = extractProperties(code)
        let linqExpressions = extractLinqExpressions(code)
        let asyncPatterns = extractAsyncPatterns(code)
        let frameworkPatterns = extractFrameworkPatterns(code)

        // Create placeholder maps for each pattern type
        var preservedPatterns: [String: String] = [:]
        var placeholderCounter = 0

        // Preserve all critical patterns
        for pattern in (attributes + properties + linqExpressions + asyncPatterns + frameworkPatterns) {
            let placeholder = "/* PRESERVED_\(placeholderCounter) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            placeholderCounter += 1
        }

        // Apply light compression
        processed = removeRedundantWhitespace(processed)

        // Restore all preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveCSharpArchitecture(_ code: String) -> String {
        var processed = code

        // Extract patterns and classify them
        let attributes = extractAttributes(code)
        let properties = extractProperties(code)
        let linqExpressions = extractLinqExpressions(code)
        let asyncPatterns = extractAsyncPatterns(code)
        let frameworkPatterns = extractFrameworkPatterns(code)
        let generics = extractGenerics(code)

        // Preserve only critical and architectural patterns
        var preservedPatterns: [String: String] = [:]
        var placeholderCounter = 0

        let allPatterns = attributes + properties + linqExpressions + asyncPatterns + frameworkPatterns + generics
        for pattern in allPatterns {
            if isCriticalPattern(pattern) || isArchitecturalPattern(pattern) {
                let placeholder = "/* PRESERVED_\(placeholderCounter) */"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
                placeholderCounter += 1
            }
        }

        // Compress method bodies while preserving structure
        processed = compressCSharpMethodBodies(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressCSharpComments(_ code: String) -> String {
        var processed = code.replacingOccurrences(
            of: #"//(?!\s*(?:TODO|FIXME|HACK|NOTE))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"/\*(?!.*(?:TODO|HACK))[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )
        return processed
    }

    private func compressCSharpMethodBodies(_ code: String) -> String {
        var processed = code

        // Extract and preserve LINQ expressions
        let linqExpressions = extractLinqExpressions(code)
        var preservedLinq: [String: String] = [:]
        for (index, linq) in linqExpressions.enumerated() {
            let placeholder = "/* LINQ_\(index) */"
            preservedLinq[placeholder] = linq
            processed = processed.replacingOccurrences(of: linq, with: placeholder)
        }

        // Extract and preserve async patterns
        let asyncPatterns = extractAsyncPatterns(code)
        var preservedAsync: [String: String] = [:]
        for (index, async) in asyncPatterns.enumerated() {
            let placeholder = "/* ASYNC_\(index) */"
            preservedAsync[placeholder] = async
            processed = processed.replacingOccurrences(of: async, with: placeholder)
        }

        // Compress method bodies
        processed = processed.replacingOccurrences(
            of: #"(\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, linq) in preservedLinq {
            processed = processed.replacingOccurrences(of: placeholder, with: linq)
        }
        for (placeholder, async) in preservedAsync {
            processed = processed.replacingOccurrences(of: placeholder, with: async)
        }

        return processed
    }

    private func removeRedundantWhitespace(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func extractCSharpSignatures(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep using statements and namespaces
            if trimmed.hasPrefix("using ") || trimmed.hasPrefix("namespace ") {
                result.append(line)
            }
            // Keep attributes
            else if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                result.append(line)
            }
            // Keep class, interface, struct, enum declarations
            else if trimmed.contains("class ") || trimmed.contains("interface ") ||
                    trimmed.contains("enum ") || trimmed.contains("struct ") {
                result.append(line)
            }
            // Keep method signatures
            else if (trimmed.contains("public ") || trimmed.contains("private ") ||
                     trimmed.contains("protected ") || trimmed.contains("internal ")) &&
                    trimmed.contains("(") && !trimmed.contains("{") {
                result.append(line)
            }
            // Keep property declarations
            else if trimmed.contains("{ get;") || trimmed.contains("{ set;") ||
                    trimmed.contains("=> ") {
                result.append(line)
            }
            // Keep framework-specific patterns
            else if trimmed.contains("ConfigureServices") || trimmed.contains("Configure") ||
                    trimmed.contains("HttpGet") || trimmed.contains("HttpPost") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // C# does not have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let criticalNamespaces = [
            "System.Web.Mvc", "Microsoft.AspNetCore", "System.Threading.Tasks",
            "System.Linq", "Microsoft.EntityFrameworkCore", "System.ComponentModel.DataAnnotations"
        ]

        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("using ") && criticalNamespaces.contains { trimmed.contains($0) }
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"using\s+[^;]+;"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        return extractLinqExpressions(code) + extractAsyncPatterns(code)
    }

    private func getFunctionBodyPattern() -> String {
        return #"(\w+\s*\([^)]*\)\s*\{)[^}]*(\})"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1 /* implementation */ $2"
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
        return trimmed.contains("class ") || trimmed.contains("interface ") ||
               trimmed.contains("enum ") || trimmed.contains("struct ") ||
               (trimmed.contains("(") && !trimmed.contains("{"))
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("public ") || trimmed.hasPrefix("[")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // C#-specific public identifier patterns
        return identifier.first?.isUppercase == true
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let csharpKeywords = [
            "abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char",
            "checked", "class", "const", "continue", "decimal", "default", "delegate",
            "do", "double", "else", "enum", "event", "explicit", "extern", "false",
            "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit",
            "in", "int", "interface", "internal", "is", "lock", "long", "namespace",
            "new", "null", "object", "operator", "out", "override", "params", "private",
            "protected", "public", "readonly", "ref", "return", "sbyte", "sealed",
            "short", "sizeof", "stackalloc", "static", "string", "struct", "switch",
            "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked",
            "unsafe", "ushort", "using", "virtual", "void", "volatile", "while"
        ]
        return csharpKeywords.contains(identifier)
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
        var prioritizedLines: [String] = []
        var regularLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("using ") || trimmed.hasPrefix("namespace ") ||
               trimmed.contains("class ") || trimmed.contains("interface ") ||
               trimmed.contains("public ") || trimmed.hasPrefix("[") {
                prioritizedLines.append(line)
            } else {
                regularLines.append(line)
            }
        }

        let availableLines = maxLines - prioritizedLines.count
        if availableLines > 0 {
            prioritizedLines.append(contentsOf: Array(regularLines.prefix(availableLines)))
        }

        return prioritizedLines.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let reductionSteps = [
            { self.compressCSharpComments($0) },
            { self.removeRedundantWhitespace($0) },
            { self.compressCSharpMethodBodies($0) }
        ]

        for step in reductionSteps {
            processed = step(processed)
            let tokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
            if tokens <= maxTokens { break }
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let classes = extractAttributes(code).count
        let methods = extractProperties(code).count
        let linq = extractLinqExpressions(code).count

        return [
            "lines": lines.count,
            "classes": classes,
            "methods": methods,
            "linq_expressions": linq
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "attributes": extractAttributes(code).count,
            "properties": extractProperties(code).count,
            "async_patterns": extractAsyncPatterns(code).count,
            "framework_patterns": extractFrameworkPatterns(code).count
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "/* C# Structure Overview */\n"
        output += "Lines: \(metrics["lines"] ?? 0)\n"
        output += "Classes: \(metrics["classes"] ?? 0)\n"
        output += "Methods: \(metrics["methods"] ?? 0)\n"
        output += "LINQ Expressions: \(metrics["linq_expressions"] ?? 0)\n"
        output += "Attributes: \(structure["attributes"] ?? 0)\n"
        output += "Properties: \(structure["properties"] ?? 0)\n"
        output += "Async Patterns: \(structure["async_patterns"] ?? 0)\n"
        output += "Framework Patterns: \(structure["framework_patterns"] ?? 0)\n"
        return output
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.91
        case .aggressive: return 0.83
        case .maximum: return 0.61
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let attributes = extractAttributes(code)
        patterns.append(contentsOf: attributes.map { .annotation($0) })

        let properties = extractProperties(code)
        patterns.append(contentsOf: properties.map { .trait($0) })

        let linqExpressions = extractLinqExpressions(code)
        patterns.append(contentsOf: linqExpressions.map { .macro($0) })

        let asyncPatterns = extractAsyncPatterns(code)
        patterns.append(contentsOf: asyncPatterns.map { .lifecycle($0) })

        let generics = extractGenerics(code)
        patterns.append(contentsOf: generics.map { .genericConstraint($0) })

        return patterns
    }
}
