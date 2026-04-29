import Foundation

class PHPOptimizer: LanguageOptimizer {

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
            return preservePHPStructure(code, options: options)
        case .medium:
            return preservePHPFeatures(code, options: options)
        case .aggressive:
            return preservePHPArchitecture(code, options: options)
        case .maximum:
            return extractPHPSignatures(code, options: options)
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

    // MARK: - PHP-Specific Pattern Recognition
    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let traits = extractTraits(code)
        patterns.append(contentsOf: traits.map { .trait($0) })

        let attributes = extractAttributes(code)
        patterns.append(contentsOf: attributes.map { .annotation($0) })

        let magicMethods = extractMagicMethods(code)
        patterns.append(contentsOf: magicMethods.map { .lifecycle($0) })

        let namespaces = extractNamespaces(code)
        patterns.append(contentsOf: namespaces.map { .interface($0) })

        let frameworkPatterns = extractFrameworkPatterns(code)
        patterns.append(contentsOf: frameworkPatterns.map { .macro($0) })

        return patterns
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

        // Remove multi-line comments but preserve DocBlocks with critical annotations
        processed = processed.replacingOccurrences(
            of: #"/\*(?!\*\s*@(?:param|return|throws|var|see|Route|Entity|Table|Column))[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        // Remove hash comments
        processed = processed.replacingOccurrences(
            of: #"#(?!\s*(?:TODO|FIXME|NOTE|HACK))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // PHP doesn't have significant whitespace, so we can be aggressive
        processed = processed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")

        // Remove excessive blank lines
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

        if options.prioritizePublicAPIs {
            // Preserve critical imports (keep namespace declarations and use statements for interfaces)
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            // Remove standard use statements
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
            // Keep DocBlocks with framework annotations
            processed = processed.replacingOccurrences(
                of: #"/\*\*(?![^*]*@(?:Route|Entity|Table|Column|param|return|throws))[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
                with: "",
                options: .regularExpression
            )
        } else {
            // Remove all DocBlocks
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
            #"echo\s+[^;]*;"#,                    // echo statements
            #"print\s+[^;]*;"#,                   // print statements
            #"print_r\([^)]*\);"#,               // print_r
            #"var_dump\([^)]*\);"#,              // var_dump
            #"var_export\([^)]*\);"#,            // var_export
            #"error_log\([^)]*\);"#,             // error_log
            #"die\([^)]*\);"#,                   // die statements
            #"exit\([^)]*\);"#,                  // exit statements
            #"dump\([^)]*\);"#,                  // Laravel dump
            #"dd\([^)]*\);"#,                    // Laravel dd
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
            // Remove simple type hints but keep complex ones
            processed = processed.replacingOccurrences(
                of: #":\s*(?:int|string|bool|float|array)\s*(?=[,\)])"#,
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
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isPHPSignature(trimmed) || isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code)
        let structure = extractPHPStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preservePHPStructure(_ code: String, options: CompressionOptions) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preservePHPFeatures(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve all PHP features
        let traits = extractTraits(code)
        let attributes = extractAttributes(code)
        let magicMethods = extractMagicMethods(code)
        let namespaces = extractNamespaces(code)
        let typeHints = extractTypeHints(code)

        // Preserve critical patterns with placeholders
        processed = preservePatternsWithPlaceholders(
            code: processed,
            patterns: [
                ("TRAIT", traits.filter { isCriticalTrait($0) }),
                ("ATTRIBUTE", attributes.filter { isCriticalAttribute($0) }),
                ("MAGIC", magicMethods.filter { isCriticalMagicMethod($0) }),
                ("NAMESPACE", namespaces.filter { isCriticalNamespace($0) }),
                ("TYPE_HINT", typeHints.filter { isCriticalTypeHint($0) })
            ]
        )

        return processed
    }

    private func preservePHPArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract patterns for architectural preservation
        let traits = extractTraits(code)
        let attributes = extractAttributes(code)
        let magicMethods = extractMagicMethods(code)
        let namespaces = extractNamespaces(code)
        let frameworkPatterns = extractFrameworkPatterns(code)
        let interfacePatterns = extractInterfacePatterns(code)

        // Preserve architecturally significant patterns
        let preservedPatterns = [
            ("TRAIT", traits.filter { isCriticalTrait($0) }),
            ("ATTRIBUTE", attributes),
            ("MAGIC", magicMethods),
            ("NAMESPACE", namespaces),
            ("FRAMEWORK", frameworkPatterns),
            ("INTERFACE", interfacePatterns)
        ]

        processed = preservePatternsWithPlaceholders(code: processed, patterns: preservedPatterns)
        processed = compressPHPMethodBodies(processed)

        return processed
    }

    private func extractPHPSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("<?php") {
                result.append(line)
            }
            else if trimmed.hasPrefix("namespace ") || trimmed.hasPrefix("use ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("#[") || trimmed.hasPrefix("@") {
                result.append(line)
            }
            else if trimmed.contains("class ") || trimmed.contains("interface ") ||
                    trimmed.contains("trait ") {
                result.append(line)
            }
            else if trimmed.contains("function ") {
                result.append(line)
            }
            else if trimmed.contains("public $") || trimmed.contains("private $") ||
                    trimmed.contains("protected $") {
                result.append(line)
            }
            else if trimmed.hasPrefix("const ") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - PHP Pattern Extraction Methods

    private func extractTraits(_ code: String) -> [String] {
        let patterns = [
            #"trait\s+\w+\s*\{[^}]*\}"#,
            #"use\s+\w+(?:,\s*\w+)*;"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractAttributes(_ code: String) -> [String] {
        let patterns = [
            #"#\[\w+(?:\([^)]*\))?\]"#,
            #"@\w+(?:\([^)]*\))?"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractMagicMethods(_ code: String) -> [String] {
        let patterns = [
            #"function\s+__\w+\([^)]*\)"#,
            #"public\s+function\s+__\w+\([^)]*\)"#,
            #"private\s+function\s+__\w+\([^)]*\)"#,
            #"protected\s+function\s+__\w+\([^)]*\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractNamespaces(_ code: String) -> [String] {
        let patterns = [
            #"namespace\s+[^;]+;"#,
            #"use\s+[^;]+;"#,
            #"use\s+function\s+[^;]+;"#,
            #"use\s+const\s+[^;]+;"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractTypeHints(_ code: String) -> [String] {
        let patterns = [
            #"function\s+\w+\([^)]*\):\s*\?\w+"#,
            #"function\s+\w+\([^)]*\):\s*\w+"#,
            #"\?\w+\s+\$\w+"#,
            #"(?:int|string|bool|float|array|object|callable)\s+\$\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractFrameworkPatterns(_ code: String) -> [String] {
        let patterns = [
            #"Route::\w+\([^)]+\)"#,
            #"->middleware\([^)]+\)"#,
            #"public\s+function\s+\w+\(\)\s*\{\s*return\s+\$this->\w+\("#,
            #"public\s+function\s+__construct\([^)]*\w+\s+\$\w+[^)]*\)"#,
            #"@Route\([^)]+\)"#,
            #"#\[Route\([^)]+\)\]"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractInterfacePatterns(_ code: String) -> [String] {
        let patterns = [
            #"interface\s+\w+(?:\s+extends\s+\w+)?\s*\{[^}]*\}"#,
            #"implements\s+\w+(?:,\s*\w+)*"#,
            #"extends\s+\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // PHP doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        // Critical imports for PHP include interfaces, traits, and framework classes
        return code.matches(of: #"use\s+(?:\w+\\)*(?:Interface|Trait|Controller|Middleware|Service)\w*;"#)
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"use\s+[^;]+;"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Preserve Laravel routes, middleware, and other framework patterns
        var patterns: [String] = []
        patterns.append(contentsOf: extractFrameworkPatterns(code))
        patterns.append(contentsOf: extractMagicMethods(code))
        return patterns
    }

    private func getFunctionBodyPattern() -> String {
        return #"(function\s+\w+\([^)]*\)(?:\s*:\s*[^{]+)?\s*\{)[^}]*(\})"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1 /* implementation */ $2"
    }

    private func getIdentifierPattern() -> String {
        return #"\$[a-zA-Z_][a-zA-Z0-9_]*|\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
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

    private func isPHPSignature(_ line: String) -> Bool {
        return line.hasPrefix("function ") ||
               line.hasPrefix("public function ") ||
               line.hasPrefix("private function ") ||
               line.hasPrefix("protected function ") ||
               line.hasPrefix("class ") ||
               line.hasPrefix("interface ") ||
               line.hasPrefix("trait ") ||
               line.hasPrefix("namespace ") ||
               line.hasPrefix("use ")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        return line.contains("__") || // Magic methods
               line.contains("#[") ||  // Attributes
               line.contains("@") ||   // Annotations
               line.contains("Route") ||
               line.contains("Entity") ||
               line.contains("Table")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In PHP, public identifiers don't start with underscore
        return !identifier.hasPrefix("_") && !identifier.hasPrefix("$_")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let phpKeywords = [
            "abstract", "and", "array", "as", "break", "callable", "case", "catch",
            "class", "clone", "const", "continue", "declare", "default", "die", "do",
            "echo", "else", "elseif", "empty", "enddeclare", "endfor", "endforeach",
            "endif", "endswitch", "endwhile", "eval", "exit", "extends", "final",
            "finally", "for", "foreach", "function", "global", "goto", "if",
            "implements", "include", "include_once", "instanceof", "insteadof",
            "interface", "isset", "list", "namespace", "new", "or", "print",
            "private", "protected", "public", "require", "require_once", "return",
            "static", "switch", "throw", "trait", "try", "unset", "use", "var",
            "while", "xor", "yield", "true", "false", "null"
        ]
        return phpKeywords.contains(identifier.lowercased())
    }

    // MARK: - Pattern Classification Methods

    private func isCriticalTrait(_ trait: String) -> Bool {
        return trait.contains("abstract") ||
               trait.contains("interface") ||
               trait.contains("implements") ||
               trait.contains("function") ||
               trait.count > 100
    }

    private func isCriticalAttribute(_ attribute: String) -> Bool {
        return true // All modern PHP attributes are critical
    }

    private func isCriticalMagicMethod(_ magic: String) -> Bool {
        return true // All magic methods define important behavior
    }

    private func isCriticalNamespace(_ namespace: String) -> Bool {
        return true // All namespace declarations are critical
    }

    private func isCriticalTypeHint(_ typeHint: String) -> Bool {
        return typeHint.contains("?") ||
               typeHint.contains("|") ||
               typeHint.contains("array") ||
               typeHint.contains("callable") ||
               typeHint.contains("\\")
    }

    // MARK: - File Limit Methods

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
        var regular: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isPHPSignature(trimmed) || trimmed.hasPrefix("<?php") ||
               trimmed.hasPrefix("#[") || trimmed.hasPrefix("@") {
                prioritized.append(line)
            } else {
                regular.append(line)
            }
        }

        let availableForRegular = maxLines - prioritized.count
        if availableForRegular > 0 {
            prioritized.append(contentsOf: Array(regular.prefix(availableForRegular)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let lines = processed.components(separatedBy: .newlines)
        var selectedLines: [String] = []

        // Prioritize critical lines first
        for line in lines {
            selectedLines.append(line)
            let currentTokens = TokenCounter.countTokens(in: selectedLines.joined(separator: "\n"), using: options.tokenizerType)
            if currentTokens > maxTokens {
                selectedLines.removeLast()
                break
            }
        }

        return selectedLines.joined(separator: "\n")
    }

    // MARK: - Structure Analysis Methods

    private func calculateCodeMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let functions = extractMagicMethods(code).count + code.matches(of: #"function\s+\w+"#).count
        let classes = code.matches(of: #"class\s+\w+"#).count
        let traits = extractTraits(code).count

        return [
            "lines": lines.count,
            "functions": functions,
            "classes": classes,
            "traits": traits
        ]
    }

    private func extractPHPStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "namespaces": extractNamespaces(code),
            "classes": code.matches(of: #"class\s+\w+"#),
            "interfaces": code.matches(of: #"interface\s+\w+"#),
            "traits": extractTraits(code),
            "functions": code.matches(of: #"function\s+\w+"#)
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "/* PHP Structure Overview */\n"

        if let lines = metrics["lines"] as? Int {
            output += "Lines: \(lines)\n"
        }
        if let functions = metrics["functions"] as? Int {
            output += "Functions: \(functions)\n"
        }
        if let classes = metrics["classes"] as? Int {
            output += "Classes: \(classes)\n"
        }
        if let traits = metrics["traits"] as? Int {
            output += "Traits: \(traits)\n"
        }

        return output
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

        // Apply compression to non-preserved parts
        processed = compressPHPComments(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressPHPComments(_ code: String) -> String {
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

    private func compressPHPMethodBodies(_ code: String) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let frameworkPatterns = extractFrameworkPatterns(code)
        let magicMethods = extractMagicMethods(code)
        let typeHints = extractTypeHints(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve framework patterns
        for (index, framework) in frameworkPatterns.enumerated() {
            let placeholder = "/* FRAMEWORK_\(index) */"
            preservedPatterns[placeholder] = framework
            processed = processed.replacingOccurrences(of: framework, with: placeholder)
        }

        // Preserve magic methods
        for (index, magic) in magicMethods.enumerated() {
            let placeholder = "/* MAGIC_\(index) */"
            preservedPatterns[placeholder] = magic
            processed = processed.replacingOccurrences(of: magic, with: placeholder)
        }

        // Preserve critical type hints
        for (index, typeHint) in typeHints.enumerated() {
            if isCriticalTypeHint(typeHint) {
                let placeholder = "/* TYPE_\(index) */"
                preservedPatterns[placeholder] = typeHint
                processed = processed.replacingOccurrences(of: typeHint, with: placeholder)
            }
        }

        // Compress function bodies while preserving signatures
        processed = processed.replacingOccurrences(
            of: #"(function\s+\w+\([^)]*\)(?:\s*:\s*[^{]+)?\s*\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.96
        case .medium: return 0.88
        case .aggressive: return 0.79
        case .maximum: return 0.56
        }
    }
}
