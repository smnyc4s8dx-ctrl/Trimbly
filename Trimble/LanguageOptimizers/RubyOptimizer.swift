import Foundation

class RubyOptimizer: LanguageOptimizer {

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
            return preserveRubyStructure(code, options: options)
        case .medium:
            return preserveRubyDSL(code, options: options)
        case .aggressive:
            return preserveRubyArchitecture(code, options: options)
        case .maximum:
            return extractRubySignatures(code, options: options)
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

    // MARK: - Ruby-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        // Remove Ruby comments but preserve encoding and frozen string literal directives
        return code.replacingOccurrences(
            of: #"#(?!\s*(?:encoding|coding|frozen_string_literal))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Ruby preserves significant whitespace for heredocs and string literals
        if options.preserveSignificantWhitespace {
            // Only remove trailing whitespace
            processed = processed.replacingOccurrences(
                of: #"[ \t]+$"#,
                with: "",
                options: .regularExpression
            )
        } else {
            // Standard whitespace removal
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

        if options.prioritizePublicAPIs {
            let criticalRequires = extractCriticalImports(code)
            var preservedRequires: [String: String] = [:]

            for (index, requireStatement) in criticalRequires.enumerated() {
                let placeholder = "# PRESERVED_REQUIRE_\(index)"
                preservedRequires[placeholder] = requireStatement
                processed = processed.replacingOccurrences(of: requireStatement, with: placeholder)
            }

            // Remove remaining requires
            processed = removeStandardImports(processed)

            // Restore critical requires
            for (placeholder, requireStatement) in preservedRequires {
                processed = processed.replacingOccurrences(of: placeholder, with: requireStatement)
            }
        } else {
            processed = removeStandardImports(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove YARD documentation comments
        processed = processed.replacingOccurrences(
            of: #"#\s*@\w+[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove RDoc comments
        processed = processed.replacingOccurrences(
            of: #"##[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        let debugPatterns = [
            #"puts\s+[^\n]*\n"#,
            #"p\s+[^\n]*\n"#,
            #"pp\s+[^\n]*\n"#,
            #"binding\.pry\s*\n"#,
            #"byebug\s*\n"#,
            #"debugger\s*\n"#,
            #"Rails\.logger\.\w+\s+[^\n]*\n"#,
            #"logger\.\w+\s+[^\n]*\n"#
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
        // Ruby is dynamically typed, but remove type hint comments if present
        var processed = code

        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #"#\s*@type\s+[^\n]*\n"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical Ruby patterns first
        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "# PRESERVED_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate method bodies while preserving signatures
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

        do {
            let regex = try NSRegularExpression(pattern: getIdentifierPattern())
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
            print("Regex error in Ruby identifier shortening: \(error)")
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

            if isRubySignature(trimmed) ||
               isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code)
        let structure = extractRubyStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveRubyStructure(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all Ruby patterns
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveRubyDSL(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve all Ruby DSL features
        let dslPatterns = extractDSLPatterns(code)
        let blocks = extractBlocks(code)
        let metaprogramming = extractMetaprogramming(code)
        let symbols = extractSymbols(code)

        // Preserve critical patterns with placeholders
        processed = preservePatternsWithPlaceholders(
            code: processed,
            patterns: [
                ("DSL", dslPatterns.filter { isCriticalDSLPattern($0) }),
                ("BLOCK", blocks.filter { isCriticalBlock($0) }),
                ("META", metaprogramming.filter { isCriticalMetaprogramming($0) }),
                ("SYMBOL", symbols.filter { isCriticalSymbol($0) })
            ]
        )

        return processed
    }

    private func preserveRubyArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract patterns for architectural preservation
        let dslPatterns = extractDSLPatterns(code)
        let blocks = extractBlocks(code)
        let metaprogramming = extractMetaprogramming(code)
        let railsPatterns = extractRailsPatterns(code)
        let gemPatterns = extractGemPatterns(code)

        // Preserve only architecturally significant patterns
        var preservedPatterns: [(String, [String])] = []

        // DSL patterns: Only preserve Rails model/routing DSL
        preservedPatterns.append(("DSL", dslPatterns.filter { isCriticalDSLPattern($0) }))

        // Blocks: Only preserve complex iterators and functional patterns
        preservedPatterns.append(("BLOCK", blocks.filter { isCriticalBlock($0) }))

        // All metaprogramming is architecturally significant
        preservedPatterns.append(("META", metaprogramming))

        // Rails and gem patterns are always architectural
        preservedPatterns.append(("RAILS", railsPatterns))
        preservedPatterns.append(("GEM", gemPatterns))

        // Apply preservation with placeholders
        processed = preservePatternsWithPlaceholders(code: processed, patterns: preservedPatterns)

        // Compress implementations while preserving architectural patterns
        processed = compressRubyMethodBodies(processed)

        return processed
    }

    private func extractRubySignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("require ") || trimmed.hasPrefix("require_relative ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("class ") || trimmed.hasPrefix("module ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("def ") || trimmed.contains("def ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("has_many ") || trimmed.hasPrefix("belongs_to ") ||
                    trimmed.hasPrefix("validates ") || trimmed.hasPrefix("scope ") {
                result.append(line)
            }
            else if trimmed.hasPrefix("attr_") || trimmed.hasPrefix("delegate ") ||
                    trimmed.hasPrefix("include ") || trimmed.hasPrefix("extend ") {
                result.append(line)
            }
            else if trimmed.matches(of: #"^[A-Z][A-Z_]*\s*="#).count > 0 {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Ruby Pattern Extraction

    private func extractDSLPatterns(_ code: String) -> [String] {
        let patterns = [
            #"has_many\s+:\w+(?:,\s*[^\n]+)?"#,
            #"belongs_to\s+:\w+(?:,\s*[^\n]+)?"#,
            #"validates\s+:\w+(?:,\s*[^\n]+)?"#,
            #"scope\s+:\w+(?:,\s*[^\n]+)?"#,
            #"(?:get|post|put|delete|patch)\s+['\"][^'\"]*['\"]"#,
            #"resources\s+:\w+"#,
            #"describe\s+['\"][^'\"]*['\"]"#,
            #"it\s+['\"][^'\"]*['\"]"#,
            #"expect\([^)]+\)\.to\s+\w+"#,
            #"task\s+:\w+(?:\s*=>\s*\[:[^\]]*\])?"#,
            #"spec\.\w+\s*=\s*['\"][^'\"]*['\"]"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractBlocks(_ code: String) -> [String] {
        let patterns = [
            #"\w+(?:\([^)]*\))?\s+do(?:\s*\|[^|]*\|)?[^}]*end"#,
            #"\w+(?:\([^)]*\))?\s*\{(?:\s*\|[^|]*\|)?[^}]*\}"#,
            #"\.(?:each|map|select|reject|find|detect)\s*\{"#,
            #"\.(?:each|map|select|reject|find|detect)\s+do"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractMetaprogramming(_ code: String) -> [String] {
        let patterns = [
            #"attr_(?:reader|writer|accessor)\s+:\w+(?:,\s*:\w+)*"#,
            #"delegate\s+:\w+(?:,\s*:\w+)*,\s*to:\s*:\w+"#,
            #"alias_method\s+:\w+,\s*:\w+"#,
            #"def\s+method_missing\([^)]*\)"#,
            #"define_method\s*\(:[^)]+\)"#,
            #"(?:class|instance)_eval\s*\{"#,
            #"(?:include|extend)\s+\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractSymbols(_ code: String) -> [String] {
        let pattern = #":\w+"#
        return code.matches(of: pattern)
    }

    private func extractRailsPatterns(_ code: String) -> [String] {
        let patterns = [
            #"(?:before_action|after_action|around_action)\s+:\w+"#,
            #"rescue_from\s+\w+(?:,\s*with:\s*:\w+)?"#,
            #"helper_method\s+:\w+(?:,\s*:\w+)*"#,
            #"respond_to\s+do\s*\|[^|]*\|[^e]*end"#,
            #"render\s+(?:json|xml|partial):"#,
            #"redirect_to\s+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractGemPatterns(_ code: String) -> [String] {
        let patterns = [
            #"gem\s+['\"][^'\"]+['\"](?:,\s*[^\n]+)?"#,
            #"source\s+['\"][^'\"]+['\"]"#,
            #"group\s+:[^\s]+\s+do[^e]*end"#,
            #"bundle\s+\w+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // Ruby doesn't have significant whitespace like Python
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let criticalPatterns = [
            #"require\s+['\"]rails['\"]"#,
            #"require\s+['\"]bundler/setup['\"]"#,
            #"require_relative\s+['\"]config/[^'\"]*['\"]"#
        ]

        var results: [String] = []
        for pattern in criticalPatterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"(?:require|require_relative)\s+[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract Ruby patterns that should be preserved even when truncating methods
        let dslPatterns = extractDSLPatterns(code)
        let metaprogramming = extractMetaprogramming(code)
        let railsPatterns = extractRailsPatterns(code)

        return dslPatterns + metaprogramming + railsPatterns
    }

    private func getFunctionBodyPattern() -> String {
        return #"(def\s+\w+[^\n]*\n)[^}]*?(?=\n\s*(?:def|class|module|end|\z))"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1    # implementation\n"
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

    private func isRubySignature(_ line: String) -> Bool {
        return line.hasPrefix("def ") ||
               line.hasPrefix("class ") ||
               line.hasPrefix("module ") ||
               line.contains("attr_") ||
               line.contains("has_many") ||
               line.contains("belongs_to")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return line.contains("public") || !line.contains("private")
        }
        return line.hasPrefix("class ") || line.hasPrefix("module ") || line.hasPrefix("def ")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        return !identifier.hasPrefix("_") && !identifier.hasPrefix("@")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let rubyKeywords: Set<String> = [
            "class", "module", "def", "end", "if", "unless", "else", "elsif",
            "case", "when", "while", "until", "for", "break", "next", "return",
            "yield", "self", "super", "nil", "true", "false", "and", "or", "not",
            "begin", "rescue", "ensure", "retry", "raise", "require", "include", "extend"
        ]
        return rubyKeywords.contains(identifier)
    }

    // MARK: - Pattern Classification

    private func isCriticalDSLPattern(_ dsl: String) -> Bool {
        return dsl.contains("has_many") ||
               dsl.contains("belongs_to") ||
               dsl.contains("validates") ||
               dsl.contains("scope") ||
               dsl.contains("resources") ||
               dsl.contains("get ") ||
               dsl.contains("post ") ||
               dsl.contains("put ") ||
               dsl.contains("patch ") ||
               dsl.contains("delete ") ||
               dsl.contains("describe") ||
               dsl.contains("it ") ||
               dsl.contains("expect")
    }

    private func isCriticalBlock(_ block: String) -> Bool {
        return block.contains("do") ||
               block.contains("each") ||
               block.contains("map") ||
               block.contains("select") ||
               block.contains("inject") ||
               block.contains("reduce") ||
               block.count > 50 ||
               block.components(separatedBy: .newlines).count > 3
    }

    private func isCriticalMetaprogramming(_ meta: String) -> Bool {
        return true // All metaprogramming patterns are architecturally significant
    }

    private func isCriticalSymbol(_ symbol: String) -> Bool {
        return symbol.count > 3 ||
               symbol.contains("_") ||
               symbol == ":id" ||
               symbol == ":name" ||
               symbol == ":type"
    }

    // MARK: - Size Limiting Methods

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
        var priorityLines: [String] = []
        var regularLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("class ") || trimmed.hasPrefix("module ") ||
               trimmed.hasPrefix("def ") || trimmed.contains("has_many") ||
               trimmed.contains("belongs_to") || trimmed.contains("validates") {
                priorityLines.append(line)
            } else {
                regularLines.append(line)
            }
        }

        result.append(contentsOf: priorityLines)
        let remainingSpace = maxLines - priorityLines.count
        if remainingSpace > 0 {
            result.append(contentsOf: Array(regularLines.prefix(remainingSpace)))
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let lines = code.components(separatedBy: .newlines)

        // Remove lines progressively while preserving critical patterns
        for ratio in stride(from: 0.9, through: 0.1, by: -0.1) {
            let targetLineCount = Int(Double(lines.count) * ratio)
            processed = Array(lines.prefix(targetLineCount)).joined(separator: "\n")

            let currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
            if currentTokens <= maxTokens {
                break
            }
        }

        return processed
    }

    // MARK: - Structure Analysis

    private func calculateCodeMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        let classCount = code.matches(of: #"^\s*class\s+"#).count
        let moduleCount = code.matches(of: #"^\s*module\s+"#).count
        let methodCount = code.matches(of: #"^\s*def\s+"#).count

        return [
            "lines": nonEmptyLines.count,
            "classes": classCount,
            "modules": moduleCount,
            "methods": methodCount,
            "dsl_patterns": extractDSLPatterns(code).count,
            "blocks": extractBlocks(code).count
        ]
    }

    private func extractRubyStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "classes": code.matches(of: #"class\s+(\w+)"#),
            "modules": code.matches(of: #"module\s+(\w+)"#),
            "rails_models": extractDSLPatterns(code).filter { $0.contains("has_many") || $0.contains("belongs_to") },
            "metaprogramming": extractMetaprogramming(code)
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "# Ruby Structure Overview\n\n"

        output += "## Metrics\n"
        output += "- Lines: \(metrics["lines"] ?? 0)\n"
        output += "- Classes: \(metrics["classes"] ?? 0)\n"
        output += "- Modules: \(metrics["modules"] ?? 0)\n"
        output += "- Methods: \(metrics["methods"] ?? 0)\n"
        output += "- DSL Patterns: \(metrics["dsl_patterns"] ?? 0)\n"
        output += "- Blocks: \(metrics["blocks"] ?? 0)\n\n"

        if let classes = structure["classes"] as? [String], !classes.isEmpty {
            output += "## Classes\n"
            output += classes.joined(separator: "\n") + "\n\n"
        }

        if let modules = structure["modules"] as? [String], !modules.isEmpty {
            output += "## Modules\n"
            output += modules.joined(separator: "\n") + "\n\n"
        }

        return output
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.91
        case .aggressive: return 0.83
        case .maximum: return 0.58
        }
    }

    // MARK: - Pattern Preservation System

    private func preservePatternsWithPlaceholders(code: String, patterns: [(String, [String])]) -> String {
        var processed = code
        var preservedPatterns: [String: String] = [:]

        // Replace patterns with placeholders
        for (patternType, patternList) in patterns {
            for (index, pattern) in patternList.enumerated() {
                let placeholder = "# \(patternType)_\(index)"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            }
        }

        // Apply compression to non-preserved parts
        processed = compressRubyComments(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressRubyComments(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"#(?!\s*(?:encoding|coding|frozen_string_literal))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func compressRubyMethodBodies(_ code: String) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let blocks = extractBlocks(code)
        let dslPatterns = extractDSLPatterns(code)
        let metaprogramming = extractMetaprogramming(code)
        let railsPatterns = extractRailsPatterns(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve critical blocks
        for (index, block) in blocks.enumerated() {
            if isCriticalBlock(block) {
                let placeholder = "# BLOCK_\(index)"
                preservedPatterns[placeholder] = block
                processed = processed.replacingOccurrences(of: block, with: placeholder)
            }
        }

        // Preserve all DSL patterns
        for (index, dsl) in dslPatterns.enumerated() {
            let placeholder = "# DSL_\(index)"
            preservedPatterns[placeholder] = dsl
            processed = processed.replacingOccurrences(of: dsl, with: placeholder)
        }

        // Preserve all metaprogramming patterns
        for (index, meta) in metaprogramming.enumerated() {
            let placeholder = "# META_\(index)"
            preservedPatterns[placeholder] = meta
            processed = processed.replacingOccurrences(of: meta, with: placeholder)
        }

        // Preserve Rails patterns
        for (index, rails) in railsPatterns.enumerated() {
            let placeholder = "# RAILS_\(index)"
            preservedPatterns[placeholder] = rails
            processed = processed.replacingOccurrences(of: rails, with: placeholder)
        }

        // Compress method bodies while preserving signatures
        processed = processed.replacingOccurrences(
            of: #"(def\s+\w+[^\n]*\n)[^}]*?(?=\n\s*(?:def|class|module|end|\z))"#,
            with: "$1    # implementation\n",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let dslPatterns = extractDSLPatterns(code)
        patterns.append(contentsOf: dslPatterns.map { .macro($0) })

        let blocks = extractBlocks(code)
        patterns.append(contentsOf: blocks.map { .lifecycle($0) })

        let metaprogramming = extractMetaprogramming(code)
        patterns.append(contentsOf: metaprogramming.map { .macro($0) })

        let symbols = extractSymbols(code)
        patterns.append(contentsOf: symbols.map { .trait($0) })

        return patterns
    }
}
