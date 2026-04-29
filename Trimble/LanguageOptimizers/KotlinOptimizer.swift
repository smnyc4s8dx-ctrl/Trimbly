//  KotlinOptimizer.swift
import Foundation

class KotlinOptimizer: LanguageOptimizer {

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
    func preserveLanguageSemantics(_ code: String, level: SemanticCompressionLevel) -> String {
        var options = CompressionOptions()
        options.semanticLevel = level
        options.applySemanticLevel()
        return preserveLanguageSemantics(code, options: options)
    }

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
            return preserveKotlinStructure(code, options: options)
        case .medium:
            return preserveKotlinFeatures(code, options: options)
        case .aggressive:
            return preserveKotlinArchitecture(code, options: options)
        case .maximum:
            return extractKotlinSignatures(code, options: options)
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
            of: #"//(?!\s*(?:TODO|FIXME|NOTE|HACK))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line comments and KDoc
        processed = processed.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        processed = processed.replacingOccurrences(
            of: #"/\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Kotlin doesn't have significant whitespace like Python
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
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
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
        var processed = code

        // Remove KDoc documentation
        processed = processed.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        let debugPatterns = [
            #"println\([^)]*\)"#,           // Kotlin println
            #"print\([^)]*\)"#,            // Kotlin print
            #"Log\.[diwev]\([^)]*\)"#,      // Android Log
            #"timber\.[diwev]\([^)]*\)"#,   // Timber logging
            #"logger\.[^(]+\([^)]*\)"#,    // Generic logger
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
            // Remove simple type annotations but keep generics and nullable types
            processed = processed.replacingOccurrences(
                of: #":\s*(String|Int|Boolean|Double|Float|Long)\s*[,;=)]"#,
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
        return extractKotlinSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractKotlinStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveKotlinStructure(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve structure with minimal changes
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveKotlinFeatures(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve all critical Kotlin features
        let dataClasses = extractDataClasses(code)
        let extensions = extractExtensionFunctions(code)
        let coroutines = extractCoroutines(code)
        let nullSafety = extractNullSafetyPatterns(code)

        // Preserve critical patterns with placeholders
        processed = preservePatternsWithPlaceholders(
            code: processed,
            patterns: [
                ("DATA_CLASS", dataClasses.filter { isCriticalDataClass($0) }),
                ("EXTENSION", extensions.filter { isCriticalExtension($0) }),
                ("COROUTINE", coroutines.filter { isCriticalCoroutine($0) }),
                ("NULL_SAFETY", nullSafety.filter { isCriticalNullSafety($0) })
            ]
        )

        return processed
    }

    private func preserveKotlinArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract patterns for architectural preservation
        let dataClasses = extractDataClasses(code)
        let extensions = extractExtensionFunctions(code)
        let coroutines = extractCoroutines(code)
        let companionObjects = extractCompanionObjects(code)
        let sealedClasses = extractSealedClasses(code)

        // Preserve only architecturally significant patterns
        var preservedPatterns: [(String, [String])] = []

        preservedPatterns.append(("DATA_CLASS", dataClasses.filter { isCriticalDataClass($0) }))
        preservedPatterns.append(("EXTENSION", extensions.filter { isCriticalExtension($0) }))
        preservedPatterns.append(("COROUTINE", coroutines))
        preservedPatterns.append(("COMPANION", companionObjects))
        preservedPatterns.append(("SEALED", sealedClasses))

        processed = preservePatternsWithPlaceholders(code: processed, patterns: preservedPatterns)
        processed = compressKotlinFunctionBodies(processed)

        return processed
    }

    private func extractKotlinSignatures(_ code: String, options: CompressionOptions) -> String {
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
                    trimmed.contains("object ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("fun ") || trimmed.hasPrefix("suspend fun ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("val ") || trimmed.hasPrefix("var ") {
                result.append(line)
            }
            else if trimmed.contains("companion object") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // Kotlin doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("import ") && (
                trimmed.contains("kotlinx.coroutines") ||
                trimmed.contains("kotlinx.serialization") ||
                trimmed.contains("android.") ||
                trimmed.contains("androidx.") ||
                trimmed.contains("dagger.") ||
                trimmed.contains("javax.inject")
            )
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.hasPrefix("import ")
        }
        return filteredLines.joined(separator: "\n")
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        var patterns: [String] = []

        // Preserve coroutines and async patterns
        patterns.append(contentsOf: extractCoroutines(code))

        // Preserve null safety patterns
        patterns.append(contentsOf: extractNullSafetyPatterns(code).filter { isCriticalNullSafety($0) })

        return patterns
    }

    private func getFunctionBodyPattern() -> String {
        return #"(fun\s+[^{]*\{)[^}]*(\})"#
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
        return trimmed.hasPrefix("fun ") ||
               trimmed.hasPrefix("val ") ||
               trimmed.hasPrefix("var ") ||
               trimmed.contains("class ") ||
               trimmed.contains("interface ") ||
               trimmed.contains("object ")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("data class") ||
               trimmed.hasPrefix("sealed class") ||
               trimmed.hasPrefix("suspend fun") ||
               trimmed.contains("companion object")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In Kotlin, assume public unless specified otherwise
        return !identifier.hasPrefix("_") && !identifier.contains("private")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let keywords = Set([
            "val", "var", "fun", "class", "interface", "object", "data", "sealed",
            "suspend", "async", "if", "else", "when", "for", "while", "do",
            "try", "catch", "finally", "throw", "return", "break", "continue",
            "null", "true", "false", "this", "super", "is", "in", "as"
        ])
        return keywords.contains(identifier)
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
        var topLevel: [String] = []
        var other: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isLanguageSignature(trimmed) || isCriticalDeclaration(trimmed, options: CompressionOptions()) {
                topLevel.append(line)
            } else {
                other.append(line)
            }
        }

        result.append(contentsOf: topLevel)
        let remaining = maxLines - result.count
        if remaining > 0 {
            result.append(contentsOf: Array(other.prefix(remaining)))
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let lines = processed.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let testContent = (result + [line]).joined(separator: "\n")
            let tokens = TokenCounter.countTokens(in: testContent, using: options.tokenizerType)

            if tokens <= maxTokens {
                result.append(line)
            } else {
                break
            }
        }

        return result.joined(separator: "\n")
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let functions = extractFunctionSignatures(code)
        let classes = extractClassDeclarations(code)

        return [
            "lines": lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count,
            "functions": functions.count,
            "classes": classes.count,
            "data_classes": extractDataClasses(code).count,
            "extensions": extractExtensionFunctions(code).count
        ]
    }

    private func extractKotlinStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "data_classes": extractDataClasses(code),
            "extension_functions": extractExtensionFunctions(code),
            "coroutines": extractCoroutines(code),
            "companion_objects": extractCompanionObjects(code),
            "sealed_classes": extractSealedClasses(code)
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output: [String] = []

        output.append("/* Kotlin Structure Overview */")
        output.append("Lines: \(metrics["lines"] ?? 0)")
        output.append("Functions: \(metrics["functions"] ?? 0)")
        output.append("Classes: \(metrics["classes"] ?? 0)")
        output.append("Data Classes: \(metrics["data_classes"] ?? 0)")
        output.append("Extensions: \(metrics["extensions"] ?? 0)")

        return output.joined(separator: "\n")
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.92
        case .aggressive: return 0.84
        case .maximum: return 0.63
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let dataClasses = extractDataClasses(code)
        patterns.append(contentsOf: dataClasses.map { .trait($0) })

        let extensions = extractExtensionFunctions(code)
        patterns.append(contentsOf: extensions.map { .trait($0) })

        let coroutines = extractCoroutines(code)
        patterns.append(contentsOf: coroutines.map { .lifecycle($0) })

        let nullSafety = extractNullSafetyPatterns(code)
        patterns.append(contentsOf: nullSafety.map { .lifecycle($0) })

        return patterns
    }

