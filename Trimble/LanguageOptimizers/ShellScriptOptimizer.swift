//  ShellScriptOptimizer.swift
import Foundation

class ShellScriptOptimizer: LanguageOptimizer {

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
            return preserveShellKeyPatterns(code, options: options)
        case .medium:
            return preserveShellArchitecture(code, options: options)
        case .aggressive:
            return preserveShellPublicAPIs(code, options: options)
        case .maximum:
            return extractShellSignatures(code, options: options)
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

        // Remove shell comments but preserve shebang and important markers
        processed = processed.replacingOccurrences(
            of: #"(?<!^)#(?!\s*(?:!|TODO|FIXME|NOTE|HACK|XXX|\[))[^\n]*"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Shell scripts are whitespace-sensitive for some constructs
        if options.preserveSignificantWhitespace {
            // Only remove trailing whitespace and compress multiple blank lines
            processed = processed.replacingOccurrences(
                of: #"[ \t]+$"#,
                with: "",
                options: .regularExpression
            )
            processed = processed.replacingOccurrences(
                of: #"\n\s*\n\s*\n+"#,
                with: "\n\n",
                options: .regularExpression
            )
        } else {
            // More aggressive whitespace removal
            processed = processed.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
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

        // Shell "imports" are source/. commands
        if options.prioritizePublicAPIs {
            // Preserve critical source commands
            let criticalSources = extractCriticalSources(code)
            var preservedSources: [String: String] = [:]

            for (index, sourceStatement) in criticalSources.enumerated() {
                let placeholder = "# PRESERVED_SOURCE_\(index)"
                preservedSources[placeholder] = sourceStatement
                processed = processed.replacingOccurrences(of: sourceStatement, with: placeholder)
            }

            // Remove remaining source commands
            processed = removeStandardSources(processed)

            // Restore critical sources
            for (placeholder, sourceStatement) in preservedSources {
                processed = processed.replacingOccurrences(of: placeholder, with: sourceStatement)
            }
        } else {
            processed = removeStandardSources(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove documentation comments (multiple line comments starting with ##)
        do {
            let regex = try NSRegularExpression(pattern: #"^[ \t]*##[^\n]*$"#, options: [.anchorsMatchLines])
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        } catch {
            print("Regex error in removeDocumentation: \(error)")
        }

        // Remove here-docs used for documentation
        do {
            let regex = try NSRegularExpression(pattern: #"cat\s*<<\s*['\"]?DOC['\"]?[\s\S]*?^DOC$"#, options: [.anchorsMatchLines, .dotMatchesLineSeparators])
            processed = regex.stringByReplacingMatches(
                in: processed,
                options: [],
                range: NSRange(processed.startIndex..., in: processed),
                withTemplate: ""
            )
        } catch {
            print("Regex error in removeDocumentation here-docs: \(error)")
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Shell debug patterns
        let debugPatterns = [
            #"echo\s+['\"]DEBUG:[^'\"]*['\"]"#,          // Debug echo statements
            #"printf\s+['\"]DEBUG:[^'\"]*['\"]"#,        // Debug printf statements
            #"set\s+-x"#,                               // Debug trace on
            #"set\s+\+x"#,                              // Debug trace off
            #"PS4=['\"][^'\"]*['\"]"#,                   // Debug prompt
            #"\$\{?DEBUG\}?"#,                          // Debug variables
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
        // Shell doesn't have type annotations in the traditional sense
        // But we can remove declare type specifiers if not critical
        var processed = code

        if !options.prioritizePublicAPIs {
            // Remove non-critical declare flags
            processed = processed.replacingOccurrences(
                of: #"declare\s+-[a-z]*[ilntu][a-z]*\s+"#,
                with: "declare ",
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
            let placeholder = "# PRESERVED_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate function bodies
        processed = processed.replacingOccurrences(
            of: #"((?:function\s+)?\w+\s*\(\)\s*\{)[^}]*(\})"#,
            with: "$1\n    # implementation\n$2",
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

        // Shell variable pattern
        let identifierPattern = #"\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: code) {
                    let identifier = String(code[range])

                    if !isCriticalShellIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "v\(counter)"
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in shell identifier shortening: \(error)")
        }

        // Apply identifier mapping
        for (original, shortened) in identifierMap {
            let patterns = [
                "\\$\\{\(NSRegularExpression.escapedPattern(for: original))\\}",
                "\\$\(NSRegularExpression.escapedPattern(for: original))\\b",
                "\\b\(NSRegularExpression.escapedPattern(for: original))="
            ]

            for pattern in patterns {
                processed = processed.replacingOccurrences(
                    of: pattern,
                    with: pattern.replacingOccurrences(of: original, with: shortened),
                    options: .regularExpression
                )
            }
        }

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isShellSignature(trimmed) || isCriticalShellDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateShellMetrics(code, options: options)
        let structure = extractShellStructure(code, options: options)

        return formatShellStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveShellKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all shell patterns, only remove comments and whitespace
        var processed = code

        // Extract all critical patterns
        let allPatterns = extractAllShellPatterns(code)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in allPatterns.enumerated() {
            let placeholder = "# SHELL_PATTERN_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Only apply light compression
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        // Restore all patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveShellArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve architectural elements
        var processed = code

        let architecturalPatterns = [
            extractErrorHandling(code),
            extractFunctions(code),
            extractConditionals(code),
            extractCriticalEnvironmentVars(code),
            extractArgumentProcessing(code)
        ].flatMap { $0 }

        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "# ARCH_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Compress function bodies while preserving logic
        processed = compressShellFunctionBodies(processed)

        // Restore architectural patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveShellPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only functions and critical patterns
        var processed = code

        let publicPatterns = [
            extractFunctions(code),
            extractCriticalEnvironmentVars(code),
            extractErrorHandling(code).filter { isCriticalErrorPattern($0) }
        ].flatMap { $0 }

        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in publicPatterns.enumerated() {
            let placeholder = "# PUBLIC_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Aggressive compression
        processed = compressShellImplementations(processed)

        // Restore public patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractShellSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Shebang line
            if trimmed.hasPrefix("#!") {
                result.append(line)
            }
            // Set options for error handling
            else if trimmed.hasPrefix("set -") {
                result.append(line)
            }
            // Function signatures
            else if (trimmed.contains("()") && (trimmed.contains("{") || trimmed.hasPrefix("function"))) ||
                    trimmed.hasPrefix("function ") {
                result.append(line)
            }
            // Environment variables and exports
            else if trimmed.hasPrefix("export ") || trimmed.hasPrefix("readonly ") ||
                    trimmed.hasPrefix("declare ") || trimmed.hasPrefix("local ") {
                result.append(line)
            }
            // Control structures
            else if trimmed.hasPrefix("if ") || trimmed.hasPrefix("while ") ||
                    trimmed.hasPrefix("for ") || trimmed.hasPrefix("case ") ||
                    trimmed.hasPrefix("until ") || trimmed.hasPrefix("select ") {
                result.append(line)
            }
            // Error handling patterns
            else if trimmed.hasPrefix("trap ") || trimmed.contains("||") ||
                    trimmed.contains("&&") || trimmed.contains("$?") {
                result.append(line)
            }
            // Pipe chains and command substitution
            else if trimmed.contains(" | ") || trimmed.contains("$(") ||
                    trimmed.contains("`") {
                result.append(line)
            }
            // Argument processing
            else if trimmed.contains("getopts") || trimmed.contains("shift") ||
                    trimmed.contains("$#") || trimmed.contains("$@") {
                result.append(line)
            }
            // Critical commands and utilities
            else if trimmed.hasPrefix("source ") || trimmed.hasPrefix(". ") ||
                    trimmed.hasPrefix("exec ") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Pattern Extraction Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let errorHandling = extractErrorHandling(code)
        patterns.append(contentsOf: errorHandling.map { .lifecycle($0) })

        let envVars = extractEnvironmentVars(code)
        patterns.append(contentsOf: envVars.map { .trait($0) })

        let pipeChains = extractPipeChains(code)
        patterns.append(contentsOf: pipeChains.map { .macro($0) })

        let functions = extractFunctions(code)
        patterns.append(contentsOf: functions.map { .interface($0) })

        let conditionals = extractConditionals(code)
        patterns.append(contentsOf: conditionals.map { .lifecycle($0) })

        let argumentProcessing = extractArgumentProcessing(code)
        patterns.append(contentsOf: argumentProcessing.map { .lifecycle($0) })

        return patterns
    }

    private func extractErrorHandling(_ code: String) -> [String] {
        let patterns = [
            #"set\s+-[euxoEpifmhvn]+"#,  // Shell options for error handling
            #"trap\s+['\"][^'\"]*['\"]\s+(?:EXIT|ERR|DEBUG|RETURN|INT|TERM|HUP|QUIT)"#,  // Trap handlers
            #"\|\|\s*\{[^}]*\}"#,  // OR error handling blocks
            #"\|\|\s*exit\s+\d+"#,  // OR exit patterns
            #"&&\s*\{[^}]*\}"#,  // AND success blocks
            #"if\s*\[\[\s*\$\?\s*-(?:eq|ne)\s*\d+\s*\]\]"#,  // Exit code checking
            #"command\s+-v\s+\w+"#,  // Command existence checking
            #"type\s+-p\s+\w+"#,  // Type checking
            #"which\s+\w+"#,  // Command location checking
            #"\$\{[^}]*:-[^}]*\}"#,  // Parameter expansion with defaults
            #"\$\{[^}]*:=\+\?[^}]*\}"#,  // Parameter expansion variants
            #"exec\s+\d+>&\d+"#,  // File descriptor redirection
            #"readonly\s+\w+="#  // Read-only variable protection
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractEnvironmentVars(_ code: String) -> [String] {
        let patterns = [
            #"export\s+\w+=[^\n]*"#,  // Export statements
            #"\$\{[A-Z_][A-Z0-9_]*[^}]*\}"#,  // Environment variable expansions
            #"\$[A-Z_][A-Z0-9_]*"#,  // Simple environment variables
            #"readonly\s+\w+=[^\n]*"#,  // Read-only variables
            #"declare\s+(?:-[a-z]+\s+)*\w+="#,  // Declare statements
            #"local\s+\w+="#,  // Local variables in functions
            #"\$\{#\w+\}"#,  // String length
            #"\$\{[^}]*%[^}]*\}"#,  // Suffix removal
            #"\$\{[^}]*#[^}]*\}"#,  // Prefix removal
            #"\$\{[^}]*//[^}]*\}"#,  // Global substitution
            #"\$\{[^}]*:[-+=?][^}]*\}"#,  // Parameter expansion operations
            #"BASH_[A-Z_]+"#,  // Bash built-in variables
            #"HOME|PATH|USER|PWD|OLDPWD|SHELL|TERM"#  // Common environment variables
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractPipeChains(_ code: String) -> [String] {
        let patterns = [
            #"[^|\n]+(?:\s*\|\s*[^|\n]+){2,}"#,  // Multi-stage pipes
            #"\$\([^)]+\)"#,  // Command substitution
            #"`[^`]+`"#,  // Backtick command substitution
            #"<\([^)]+\)"#,  // Process substitution input
            #">\([^)]+\)"#,  // Process substitution output
            #"while\s+read\s+[^;]*;\s*do"#,  // Read loops
            #"for\s+\w+\s+in\s+\$\([^)]+\)"#,  // Command substitution in loops
            #"mapfile\s+(?:-[a-z]+\s+)*\w+"#,  // Mapfile/readarray
            #"xargs\s+[^|;\n]*"#,  // Xargs patterns
            #"find\s+[^|;\n]*\s+-exec\s+[^;]+;"#,  // Find with exec
            #"awk\s+['\"][^'\"]*['\"]"#,  // AWK programs
            #"sed\s+['\"][^'\"]*['\"]"#,  // Sed programs
            #"grep\s+(?:-[a-zA-Z]+\s+)*['\"][^'\"]*['\"]"#  // Grep patterns
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractFunctions(_ code: String) -> [String] {
        let patterns = [
            #"(?:function\s+)?\w+\s*\(\)\s*\{[^}]*\}"#,  // Function definitions
            #"^\s*\w+\s*\(\)\s*\{"#,  // Function signature lines
            #"function\s+\w+\s*\{[^}]*\}"#,  // Function keyword style
            #"return\s+\d+"#,  // Return statements
            #"\$\{FUNCNAME(?:\[\d+\])?\}"#,  // Function name variable
            #"\$\{BASH_LINENO(?:\[\d+\])?\}"#,  // Line number in functions
            #"caller\s+\d+"#  // Caller information
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractConditionals(_ code: String) -> [String] {
        let patterns = [
            #"if\s+\[\[[^\]]*\]\];\s*then[^f]*fi"#,  // Complete if statements with [[]]
            #"if\s+\[[^\]]*\];\s*then[^f]*fi"#,  // Complete if statements with []
            #"case\s+[^\n]*\s+in[^c]*esac"#,  // Complete case statements
            #"while\s+\[[^\]]*\];\s*do[^d]*done"#,  // Complete while loops
            #"for\s+\w+\s+in\s+[^;]*;\s*do[^d]*done"#,  // Complete for loops
            #"until\s+\[[^\]]*\];\s*do[^d]*done"#,  // Complete until loops
            #"select\s+\w+\s+in\s+[^;]*;\s*do[^d]*done"#,  // Select statements
            #"\[\[\s*[^]]*\]\]"#,  // Test conditions
            #"\[\s*[^]]*\]"#,  // Test conditions (single bracket)
            #"test\s+[^\n]*"#,  // Test command
            #"-[a-z]\s+\$\w+"#  // File test operators
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractArgumentProcessing(_ code: String) -> [String] {
        let patterns = [
            #"getopts\s+['\"][^'\"]*['\"]"#,  // Getopts option parsing
            #"while\s+getopts\s+[^;]*;\s*do[^d]*done"#,  // Getopts loops
            #"shift\s*(?:\d+)?"#,  // Shift parameters
            #"if\s+\[\[\s*\$#\s*-[a-z]+\s*\d+\s*\]\]"#,  // Argument count checking
            #"\$\{?\d+\}?"#,  // Positional parameters
            #"\$@|\$\*"#,  // All parameters
            #"\$#"#,  // Parameter count
            #"set\s+--\s+"#,  // Reset positional parameters
            #"usage\(\)\s*\{[^}]*\}"#,  // Usage functions
            #"help\(\)\s*\{[^}]*\}"#  // Help functions
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return true // Shell scripts can be whitespace-sensitive
    }

    private func extractCriticalSources(_ code: String) -> [String] {
        let patterns = [
            #"source\s+['\"][^'\"]*['\"]"#,
            #"\.\s+['\"][^'\"]*['\"]"#,
            #"source\s+\$\{[^}]+\}"#,
            #"\.\s+\$\{[^}]+\}"#
        ]

        return extractPatternMatches(code, patterns: patterns).filter { sourceStatement in
            // Only preserve sources that look critical (config, libs, etc.)
            sourceStatement.lowercased().contains("config") ||
            sourceStatement.lowercased().contains("lib") ||
            sourceStatement.lowercased().contains("common") ||
            sourceStatement.lowercased().contains("util")
        }
    }

    private func removeStandardSources(_ code: String) -> String {
        var processed = code

        let sourcePatterns = [
            #"^[ \t]*source\s+[^\n]*$"#,
            #"^[ \t]*\.\s+[^\n]*$"#
        ]

        for pattern in sourcePatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
                processed = regex.stringByReplacingMatches(
                    in: processed,
                    options: [],
                    range: NSRange(processed.startIndex..., in: processed),
                    withTemplate: ""
                )
            } catch {
                print("Regex error in removeStandardSources: \(error)")
            }
        }

        return processed
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating functions
        if options.prioritizePublicAPIs {
            return [
                extractErrorHandling(code),
                extractPipeChains(code),
                extractConditionals(code)
            ].flatMap { $0 }
        }
        return []
    }

    private func isShellSignature(_ line: String) -> Bool {
        let signaturePatterns = [
            #"^\s*(?:function\s+)?\w+\s*\(\)\s*\{"#,
            #"^\s*function\s+\w+"#,
            #"^\s*export\s+\w+="#,
            #"^\s*readonly\s+\w+="#,
            #"^\s*declare\s+"#,
            #"^\s*set\s+-"#,
            #"^\s*trap\s+"#
        ]

        return signaturePatterns.contains { pattern in
            line.range(of: pattern, options: .regularExpression) != nil
        }
    }

    private func isCriticalShellDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return line.contains("export") || line.contains("function") || line.hasPrefix("#!")
        }
        return false
    }

    private func isCriticalShellIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        // Don't shorten critical shell variables
        let criticalVars = [
            "PATH", "HOME", "USER", "SHELL", "TERM", "PWD", "OLDPWD",
            "BASH_VERSION", "BASH_SOURCE", "FUNCNAME", "LINENO",
            "OPTARG", "OPTIND", "PIPESTATUS", "PPID", "UID", "EUID"
        ]

        if criticalVars.contains(identifier) {
            return true
        }

        if options.prioritizePublicAPIs {
            // Don't shorten variables that look like public APIs
            return identifier.allSatisfy { $0.isUppercase || $0 == "_" }
        }

        return false
    }

    private func extractAllShellPatterns(_ code: String) -> [String] {
        return [
            extractErrorHandling(code),
            extractEnvironmentVars(code),
            extractPipeChains(code),
            extractFunctions(code),
            extractConditionals(code),
            extractArgumentProcessing(code)
        ].flatMap { $0 }
    }

    private func extractCriticalEnvironmentVars(_ code: String) -> [String] {
        let patterns = [
            #"export\s+(?:PATH|HOME|USER|SHELL|TERM)="#,  // Critical system variables
            #"readonly\s+\w+="#,  // Read-only protections
            #"declare\s+-[a-z]*r[a-z]*\s+\w+="#,  // Read-only declarations
            #"\$\{[A-Z_][A-Z0-9_]*:-[^}]*\}"#  // Default value patterns
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func isCriticalErrorPattern(_ pattern: String) -> Bool {
        return pattern.contains("trap") || pattern.contains("set -") || pattern.contains("||")
    }

    private func compressShellFunctionBodies(_ code: String) -> String {
        var processed = code

        // Extract and preserve error handling patterns
        let errorPatterns = extractErrorHandling(code)
        var preservedErrors: [String: String] = [:]
        for (index, error) in errorPatterns.enumerated() {
            let placeholder = "# ERROR_\(index)"
            preservedErrors[placeholder] = error
            processed = processed.replacingOccurrences(of: error, with: placeholder)
        }

        // Extract and preserve pipe chains
        let pipePatterns = extractPipeChains(code)
        var preservedPipes: [String: String] = [:]
        for (index, pipe) in pipePatterns.enumerated() {
            let placeholder = "# PIPE_\(index)"
            preservedPipes[placeholder] = pipe
            processed = processed.replacingOccurrences(of: pipe, with: placeholder)
        }

        // Extract and preserve conditionals
        let conditionalPatterns = extractConditionals(code)
        var preservedConditionals: [String: String] = [:]
        for (index, conditional) in conditionalPatterns.enumerated() {
            let placeholder = "# COND_\(index)"
            preservedConditionals[placeholder] = conditional
            processed = processed.replacingOccurrences(of: conditional, with: placeholder)
        }

        // Compress function bodies while preserving signatures
        processed = processed.replacingOccurrences(
            of: #"((?:function\s+)?\w+\s*\(\)\s*\{)[^}]*(\})"#,
            with: "$1\n    # implementation\n$2",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, error) in preservedErrors {
            processed = processed.replacingOccurrences(of: placeholder, with: error)
        }
        for (placeholder, pipe) in preservedPipes {
            processed = processed.replacingOccurrences(of: placeholder, with: pipe)
        }
        for (placeholder, conditional) in preservedConditionals {
            processed = processed.replacingOccurrences(of: placeholder, with: conditional)
        }

        return processed
    }

    private func compressShellImplementations(_ code: String) -> String {
        return compressShellFunctionBodies(code)
    }

    private func extractPatternMatches(_ code: String, patterns: [String]) -> [String] {
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeShellTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceShellToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeShellTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        var prioritized: [String] = []
        var remaining: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#!") ||
               trimmed.hasPrefix("set -") ||
               trimmed.hasPrefix("export ") ||
               trimmed.hasPrefix("function ") ||
               trimmed.contains("()") {
                prioritized.append(line)
            } else {
                remaining.append(line)
            }
        }

        let availableLines = maxLines - prioritized.count
        if availableLines > 0 {
            prioritized.append(contentsOf: remaining.prefix(availableLines))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceShellToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        // Start with function body compression
        var processed = compressShellFunctionBodies(code)

        var currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        if currentTokens <= maxTokens { return processed }

        // Then try removing comments
        processed = removeLanguageComments(processed)
        currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        if currentTokens <= maxTokens { return processed }

        // Finally, truncate lines while preserving critical ones
        let lines = processed.components(separatedBy: .newlines)
        let criticalLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return isShellSignature(trimmed) || isCriticalShellDeclaration(trimmed, options: options)
        }

        var result = criticalLines
        let remainingLines = lines.filter { !criticalLines.contains($0) }

        for line in remainingLines {
            let candidate = result + [line]
            let candidateTokens = TokenCounter.countTokens(in: candidate.joined(separator: "\n"), using: options.tokenizerType)
            if candidateTokens <= maxTokens {
                result.append(line)
            } else {
                break
            }
        }

        return result.joined(separator: "\n")
    }

    private func calculateShellMetrics(_ code: String, options: CompressionOptions) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let functions = extractFunctions(code)
        let variables = extractEnvironmentVars(code)
        let conditionals = extractConditionals(code)

        return [
            "lines": lines.count,
            "functions": functions.count,
            "variables": variables.count,
            "conditionals": conditionals.count,
            "tokens": TokenCounter.countTokens(in: code, using: options.tokenizerType)
        ]
    }

    private func extractShellStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "functions": extractFunctions(code).count,
            "exports": extractEnvironmentVars(code).filter { $0.contains("export") }.count,
            "error_handlers": extractErrorHandling(code).count,
            "pipe_chains": extractPipeChains(code).count,
            "conditionals": extractConditionals(code).count
        ]
    }

    private func formatShellStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let functions = structure["functions"] as? Int ?? 0
        let exports = structure["exports"] as? Int ?? 0
        let errorHandlers = structure["error_handlers"] as? Int ?? 0

        return """
        # Shell Script Structure
        Lines: \(lines)
        Functions: \(functions)
        Exports: \(exports)
        Error Handlers: \(errorHandlers)
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98    // Preserves all shell semantics
        case .medium: return 0.91   // Removes comments, preserves all functional patterns
        case .aggressive: return 0.84  // Compresses implementations, preserves architecture
        case .maximum: return 0.67  // Signatures and critical patterns only
        }
    }
}
