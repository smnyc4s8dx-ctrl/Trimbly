//  HTMLTemplateOptimizer.swift
import Foundation

class HTMLTemplateOptimizer: LanguageOptimizer {

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
        // Remove HTML comments but preserve template comments that contain logic
        let processed = code.replacingOccurrences(
            of: #"<!--(?![^>]*(?:\{|\[|@|<%|%\}|\}\})).*?-->"#,
            with: "",
            options: .regularExpression
        )
        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // For HTML templates, be careful about whitespace in text content
        if options.preserveSignificantWhitespace {
            // Only remove whitespace between tags
            processed = processed.replacingOccurrences(
                of: #">\s+<"#,
                with: "><",
                options: .regularExpression
            )
        } else {
            // More aggressive whitespace removal
            processed = processed.replacingOccurrences(
                of: #">\s*([^<{@%]+)\s*<"#,
                with: ">$1<",
                options: .regularExpression
            )
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

        // HTML templates typically use script tags for imports
        if !options.prioritizePublicAPIs {
            // Remove script imports but preserve inline scripts with logic
            processed = processed.replacingOccurrences(
                of: #"<script[^>]*src=[^>]*></script>"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove JSDoc and other documentation comments
        processed = processed.replacingOccurrences(
            of: #"/\*\*[\s\S]*?\*/"#,
            with: "",
            options: .regularExpression
        )

        // Remove documentation comments in script tags using NSRegularExpression
        do {
            let regex = try NSRegularExpression(pattern: #"//\s*@\w+.*$"#, options: [.anchorsMatchLines])
            let range = NSRange(processed.startIndex..., in: processed)
            processed = regex.stringByReplacingMatches(in: processed, options: [], range: range, withTemplate: "")
        } catch {
            print("Regex error in removeDocumentation: \(error)")
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Common debug patterns in templates
        let debugPatterns = [
            #"console\.log\([^)]*\);"#,
            #"console\.debug\([^)]*\);"#,
            #"debugger;"#,
            #"\{\{\s*console\.log\([^}]*\)\s*\}\}"#,
            #"v-if=[\"']false[\"']"#  // Debug visibility toggles
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

        // TypeScript type annotations in template expressions
        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #":\s*\w+(?:\[\])?(?:\s*\|[^}>,]*)*"#,
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

        // Truncate function bodies in script sections
        processed = processed.replacingOccurrences(
            of: #"(function\s+\w*\s*\([^)]*\)\s*\{)[^}]*(\})"#,
            with: "$1 /* implementation */ $2",
            options: .regularExpression
        )

        // Truncate arrow functions
        processed = processed.replacingOccurrences(
            of: #"(=>\s*\{)[^}]*(\})"#,
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

        // Extract JavaScript/TypeScript identifiers in script sections
        let identifierPattern = #"\b[a-zA-Z_$][a-zA-Z0-9_$]*\b"#

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
        return extractTemplateSignatures(code)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)
        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all template logic and structure
        var processed = code

        processed = removeLanguageComments(processed)
        processed = preserveHTMLStructure(processed)

        return processed
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve template logic and component structure
        return preserveTemplateLogic(code)
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only component architecture
        return preserveComponentArchitecture(code)
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only signatures and structure
        return extractTemplateSignatures(code)
    }

    // MARK: - HTML Template Specific Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let directives = extractTemplateDirectives(code)
        patterns.append(contentsOf: directives.map { .lifecycle($0) })

        let components = extractComponents(code)
        patterns.append(contentsOf: components.map { .interface($0) })

        let eventHandlers = extractEventHandlers(code)
        patterns.append(contentsOf: eventHandlers.map { .lifecycle($0) })

        let conditionals = extractConditionalRendering(code)
        patterns.append(contentsOf: conditionals.map { .lifecycle($0) })

        return patterns
    }

    private func preserveTemplateLogic(_ code: String) -> String {
        var processed = code

        let directives = extractTemplateDirectives(code)
        let components = extractComponents(code)
        let handlers = extractEventHandlers(code)
        let conditionals = extractConditionalRendering(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve template directives (v-if, *ngFor, etc.)
        for (index, directive) in directives.enumerated() {
            let placeholder = "<!-- DIRECTIVE_\(index) -->"
            preservedPatterns[placeholder] = directive
            processed = processed.replacingOccurrences(of: directive, with: placeholder)
        }

        // Preserve components (critical for understanding structure)
        for (index, component) in components.enumerated() {
            let placeholder = "<!-- COMPONENT_\(index) -->"
            preservedPatterns[placeholder] = component
            processed = processed.replacingOccurrences(of: component, with: placeholder)
        }

        // Preserve event handlers
        for (index, handler) in handlers.enumerated() {
            let placeholder = "<!-- HANDLER_\(index) -->"
            preservedPatterns[placeholder] = handler
            processed = processed.replacingOccurrences(of: handler, with: placeholder)
        }

        // Preserve conditional rendering
        for (index, conditional) in conditionals.enumerated() {
            let placeholder = "<!-- CONDITIONAL_\(index) -->"
            preservedPatterns[placeholder] = conditional
            processed = processed.replacingOccurrences(of: conditional, with: placeholder)
        }

        // Apply compression while preserving logic
        processed = removeLanguageComments(processed)
        processed = preserveHTMLStructure(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveComponentArchitecture(_ code: String) -> String {
        var processed = code

        let components = extractComponents(code)
        let bindings = extractDataBindings(code)
        let directives = extractTemplateDirectives(code)
        let handlers = extractEventHandlers(code)

        var preservedPatterns: [String: String] = [:]

        // Only preserve architectural patterns
        let architecturalPatterns = components.filter { isComponentDefinition($0) } +
                                  bindings +
                                  directives.filter { isCriticalDirective($0) }

        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "<!-- ARCH_\(index) -->"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Preserve critical event handlers
        let criticalHandlers = handlers.filter { isCriticalHandler($0) }
        for (index, handler) in criticalHandlers.enumerated() {
            let placeholder = "<!-- HANDLER_\(index) -->"
            preservedPatterns[placeholder] = handler
            processed = processed.replacingOccurrences(of: handler, with: placeholder)
        }

        // Aggressive compression of static content
        processed = compressStaticHTML(processed)
        processed = removeLanguageComments(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    // MARK: - Pattern Extraction Methods

    private func extractTemplateDirectives(_ code: String) -> [String] {
        let patterns = [
            #"v-\w+(?::[^=\s]+)?(?:="[^"]*")?"#,
            #"\*ng\w+(?:="[^"]*")?"#,
            #"\[[\w.-]+\](?:="[^"]*")?"#,
            #"\([\w.-]+\)(?:="[^"]*")?"#,
            #"\{[^}]+\}"#,
            #"<%[^%]*%>"#,
            #"@\w+(?:\([^)]*\))?"#,
            #"\{%[^%]*%\}"#,
            #"\{\{[^}]*\}\}"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractComponents(_ code: String) -> [String] {
        let patterns = [
            #"function\s+[A-Z]\w*\s*\([^)]*\)\s*\{"#,
            #"const\s+[A-Z]\w*\s*=\s*\([^)]*\)\s*=>"#,
            #"<template[^>]*>"#,
            #"<script[^>]*>"#,
            #"<style[^>]*>"#,
            #"<[a-z]+-[a-z-]+[^>]*>"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractEventHandlers(_ code: String) -> [String] {
        let patterns = [
            #"on[A-Z]\w*=\{[^}]+\}"#,
            #"@\w+=[\"\'][^\"\']*[\"\']"#,
            #"\(\w+\)=[\"\'][^\"\']*[\"\']"#,
            #"on\w+=[\"\'][^\"\']*[\"\']"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractConditionalRendering(_ code: String) -> [String] {
        let patterns = [
            #"\{[^}]*\?\s*[^:}]*\s*:\s*[^}]*\}"#,
            #"\{[^}]*&&\s*[^}]*\}"#,
            #"v-if=[\"\'][^\"\']*[\"\']"#,
            #"v-else-if=[\"\'][^\"\']*[\"\']"#,
            #"v-show=[\"\'][^\"\']*[\"\']"#,
            #"\*ngIf=[\"\'][^\"\']*[\"\']"#,
            #"v-for=[\"\'][^\"\']*[\"\']"#,
            #"\*ngFor=[\"\'][^\"\']*[\"\']"#,
            #"<%\s*if[^%]*%>"#,
            #"@if\([^)]*\)"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractDataBindings(_ code: String) -> [String] {
        let patterns = [
            #"\[[\w.-]+\](?:="[^"]*")?"#,
            #"\{\{[^}]*\}\}"#,
            #"v-bind:[^=\s]+(?:="[^"]*")?"#,
            #":[\w.-]+(?:="[^"]*")?"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        // HTML can be sensitive to whitespace in certain contexts
        return true
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        // Extract critical script imports that define components or libraries
        let patterns = [
            #"<script[^>]*src=[\"'][^\"']*(?:vue|react|angular|component)[^\"']*[\"'][^>]*>"#,
            #"import\s+[^;]+from\s+[\"'][^\"']*[\"']"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func removeStandardImports(_ code: String) -> String {
        var processed = code

        // Remove script tag imports
        processed = processed.replacingOccurrences(
            of: #"<script[^>]*src=[^>]*></script>"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract template expressions and directives that should be preserved
        return extractTemplateDirectives(code) + extractEventHandlers(code)
    }

    private func getFunctionBodyPattern() -> String {
        return #"(function\s+\w*\s*\([^)]*\)\s*\{)[^}]*(\})"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1 /* implementation */ $2"
    }

    private func getIdentifierPattern() -> String {
        return #"\b[a-zA-Z_$][a-zA-Z0-9_$]*\b"#
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Framework keywords and built-ins
        let frameworks = ["Vue", "React", "Angular", "Component", "mount", "render", "computed", "watch"]
        let builtins = ["document", "window", "console", "Array", "Object", "Function"]
        let htmlEvents = ["click", "submit", "change", "input", "focus", "blur"]

        return frameworks.contains(identifier) ||
               builtins.contains(identifier) ||
               htmlEvents.contains(identifier) ||
               identifier.count <= 2  // Don't shorten very short identifiers
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func isLanguageSignature(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("<template") || trimmed.contains("<script") ||
               trimmed.contains("<style") || trimmed.contains("function ") ||
               trimmed.contains("const ") || trimmed.contains("let ") ||
               trimmed.contains("v-") || trimmed.contains("*ng") ||
               trimmed.contains("@") || trimmed.contains("<%")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        return isComponentDefinition(line) || isCriticalDirective(line) || isCriticalHandler(line)
    }

    private func isComponentDefinition(_ component: String) -> Bool {
        return component.contains("function") || component.contains("const") ||
               component.contains("<template") || component.contains("<script")
    }

    private func isCriticalDirective(_ directive: String) -> Bool {
        let critical = ["v-if", "v-for", "*ngFor", "*ngIf", "v-model", "[", "(", "{"]
        return critical.contains { directive.contains($0) }
    }

    private func isCriticalHandler(_ handler: String) -> Bool {
        return handler.contains("click") || handler.contains("submit") ||
               handler.contains("change") || handler.contains("input")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In templates, exported components and props are considered public
        return identifier.first?.isUppercase == true || identifier.hasPrefix("prop")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        let keywords = ["var", "let", "const", "function", "class", "export", "import", "if", "else", "for", "while"]
        let builtins = ["document", "window", "console", "Array", "Object"]
        return keywords.contains(identifier) || builtins.contains(identifier)
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
        var priorityLines: [String] = []
        var regularLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("<template") || trimmed.contains("<script") ||
               trimmed.contains("<style") || trimmed.contains("function ") ||
               trimmed.contains("v-") || trimmed.contains("*ng") {
                priorityLines.append(line)
            } else {
                regularLines.append(line)
            }
        }

        result.append(contentsOf: priorityLines)
        let remainingSpace = maxLines - result.count
        if remainingSpace > 0 {
            result.append(contentsOf: Array(regularLines.prefix(remainingSpace)))
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // First try removing comments and whitespace
        processed = removeLanguageComments(processed)
        processed = removeExcessWhitespace(processed, options: options)

        let currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        if currentTokens <= maxTokens { return processed }

        // If still too large, truncate less important sections
        let lines = processed.components(separatedBy: .newlines)
        let targetRatio = Double(maxTokens) / Double(currentTokens)
        let targetLines = Int(Double(lines.count) * targetRatio)

        return prioritizeTopLevelLines(lines, maxLines: targetLines)
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let components = extractComponents(code).count
        let directives = extractTemplateDirectives(code).count
        let handlers = extractEventHandlers(code).count

        return [
            "lines": lines.count,
            "components": components,
            "directives": directives,
            "handlers": handlers,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "components": extractComponents(code).map { String($0.prefix(50)) },
            "directives": extractTemplateDirectives(code).map { String($0.prefix(30)) },
            "handlers": extractEventHandlers(code).map { String($0.prefix(30)) }
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let components = metrics["components"] as? Int ?? 0
        let directives = metrics["directives"] as? Int ?? 0
        let handlers = metrics["handlers"] as? Int ?? 0

        return """
        /* HTML Template Structure Overview */
        Lines: \(lines)
        Components: \(components)
        Directives: \(directives)
        Event Handlers: \(handlers)
        
        Component Types: \(structure["components"] as? [String] ?? [])
        Directive Types: \(structure["directives"] as? [String] ?? [])
        Handler Types: \(structure["handlers"] as? [String] ?? [])
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.99
        case .medium: return 0.94
        case .aggressive: return 0.88
        case .maximum: return 0.70
        }
    }

    // MARK: - HTML Specific Helper Methods

    private func preserveHTMLStructure(_ code: String) -> String {
        var processed = code.replacingOccurrences(
            of: #">\s+<"#,
            with: "><",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
        return processed
    }

    private func compressStaticHTML(_ code: String) -> String {
        var processed = code

        let directives = extractTemplateDirectives(code)
        var preservedDirectives: [String: String] = [:]
        for (index, directive) in directives.enumerated() {
            let placeholder = "<!-- DIRECTIVE_\(index) -->"
            preservedDirectives[placeholder] = directive
            processed = processed.replacingOccurrences(of: directive, with: placeholder)
        }

        let handlers = extractEventHandlers(code)
        var preservedHandlers: [String: String] = [:]
        for (index, handler) in handlers.enumerated() {
            let placeholder = "<!-- HANDLER_\(index) -->"
            preservedHandlers[placeholder] = handler
            processed = processed.replacingOccurrences(of: handler, with: placeholder)
        }

        processed = processed.replacingOccurrences(
            of: #">\s*([^<{@%]+)\s*<"#,
            with: ">$1<",
            options: .regularExpression
        )

        processed = processed.replacingOccurrences(
            of: #"\n\s*\n"#,
            with: "\n",
            options: .regularExpression
        )

        for (placeholder, directive) in preservedDirectives {
            processed = processed.replacingOccurrences(of: placeholder, with: directive)
        }
        for (placeholder, handler) in preservedHandlers {
            processed = processed.replacingOccurrences(of: placeholder, with: handler)
        }

        return processed
    }

    private func extractTemplateSignatures(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("<template") || trimmed.contains("<script") ||
               trimmed.contains("<style") {
                result.append(line)
            }
            else if trimmed.contains("function ") && trimmed.contains("Component") {
                result.append(line)
            }
            else if trimmed.contains("v-") || trimmed.contains("*ng") ||
                    trimmed.contains("@") || trimmed.contains("<%") {
                result.append(line)
            }
            else if trimmed.matches(of: #"<[A-Z][^>]*>"#).count > 0 {
                result.append(line)
            }
            else if trimmed.contains("{") || trimmed.contains("}") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }
}