    // MARK: - Kotlin-Specific Pattern Extraction Methods

    private func extractDataClasses(_ code: String) -> [String] {
        let pattern = #"data class\s+\w+\s*\([^)]+\)"#
        return code.matches(of: pattern)
    }

    private func extractExtensionFunctions(_ code: String) -> [String] {
        let pattern = #"fun\s+\w+\.\w+\s*\([^)]*\)(?:\s*:\s*[^{=]+)?(?:\s*=\s*[^{]+|\s*\{)"#
        return code.matches(of: pattern)
    }

    private func extractCoroutines(_ code: String) -> [String] {
        let patterns = [
            #"suspend\s+fun\s+\w+"#,
            #"withContext\s*\([^)]+\)"#,
            #"launch\s*\{"#,
            #"async\s*\{"#,
            #"runBlocking\s*\{"#,
            #"flow\s*\{"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractNullSafetyPatterns(_ code: String) -> [String] {
        let patterns = [
            #"\w+\?\."#,
            #"\w+\s*\?\:"#,
            #"\w+!!"#,
            #"let\s*\{\s*\w+\s*->"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractCompanionObjects(_ code: String) -> [String] {
        let pattern = #"companion object\s*\{[^}]*\}"#
        return code.matches(of: pattern)
    }

    private func extractSealedClasses(_ code: String) -> [String] {
        let pattern = #"sealed class\s+\w+[^{]*\{[^}]*\}"#
        return code.matches(of: pattern)
    }

    private func extractFunctionSignatures(_ code: String) -> [String] {
        let pattern = #"fun\s+\w+\s*\([^)]*\)(?:\s*:\s*[^{=]+)?"#
        return code.matches(of: pattern)
    }

    private func extractClassDeclarations(_ code: String) -> [String] {
        let pattern = #"(?:data\s+|sealed\s+)?class\s+\w+"#
        return code.matches(of: pattern)
    }

    private func extractLambdas(_ code: String) -> [String] {
        let pattern = #"\{[^}]*->[^}]*\}"#
        return code.matches(of: pattern)
    }

    // MARK: - Smart Pattern Filtering

    private func isCriticalDataClass(_ dataClass: String) -> Bool {
        return dataClass.contains("@Serializable") ||
               dataClass.contains("@Entity") ||
               dataClass.contains("@Parcelize") ||
               dataClass.contains("override") ||
               dataClass.contains("init") ||
               dataClass.count > 100
    }

    private func isCriticalExtension(_ ext: String) -> Bool {
        return ext.contains("operator") ||
               ext.contains("inline") ||
               ext.contains("reified") ||
               ext.contains("suspend") ||
               !ext.contains("= ")
    }

    private func isCriticalCoroutine(_ coroutine: String) -> Bool {
        return true // All coroutines are critical for async behavior
    }

    private func isCriticalNullSafety(_ nullSafety: String) -> Bool {
        return nullSafety.contains("?.let") ||
               nullSafety.contains("?.run") ||
               nullSafety.contains("?.also") ||
               nullSafety.contains("?.apply") ||
               nullSafety.contains("?:") ||
               nullSafety.count > 20
    }

    // MARK: - Pattern Preservation System

    private func preservePatternsWithPlaceholders(code: String, patterns: [(String, [String])]) -> String {
        var processed = code
        var preservedPatterns: [String: String] = [:]

        for (patternType, patternList) in patterns {
            for (index, pattern) in patternList.enumerated() {
                let placeholder = "/* \(patternType)_\(index) */"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            }
        }

        processed = compressKotlinComments(processed)

        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    // MARK: - Compression Methods with Pattern Awareness

    private func compressKotlinComments(_ code: String) -> String {
        var processed = code.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        processed = processed.replacingOccurrences(
            of: #"//(?!\s*(?:TODO|FIXME|NOTE|HACK))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func compressKotlinFunctionBodies(_ code: String) -> String {
        var processed = code

        let lambdas = extractLambdas(code)
        let coroutines = extractCoroutines(code)
        let nullSafety = extractNullSafetyPatterns(code)

        var preservedPatterns: [String: String] = [:]

        for (index, lambda) in lambdas.enumerated() {
            if lambda.count > 50 || lambda.contains("suspend") || lambda.contains("->") {
                let placeholder = "/* LAMBDA_\(index) */"
                preservedPatterns[placeholder] = lambda
                processed = processed.replacingOccurrences(of: lambda, with: placeholder)
            }
        }

        for (index, coroutine) in coroutines.enumerated() {
            let placeholder = "/* COROUTINE_\(index) */"
            preservedPatterns[placeholder] = coroutine
            processed = processed.replacingOccurrences(of: coroutine, with: placeholder)
        }

        for (index, safety) in nullSafety.enumerated() {
            if isCriticalNullSafety(safety) {
                let placeholder = "/* NULL_SAFETY_\(index) */"
                preservedPatterns[placeholder] = safety
                processed = processed.replacingOccurrences(of: safety, with: placeholder)
            }
        }

        processed = processed.replacingOccurrences(
            of: #"(fun\s+[^{]*\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }
}
