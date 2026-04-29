// SwiftOptimizer.swift
import Foundation

class SwiftOptimizer: LanguageOptimizer {

    // Pre-compiled regex cache for performance
    private static let regexCache: [String: NSRegularExpression] = {
        var cache: [String: NSRegularExpression] = [:]

        let patterns = [
            "protocolExtensions": #"extension\s+\w+\s*:\s*\w+\s*where\s+[^{]+\{"#,
            "propertyWrappers": #"@(State|Published|ObservedObject|StateObject|Binding|Environment|EnvironmentObject|AppStorage|SceneStorage|FocusState|GestureState)\s*"#,
            "genericConstraints": #"<[^>]*:\s*[^>]+>"#,
            "protocolDefinitions": #"protocol\s+\w+[^{]*\{[^}]*\}"#,
            "extensions": #"extension\s+\w+[^{]*\{[^}]*\}"#,
            "publicProtocols": #"public\s+protocol\s+\w+[^{]*\{[^}]*\}"#,
            "publicExtensions": #"public\s+extension\s+\w+[^{]*\{[^}]*\}"#,
            "documentation": #"///[^\n]*\n"#,
            "docBlocks": #"/\*\*[\s\S]*?\*/"#,
            "singleLineComments": #"//[^\n]*\n"#,
            "blockComments": #"/\*[\s\S]*?\*/"#,
            "imports": #"import\s+[^\n]+"#,
            "debugPrints": #"print\([^)]*\)"#,
            "typeAnnotations": #":\s*[A-Za-z][A-Za-z0-9<>\[\]?]*"#,
            "identifiers": #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#,
            "functionSignatures": #"func\s+\w+[^{]*"#,
            "propertyDeclarations": #"(?:var|let)\s+\w+[^=\n]*"#,
            "classStructEnum": #"(?:class|struct|enum)\s+\w+[^{]*"#
        ]

        for (key, pattern) in patterns {
            do {
                cache[key] = try NSRegularExpression(pattern: pattern, options: [])
            } catch {
                print("Failed to compile Swift regex for \(key): \(error)")
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

        // Step 1.5: Strip #Preview blocks (developer-only Xcode canvas artifacts)
        if options.removeComments {
            processed = removePreviewBlocks(processed)
        }

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
            processed = removeSwiftComments(processed)
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
            processed = removeSwiftDocumentation(processed, options: options)
        }

        if options.removeDebugStatements {
            processed = removeSwiftDebugStatements(processed)
        }

        return processed
    }

    // MARK: - Semantic Level Compression
    private func applySemanticLevelCompression(_ code: String, options: CompressionOptions) -> String {
        switch options.semanticLevel {
        case .light:
            return preserveSwiftKeyPatterns(code, options: options)
        case .medium:
            return preserveSwiftArchitecture(code, options: options)
        case .aggressive:
            return preserveSwiftPublicAPIs(code, options: options)
        case .maximum:
            return extractSwiftSignatures(code, options: options)
        }
    }

    // MARK: - Advanced Compression Options
    private func applyAdvancedCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeTypeAnnotations {
            processed = removeSwiftTypeAnnotations(processed, options: options)
        }

        if options.truncateFunctions {
            processed = truncateSwiftFunctionBodies(processed, options: options)
        }

        if options.shortenIdentifiers {
            processed = shortenSwiftIdentifiers(processed, options: options)
        }

        if options.signaturesOnly {
            processed = extractSwiftSignaturesOnly(processed, options: options)
        }

        if options.structureOnly {
            processed = extractSwiftStructureOnly(processed, options: options)
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

    // MARK: - Swift-Specific Implementation Methods

    private func removeSwiftComments(_ code: String) -> String {
        var processed = code

        // Remove single-line comments
        if let regex = Self.regexCache["singleLineComments"] {
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Remove block comments
        if let regex = Self.regexCache["blockComments"] {
            processed = regex.stringByReplacingMatches(
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

        // Swift doesn't have significant whitespace like Python
        // Aggressive whitespace removal
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

        // Preserve critical imports if prioritizing public APIs
        if options.prioritizePublicAPIs {
            let criticalImports = extractCriticalSwiftImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            // Remove remaining imports
            if let regex = Self.regexCache["imports"] {
                processed = regex.stringByReplacingMatches(
                    in: processed,
                    options: [],
                    range: NSRange(processed.startIndex..., in: processed),
                    withTemplate: ""
                )
            }

            // Restore critical imports
            for (placeholder, importStatement) in preservedImports {
                processed = processed.replacingOccurrences(of: placeholder, with: importStatement)
            }
        } else {
            if let regex = Self.regexCache["imports"] {
                processed = regex.stringByReplacingMatches(
                    in: processed,
                    options: [],
                    range: NSRange(processed.startIndex..., in: processed),
                    withTemplate: ""
                )
            }
        }

        return processed
    }

    private func removeSwiftDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove triple-slash documentation
        if let regex = Self.regexCache["documentation"] {
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Remove doc block comments
        if let regex = Self.regexCache["docBlocks"] {
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        return processed
    }

    private func removeSwiftDebugStatements(_ code: String) -> String {
        var processed = code

        // Remove print statements
        if let regex = Self.regexCache["debugPrints"] {
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Remove other debug patterns
        let debugPatterns = [
            #"NSLog\([^)]*\)"#,
            #"debugPrint\([^)]*\)"#,
            #"dump\([^)]*\)"#,
            #"fatalError\([^)]*\)"#,
            #"preconditionFailure\([^)]*\)"#
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

    private func removeSwiftTypeAnnotations(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Only remove non-critical type annotations
        if !options.prioritizePublicAPIs {
            // Remove simple type annotations but preserve complex ones
            processed = processed.replacingOccurrences(
                of: #":\s*(?:String|Int|Double|Float|Bool|Data|URL)\b"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private static let funcSignaturePattern: NSRegularExpression = {
        try! NSRegularExpression(pattern: #"(?:public |private |internal |open |fileprivate |static |class |override |@\w+\s+)*\s*func\s+[^{]+"#)
    }()

    private static let privateDeclPattern: NSRegularExpression = {
        try! NSRegularExpression(pattern: #"private\s+[^{]+"#)
    }()

    private func truncateSwiftFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let criticalPatterns = extractSwiftFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Use brace-counting for correct nested body handling
        processed = replaceBracedBodies(in: processed, pattern: Self.funcSignaturePattern, placeholder: "/* implementation */")

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenSwiftIdentifiers(_ code: String, options: CompressionOptions) -> String {
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        guard let regex = Self.regexCache["identifiers"] else { return processed }

        let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

        for match in matches {
            if let range = Range(match.range, in: code) {
                let identifier = String(code[range])

                // Don't shorten critical identifiers
                if !isSwiftCriticalIdentifier(identifier, options: options) {
                    if identifierMap[identifier] == nil {
                        identifierMap[identifier] = generateShortIdentifier(counter)
                        counter += 1
                    }
                }
            }
        }

        // Apply identifier mapping
        for (original, shortened) in identifierMap {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: original))\\b"
            processed = processed.replacingOccurrences(of: pattern, with: shortened, options: .regularExpression)
        }

        return processed
    }

    private func extractSwiftSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isSwiftSignature(trimmed) ||
               isSwiftCriticalDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractSwiftStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateSwiftCodeMetrics(code, options: options)
        let structure = extractSwiftStructure(code, options: options)

        return formatSwiftStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveSwiftKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove documentation comments but preserve critical patterns
        if let docRegex = Self.regexCache["documentation"] {
            processed = docRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Clean up excessive whitespace
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )

        return processed
    }

    private func preserveSwiftArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical patterns
        let protocolExtensions = extractWithRegex(code, key: "protocolExtensions")
        let propertyWrappers = extractWithRegex(code, key: "propertyWrappers")
        let protocols = extractWithRegex(code, key: "protocolDefinitions")
        let extensions = extractWithRegex(code, key: "extensions")

        var preservedPatterns: [String: String] = [:]

        // Preserve protocol extensions
        for (index, pattern) in protocolExtensions.enumerated() {
            let placeholder = "/* PROTO_EXT_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Preserve property wrappers
        for (index, wrapper) in propertyWrappers.enumerated() {
            let placeholder = "/* WRAPPER_\(index) */"
            preservedPatterns[placeholder] = wrapper
            processed = processed.replacingOccurrences(of: wrapper, with: placeholder)
        }

        // Compress method bodies using brace-counting
        processed = replaceBracedBodies(in: processed, pattern: Self.funcSignaturePattern, placeholder: "/* implementation */")

        // Remove documentation
        if let docRegex = Self.regexCache["documentation"] {
            processed = docRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveSwiftPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        let publicProtocols = extractWithRegex(code, key: "publicProtocols")
        let publicExtensions = extractWithRegex(code, key: "publicExtensions")
        let propertyWrappers = extractWithRegex(code, key: "propertyWrappers")

        var preservedPatterns: [String: String] = [:]

        // Preserve only public elements
        for (index, protocolDef) in publicProtocols.enumerated() {
            let placeholder = "/* PUBLIC_PROTOCOL_\(index) */"
            preservedPatterns[placeholder] = protocolDef
            processed = processed.replacingOccurrences(of: protocolDef, with: placeholder)
        }

        for (index, extensionDef) in publicExtensions.enumerated() {
            let placeholder = "/* PUBLIC_EXT_\(index) */"
            preservedPatterns[placeholder] = extensionDef
            processed = processed.replacingOccurrences(of: extensionDef, with: placeholder)
        }

        for (index, wrapper) in propertyWrappers.enumerated() {
            let placeholder = "/* WRAPPER_\(index) */"
            preservedPatterns[placeholder] = wrapper
            processed = processed.replacingOccurrences(of: wrapper, with: placeholder)
        }

        // Aggressive compression — brace-counting for correct nested body handling
        processed = replaceBracedBodies(in: processed, pattern: Self.funcSignaturePattern, placeholder: "/* impl */")

        // Remove private implementations using brace-counting
        processed = replaceBracedBodies(in: processed, pattern: Self.privateDeclPattern, placeholder: "/* private implementation */")

        // Remove documentation
        if let docRegex = Self.regexCache["documentation"] {
            processed = docRegex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        }

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func extractSwiftSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Keep imports, protocols, classes, structs, enums
            if trimmed.hasPrefix("import ") ||
               trimmed.contains("protocol ") ||
               trimmed.contains("struct ") ||
               trimmed.contains("class ") ||
               trimmed.contains("enum ") ||
               trimmed.contains("extension ") ||
               trimmed.contains("func ") ||
               trimmed.hasPrefix("@") ||
               (trimmed.hasPrefix("var ") || trimmed.hasPrefix("let ")) ||
               trimmed == "}" {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Preview & Brace-Counting Utilities

    private func removePreviewBlocks(_ code: String) -> String {
        var result = code
        while let range = findBracedBlock(in: result, startingWith: "#Preview") {
            result.removeSubrange(range)
        }
        return result
    }

    private func findBracedBlock(in code: String, startingWith marker: String) -> Range<String.Index>? {
        guard let markerRange = code.range(of: marker) else { return nil }
        guard let braceStart = code[markerRange.upperBound...].firstIndex(of: "{") else { return nil }
        guard let closingIdx = findMatchingBrace(in: code, from: braceStart) else { return nil }
        var end = code.index(after: closingIdx)
        if end < code.endIndex && code[end] == "\n" { end = code.index(after: end) }
        return markerRange.lowerBound..<end
    }

    /// Find the index of the closing `}` that matches the opening `{` at `braceStart`,
    /// skipping braces inside string literals and comments.
    private func findMatchingBrace(in code: String, from braceStart: String.Index) -> String.Index? {
        var depth = 0
        var i = braceStart
        var inString = false
        var inMultilineString = false
        var inLineComment = false
        var inBlockComment = false

        while i < code.endIndex {
            let ch = code[i]
            let next: Character? = code.index(after: i) < code.endIndex ? code[code.index(after: i)] : nil

            // Line comment: skip to end of line
            if inLineComment {
                if ch == "\n" { inLineComment = false }
                i = code.index(after: i)
                continue
            }

            // Block comment: skip to */
            if inBlockComment {
                if ch == "*" && next == "/" {
                    inBlockComment = false
                    i = code.index(i, offsetBy: 2)
                    continue
                }
                i = code.index(after: i)
                continue
            }

            // Multiline string literal (""")
            if inMultilineString {
                if ch == "\"" && next == "\"" {
                    let third = code.index(i, offsetBy: 2)
                    if third < code.endIndex && code[third] == "\"" {
                        inMultilineString = false
                        i = code.index(i, offsetBy: 3)
                        continue
                    }
                }
                // Skip escaped characters
                if ch == "\\" {
                    i = code.index(i, offsetBy: 2, limitedBy: code.endIndex) ?? code.endIndex
                    continue
                }
                i = code.index(after: i)
                continue
            }

            // Regular string literal
            if inString {
                if ch == "\\" {
                    i = code.index(i, offsetBy: 2, limitedBy: code.endIndex) ?? code.endIndex
                    continue
                }
                if ch == "\"" { inString = false }
                i = code.index(after: i)
                continue
            }

            // Normal code
            if ch == "/" && next == "/" {
                inLineComment = true
                i = code.index(i, offsetBy: 2)
                continue
            }
            if ch == "/" && next == "*" {
                inBlockComment = true
                i = code.index(i, offsetBy: 2)
                continue
            }
            if ch == "\"" {
                if next == "\"" {
                    let third = code.index(i, offsetBy: 2)
                    if third < code.endIndex && code[third] == "\"" {
                        inMultilineString = true
                        i = code.index(i, offsetBy: 3)
                        continue
                    }
                }
                inString = true
                i = code.index(after: i)
                continue
            }

            if ch == "{" { depth += 1 }
            else if ch == "}" {
                depth -= 1
                if depth == 0 { return i }
            }
            i = code.index(after: i)
        }
        return nil
    }

    /// Replace all braced blocks matching a regex pattern with a placeholder.
    /// The regex should match everything up to (but not including) the opening `{`.
    private func replaceBracedBodies(in code: String, pattern: NSRegularExpression, placeholder: String) -> String {
        var result = ""
        var searchStart = code.startIndex

        while searchStart < code.endIndex {
            let searchString = String(code[searchStart...])
            let searchRange = NSRange(location: 0, length: searchString.utf16.count)

            guard let match = pattern.firstMatch(in: searchString, range: searchRange),
                  match.range.location != NSNotFound,
                  let matchRange = Range(match.range, in: searchString) else {
                result += code[searchStart...]
                break
            }

            // Map match offsets back into original code indices
            let matchStartOffset = searchString.distance(from: searchString.startIndex, to: matchRange.lowerBound)
            let matchEndOffset = searchString.distance(from: searchString.startIndex, to: matchRange.upperBound)
            let codeMatchStart = code.index(searchStart, offsetBy: matchStartOffset)
            let codeMatchEnd = code.index(searchStart, offsetBy: matchEndOffset)

            // Add everything before the match
            result += code[searchStart..<codeMatchStart]
            let signature = String(code[codeMatchStart..<codeMatchEnd])

            // Find opening brace after signature
            guard let braceStart = code[codeMatchEnd...].firstIndex(of: "{") else {
                result += signature
                searchStart = codeMatchEnd
                continue
            }

            // Lexical-aware brace-counting to find matching close
            if let closingIdx = findMatchingBrace(in: code, from: braceStart) {
                result += signature + "{ \(placeholder) }"
                searchStart = code.index(after: closingIdx)
            } else {
                // Unmatched braces — keep remaining text as-is
                result += code[codeMatchStart...]
                break
            }
        }
        return result
    }

    // MARK: - Swift-Specific Utility Methods

    private func extractWithRegex(_ code: String, key: String) -> [String] {
        guard let regex = Self.regexCache[key] else { return [] }

        let range = NSRange(code.startIndex..., in: code)
        let matches = regex.matches(in: code, options: [], range: range)

        return matches.compactMap { match in
            Range(match.range, in: code).map { String(code[$0]) }
        }
    }

    private func extractCriticalSwiftImports(_ code: String) -> [String] {
        let imports = extractWithRegex(code, key: "imports")
        return imports.filter { importStatement in
            let criticalFrameworks = ["SwiftUI", "Combine", "Foundation", "UIKit", "AppKit"]
            return criticalFrameworks.contains { framework in
                importStatement.contains(framework)
            }
        }
    }

    private func extractSwiftFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        var patterns: [String] = []

        // Preserve property wrappers in function bodies
        patterns.append(contentsOf: extractWithRegex(code, key: "propertyWrappers"))

        // Preserve async/await patterns
        let asyncPatterns = code.matches(of: #"(?:async|await)\s+[^\n]+"#)
        patterns.append(contentsOf: asyncPatterns)

        return patterns
    }

    private func isSwiftSignature(_ line: String) -> Bool {
        return line.contains("func ") ||
               line.contains("var ") ||
               line.contains("let ") ||
               line.contains("protocol ") ||
               line.contains("struct ") ||
               line.contains("class ") ||
               line.contains("enum ") ||
               line.hasPrefix("@")
    }

    private func isSwiftCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return line.contains("public ") || line.contains("open ")
        }
        return isSwiftSignature(line)
    }

    private func isSwiftCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Swift keywords and built-ins
        let swiftKeywords = Set([
            "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "public", "private", "internal", "open", "fileprivate", "static", "final",
            "override", "mutating", "nonmutating", "convenience", "required", "optional",
            "lazy", "weak", "unowned", "async", "await", "throws", "rethrows",
            "self", "Self", "super", "init", "deinit", "subscript", "operator",
            "associatedtype", "typealias", "inout", "some", "any"
        ])

        if swiftKeywords.contains(identifier) {
            return true
        }

        // SwiftUI property wrappers and common identifiers
        let swiftUIIdentifiers = Set([
            "State", "Binding", "ObservedObject", "StateObject", "EnvironmentObject",
            "Environment", "AppStorage", "SceneStorage", "FocusState", "GestureState",
            "body", "view", "content", "action", "label"
        ])

        if swiftUIIdentifiers.contains(identifier) {
            return true
        }

        if options.prioritizePublicAPIs {
            // Don't shorten identifiers that start with capital letters (likely public types)
            return identifier.first?.isUppercase ?? false
        }

        return false
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "v\(counter)"
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeSwiftTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeSwiftTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        var prioritized: [String] = []
        var remaining: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isSwiftSignature(trimmed) || trimmed.hasPrefix("import ") || trimmed == "}" {
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
        let targetTokens = Int(Double(maxTokens) * 0.9) // 10% buffer

        // Try progressive compression steps
        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > targetTokens {
            processed = removeSwiftComments(processed)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > targetTokens {
            processed = removeSwiftDocumentation(processed, options: options)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > targetTokens {
            processed = truncateSwiftFunctionBodies(processed, options: options)
        }

        if TokenCounter.countTokens(in: processed, using: options.tokenizerType) > targetTokens {
            // Last resort: extract signatures only
            processed = extractSwiftSignatures(processed, options: options)
        }

        return processed
    }

    private func calculateSwiftCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let functions = extractWithRegex(code, key: "functionSignatures").count
        let classes = code.matches(of: #"class\s+\w+"#).count
        let structs = code.matches(of: #"struct\s+\w+"#).count
        let enums = code.matches(of: #"enum\s+\w+"#).count
        let protocols = code.matches(of: #"protocol\s+\w+"#).count
        let extensions = code.matches(of: #"extension\s+\w+"#).count

        return [
            "lines": lines.count,
            "functions": functions,
            "classes": classes,
            "structs": structs,
            "enums": enums,
            "protocols": protocols,
            "extensions": extensions,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractSwiftStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        let propertyWrappers = extractWithRegex(code, key: "propertyWrappers")
        let protocols = extractWithRegex(code, key: "protocolDefinitions")
        let extensions = extractWithRegex(code, key: "extensions")

        return [
            "propertyWrappers": propertyWrappers.count,
            "protocols": protocols.count,
            "extensions": extensions.count,
            "hasSwiftUI": propertyWrappers.contains { $0.contains("@State") || $0.contains("@Binding") },
            "hasCombine": code.contains("Publisher") || code.contains("@Published")
        ]
    }

    private func formatSwiftStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let functions = metrics["functions"] as? Int ?? 0
        let classes = metrics["classes"] as? Int ?? 0
        let structs = metrics["structs"] as? Int ?? 0
        let protocols = metrics["protocols"] as? Int ?? 0
        let hasSwiftUI = structure["hasSwiftUI"] as? Bool ?? false
        let hasCombine = structure["hasCombine"] as? Bool ?? false

        var output = """
        /* Swift Structure Overview */
        // Lines: \(lines)
        // Functions: \(functions)
        // Classes: \(classes)
        // Structs: \(structs)
        // Protocols: \(protocols)
        """

        if hasSwiftUI {
            output += "\n// Framework: SwiftUI"
        }
        if hasCombine {
            output += "\n// Framework: Combine"
        }

        return output
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.92
        case .aggressive: return 0.85
        case .maximum: return 0.60
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        patterns.append(contentsOf: extractWithRegex(code, key: "protocolExtensions").map { .protocolExtension($0) })
        patterns.append(contentsOf: extractWithRegex(code, key: "propertyWrappers").map { .propertyWrapper($0) })
        patterns.append(contentsOf: extractWithRegex(code, key: "genericConstraints").map { .genericConstraint($0) })

        return patterns
    }
}

// MARK: - Extensions for String regex matching
private extension String {
    func matches(of pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return matches.compactMap { match in
                Range(match.range, in: self).map { String(self[$0]) }
            }
        } catch {
            return []
        }
    }
}
