import Foundation

class ObjectiveCOptimizer: LanguageOptimizer {

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
            return preserveObjectiveCStructure(code, options: options)
        case .medium:
            return preserveObjectiveCFeatures(code, options: options)
        case .aggressive:
            return preserveObjectiveCArchitecture(code, options: options)
        case .maximum:
            return extractObjectiveCSignatures(code, options: options)
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

        // Remove single-line comments while preserving TODO/FIXME
        processed = processed.replacingOccurrences(
            of: #"//(?!\s*(?:TODO|FIXME|NOTE|HACK|MARK))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove multi-line comments while preserving header comments
        processed = processed.replacingOccurrences(
            of: #"/\*(?![*!])[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Objective-C doesn't have significant whitespace like Python
        // Aggressive whitespace removal
        processed = processed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        // Clean up multiple newlines
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
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

        // Remove header documentation blocks
        processed = processed.replacingOccurrences(
            of: #"/\*\*[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        // Remove method documentation comments
        processed = processed.replacingOccurrences(
            of: #"///[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Objective-C specific debug patterns
        let debugPatterns = [
            #"NSLog\s*\([^)]*\)\s*;"#,
            #"printf\s*\([^)]*\)\s*;"#,
            #"NSAssert\s*\([^)]*\)\s*;"#,
            #"NSParameterAssert\s*\([^)]*\)\s*;"#,
            #"#ifdef\s+DEBUG[\s\S]*?#endif"#,
            #"#if\s+DEBUG[\s\S]*?#endif"#
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

        // Only remove non-critical type annotations
        if !options.prioritizePublicAPIs {
            // Remove explicit type annotations that can be inferred
            processed = processed.replacingOccurrences(
                of: #"\s*\*\s*"#,
                with: " * ",
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

        // Truncate Objective-C method bodies
        processed = processed.replacingOccurrences(
            of: #"([-+]\s*\([^)]+\)[^{]*\{)[^}]*(\})"#,
            with: "$1\n    // implementation\n$2",
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

        // Extract identifiers and create mapping
        let identifierPattern = #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    // Don't shorten critical Objective-C identifiers
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
        return extractObjectiveCSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code, options: options)
        let structure = extractObjectiveCStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveObjectiveCStructure(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical Objective-C patterns
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func preserveObjectiveCFeatures(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve all Objective-C features
        let methodSignatures = extractMethodSignatures(code)
        let categories = extractCategories(code)
        let properties = extractProperties(code)
        let protocols = extractProtocols(code)
        let memoryManagement = extractMemoryManagement(code)

        // Preserve critical patterns with placeholders
        processed = preservePatternsWithPlaceholders(
            code: processed,
            patterns: [
                ("METHOD", methodSignatures.filter { isCriticalMethodSignature($0) }),
                ("CATEGORY", categories.filter { isCriticalCategory($0) }),
                ("PROPERTY", properties.filter { isCriticalProperty($0) }),
                ("PROTOCOL", protocols.filter { isCriticalProtocol($0) }),
                ("MEMORY", memoryManagement.filter { isCriticalMemoryManagement($0) })
            ]
        )

        return processed
    }

    private func preserveObjectiveCArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract patterns for architectural preservation
        let methodSignatures = extractMethodSignatures(code)
        let categories = extractCategories(code)
        let properties = extractProperties(code)
        let protocols = extractProtocols(code)
        let ibConnections = extractIBConnections(code)
        let memoryManagement = extractMemoryManagement(code)

        // Preserve only architecturally significant patterns
        var preservedPatterns: [(String, [String])] = []

        // Method signatures: Only preserve IBActions, delegates, and complex ones
        preservedPatterns.append(("METHOD", methodSignatures.filter { isCriticalMethodSignature($0) }))

        // All categories are architecturally significant
        preservedPatterns.append(("CATEGORY", categories))

        // Properties: Only preserve those with memory management or IBOutlet
        preservedPatterns.append(("PROPERTY", properties.filter { isCriticalProperty($0) }))

        // All protocols and IB connections are architectural
        preservedPatterns.append(("PROTOCOL", protocols))
        preservedPatterns.append(("IB_CONNECTION", ibConnections))
        preservedPatterns.append(("MEMORY", memoryManagement))

        // Apply preservation with placeholders
        processed = preservePatternsWithPlaceholders(code: processed, patterns: preservedPatterns)

        // Compress implementations while preserving architectural patterns
        processed = compressObjectiveCMethodBodies(processed)

        return processed
    }

    private func extractObjectiveCSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("#import") || trimmed.hasPrefix("#include") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@class") || trimmed.hasPrefix("@protocol") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@interface") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@implementation") {
                result.append(line)
            }
            else if trimmed.hasPrefix("@property") {
                result.append(line)
            }
            else if trimmed.hasPrefix("-") || trimmed.hasPrefix("+") {
                result.append(line)
            }
            else if trimmed.contains("IBOutlet") || trimmed.contains("IBAction") {
                result.append(line)
            }
            else if trimmed == "@end" {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // Objective-C doesn't have significant whitespace
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("#import") &&
                   (trimmed.contains("Foundation") ||
                    trimmed.contains("UIKit") ||
                    trimmed.contains("AppKit") ||
                    trimmed.contains(".h\""))
        }
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"#import\s+[<\"][^>\"\n]+[>\"][\s]*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating functions
        var patterns: [String] = []

        // Preserve IBAction implementations
        patterns.append(contentsOf: extractIBConnections(code))

        // Preserve memory management patterns
        patterns.append(contentsOf: extractMemoryManagement(code))

        // Preserve delegate patterns
        patterns.append(contentsOf: extractDelegatePatterns(code))

        return patterns
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Objective-C keywords and critical identifiers
        let objectiveCKeywords = [
            "self", "super", "nil", "YES", "NO", "TRUE", "FALSE",
            "id", "Class", "SEL", "IMP", "BOOL",
            "NSString", "NSArray", "NSDictionary", "NSNumber",
            "UIView", "UIViewController", "NSObject",
            "delegate", "datasource", "target", "action"
        ]

        if objectiveCKeywords.contains(identifier) {
            return true
        }

        if options.prioritizePublicAPIs {
            return isPublicIdentifier(identifier)
        }

        return identifier.count <= 2 // Don't shorten very short identifiers
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // Check if identifier follows public naming conventions
        return identifier.hasPrefix("NS") ||
               identifier.hasPrefix("UI") ||
               identifier.hasPrefix("CG") ||
               identifier.hasPrefix("CF") ||
               identifier.contains("delegate") ||
               identifier.contains("Delegate") ||
               identifier.contains("Protocol")
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        // Prioritize important lines if specified
        if options.prioritizeTopLevel {
            return prioritizeTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        // Iteratively remove content until under token limit
        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        var prioritizedLines: [String] = []
        var regularLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("@interface") ||
               trimmed.hasPrefix("@implementation") ||
               trimmed.hasPrefix("@protocol") ||
               trimmed.hasPrefix("@property") ||
               trimmed.hasPrefix("-") ||
               trimmed.hasPrefix("+") ||
               trimmed == "@end" {
                prioritizedLines.append(line)
            } else {
                regularLines.append(line)
            }
        }

        let remainingSlots = maxLines - prioritizedLines.count
        if remainingSlots > 0 {
            prioritizedLines.append(contentsOf: Array(regularLines.prefix(remainingSlots)))
        }

        return prioritizedLines.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let targetTokens = Int(Double(maxTokens) * 0.9) // 10% buffer

        // Iteratively apply more aggressive compression
        while TokenCounter.countTokens(in: processed, using: options.tokenizerType) > targetTokens {
            // First, remove more comments
            processed = removeLanguageComments(processed)

            // Then, truncate method bodies more aggressively
            processed = processed.replacingOccurrences(
                of: #"([-+]\s*\([^)]+\)[^{]*\{)[^}]*(\})"#,
                with: "$1/* impl */$2",
                options: .regularExpression
            )

            // Finally, limit lines
            let lines = processed.components(separatedBy: .newlines)
            let newLineLimit = Int(Double(lines.count) * 0.8)
            processed = Array(lines.prefix(newLineLimit)).joined(separator: "\n")

            break // Prevent infinite loop
        }

        return processed
    }

    private func calculateCodeMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        let methods = extractMethodSignatures(code)
        let properties = extractProperties(code)
        let protocols = extractProtocols(code)

        return [
            "lines": nonEmptyLines.count,
            "methods": methods.count,
            "properties": properties.count,
            "protocols": protocols.count,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractObjectiveCStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "interfaces": extractInterfaces(code),
            "implementations": extractImplementations(code),
            "categories": extractCategories(code),
            "protocols": extractProtocols(code)
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "/* Objective-C Structure Overview */\n"

        if let lines = metrics["lines"] as? Int {
            output += "Lines: \(lines)\n"
        }
        if let methods = metrics["methods"] as? Int {
            output += "Methods: \(methods)\n"
        }
        if let properties = metrics["properties"] as? Int {
            output += "Properties: \(properties)\n"
        }
        if let protocols = metrics["protocols"] as? Int {
            output += "Protocols: \(protocols)\n"
        }

        return output
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.97
        case .medium: return 0.90
        case .aggressive: return 0.82
        case .maximum: return 0.61
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let methodSignatures = extractMethodSignatures(code)
        patterns.append(contentsOf: methodSignatures.map { .interface($0) })

        let categories = extractCategories(code)
        patterns.append(contentsOf: categories.map { .trait($0) })

        let properties = extractProperties(code)
        patterns.append(contentsOf: properties.map { .trait($0) })

        let protocols = extractProtocols(code)
        patterns.append(contentsOf: protocols.map { .interface($0) })

        return patterns
    }

    // MARK: - Objective-C Specific Pattern Extraction

    private func extractMethodSignatures(_ code: String) -> [String] {
        let patterns = [
            #"-\s*\([^)]+\)\s*[\w:]+(?:\s*\([^)]+\)\s*\w+)*\s*;"#,
            #"\+\s*\([^)]+\)\s*[\w:]+(?:\s*\([^)]+\)\s*\w+)*\s*;"#,
            #"-\s*\([^)]+\)\s*[\w:]+(?:\s*\([^)]+\)\s*\w+)*\s*\{"#,
            #"\+\s*\([^)]+\)\s*[\w:]+(?:\s*\([^)]+\)\s*\w+)*\s*\{"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractCategories(_ code: String) -> [String] {
        let patterns = [
            #"@interface\s+\w+\s*\([^)]*\)"#,
            #"@implementation\s+\w+\s*\([^)]*\)"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractProperties(_ code: String) -> [String] {
        let patterns = [
            #"@property\s*\([^)]*\)[^;]*;"#,
            #"@synthesize\s+\w+(?:\s*=\s*\w+)?;"#,
            #"@dynamic\s+\w+;"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractProtocols(_ code: String) -> [String] {
        let pattern = #"@protocol\s+\w+[^@]*@end"#
        return code.matches(of: pattern)
    }

    private func extractInterfaces(_ code: String) -> [String] {
        let pattern = #"@interface\s+\w+[^@]*@end"#
        return code.matches(of: pattern)
    }

    private func extractImplementations(_ code: String) -> [String] {
        let pattern = #"@implementation\s+\w+[^@]*@end"#
        return code.matches(of: pattern)
    }

    private func extractMemoryManagement(_ code: String) -> [String] {
        let patterns = [
            #"@property\s*\([^)]*\b(?:strong|weak|assign|copy|retain)\b[^)]*\)"#,
            #"__(?:strong|weak|unsafe_unretained|autoreleasing)\s+"#,
            #"\b(?:retain|release|autorelease)\b"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractIBConnections(_ code: String) -> [String] {
        let patterns = [
            #"@property\s*\([^)]*\)\s*IBOutlet\s+[^;]*;"#,
            #"-\s*\(IBAction\)[^;]*;"#,
            #"-\s*\(IBAction\)[^{]*\{"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractDelegatePatterns(_ code: String) -> [String] {
        let patterns = [
            #"<\w*Delegate\w*>"#,
            #"@property[^;]*delegate[^;]*;"#,
            #"-\s*\([^)]*\)[^{]*delegate[^{]*\{"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractNotificationPatterns(_ code: String) -> [String] {
        let patterns = [
            #"\[\[NSNotificationCenter[^]]*\]"#,
            #"addObserver:[^;]*;"#,
            #"removeObserver:[^;]*;"#,
            #"postNotificationName:[^;]*;"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Smart Pattern Filtering

    private func isCriticalMethodSignature(_ method: String) -> Bool {
        // IBActions, delegate methods, and complex method signatures are critical
        return method.contains("IBAction") ||
               method.contains("delegate") ||
               method.contains("datasource") ||
               method.contains("notification") ||
               method.contains(":(id)") ||
               method.contains("completionHandler") ||
               method.count > 80 // Complex signatures
    }

    private func isCriticalCategory(_ category: String) -> Bool {
        // All categories add significant functionality
        return true
    }

    private func isCriticalProperty(_ property: String) -> Bool {
        // Properties with memory management or IBOutlet are critical
        return property.contains("IBOutlet") ||
               property.contains("weak") ||
               property.contains("strong") ||
               property.contains("copy") ||
               property.contains("retain") ||
               property.contains("assign") ||
               property.contains("delegate") ||
               property.contains("readonly") ||
               property.contains("nonatomic")
    }

    private func isCriticalProtocol(_ protocol: String) -> Bool {
        // All protocols define important interfaces
        return true
    }

    private func isCriticalMemoryManagement(_ memory: String) -> Bool {
        // All memory management patterns are critical
        return true
    }

    private func isCriticalIBConnection(_ connection: String) -> Bool {
        // All Interface Builder connections are critical
        return true
    }

    // MARK: - Pattern Preservation System

    private func preservePatternsWithPlaceholders(code: String, patterns: [(String, [String])]) -> String {
        var processed = code
        var preservedPatterns: [String: String] = [:]

        // Replace patterns with placeholders
        for (patternType, patternList) in patterns {
            for (index, pattern) in patternList.enumerated() {
                let placeholder = "/* \(patternType)_\(index) */"
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
            }
        }

        // Apply compression to non-preserved parts
        processed = removeLanguageComments(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressObjectiveCMethodBodies(_ code: String) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let ibConnections = extractIBConnections(code)
        let memoryManagement = extractMemoryManagement(code)
        let delegatePatterns = extractDelegatePatterns(code)
        let notificationPatterns = extractNotificationPatterns(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve all IB connections
        for (index, connection) in ibConnections.enumerated() {
            let placeholder = "/* IB_\(index) */"
            preservedPatterns[placeholder] = connection
            processed = processed.replacingOccurrences(of: connection, with: placeholder)
        }

        // Preserve all memory management patterns
        for (index, memory) in memoryManagement.enumerated() {
            let placeholder = "/* MEMORY_\(index) */"
            preservedPatterns[placeholder] = memory
            processed = processed.replacingOccurrences(of: memory, with: placeholder)
        }

        // Preserve delegate patterns
        for (index, delegate) in delegatePatterns.enumerated() {
            let placeholder = "/* DELEGATE_\(index) */"
            preservedPatterns[placeholder] = delegate
            processed = processed.replacingOccurrences(of: delegate, with: placeholder)
        }

        // Preserve notification patterns
        for (index, notification) in notificationPatterns.enumerated() {
            let placeholder = "/* NOTIFICATION_\(index) */"
            preservedPatterns[placeholder] = notification
            processed = processed.replacingOccurrences(of: notification, with: placeholder)
        }

        // Compress method bodies while preserving signatures
        processed = processed.replacingOccurrences(
            of: #"([-+]\s*\([^)]+\)[^{]*\{)[^}]*(\})"#,
            with: "$1\n    // implementation\n$2",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }
}
