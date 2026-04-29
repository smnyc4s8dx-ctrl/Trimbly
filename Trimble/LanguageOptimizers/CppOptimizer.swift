//  CppOptimizer.swift
import Foundation

class CppOptimizer: LanguageOptimizer {

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

        if let maxLines = options.maxLinesPerFile {
            processed = limitFileLines(processed, maxLines: maxLines, options: options)
        }

        if let maxTokens = options.maxTokensPerFile {
            processed = limitFileTokens(processed, maxTokens: maxTokens, options: options)
        }

        return processed
    }

    // MARK: - C++-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Remove single-line comments (preserve TODO/FIXME/HACK/NOTE)
        processed = processed.replacingOccurrences(
            of: #"//(?!\s*(?:TODO|FIXME|HACK|NOTE))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line comments
        processed = processed.replacingOccurrences(
            of: #"/\*(?!.*(?:TODO|HACK))[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.prioritizePublicAPIs {
            let criticalIncludes = extractCriticalIncludes(code)
            var preserved: [String: String] = [:]

            for (index, inc) in criticalIncludes.enumerated() {
                let placeholder = "/* PRESERVED_INCLUDE_\(index) */"
                preserved[placeholder] = inc
                processed = processed.replacingOccurrences(of: inc, with: placeholder)
            }

            processed = removeStandardIncludes(processed)

            for (placeholder, inc) in preserved {
                processed = processed.replacingOccurrences(of: placeholder, with: inc)
            }
        } else {
            processed = removeStandardIncludes(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove Doxygen-style documentation
        processed = processed.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        // Remove triple-slash Doxygen comments
        processed = processed.replacingOccurrences(
            of: #"///[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        let debugPatterns = [
            #"std::cout\s*<<[^;]*;"#,
            #"std::cerr\s*<<[^;]*;"#,
            #"printf\([^)]*\);"#,
            #"fprintf\(stderr[^)]*\);"#,
            #"qDebug\(\)\s*<<[^;]*;"#,
            #"LOG\([^)]*\);"#,
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
        // C++ type annotations are integral to the language; only remove auto where obvious
        return code
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Preserve RAII patterns and smart pointers
        let criticalPatterns = extractRAIIPatterns(code) + extractSmartPointerPatterns(code)
        var preserved: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preserved[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Compress function bodies
        processed = processed.replacingOccurrences(
            of: #"(\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        for (placeholder, pattern) in preserved {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenIdentifiers(_ code: String, options: CompressionOptions) -> String {
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        do {
            let regex = try NSRegularExpression(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#)
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
            // Regex compilation failure - return unmodified
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
        return extractCppSignatures(code)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)
        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - clean up whitespace only
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve C++ architectural patterns
        let templates = extractTemplatePatterns(code)
        let preprocessor = extractPreprocessorDirectives(code)
        let namespaces = extractNamespaceBlocks(code)
        let smartPointers = extractSmartPointerPatterns(code)

        var preserved: [String: String] = [:]
        var counter = 0

        let allPatterns = templates + preprocessor + namespaces + smartPointers
        for pattern in allPatterns {
            let placeholder = "/* PRESERVED_\(counter) */"
            preserved[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            counter += 1
        }

        // Light compression
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )

        for (placeholder, pattern) in preserved {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        let templates = extractTemplatePatterns(code)
        let preprocessor = extractPreprocessorDirectives(code)
        let headerGuards = extractHeaderGuards(code)

        var preserved: [String: String] = [:]
        var counter = 0

        let architecturalPatterns = templates + preprocessor + headerGuards
        for pattern in architecturalPatterns {
            if isCriticalCppPattern(pattern) || isArchitecturalCppPattern(pattern) {
                let placeholder = "/* PRESERVED_\(counter) */"
                preserved[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
                counter += 1
            }
        }

        // Compress function/method bodies
        processed = processed.replacingOccurrences(
            of: #"(\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        for (placeholder, pattern) in preserved {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        return extractCppSignatures(code)
    }

    // MARK: - C++-Specific Pattern Extraction

    private func extractTemplatePatterns(_ code: String) -> [String] {
        let patterns = [
            #"template\s*<[^>]*>"#,
            #"typename\s+\w+"#,
            #"class\s+\w+<[^>]+>"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractPreprocessorDirectives(_ code: String) -> [String] {
        let patterns = [
            #"#include\s*[<"][^>"]+[>"]"#,
            #"#define\s+[^\n]+"#,
            #"#ifdef\s+\w+"#,
            #"#ifndef\s+\w+"#,
            #"#endif"#,
            #"#pragma\s+[^\n]+"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractHeaderGuards(_ code: String) -> [String] {
        let patterns = [
            #"#ifndef\s+\w+_H\b"#,
            #"#define\s+\w+_H\b"#,
            #"#pragma\s+once"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractRAIIPatterns(_ code: String) -> [String] {
        let patterns = [
            #"~\w+\s*\([^)]*\)"#,                              // Destructors
            #"explicit\s+\w+\s*\([^)]*\)"#,                    // Explicit constructors
            #"std::lock_guard<[^>]+>\s+\w+"#,                   // Lock guards
            #"std::unique_lock<[^>]+>\s+\w+"#                   // Unique locks
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractSmartPointerPatterns(_ code: String) -> [String] {
        let patterns = [
            #"std::unique_ptr<[^>]+>"#,
            #"std::shared_ptr<[^>]+>"#,
            #"std::weak_ptr<[^>]+>"#,
            #"std::make_unique<[^>]+>\([^)]*\)"#,
            #"std::make_shared<[^>]+>\([^)]*\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractNamespaceBlocks(_ code: String) -> [String] {
        let pattern = #"namespace\s+\w+\s*\{"#
        return code.matches(of: pattern)
    }

    private func extractCppSignatures(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep includes and preprocessor directives
            if trimmed.hasPrefix("#") {
                result.append(line)
            }
            // Keep namespace declarations
            else if trimmed.hasPrefix("namespace ") {
                result.append(line)
            }
            // Keep class/struct/enum declarations
            else if trimmed.contains("class ") || trimmed.contains("struct ") ||
                    trimmed.contains("enum ") {
                result.append(line)
            }
            // Keep template declarations
            else if trimmed.hasPrefix("template") {
                result.append(line)
            }
            // Keep access specifiers
            else if trimmed.hasPrefix("public:") || trimmed.hasPrefix("private:") ||
                    trimmed.hasPrefix("protected:") {
                result.append(line)
            }
            // Keep function/method declarations (with return types)
            else if (trimmed.contains("(") && !trimmed.contains("{") &&
                     !trimmed.hasPrefix("if") && !trimmed.hasPrefix("for") &&
                     !trimmed.hasPrefix("while") && !trimmed.hasPrefix("switch")) {
                result.append(line)
            }
            // Keep using declarations
            else if trimmed.hasPrefix("using ") || trimmed.hasPrefix("typedef ") {
                result.append(line)
            }
            // Keep closing braces
            else if trimmed == "}" || trimmed == "};" {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Smart Pattern Classification

    private func isCriticalCppPattern(_ pattern: String) -> Bool {
        let criticalKeywords = [
            "template", "virtual", "override", "noexcept",
            "std::unique_ptr", "std::shared_ptr", "constexpr",
            "static_assert", "decltype", "auto"
        ]
        return criticalKeywords.contains { pattern.contains($0) }
    }

    private func isArchitecturalCppPattern(_ pattern: String) -> Bool {
        let architecturalKeywords = [
            "public", "private", "protected", "class", "struct",
            "namespace", "template", "virtual", "abstract"
        ]
        return architecturalKeywords.contains { pattern.contains($0) }
    }

    // MARK: - Utility Methods

    private func extractCriticalIncludes(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("#include") && (
                trimmed.contains("<memory>") ||
                trimmed.contains("<string>") ||
                trimmed.contains("<vector>") ||
                trimmed.contains("<map>") ||
                trimmed.contains("<algorithm>") ||
                trimmed.contains("<functional>") ||
                trimmed.contains("<iostream>") ||
                trimmed.contains("<thread>") ||
                trimmed.contains("<mutex>")
            )
        }
    }

    private func removeStandardIncludes(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"#include\s*[<"][^>"]+[>"]"#,
            with: "",
            options: .regularExpression
        )
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return identifier.first?.isUppercase == true
        }
        return isCppKeyword(identifier)
    }

    private func isCppKeyword(_ identifier: String) -> Bool {
        let cppKeywords: Set<String> = [
            "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor",
            "bool", "break", "case", "catch", "char", "char8_t", "char16_t", "char32_t",
            "class", "compl", "concept", "const", "consteval", "constexpr", "constinit",
            "const_cast", "continue", "co_await", "co_return", "co_yield", "decltype",
            "default", "delete", "do", "double", "dynamic_cast", "else", "enum",
            "explicit", "export", "extern", "false", "float", "for", "friend", "goto",
            "if", "inline", "int", "long", "mutable", "namespace", "new", "noexcept",
            "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected",
            "public", "register", "reinterpret_cast", "requires", "return", "short",
            "signed", "sizeof", "static", "static_assert", "static_cast", "struct",
            "switch", "template", "this", "thread_local", "throw", "true", "try",
            "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual",
            "void", "volatile", "wchar_t", "while", "xor", "xor_eq",
            // Common std:: types
            "std", "string", "vector", "map", "set", "pair", "tuple",
            "unique_ptr", "shared_ptr", "weak_ptr", "optional", "variant"
        ]
        return cppKeywords.contains(identifier)
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
        var regular: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") || trimmed.hasPrefix("namespace ") ||
               trimmed.contains("class ") || trimmed.contains("struct ") ||
               trimmed.hasPrefix("template") || trimmed.hasPrefix("public:") ||
               trimmed.hasPrefix("private:") || trimmed.hasPrefix("protected:") {
                prioritized.append(line)
            } else {
                regular.append(line)
            }
        }

        let available = maxLines - prioritized.count
        if available > 0 {
            prioritized.append(contentsOf: Array(regular.prefix(available)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

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
            processed = extractCppSignatures(processed)
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let classes = code.matches(of: #"class\s+\w+"#).count
        let structs = code.matches(of: #"struct\s+\w+"#).count
        let functions = code.matches(of: #"\w+\s+\w+\s*\([^)]*\)\s*(?:const)?\s*(?:override)?\s*\{"#).count
        let templates = extractTemplatePatterns(code).count
        let namespaces = extractNamespaceBlocks(code).count

        return [
            "lines": lines.count,
            "classes": classes,
            "structs": structs,
            "functions": functions,
            "templates": templates,
            "namespaces": namespaces,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "templates": extractTemplatePatterns(code).count,
            "preprocessor": extractPreprocessorDirectives(code).count,
            "smart_pointers": extractSmartPointerPatterns(code).count,
            "raii_patterns": extractRAIIPatterns(code).count,
            "header_guards": extractHeaderGuards(code).count
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "/* C++ Structure Overview */\n"
        output += "Lines: \(metrics["lines"] ?? 0)\n"
        output += "Classes: \(metrics["classes"] ?? 0)\n"
        output += "Structs: \(metrics["structs"] ?? 0)\n"
        output += "Functions: \(metrics["functions"] ?? 0)\n"
        output += "Templates: \(metrics["templates"] ?? 0)\n"
        output += "Namespaces: \(metrics["namespaces"] ?? 0)\n"
        output += "Smart Pointers: \(structure["smart_pointers"] ?? 0)\n"
        output += "RAII Patterns: \(structure["raii_patterns"] ?? 0)\n"
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

        let templates = extractTemplatePatterns(code)
        patterns.append(contentsOf: templates.map { .genericConstraint($0) })

        let preprocessor = extractPreprocessorDirectives(code)
        patterns.append(contentsOf: preprocessor.map { .macro($0) })

        let smartPointers = extractSmartPointerPatterns(code)
        patterns.append(contentsOf: smartPointers.map { .lifecycle($0) })

        let raii = extractRAIIPatterns(code)
        patterns.append(contentsOf: raii.map { .lifecycle($0) })

        return patterns
    }
}
