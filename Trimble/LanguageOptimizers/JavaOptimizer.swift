//  JavaOptimizer.swift
import Foundation

class JavaOptimizer: LanguageOptimizer {

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
            return preserveJavaKeyPatterns(code, options: options)
        case .medium:
            return preserveJavaArchitecture(code, options: options)
        case .aggressive:
            return preserveJavaPublicAPIs(code, options: options)
        case .maximum:
            return extractJavaSignatures(code, options: options)
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

        // Remove single-line comments
        processed = processed.replacingOccurrences(
            of: #"//.*$"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line comments but preserve JavaDoc if needed
        processed = processed.replacingOccurrences(
            of: #"/\*(?!\*)[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Java doesn't have significant whitespace, so we can be more aggressive
        processed = processed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")

        // Normalize multiple spaces to single spaces (except in strings)
        processed = processed.replacingOccurrences(
            of: #"(?<!")[ \t]+(?!")"#,
            with: " ",
            options: .regularExpression
        )

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

        if options.prioritizePublicAPIs {
            // Only remove documentation from private methods
            processed = processed.replacingOccurrences(
                of: #"(private\s+[^{]*)\s*/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
                with: "$1",
                options: .regularExpression
            )
        } else {
            // Remove all JavaDoc comments
            processed = processed.replacingOccurrences(
                of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        let debugPatterns = [
            #"System\.out\.println\([^)]*\);"#,
            #"System\.err\.println\([^)]*\);"#,
            #"\.printStackTrace\(\);"#,
            #"logger\.debug\([^)]*\);"#,
            #"log\.debug\([^)]*\);"#,
            #"@SuppressWarnings\([^)]*\)"#
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

        if !options.prioritizePublicAPIs {
            // Remove generic type parameters that aren't critical
            processed = processed.replacingOccurrences(
                of: #"<(?!extends\s+)[A-Za-z0-9_,\s]*>"#,
                with: "",
                options: .regularExpression
            )
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

        // Truncate method bodies
        processed = processed.replacingOccurrences(
            of: #"(\w+\s*\([^)]*\)\s*(?:throws\s+[^{]+)?\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
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

        let identifierPattern = #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    if !isCriticalIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "v\(counter)"
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
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("package ") || trimmed.hasPrefix("import ") ||
               trimmed.hasPrefix("@") ||
               trimmed.contains("class ") || trimmed.contains("interface ") ||
               (trimmed.contains("public ") || trimmed.contains("protected ")) && trimmed.contains("(") ||
               isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractJavaStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveJavaKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical Java patterns
        var processed = code

        // Keep all annotations, interfaces, and class structures intact
        processed = preserveJavaStructure(processed)

        return processed
    }

    private func preserveJavaArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - focus on architectural elements
        var processed = code

        let annotations = extractAnnotations(code)
        let interfaces = extractInterfaces(code)
        let genericBounds = extractGenericBounds(code)
        let classes = extractClasses(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve critical Java annotations
        let criticalAnnotations = annotations.filter { annotation in
            let critical = ["@Override", "@Component", "@Service", "@Repository", "@Controller",
                          "@Entity", "@Table", "@Column", "@Id", "@GeneratedValue",
                          "@Test", "@Before", "@After", "@Autowired", "@Inject", "@Qualifier"]
            return critical.contains { annotation.contains($0) }
        }

        for (index, annotation) in criticalAnnotations.enumerated() {
            let placeholder = "/* ANNOTATION_\(index) */"
            preservedPatterns[placeholder] = annotation
            processed = processed.replacingOccurrences(of: annotation, with: placeholder)
        }

        // Preserve interfaces (critical for understanding contracts)
        for (index, interface) in interfaces.enumerated() {
            let placeholder = "/* INTERFACE_\(index) */"
            preservedPatterns[placeholder] = interface
            processed = processed.replacingOccurrences(of: interface, with: placeholder)
        }

        // Preserve generic bounds (important for type safety)
        for (index, bound) in genericBounds.enumerated() {
            let placeholder = "/* GENERIC_\(index) */"
            preservedPatterns[placeholder] = bound
            processed = processed.replacingOccurrences(of: bound, with: placeholder)
        }

        // Apply medium compression
        if options.removeDocumentation {
            processed = removeDocumentation(processed, options: options)
        }
        processed = preserveJavaStructure(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveJavaPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only public interfaces
        var processed = code

        let classes = extractClasses(code)
        let interfaces = extractInterfaces(code)
        let methods = extractMethods(code)
        let annotations = extractAnnotations(code)

        var preservedPatterns: [String: String] = [:]

        // Only preserve public APIs and critical annotations
        let publicElements = classes.filter { $0.contains("public") } +
                           interfaces +
                           methods.filter { $0.contains("public") } +
                           annotations.filter { isFrameworkAnnotation($0) }

        for (index, element) in publicElements.enumerated() {
            let placeholder = "/* PUBLIC_\(index) */"
            preservedPatterns[placeholder] = element
            processed = processed.replacingOccurrences(of: element, with: placeholder)
        }

        // Aggressive compression
        processed = compressJavaMethodBodies(processed)
        processed = removePrivateImplementations(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func extractJavaSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("package ") || trimmed.hasPrefix("import ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@") {
                result.append(line)
            }
            else if trimmed.contains("class ") || trimmed.contains("interface ") ||
                    trimmed.contains("enum ") {
                result.append(line)
            }
            else if (trimmed.contains("public ") || trimmed.contains("private ") ||
                     trimmed.contains("protected ")) && trimmed.contains("(") {
                result.append(line)
            }
            else if trimmed.contains("private ") || trimmed.contains("public ") ||
                     trimmed.contains("protected ") {
                if trimmed.contains(";") && !trimmed.contains("(") {
                    result.append(line)
                }
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Java-Specific Pattern Extraction

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let annotations = extractAnnotations(code)
        patterns.append(contentsOf: annotations.map { .annotation($0) })

        let interfaces = extractInterfaces(code)
        patterns.append(contentsOf: interfaces.map { .interface($0) })

        let genericBounds = extractGenericBounds(code)
        patterns.append(contentsOf: genericBounds.map { .genericConstraint($0) })

        return patterns
    }

    private func extractAnnotations(_ code: String) -> [String] {
        let pattern = #"@\w+(?:\([^)]*\))?"#
        return code.matches(of: pattern)
    }

    private func extractInterfaces(_ code: String) -> [String] {
        let pattern = #"interface\s+\w+[^{]*\{[^}]*\}"#
        return code.matches(of: pattern)
    }

    private func extractGenericBounds(_ code: String) -> [String] {
        let pattern = #"<[^>]*extends\s+[^>]+>"#
        return code.matches(of: pattern)
    }

    private func extractClasses(_ code: String) -> [String] {
        let pattern = #"(?:public\s+|private\s+|protected\s+)?(?:abstract\s+|final\s+)?class\s+\w+(?:\s+extends\s+\w+)?(?:\s+implements\s+[^{]+)?\s*\{"#
        return code.matches(of: pattern)
    }

    private func extractMethods(_ code: String) -> [String] {
        let pattern = #"(?:public\s+|private\s+|protected\s+)(?:static\s+)?(?:final\s+)?[^{]+\{"#
        return code.matches(of: pattern)
    }

    // MARK: - Utility Methods

    private func extractCriticalImports(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        let criticalPatterns = ["javax.", "org.springframework", "javax.persistence",
                              "org.junit", "org.mockito", "lombok"]

        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("import ") && criticalPatterns.contains { trimmed.contains($0) }
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"import\s+[^;]+;"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract Spring framework patterns, exception handling, etc.
        let patterns = [
            #"@Transactional[^}]*\}"#,
            #"try\s*\{[^}]*\}\s*catch[^}]*\}"#,
            #"throw\s+new\s+\w+Exception[^;]*;"#
        ]

        var result: [String] = []
        for pattern in patterns {
            result.append(contentsOf: code.matches(of: pattern))
        }
        return result
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        let javaKeywords = ["public", "private", "protected", "static", "final", "abstract",
                          "class", "interface", "enum", "extends", "implements", "throw",
                          "throws", "try", "catch", "finally", "if", "else", "for", "while",
                          "do", "switch", "case", "default", "break", "continue", "return",
                          "new", "this", "super", "null", "true", "false", "void", "int",
                          "String", "boolean", "double", "float", "long", "short", "byte",
                          "char", "Object", "List", "Map", "Set", "Collection"]

        if javaKeywords.contains(identifier) { return true }

        if options.prioritizePublicAPIs {
            // Keep common Spring/JPA class names
            let frameworkClasses = ["Component", "Service", "Repository", "Controller",
                                  "Entity", "Table", "Column", "Id", "Override"]
            return frameworkClasses.contains(identifier)
        }

        return false
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        return line.contains("@") || line.contains("interface ") ||
               line.contains("enum ") || line.contains("extends ") ||
               line.contains("implements ")
    }

    private func isFrameworkAnnotation(_ annotation: String) -> Bool {
        let frameworkAnnotations = ["@Override", "@Component", "@Service", "@Repository",
                                  "@Controller", "@Entity", "@Test", "@Autowired", "@Inject"]
        return frameworkAnnotations.contains { annotation.contains($0) }
    }

    private func preserveJavaStructure(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func compressJavaMethodBodies(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"(\w+\s*\([^)]*\)\s*(?:throws\s+[^{]+)?\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )
    }

    private func removePrivateImplementations(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"private\s+[^{]*\{[^}]*\}"#,
            with: "/* private implementation */",
            options: .regularExpression
        )
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
        // Prioritize class declarations, interfaces, public methods
        var result: [String] = []
        var remaining = maxLines

        // First pass: critical declarations
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if (trimmed.contains("class ") || trimmed.contains("interface ") ||
                trimmed.hasPrefix("@") || trimmed.hasPrefix("package ") ||
                trimmed.hasPrefix("import ")) && remaining > 0 {
                result.append(line)
                remaining -= 1
            }
        }

        // Second pass: public methods
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("public ") && trimmed.contains("(") && remaining > 0 {
                result.append(line)
                remaining -= 1
            }
        }

        // Fill remaining with any other lines
        for line in lines {
            if !result.contains(line) && remaining > 0 {
                result.append(line)
                remaining -= 1
            }
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // Progressive reduction strategies
        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = compressJavaMethodBodies(processed)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = removePrivateImplementations(processed)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = extractJavaSignatures(processed, options: options)
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let classes = extractClasses(code).count
        let methods = extractMethods(code).count
        let interfaces = extractInterfaces(code).count

        return [
            "lines": lines.count,
            "classes": classes,
            "methods": methods,
            "interfaces": interfaces,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractJavaStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "annotations": extractAnnotations(code).count,
            "interfaces": extractInterfaces(code).count,
            "classes": extractClasses(code).count,
            "methods": extractMethods(code).count
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        return """
        /* Java Structure Overview */
        // Lines: \(metrics["lines"] ?? 0)
        // Classes: \(structure["classes"] ?? 0)
        // Interfaces: \(structure["interfaces"] ?? 0)
        // Methods: \(structure["methods"] ?? 0)
        // Annotations: \(structure["annotations"] ?? 0)
        // Total tokens: \(metrics["tokens"] ?? 0)
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.96
        case .medium: return 0.88
        case .aggressive: return 0.80
        case .maximum: return 0.58
        }
    }
}
