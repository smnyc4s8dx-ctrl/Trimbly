//  RustOptimizer.swift
import Foundation

class RustOptimizer: LanguageOptimizer {

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

    // MARK: - Rust-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Remove line comments but preserve important ones (TODO, FIXME, SAFETY, etc.)
        processed = processed.replacingOccurrences(
            of: #"//(?!\s*(?:TODO|FIXME|NOTE|SAFETY|HACK|XXX|WARNING))[^\n]*"#,
            with: "",
            options: .regularExpression
        )

        // Remove block comments but preserve doc comments (/// and /** */)
        processed = processed.replacingOccurrences(
            of: #"/\*(?![\*!])[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Rust doesn't have significant whitespace like Python, so we can be more aggressive
        if options.preserveSignificantWhitespace {
            // Only remove trailing whitespace
            processed = processed.replacingOccurrences(
                of: #"[ \t]+$"#,
                with: "",
                options: .regularExpression
            )
        } else {
            // Aggressive whitespace removal while preserving structure
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

        if options.prioritizePublicAPIs {
            // Keep public API documentation but remove internal docs
            processed = processed.replacingOccurrences(
                of: #"///(?!\s*pub)[^\n]*"#,
                with: "",
                options: .regularExpression
            )
        } else {
            // Remove all documentation comments
            processed = processed.replacingOccurrences(
                of: #"///[^\n]*"#,
                with: "",
                options: .regularExpression
            )

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
            #"println!\([^)]*\);"#,           // println! macro
            #"print!\([^)]*\);"#,             // print! macro
            #"eprintln!\([^)]*\);"#,          // eprintln! macro
            #"eprint!\([^)]*\);"#,            // eprint! macro
            #"dbg!\([^)]*\)"#,                // dbg! macro
            #"debug!\([^)]*\);"#,             // log debug macro
            #"trace!\([^)]*\);"#,             // log trace macro
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
            // Remove simple type annotations but keep complex ones with lifetimes/generics
            processed = processed.replacingOccurrences(
                of: #":\s*(?:i32|i64|u32|u64|f32|f64|bool|String|str|usize|isize)\b"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = processed.replacingOccurrences(
            of: getFunctionBodyPattern(),
            with: getFunctionTruncationReplacement(),
            options: .regularExpression
        )

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
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isLanguageSignature(trimmed) ||
               isCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code)
        let structure = extractLanguageStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical Rust patterns
        var processed = code

        // Only remove excessive whitespace while preserving Rust formatting
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        return processed
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve all critical Rust patterns but compress comments
        var processed = code

        let allPatterns = [
            extractTraits(code),
            extractMacros(code),
            extractLifetimePatterns(code),
            extractErrorHandling(code),
            extractConcurrencyPatterns(code),
            extractOwnershipPatterns(code)
        ].flatMap { $0 }

        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in allPatterns.enumerated() {
            let placeholder = "/* RUST_PATTERN_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = removeLanguageComments(processed)

        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve architectural patterns and compress implementations
        var processed = code

        let architecturalPatterns = [
            extractTraits(code),
            extractErrorHandling(code),
            extractConcurrencyPatterns(code),
            extractCriticalMacros(code)
        ].flatMap { $0 }

        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "/* ARCH_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = compressRustFunctionBodies(processed)

        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only signatures and critical patterns
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Module declarations and imports
            if trimmed.hasPrefix("use ") || trimmed.hasPrefix("mod ") ||
               trimmed.hasPrefix("extern crate ") {
                result.append(line)
            }
            // Struct, enum, trait, and impl declarations
            else if trimmed.contains("struct ") || trimmed.contains("enum ") ||
                    trimmed.contains("trait ") || trimmed.contains("impl ") {
                result.append(line)
            }
            // Function signatures
            else if trimmed.hasPrefix("fn ") || trimmed.hasPrefix("pub fn ") ||
                    trimmed.hasPrefix("async fn ") || trimmed.hasPrefix("pub async fn ") {
                result.append(line)
            }
            // Type aliases and constants
            else if trimmed.hasPrefix("type ") || trimmed.hasPrefix("const ") ||
                    trimmed.hasPrefix("static ") {
                result.append(line)
            }
            // Macros and attributes
            else if trimmed.hasPrefix("#[") || trimmed.contains("macro_rules!") {
                result.append(line)
            }
            // Critical error handling and ownership patterns
            else if trimmed.contains("Result<") || trimmed.contains("Option<") ||
                    trimmed.contains("Arc<") || trimmed.contains("Mutex<") ||
                    trimmed.contains("async ") || trimmed.contains(".await") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // Rust doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        var criticalImports: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Critical external crates and std imports
            if trimmed.hasPrefix("use std::") ||
               trimmed.hasPrefix("use tokio::") ||
               trimmed.hasPrefix("use serde::") ||
               trimmed.hasPrefix("use async_trait::") ||
               trimmed.hasPrefix("extern crate") ||
               trimmed.contains("pub use") {
                criticalImports.append(line)
            }
        }

        return criticalImports
    }

    private func removeStandardImports(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.hasPrefix("use ") && !trimmed.hasPrefix("extern crate ")
        }
        return filteredLines.joined(separator: "\n")
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating functions
        var patterns: [String] = []

        if options.prioritizePublicAPIs {
            patterns.append(contentsOf: extractErrorHandling(code))
            patterns.append(contentsOf: extractConcurrencyPatterns(code))
            patterns.append(contentsOf: extractOwnershipPatterns(code))
        }

        return patterns
    }

