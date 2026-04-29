//  TypeScriptOptimizer.swift
import Foundation

class TypeScriptOptimizer: LanguageOptimizer {

    // Pre-compiled regex patterns for performance
    private static let regexCache: [String: NSRegularExpression] = {
        var cache: [String: NSRegularExpression] = [:]

        let patterns = [
            "typeGuards": #"function\s+\w+\([^)]*\):\s*\w+\s+is\s+\w+"#,
            "genericConstraints": #"<[^>]*extends\s+[^>]+>"#,
            "interfaces": #"interface\s+\w+[^{]*\{[^}]*\}"#,
            "typeAnnotations": #":\s*[A-Za-z<>\[\]|&{}]+"#,
            "typeAliases": #"type\s+\w+\s*=\s*[^;\n]+"#,
            "publicAnnotations": #"export\s+[^:]*:\s*[A-Za-z<>\[\]|&{}]+"#,
            "jsDoc": #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            "comments": #"//[^\n]*\n"#,
            "blockComments": #"/\*[\s\S]*?\*/"#,
            "implementations": #"(\w+\s*\([^)]*\)\s*:\s*[^{]+\{)[^}]*(\})"#,
            "functionBodies": #"(function\s+\w+\s*\([^)]*\)\s*:\s*[^{]+\{)[^}]*(\})"#,
            "methodBodies": #"(\w+\s*\([^)]*\)\s*:\s*[^{]+\{)[^}]*(\})"#
        ]

        for (key, pattern) in patterns {
            do {
                cache[key] = try NSRegularExpression(pattern: pattern, options: [])
            } catch {
                print("Failed to compile TypeScript regex for \(key): \(error)")
            }
        }

        return cache
    }()

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
            return preserveTypeScriptKeyPatterns(code, options: options)
        case .medium:
            return preserveTypeScriptArchitecture(code, options: options)
        case .aggressive:
            return preserveTypeScriptPublicAPIs(code, options: options)
        case .maximum:
            return extractTypeScriptSignatures(code, options: options)
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

