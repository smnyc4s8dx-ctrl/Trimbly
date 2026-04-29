//  CSSOptimizer.swift
import Foundation

class CSSOptimizer: LanguageOptimizer {

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

    // MARK: - CSS-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"/\*(?![*!])[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // CSS doesn't have significant whitespace like Python
        processed = processed.replacingOccurrences(
            of: #"\s*:\s*"#,
            with: ":",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*,\s*"#,
            with: ",",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*\{\s*"#,
            with: "{",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*\}\s*"#,
            with: "}",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*;\s*"#,
            with: ";",
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

        // CSS imports (@import statements)
        if options.prioritizePublicAPIs {
            // Preserve critical imports like custom fonts, reset stylesheets
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
        // CSS doesn't have formal documentation blocks like JSDoc
        // Already handled by comment removal
        return code
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Remove CSS debug-specific patterns
        let debugPatterns = [
            #"border:\s*1px\s+solid\s+red[^;]*;"#,  // Debug borders
            #"outline:\s*1px\s+solid\s+red[^;]*;"#, // Debug outlines
            #"/\*\s*debug[^*]*\*/"#,                 // Debug comments
            #"background:\s*#ff0000[^;]*;"#,         // Debug backgrounds
        ]

        for pattern in debugPatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        return processed
    }

    private func removeTypeAnnotations(_ code: String, options: CompressionOptions) -> String {
        // CSS doesn't have type annotations in the traditional sense
        // Could remove vendor prefixes if not prioritizing compatibility
        if !options.prioritizePublicAPIs {
            var processed = code
            let vendorPrefixes = [
                #"-webkit-[^:]*:[^;]*;"#,
                #"-moz-[^:]*:[^;]*;"#,
                #"-ms-[^:]*:[^;]*;"#,
                #"-o-[^:]*:[^;]*;"#
            ]

            for pattern in vendorPrefixes {
                processed = processed.replacingOccurrences(
                    of: pattern,
                    with: "",
                    options: .regularExpression
                )
            }
            return processed
        }
        return code
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        // CSS doesn't have functions in the traditional sense, but has @function in Sass
        // For pure CSS, we can truncate large rule blocks
        var processed = code

        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate large CSS rule blocks
        processed = processed.replacingOccurrences(
            of: #"(\{)[^}]{200,}(\})"#,
            with: "$1/* large rule block */$2",
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

        // CSS class and ID selectors
        let classPattern = #"\.([a-zA-Z][a-zA-Z0-9_-]*)"#
        let idPattern = #"#([a-zA-Z][a-zA-Z0-9_-]*)"#

        do {
            // Shorten class names
            let classRegex = try NSRegularExpression(pattern: classPattern)
            let classMatches = classRegex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in classMatches {
                if let range = Range(match.range(at: 1), in: code) {
                    let className = String(code[range])
                    if !isCriticalIdentifier(className, options: options) {
                        if identifierMap[className] == nil {
                            identifierMap[className] = "c\(counter)"
                            counter += 1
                        }
                    }
                }
            }

            // Shorten ID names
            let idRegex = try NSRegularExpression(pattern: idPattern)
            let idMatches = idRegex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in idMatches {
                if let range = Range(match.range(at: 1), in: code) {
                    let idName = String(code[range])
                    if !isCriticalIdentifier(idName, options: options) {
                        if identifierMap[idName] == nil {
                            identifierMap[idName] = "i\(counter)"
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in CSS identifier shortening: \(error)")
        }

        // Apply identifier mapping
        for (original, shortened) in identifierMap {
            processed = processed.replacingOccurrences(of: "\\.\(NSRegularExpression.escapedPattern(for: original))\\b", with: ".\(shortened)", options: .regularExpression)
            processed = processed.replacingOccurrences(of: "#\(NSRegularExpression.escapedPattern(for: original))\\b", with: "#\(shortened)", options: .regularExpression)
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
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractLanguageStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical CSS patterns
        return preserveCSSStructure(code)
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - focus on layout and responsive design
        return preserveCSSFeatures(code)
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only critical architectural patterns
        return preserveCSSArchitecture(code)
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only selectors and key properties
        return extractCSSSignatures(code)
    }

    // MARK: - CSS-Specific Methods (Preserved from original)

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let mediaQueries = extractMediaQueries(code)
        patterns.append(contentsOf: mediaQueries.map { .lifecycle($0) })

        let layoutSystems = extractLayoutSystems(code)
        patterns.append(contentsOf: layoutSystems.map { .trait($0) })

        let customProperties = extractCustomProperties(code)
        patterns.append(contentsOf: customProperties.map { .trait($0) })

        let animations = extractAnimations(code)
        patterns.append(contentsOf: animations.map { .lifecycle($0) })

        return patterns
    }

    private func preserveCSSFeatures(_ code: String) -> String {
        var processed = code

        let mediaQueries = extractMediaQueries(code)
        let layoutSystems = extractLayoutSystems(code)
        let customProperties = extractCustomProperties(code)
        let animations = extractAnimations(code)
        let cssInJS = extractCSSInJSPatterns(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve media queries (critical for responsive design)
        for (index, query) in mediaQueries.enumerated() {
            let placeholder = "/* MEDIA_QUERY_\(index) */"
            preservedPatterns[placeholder] = query
            processed = processed.replacingOccurrences(of: query, with: placeholder)
        }

        // Preserve layout systems (flexbox, grid)
        for (index, layout) in layoutSystems.enumerated() {
            let placeholder = "/* LAYOUT_\(index) */"
            preservedPatterns[placeholder] = layout
            processed = processed.replacingOccurrences(of: layout, with: placeholder)
        }

        // Preserve custom properties (CSS variables)
        for (index, property) in customProperties.enumerated() {
            let placeholder = "/* CUSTOM_PROP_\(index) */"
            preservedPatterns[placeholder] = property
            processed = processed.replacingOccurrences(of: property, with: placeholder)
        }

        // Preserve animations and transitions
        for (index, animation) in animations.enumerated() {
            let placeholder = "/* ANIMATION_\(index) */"
            preservedPatterns[placeholder] = animation
            processed = processed.replacingOccurrences(of: animation, with: placeholder)
        }

        // Preserve CSS-in-JS patterns
        for (index, cssInJSPattern) in cssInJS.enumerated() {
            let placeholder = "/* CSS_IN_JS_\(index) */"
            preservedPatterns[placeholder] = cssInJSPattern
            processed = processed.replacingOccurrences(of: cssInJSPattern, with: placeholder)
        }

        // Apply compression while preserving critical patterns
        processed = removeLanguageComments(processed)
        processed = preserveCSSStructure(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveCSSArchitecture(_ code: String) -> String {
        var processed = code

        let mediaQueries = extractMediaQueries(code)
        let layoutSystems = extractLayoutSystems(code)
        let customProperties = extractCustomProperties(code)
        let animations = extractAnimations(code)
        let advancedSelectors = extractAdvancedSelectors(code)

        var preservedPatterns: [String: String] = [:]

        // Only preserve architectural CSS patterns
        let architecturalPatterns = mediaQueries + layoutSystems + customProperties + animations + advancedSelectors

        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "/* ARCH_CSS_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Aggressive compression of decorative properties
        processed = compressDecorativeProperties(processed)
        processed = removeLanguageComments(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func compressDecorativeProperties(_ code: String) -> String {
        var processed = code

        // Get critical patterns to preserve
        let layoutProperties = extractLayoutSystems(code)
        let customProperties = extractCustomProperties(code)
        let animations = extractAnimations(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve layout properties
        for (index, property) in layoutProperties.enumerated() {
            let placeholder = "/* LAYOUT_\(index) */"
            preservedPatterns[placeholder] = property
            processed = processed.replacingOccurrences(of: property, with: placeholder)
        }

        // Preserve custom properties
        for (index, property) in customProperties.enumerated() {
            let placeholder = "/* CUSTOM_\(index) */"
            preservedPatterns[placeholder] = property
            processed = processed.replacingOccurrences(of: property, with: placeholder)
        }

        // Preserve animations
        for (index, animation) in animations.enumerated() {
            let placeholder = "/* ANIMATION_\(index) */"
            preservedPatterns[placeholder] = animation
            processed = processed.replacingOccurrences(of: animation, with: placeholder)
        }

        // Compress decorative properties
        let decorativePatterns = [
            #"color:[^;]*;"#,
            #"background(?:-color|-image)?:[^;]*;"#,
            #"border(?:-width|-style|-color)?:[^;]*;"#,
            #"box-shadow:[^;]*;"#,
            #"text-shadow:[^;]*;"#,
            #"border-radius:[^;]*;"#
        ]

        for pattern in decorativePatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "/* decorative */",
                options: .regularExpression
            )
        }

        // Restore preserved patterns
        for (placeholder, property) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: property)
        }

        return processed
    }

    // MARK: - Pattern Extraction Methods

    private func extractMediaQueries(_ code: String) -> [String] {
        let patterns = [
            #"@media[^{]*\{[^}]*\}"#,
            #"@supports[^{]*\{[^}]*\}"#,
            #"@container[^{]*\{[^}]*\}"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractLayoutSystems(_ code: String) -> [String] {
        let patterns = [
            #"display:\s*(?:grid|flex|inline-grid|inline-flex)"#,
            #"grid-template-[^;]*"#,
            #"grid-area:[^;]*"#,
            #"flex-direction:[^;]*"#,
            #"justify-content:[^;]*"#,
            #"align-items:[^;]*"#,
            #"gap:[^;]*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractCustomProperties(_ code: String) -> [String] {
        let patterns = [
            #"--[\w-]+:[^;]*"#,
            #"var\(--[\w-]+(?:,[^)]+)?\)"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractAnimations(_ code: String) -> [String] {
        let patterns = [
            #"@keyframes\s+[\w-]+\s*\{[^}]*\}"#,
            #"animation:[^;]*"#,
            #"transition:[^;]*"#,
            #"transform:[^;]*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractCSSInJSPatterns(_ code: String) -> [String] {
        let patterns = [
            #"styled\.\w+`[^`]*`"#,
            #"css`[^`]*`"#,
            #"makeStyles\([^)]*\)"#,
            #"useStyles\(\)"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractAdvancedSelectors(_ code: String) -> [String] {
        let patterns = [
            #":(?:hover|focus|active|disabled|checked|nth-child|nth-of-type)\([^)]*\)"#,
            #"::(?:before|after|first-line|first-letter)"#,
            #"\[[\w-]+(?:[~|^$*]?=[^\]]+)?\]"#,
            #":not\([^)]+\)"#,
            #":has\([^)]+\)"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func preserveCSSStructure(_ code: String) -> String {
        var processed = code.replacingOccurrences(
            of: #"\s*:\s*"#,
            with: ": ",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*,\s*"#,
            with: ", ",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*\{\s*"#,
            with: " { ",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*\}\s*"#,
            with: " }\n",
            options: .regularExpression
        )
        return processed
    }

    private func extractCSSSignatures(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("{") && !trimmed.contains("}") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@media") || trimmed.hasPrefix("@supports") {
                result.append(line)
            }
            else if trimmed.hasPrefix("--") || trimmed.contains("var(--") {
                result.append(line)
            }
            else if trimmed.contains("display:") || trimmed.contains("grid-") ||
                    trimmed.contains("flex-") || trimmed.contains("gap:") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@keyframes") || trimmed.contains("animation:") ||
                    trimmed.contains("transition:") {
                result.append(line)
            }
            else if trimmed == "}" {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // CSS doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let patterns = [
            #"@import\s+url\([^)]*\)\s*;"#,           // External stylesheets
            #"@import\s+[\"'][^\"']*fonts[^\"']*[\"']\s*;"#, // Font imports
            #"@import\s+[\"'][^\"']*reset[^\"']*[\"']\s*;"#,  // Reset stylesheets
            #"@import\s+[\"'][^\"']*normalize[^\"']*[\"']\s*;"# // Normalize stylesheets
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"@import[^;]*;"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract critical CSS patterns that should be preserved
        return extractMediaQueries(code) + extractAnimations(code) + extractCustomProperties(code)
    }

    private func isLanguageSignature(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("{") && !trimmed.contains("}") ||
               trimmed.hasPrefix("@") ||
               trimmed.contains("--") ||
               trimmed == "}"
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("display:") ||
               trimmed.contains("position:") ||
               trimmed.contains("grid-") ||
               trimmed.contains("flex-") ||
               trimmed.contains("animation:") ||
               trimmed.contains("transition:")
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return isPublicIdentifier(identifier)
        }
        return isKeywordOrBuiltin(identifier)
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // CSS classes/IDs that are likely to be referenced externally
        let publicPatterns = ["header", "footer", "nav", "main", "sidebar", "content", "menu", "button", "form", "input"]
        return publicPatterns.contains { identifier.lowercased().contains($0) }
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        // CSS keywords and built-in values
        let cssKeywords = ["auto", "inherit", "initial", "unset", "none", "block", "inline", "flex", "grid"]
        return cssKeywords.contains(identifier.lowercased())
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
        var lineCount = 0

        // Prioritize CSS rules with selectors
        for line in lines {
            if lineCount >= maxLines { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep selectors, media queries, and closing braces
            if trimmed.contains("{") || trimmed.hasPrefix("@") || trimmed == "}" {
                result.append(line)
                lineCount += 1
            }
        }

        // Fill remaining space with other lines
        for line in lines {
            if lineCount >= maxLines { break }
            if !result.contains(line) {
                result.append(line)
                lineCount += 1
            }
        }

        return result.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        var currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)

        // Progressive reduction strategies
        if currentTokens > maxTokens {
            // 1. Remove decorative properties first
            processed = compressDecorativeProperties(processed)
            currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        }

        if currentTokens > maxTokens {
            // 2. Extract signatures only
            processed = extractCSSSignatures(processed)
            currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        }

        if currentTokens > maxTokens {
            // 3. Truncate to fit
            let lines = processed.components(separatedBy: .newlines)
            let ratio = Double(maxTokens) / Double(currentTokens)
            let targetLines = max(1, Int(Double(lines.count) * ratio))
            processed = prioritizeTopLevelLines(lines, maxLines: targetLines)
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let rules = code.components(separatedBy: "{").count - 1
        let mediaQueries = extractMediaQueries(code).count
        let animations = extractAnimations(code).count
        let customProperties = extractCustomProperties(code).count

        return [
            "lines": lines.count,
            "rules": rules,
            "mediaQueries": mediaQueries,
            "animations": animations,
            "customProperties": customProperties
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        let metrics = calculateCodeMetrics(code, options: options)
        return [
            "selectors": extractSelectors(code),
            "mediaQueries": extractMediaQueries(code).count,
            "animations": extractAnimations(code).count,
            "customProperties": extractCustomProperties(code).count,
            "metrics": metrics
        ]
    }

    private func extractSelectors(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("{") && !trimmed.contains("}") {
                return trimmed.replacingOccurrences(of: "{", with: "").trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let rules = metrics["rules"] as? Int ?? 0
        let mediaQueries = metrics["mediaQueries"] as? Int ?? 0
        let animations = metrics["animations"] as? Int ?? 0
        let customProperties = metrics["customProperties"] as? Int ?? 0

        return """
        /* CSS Structure Overview */
        /* Rules: \(rules) */
        /* Media Queries: \(mediaQueries) */
        /* Animations: \(animations) */
        /* Custom Properties: \(customProperties) */
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.93
        case .aggressive: return 0.85
        case .maximum: return 0.68
        }
    }

}