    private func getFunctionBodyPattern() -> String {
        return #"((?:pub\s+)?(?:async\s+)?fn\s+\w+(?:<[^>]*>)?\([^)]*\)(?:\s*->\s*[^{]+)?\s*\{)[^}]*(\})"#
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

        return trimmed.hasPrefix("fn ") ||
               trimmed.hasPrefix("pub fn ") ||
               trimmed.hasPrefix("struct ") ||
               trimmed.hasPrefix("enum ") ||
               trimmed.hasPrefix("trait ") ||
               trimmed.hasPrefix("impl ") ||
               trimmed.hasPrefix("type ") ||
               trimmed.hasPrefix("const ") ||
               trimmed.hasPrefix("static ")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if options.prioritizePublicAPIs {
            return trimmed.hasPrefix("pub ") ||
                   trimmed.contains("pub fn ") ||
                   trimmed.contains("pub struct ") ||
                   trimmed.contains("pub enum ") ||
                   trimmed.contains("pub trait ")
        }

        return trimmed.hasPrefix("#[") ||
               trimmed.contains("macro_rules!") ||
               trimmed.contains("unsafe")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In Rust context, we can't easily determine if an identifier is public
        // without more context, so we'll be conservative
        return identifier.count > 10 || identifier.contains("_")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let rustKeywords: Set<String> = [
            "as", "break", "const", "continue", "crate", "else", "enum", "extern",
            "false", "fn", "for", "if", "impl", "in", "let", "loop", "match",
            "mod", "move", "mut", "pub", "ref", "return", "self", "Self", "static",
            "struct", "super", "trait", "true", "type", "unsafe", "use", "where",
            "while", "async", "await", "dyn", "abstract", "become", "box", "do",
            "final", "macro", "override", "priv", "typeof", "unsized", "virtual", "yield"
        ]

        return rustKeywords.contains(identifier)
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

            // Prioritize top-level declarations
            if trimmed.hasPrefix("pub ") ||
               trimmed.hasPrefix("fn ") ||
               trimmed.hasPrefix("struct ") ||
               trimmed.hasPrefix("enum ") ||
               trimmed.hasPrefix("trait ") ||
               trimmed.hasPrefix("impl ") ||
               trimmed.hasPrefix("use ") ||
               trimmed.hasPrefix("mod ") {
                prioritized.append(line)
            } else {
                remaining.append(line)
            }
        }