    // MARK: - TypeScript-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Remove single-line comments
        if let commentRegex = Self.regexCache["comments"] {
            processed = commentRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Remove multi-line comments
        if let blockCommentRegex = Self.regexCache["blockComments"] {
            processed = blockCommentRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // TypeScript doesn't have significant whitespace like Python
        // Aggressive whitespace removal is safe
        processed = processed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        // Clean up excessive newlines
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
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

        // Remove JSDoc comments
        if let jsDocRegex = Self.regexCache["jsDoc"] {
            processed = jsDocRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // TypeScript/JavaScript debug patterns
        let debugPatterns = [
            #"console\.log\([^)]*\);"#,
            #"console\.debug\([^)]*\);"#,
            #"console\.warn\([^)]*\);"#,
            #"console\.error\([^)]*\);"#,
            #"debugger;"#,
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

        // Only remove non-critical type annotations if not prioritizing public APIs
        if !options.prioritizePublicAPIs {
            // Remove basic type annotations like : string, : number, : boolean
            processed = processed.replacingOccurrences(
                of: #":\s*(?:string|number|boolean|any)\s*([;,=])"#,
                with: "$1",
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

        // Truncate function bodies
        if let functionRegex = Self.regexCache["functionBodies"] {
            processed = functionRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: "$1 /* implementation */ $2"
            )
        }

        if let methodRegex = Self.regexCache["methodBodies"] {
            processed = methodRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: "$1 /* implementation */ $2"
            )
        }

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

        let identifierPattern = #"\b[a-zA-Z_$][a-zA-Z0-9_$]*\b"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    // Don't shorten critical TypeScript identifiers
                    if !isCriticalTypeScriptIdentifier(identifier, options: options) {
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
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isTypeScriptSignature(trimmed) ||
               isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractTypeScriptStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveTypeScriptKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all type information
        var processed = code

        // Only remove single-line comments and excess whitespace
        processed = removeLanguageComments(processed)
        processed = removeExcessWhitespace(processed, options: options)

        return processed
    }

    private func preserveTypeScriptArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve essential type constructs
        var processed = code

        let interfaces = extractWithRegex(code, key: "interfaces")
        let typeGuards = extractWithRegex(code, key: "typeGuards")
        let genericConstraints = extractWithRegex(code, key: "genericConstraints")
        let typeAliases = extractWithRegex(code, key: "typeAliases")

        var preservedPatterns: [String: String] = [:]

        // Preserve critical type constructs
        for (index, interface) in interfaces.enumerated() {
            let placeholder = "/* INTERFACE_\(index) */"
            preservedPatterns[placeholder] = interface
            processed = processed.replacingOccurrences(of: interface, with: placeholder)
        }

        for (index, typeGuard) in typeGuards.enumerated() {
            let placeholder = "/* TYPE_GUARD_\(index) */"
            preservedPatterns[placeholder] = typeGuard
            processed = processed.replacingOccurrences(of: typeGuard, with: placeholder)
        }

        for (index, constraint) in genericConstraints.enumerated() {
            let placeholder = "/* GENERIC_\(index) */"
            preservedPatterns[placeholder] = constraint
            processed = processed.replacingOccurrences(of: constraint, with: placeholder)
        }

        for (index, alias) in typeAliases.enumerated() {
            let placeholder = "/* TYPE_ALIAS_\(index) */"
            preservedPatterns[placeholder] = alias
            processed = processed.replacingOccurrences(of: alias, with: placeholder)
        }

        // Apply basic compression
        processed = removeLanguageComments(processed)
        processed = removeDocumentation(processed, options: options)
        processed = removeExcessWhitespace(processed, options: options)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveTypeScriptPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only public interfaces and exports
        var processed = code

        let interfaces = extractWithRegex(code, key: "interfaces")
        let typeGuards = extractWithRegex(code, key: "typeGuards")
        let publicAnnotations = extractWithRegex(code, key: "publicAnnotations")

        var preservedPatterns: [String: String] = [:]

        // Only preserve public interfaces and type guards
        for (index, interface) in interfaces.enumerated() {
            if interface.contains("export") {
                let placeholder = "/* PUB_INTERFACE_\(index) */"
                preservedPatterns[placeholder] = interface
                processed = processed.replacingOccurrences(of: interface, with: placeholder)
            }
        }

        for (index, typeGuard) in typeGuards.enumerated() {
            let placeholder = "/* TYPE_GUARD_\(index) */"
            preservedPatterns[placeholder] = typeGuard
            processed = processed.replacingOccurrences(of: typeGuard, with: placeholder)
        }

        for (index, annotation) in publicAnnotations.enumerated() {
            let placeholder = "/* PUB_TYPE_\(index) */"
            preservedPatterns[placeholder] = annotation
            processed = processed.replacingOccurrences(of: annotation, with: placeholder)
        }

        // Apply aggressive compression
        processed = removeLanguageComments(processed)
        processed = removeDocumentation(processed, options: options)
        processed = truncateFunctionBodies(processed, options: options)
        processed = removeTypeAnnotations(processed, options: options)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func extractTypeScriptSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("import ") || trimmed.hasPrefix("export ") ||
               trimmed.hasPrefix("interface ") || trimmed.hasPrefix("type ") ||
               (trimmed.contains("function ") || (trimmed.contains("(") && trimmed.contains("):"))) ||
               trimmed.hasPrefix("class ") || trimmed.hasPrefix("enum ") ||
               (trimmed.contains(": ") && !trimmed.contains("if ") && !trimmed.contains("for ")) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func extractWithRegex(_ code: String, key: String) -> [String] {
        guard let regex = Self.regexCache[key] else { return [] }

        let range = NSRange(code.startIndex..., in: code)
        let matches = regex.matches(in: code, options: [], range: range)

        return matches.compactMap { match in
            Range(match.range, in: code).map { String(code[$0]) }
        }
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("import") && (
                trimmed.contains("@types/") ||
                trimmed.contains("React") ||
                trimmed.contains("Vue") ||
                trimmed.contains("Angular") ||
                trimmed.contains("express") ||
                trimmed.contains("typescript")
            )
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        // YAML doesn't have import statements - return unchanged
        return code
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating functions
        var patterns: [String] = []

        // Preserve type guards and critical type checks
        patterns.append(contentsOf: extractWithRegex(code, key: "typeGuards"))

        return patterns
    }

    private func isCriticalTypeScriptIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // TypeScript keywords and built-ins
        let keywords = [
            "function", "class", "interface", "type", "enum", "namespace",
            "import", "export", "default", "extends", "implements",
            "public", "private", "protected", "readonly", "static",
            "abstract", "async", "await", "const", "let", "var",
            "string", "number", "boolean", "any", "void", "never",
            "unknown", "object", "null", "undefined"
        ]

        if keywords.contains(identifier) {
            return true
        }

        // Common TypeScript utility types
        let utilityTypes = [
            "Partial", "Required", "Readonly", "Record", "Pick", "Omit",
            "Exclude", "Extract", "NonNullable", "Parameters", "ReturnType"
        ]

        if utilityTypes.contains(identifier) {
            return true
        }

        if options.prioritizePublicAPIs {
            return isPublicTypeScriptIdentifier(identifier)
        }

        return false
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func isTypeScriptSignature(_ line: String) -> Bool {
        return line.hasPrefix("import ") ||
               line.hasPrefix("export ") ||
               line.hasPrefix("interface ") ||
               line.hasPrefix("type ") ||
               line.hasPrefix("class ") ||
               line.hasPrefix("enum ") ||
               line.hasPrefix("namespace ") ||
               (line.contains("function ") && line.contains("(")) ||
               (line.contains("(") && line.contains("):"))
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return line.contains("export")
        }
        return line.contains("interface") || line.contains("type") || line.contains("class")
    }

    private func isPublicTypeScriptIdentifier(_ identifier: String) -> Bool {
        // Common public API patterns in TypeScript
        return identifier.first?.isUppercase == true || identifier.hasPrefix("I")
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
        var typeLines: [String] = []
        var otherLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import") || trimmed.hasPrefix("export") {
                importLines.append(line)
            } else if trimmed.hasPrefix("interface") || trimmed.hasPrefix("type") || trimmed.hasPrefix("class") {
                typeLines.append(line)
            } else {
                otherLines.append(line)
            }
        }

        // Prioritize imports, then types, then other code
        result.append(contentsOf: importLines)
        result.append(contentsOf: typeLines)

        let remaining = maxLines - result.count
        if remaining > 0 {
            result.append(contentsOf: Array(otherLines.prefix(remaining)))
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // Progressively apply more aggressive compression
        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = removeLanguageComments(processed)
        }

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
        let interfaces = extractWithRegex(code, key: "interfaces")
        let typeAliases = extractWithRegex(code, key: "typeAliases")

        return [
            "lines": lines.count,
            "interfaces": interfaces.count,
            "types": typeAliases.count,
            "functions": code.components(separatedBy: "function ").count - 1,
            "classes": code.components(separatedBy: "class ").count - 1
        ]
    }

    private func extractTypeScriptStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "interfaces": extractWithRegex(code, key: "interfaces").map { $0.prefix(50) },
            "typeAliases": extractWithRegex(code, key: "typeAliases").map { $0.prefix(50) },
            "exports": code.components(separatedBy: "export ").count - 1
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        return """
        /* TypeScript Structure Overview */
        Lines: \(metrics["lines"] ?? 0)
        Interfaces: \(metrics["interfaces"] ?? 0)
        Types: \(metrics["types"] ?? 0)
        Functions: \(metrics["functions"] ?? 0)
        Classes: \(metrics["classes"] ?? 0)
        Exports: \(structure["exports"] ?? 0)
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.93
        case .aggressive: return 0.86
        case .maximum: return 0.65
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        patterns.append(contentsOf: extractWithRegex(code, key: "typeGuards").map { .typeGuard($0) })
        patterns.append(contentsOf: extractWithRegex(code, key: "genericConstraints").map { .genericConstraint($0) })
        patterns.append(contentsOf: extractWithRegex(code, key: "interfaces").map { .interface($0) })
        patterns.append(contentsOf: extractWithRegex(code, key: "typeAliases").map { .trait($0) })

        return patterns
    }
}