        let availableForRemaining = maxLines - prioritized.count
        if availableForRemaining > 0 {
            prioritized.append(contentsOf: Array(remaining.prefix(availableForRemaining)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // Try increasingly aggressive compression until we fit
        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = removeLanguageComments(processed)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = removeExcessWhitespace(processed, options: options)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            processed = extractSignaturesOnly(processed, options: options)
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        let functionCount = code.matches(of: #"\bfn\s+\w+"#).count
        let structCount = code.matches(of: #"\bstruct\s+\w+"#).count
        let enumCount = code.matches(of: #"\benum\s+\w+"#).count
        let traitCount = code.matches(of: #"\btrait\s+\w+"#).count
        let implCount = code.matches(of: #"\bimpl\b"#).count

        return [
            "lines": nonEmptyLines.count,
            "functions": functionCount,
            "structs": structCount,
            "enums": enumCount,
            "traits": traitCount,
            "impls": implCount
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "traits": extractTraits(code),
            "macros": extractMacros(code),
            "errorHandling": extractErrorHandling(code),
            "concurrency": extractConcurrencyPatterns(code),
            "ownership": extractOwnershipPatterns(code)
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output: [String] = []

        output.append("/* Rust Structure Overview */")
        output.append("Lines: \(metrics["lines"] ?? 0)")
        output.append("Functions: \(metrics["functions"] ?? 0)")
        output.append("Structs: \(metrics["structs"] ?? 0)")
        output.append("Enums: \(metrics["enums"] ?? 0)")
        output.append("Traits: \(metrics["traits"] ?? 0)")
        output.append("Impls: \(metrics["impls"] ?? 0)")

        if let traits = structure["traits"] as? [String], !traits.isEmpty {
            output.append("Key Traits: \(traits.count)")
        }

        if let errorHandling = structure["errorHandling"] as? [String], !errorHandling.isEmpty {
            output.append("Error Patterns: \(errorHandling.count)")
        }

        if let concurrency = structure["concurrency"] as? [String], !concurrency.isEmpty {
            output.append("Async Patterns: \(concurrency.count)")
        }

        return output.joined(separator: "\n")
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98    // Preserves all Rust semantics
        case .medium: return 0.92   // Removes comments, preserves all functional patterns
        case .aggressive: return 0.84  // Compresses implementations, preserves architecture
        case .maximum: return 0.62  // Signatures and critical patterns only
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let traits = extractTraits(code)
        patterns.append(contentsOf: traits.map { .trait($0) })

        let macros = extractMacros(code)
        patterns.append(contentsOf: macros.map { .macro($0) })

        let lifetimes = extractLifetimePatterns(code)
        patterns.append(contentsOf: lifetimes.map { .genericConstraint($0) })

        let errorHandling = extractErrorHandling(code)
        patterns.append(contentsOf: errorHandling.map { .lifecycle($0) })

        let concurrency = extractConcurrencyPatterns(code)
        patterns.append(contentsOf: concurrency.map { .lifecycle($0) })

        let ownership = extractOwnershipPatterns(code)
        patterns.append(contentsOf: ownership.map { .lifecycle($0) })

        return patterns
    }

    // MARK: - Pattern Extraction (Preserved from original)

    private func extractTraits(_ code: String) -> [String] {
        let patterns = [
            #"trait\s+\w+[^{]*\{[^}]*\}"#,
            #"impl(?:<[^>]*>)?\s+\w+(?:<[^>]*>)?\s+for\s+\w+(?:<[^>]*>)?\s*\{[^}]*\}"#,
            #"impl(?:<[^>]*>)?\s+\w+(?:<[^>]*>)?\s*\{[^}]*\}"#,
            #"derive\([^)]+\)"#,
            #"#\[derive\([^)]+\)\]"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractMacros(_ code: String) -> [String] {
        let patterns = [
            #"macro_rules!\s+\w+[^{]*\{[^}]*\}"#,
            #"\w+![^;]*;"#,
            #"#\[\w+(?:\([^)]*\))?\]"#,
            #"println!\([^)]*\)"#,
            #"vec!\[[^\]]*\]"#,
            #"format!\([^)]*\)"#,
            #"assert(?:_eq)?!\([^)]*\)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractLifetimePatterns(_ code: String) -> [String] {
        let patterns = [
            #"<'[a-z]+[^>]*>"#,
            #"&'[a-z]+\s+\w+"#,
            #"fn\s+\w+<[^>]*'[a-z]+[^>]*>\([^)]*\)"#,
            #"struct\s+\w+<[^>]*'[a-z]+[^>]*>"#,
            #"impl<[^>]*'[a-z]+[^>]*>"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractErrorHandling(_ code: String) -> [String] {
        let patterns = [
            #"\?\s*;"#,
            #"\.unwrap\(\)"#,
            #"\.unwrap_or\([^)]+\)"#,
            #"\.unwrap_or_else\([^)]+\)"#,
            #"\.expect\([^)]+\)"#,
            #"match\s+[^{]+\{\s*Ok\([^)]*\)\s*=>[^,}]+,\s*Err\([^)]*\)\s*=>[^}]+\}"#,
            #"if let (?:Ok|Err)\([^)]*\)\s*=\s*[^{]+\{"#,
            #"Result<[^>]+>"#,
            #"Option<[^>]+>"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractConcurrencyPatterns(_ code: String) -> [String] {
        let patterns = [
            #"async\s+fn\s+\w+"#,
            #"\.await"#,
            #"tokio::\w+(?:::\w+)*"#,
            #"Arc<[^>]+>"#,
            #"Mutex<[^>]+>"#,
            #"RwLock<[^>]+>"#,
            #"mpsc::\w+"#,
            #"crossbeam::\w+"#,
            #"rayon::\w+"#,
            #"spawn\([^)]+\)"#,
            #"JoinHandle<[^>]+>"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractOwnershipPatterns(_ code: String) -> [String] {
        let patterns = [
            #"&mut\s+\w+"#,
            #"&\s*\w+"#,
            #"Box<[^>]+>"#,
            #"Rc<[^>]+>"#,
            #"RefCell<[^>]+>"#,
            #"Cell<[^>]+>"#,
            #"std::mem::\w+"#,
            #"std::ptr::\w+"#,
            #"unsafe\s*\{"#,
            #"Pin<[^>]+>"#,
            #"move\s+\|[^|]*\|"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractCriticalMacros(_ code: String) -> [String] {
        let patterns = [
            #"#\[derive\([^)]+\)\]"#,
            #"#\[cfg\([^)]+\)\]"#,
            #"#\[test\]"#,
            #"#\[bench\]"#,
            #"macro_rules!\s+\w+"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractPatternMatches(_ code: String, patterns: [String]) -> [String] {
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func compressRustFunctionBodies(_ code: String) -> String {
        var processed = code

        let errorPatterns = extractErrorHandling(code)
        var preservedErrors: [String: String] = [:]
        for (index, error) in errorPatterns.enumerated() {
            let placeholder = "/* ERROR_\(index) */"
            preservedErrors[placeholder] = error
            processed = processed.replacingOccurrences(of: error, with: placeholder)
        }

        let concurrencyPatterns = extractConcurrencyPatterns(code)
        var preservedConcurrency: [String: String] = [:]
        for (index, pattern) in concurrencyPatterns.enumerated() {
            let placeholder = "/* CONCURRENCY_\(index) */"
            preservedConcurrency[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        let ownershipPatterns = extractOwnershipPatterns(code)
        var preservedOwnership: [String: String] = [:]
        for (index, pattern) in ownershipPatterns.enumerated() {
            let placeholder = "/* OWNERSHIP_\(index) */"
            preservedOwnership[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = processed.replacingOccurrences(
            of: #"((?:pub\s+)?(?:async\s+)?fn\s+\w+(?:<[^>]*>)?\([^)]*\)(?:\s*->\s*[^{]+)?\s*\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        for (placeholder, error) in preservedErrors {
            processed = processed.replacingOccurrences(of: placeholder, with: error)
        }
        for (placeholder, pattern) in preservedConcurrency {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }
        for (placeholder, pattern) in preservedOwnership {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }
}
