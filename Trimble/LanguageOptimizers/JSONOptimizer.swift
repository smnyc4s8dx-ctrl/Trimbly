import Foundation

class JSONOptimizer: LanguageOptimizer {

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
            // JSON doesn't have imports, but we can remove external references
            processed = removeExternalReferences(processed, options: options)
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
            return preserveJSONKeyPatterns(code, options: options)
        case .medium:
            return preserveJSONArchitecture(code, options: options)
        case .aggressive:
            return preserveJSONPublicAPIs(code, options: options)
        case .maximum:
            return extractJSONSignatures(code, options: options)
        }
    }

    // MARK: - Advanced Compression Options
    private func applyAdvancedCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeTypeAnnotations {
            processed = removeTypeAnnotations(processed, options: options)
        }

        if options.truncateFunctions {
            processed = truncateObjectBodies(processed, options: options)
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

    // MARK: - JSON-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        // JSON doesn't officially support comments, but some parsers allow them
        var processed = code

        // Remove // style comments (sometimes found in JSON-like configs)
        processed = processed.replacingOccurrences(
            of: #"//.*$"#,
            with: "",
            options: .regularExpression
        )

        // Remove /* */ style comments
        processed = processed.replacingOccurrences(
            of: #"/\*[\s\S]*?\*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // JSON formatting compression
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
            of: #"\s*\[\s*"#,
            with: "[",
            options: .regularExpression
        )
        processed = processed.replacingOccurrences(
            of: #"\s*\]\s*"#,
            with: "]",
            options: .regularExpression
        )

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeExternalReferences(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Preserve critical external references if prioritizing public APIs
        if options.prioritizePublicAPIs {
            let criticalRefs = extractCriticalExternalReferences(code)
            var preservedRefs: [String: String] = [:]

            for (index, ref) in criticalRefs.enumerated() {
                let placeholder = "\"PRESERVED_REF_\(index)\": \"placeholder\""
                preservedRefs[placeholder] = ref
                processed = processed.replacingOccurrences(of: ref, with: placeholder)
            }

            // Remove non-critical external references
            processed = removeStandardExternalReferences(processed)

            // Restore critical references
            for (placeholder, ref) in preservedRefs {
                processed = processed.replacingOccurrences(of: placeholder, with: ref)
            }
        } else {
            processed = removeStandardExternalReferences(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove descriptive fields that serve as documentation
        if !options.prioritizePublicAPIs {
            let documentationPatterns = [
                #""description":\s*"[^"]*",?\s*"#,
                #""readme":\s*"[^"]*",?\s*"#,
                #""documentation":\s*"[^"]*",?\s*"#,
                #""example":\s*"[^"]*",?\s*"#
            ]

            for pattern in documentationPatterns {
                processed = processed.replacingOccurrences(
                    of: pattern,
                    with: "",
                    options: .regularExpression
                )
            }
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Remove debug-related configuration
        let debugPatterns = [
            #""debug":\s*true,?\s*"#,
            #""verbose":\s*true,?\s*"#,
            #""logLevel":\s*"debug",?\s*"#,
            #""devtool":\s*"[^"]*",?\s*"#
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

        // Remove JSON Schema type annotations if not critical
        if !options.prioritizePublicAPIs {
            let typePatterns = [
                #""type":\s*"(?:string|number|boolean|array|object|null)",?\s*"#,
                #""format":\s*"[^"]*",?\s*"#,
                #""additionalProperties":\s*(?:true|false),?\s*"#
            ]

            for pattern in typePatterns {
                processed = processed.replacingOccurrences(
                    of: pattern,
                    with: "",
                    options: .regularExpression
                )
            }
        }

        return processed
    }

    private func truncateObjectBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical patterns first
        let criticalPatterns = extractObjectBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "\"PRESERVED_\(index)\": \"placeholder\""
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate large object bodies while preserving structure
        processed = processed.replacingOccurrences(
            of: #"(\{[^{}]*){10,}([^{}]*\})"#,
            with: "$1...truncated...$2",
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

        // Extract JSON keys and create mapping
        let keyPattern = #""([a-zA-Z_][a-zA-Z0-9_]*)":\s*"#

        do {
            let regex = try NSRegularExpression(pattern: keyPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range(at: 1), in: code) {
                    let identifier = String(code[range])

                    // Don't shorten critical identifiers
                    if !isCriticalJSONKey(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "k\(counter)"
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
                of: #""\#(NSRegularExpression.escapedPattern(for: original))":"#,
                with: "\"\(shortened)\":",
                options: .regularExpression
            )
        }

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        if let data = code.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            var signatures: [String: Any] = [:]

            // Extract only key signatures
            let signatureKeys = ["name", "version", "main", "module", "type", "scripts", "dependencies"]
            for key in signatureKeys {
                if let value = json[key] {
                    if key == "scripts" || key == "dependencies", let dict = value as? [String: Any] {
                        signatures[key] = Array(dict.keys)
                    } else {
                        signatures[key] = value
                    }
                }
            }

            if let signatureData = try? JSONSerialization.data(withJSONObject: signatures, options: .prettyPrinted),
               let signatureString = String(data: signatureData, encoding: .utf8) {
                return signatureString
            }
        }

        return extractFallbackSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        // Return high-level metrics and structure
        let metrics = calculateJSONMetrics(code)
        let structure = extractJSONStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveJSONKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all critical JSON patterns
        var processed = code

        // Only remove excess whitespace while preserving all content
        processed = removeExcessWhitespace(processed, options: options)

        // Clean up formatting but preserve everything else
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        return processed
    }

    private func preserveJSONArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - focus on architectural elements
        var processed = code

        let configKeys = extractConfigurationKeys(code)
        let scripts = extractScripts(code)
        let dependencies = extractDependencies(code)
        let buildConfig = extractBuildConfiguration(code)

        // Preserve architectural patterns
        var preservedPatterns: [String: String] = [:]
        var placeholderCounter = 0

        let architecturalPatterns = configKeys + scripts + dependencies + buildConfig
        for pattern in architecturalPatterns {
            if isArchitecturalPattern(pattern) {
                let placeholder = "\"ARCH_\(placeholderCounter)\": \"placeholder\""
                preservedPatterns[placeholder] = pattern
                processed = processed.replacingOccurrences(of: pattern, with: placeholder)
                placeholderCounter += 1
            }
        }

        // Remove descriptive fields
        processed = compressDescriptiveFields(processed)

        // Restore architectural patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveJSONPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only public interfaces
        if let data = code.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            let publicKeys = [
                "name", "version", "main", "module", "exports", "type",
                "scripts", "dependencies", "peerDependencies", "engines"
            ]

            var publicStructure: [String: Any] = [:]

            for key in publicKeys {
                if let value = json[key] {
                    publicStructure[key] = value
                }
            }

            if let publicData = try? JSONSerialization.data(withJSONObject: publicStructure, options: .prettyPrinted),
               let publicString = String(data: publicData, encoding: .utf8) {
                return publicString
            }
        }

        return extractFallbackPublicAPIs(code, options: options)
    }

    private func extractJSONSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only signatures and structure
        if let data = code.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            var signature: [String: Any] = [:]

            // Essential identification only
            if let name = json["name"] { signature["name"] = name }
            if let version = json["version"] { signature["version"] = version }
            if let type = json["type"] { signature["type"] = type }

            // Entry points
            if let main = json["main"] { signature["main"] = main }
            if let module = json["module"] { signature["module"] = module }

            // Dependencies (names only)
            if let deps = json["dependencies"] as? [String: Any] {
                signature["dependencies"] = Array(deps.keys)
            }

            if let signatureData = try? JSONSerialization.data(withJSONObject: signature, options: .prettyPrinted),
               let signatureString = String(data: signatureData, encoding: .utf8) {
                return signatureString
            }
        }

        return extractFallbackSignatures(code, options: options)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // JSON doesn't preserve significant whitespace
    }

    private func extractCriticalExternalReferences(_ code: String) -> [String] {
        // Extract critical external references like schema URLs
        let patterns = [
            #""\$schema":\s*"[^"]*""#,
            #""baseUrl":\s*"[^"]*""#,
            #""registry":\s*"[^"]*""#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func removeStandardExternalReferences(_ code: String) -> String {
        // Remove non-critical external references
        return code.replacingOccurrences(
            of: #""homepage":\s*"[^"]*",?\s*"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractObjectBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract patterns that should be preserved even when truncating objects
        let criticalPatterns = extractConfigurationKeys(code) + extractScripts(code)
        return criticalPatterns.filter { isCriticalPattern($0) }
    }

    private func isCriticalJSONKey(_ key: String, options: CompressionOptions) -> Bool {
        if options.prioritizePublicAPIs {
            return isPublicJSONKey(key)
        }
        return isStandardJSONKey(key)
    }

    private func isPublicJSONKey(_ key: String) -> Bool {
        let publicKeys = [
            "name", "version", "main", "module", "exports", "type",
            "scripts", "dependencies", "peerDependencies", "engines"
        ]
        return publicKeys.contains(key)
    }

    private func isStandardJSONKey(_ key: String) -> Bool {
        let standardKeys = [
            "name", "version", "description", "main", "scripts", "dependencies",
            "devDependencies", "author", "license", "type", "module"
        ]
        return standardKeys.contains(key)
    }

    private func extractFallbackSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("\"name\":") || trimmed.contains("\"version\":") ||
               trimmed.contains("\"main\":") || trimmed.contains("\"type\":") {
                result.append(line)
            }
            else if trimmed == "{" || trimmed == "}" {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractFallbackPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isPublicAPILine(trimmed) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func isPublicAPILine(_ line: String) -> Bool {
        let publicKeywords = ["name", "version", "main", "module", "scripts", "dependencies"]
        return publicKeywords.contains { line.contains("\"\($0)\":") }
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeTopLevelJSONLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceJSONToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelJSONLines(_ lines: [String], maxLines: Int) -> String {
        var prioritizedLines: [String] = []
        var regularLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isTopLevelJSONKey(trimmed) {
                prioritizedLines.append(line)
            } else {
                regularLines.append(line)
            }
        }

        let remainingLines = max(0, maxLines - prioritizedLines.count)
        prioritizedLines.append(contentsOf: Array(regularLines.prefix(remainingLines)))

        return prioritizedLines.joined(separator: "\n")
    }

    private func isTopLevelJSONKey(_ line: String) -> Bool {
        return !line.hasPrefix("  ") && line.contains("\"") && line.contains(":")
    }

    private func reduceJSONToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        // Iteratively remove less important fields until under token limit
        var processed = code
        let removalOrder = ["description", "keywords", "author", "license", "devDependencies"]

        for field in removalOrder {
            let currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
            if currentTokens <= maxTokens { break }

            processed = processed.replacingOccurrences(
                of: #""\#(field)":[^,}]*[,}]"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func calculateJSONMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let keyCount = code.components(separatedBy: "\":").count - 1
        let objectCount = code.components(separatedBy: "{").count - 1
        let arrayCount = code.components(separatedBy: "[").count - 1

        return [
            "lines": lines.count,
            "keys": keyCount,
            "objects": objectCount,
            "arrays": arrayCount
        ]
    }

    private func extractJSONStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        if let data = code.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return [
                "topLevelKeys": Array(json.keys),
                "hasScripts": json["scripts"] != nil,
                "hasDependencies": json["dependencies"] != nil,
                "hasDevDependencies": json["devDependencies"] != nil
            ]
        }
        return [:]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "/* JSON Structure Overview */\n"
        output += "// Lines: \(metrics["lines"] ?? 0)\n"
        output += "// Keys: \(metrics["keys"] ?? 0)\n"
        output += "// Objects: \(metrics["objects"] ?? 0)\n"
        output += "// Arrays: \(metrics["arrays"] ?? 0)\n"

        if let topLevelKeys = structure["topLevelKeys"] as? [String] {
            output += "// Top-level keys: \(topLevelKeys.joined(separator: ", "))\n"
        }

        return output
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.99
        case .medium: return 0.95
        case .aggressive: return 0.85
        case .maximum: return 0.70
        }
    }

    // MARK: - Required Protocol Methods (from existing code)

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let configKeys = extractConfigurationKeys(code)
        patterns.append(contentsOf: configKeys.map { .trait($0) })

        let scripts = extractScripts(code)
        patterns.append(contentsOf: scripts.map { .lifecycle($0) })

        let dependencies = extractDependencies(code)
        patterns.append(contentsOf: dependencies.map { .interface($0) })

        let schemas = extractSchemas(code)
        patterns.append(contentsOf: schemas.map { .trait($0) })

        let buildConfig = extractBuildConfiguration(code)
        patterns.append(contentsOf: buildConfig.map { .trait($0) })

        return patterns
    }

    // MARK: - Enhanced Pattern Extraction (from existing code)

    private func extractConfigurationKeys(_ code: String) -> [String] {
        let patterns = [
            // Package.json essentials
            #""(?:name|version|main|entry|module|exports)":\s*"[^"]*""#,
            #""(?:type|sideEffects)":\s*(?:"[^"]*"|true|false)"#,
            #""(?:engines|browserslist)":\s*\{[^}]*\}"#,
            #""(?:repository|homepage|bugs)":\s*(?:"[^"]*"|\{[^}]*\})"#,
            #""(?:license|author|contributors)":\s*(?:"[^"]*"|\[[^\]]*\])"#,
            #""(?:private|publishConfig)":\s*(?:true|false|\{[^}]*\})"#,

            // TypeScript config
            #""(?:compilerOptions|include|exclude|extends)":\s*(?:\{[^}]*\}|\[[^\]]*\]|"[^"]*")"#,
            #""(?:target|module|moduleResolution|lib)":\s*(?:"[^"]*"|\[[^\]]*\])"#,

            // Build tools
            #""(?:webpack|babel|eslint|prettier)":\s*\{[^}]*\}"#,
            #""(?:jest|cypress|playwright)":\s*\{[^}]*\}"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractScripts(_ code: String) -> [String] {
        let patterns = [
            #""scripts":\s*\{[^}]*\}"#,
            #""(?:start|build|test|dev|serve|deploy|lint|format)":\s*"[^"]*""#,
            #""(?:preinstall|postinstall|prepare|prepublishOnly)":\s*"[^"]*""#,
            #""(?:typecheck|coverage|e2e|storybook)":\s*"[^"]*""#,
            #""(?:clean|watch|debug|analyze)":\s*"[^"]*""#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractDependencies(_ code: String) -> [String] {
        let patterns = [
            #""(?:dependencies|devDependencies|peerDependencies|optionalDependencies)":\s*\{[^}]*\}"#,
            #""@types/[^"]*":\s*"[^"]*""#,
            #""(?:@[^/]+/)?(?:webpack|babel|eslint|prettier|jest|typescript)-[^"]*":\s*"[^"]*""#,
            #""(?:react|vue|angular|svelte|next|nuxt)":\s*"[^"]*""#,
            #""(?:express|fastify|koa|hapi)":\s*"[^"]*""#,
            #""(?:lodash|moment|axios|uuid)":\s*"[^"]*""#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractSchemas(_ code: String) -> [String] {
        let patterns = [
            #""\$schema":\s*"[^"]*""#,
            #""type":\s*"(?:string|number|boolean|array|object|null)""#,
            #""properties":\s*\{[^}]*\}"#,
            #""required":\s*\[[^\]]*\]"#,
            #""enum":\s*\[[^\]]*\]"#,
            #""pattern":\s*"[^"]*""#,
            #""(?:minimum|maximum|minLength|maxLength|minItems|maxItems)":\s*\d+"#,
            #""(?:additionalProperties|additionalItems)":\s*(?:true|false|\{[^}]*\})"#,
            #""(?:oneOf|anyOf|allOf)":\s*\[[^\]]*\]"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractBuildConfiguration(_ code: String) -> [String] {
        let patterns = [
            // Webpack config
            #""(?:entry|output|resolve|module|plugins)":\s*(?:\{[^}]*\}|\[[^\]]*\])"#,
            #""(?:mode|devtool|externals)":\s*"[^"]*""#,

            // Babel config
            #""(?:presets|plugins|env)":\s*\[[^\]]*\]"#,

            // ESLint config
            #""(?:extends|parser|parserOptions|rules|env)":\s*(?:\[[^\]]*\]|\{[^}]*\}|"[^"]*")"#,

            // Jest config
            #""(?:testEnvironment|setupFilesAfterEnv|moduleNameMapping|transform)":\s*(?:"[^"]*"|\{[^}]*\})"#,

            // Vite/Rollup config
            #""(?:build|define|server|preview)":\s*\{[^}]*\}"#
        ]

        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Smart Pattern Classification (from existing code)

    private func isCriticalPattern(_ pattern: String) -> Bool {
        let criticalKeywords = [
            "name", "version", "main", "entry", "module", "exports",
            "dependencies", "devDependencies", "scripts",
            "compilerOptions", "target", "module",
            "$schema", "type", "properties", "required"
        ]

        return criticalKeywords.contains { pattern.contains($0) }
    }

    private func isArchitecturalPattern(_ pattern: String) -> Bool {
        let architecturalKeywords = [
            "scripts", "dependencies", "compilerOptions", "webpack", "babel",
            "eslint", "jest", "build", "test", "entry", "output"
        ]

        return architecturalKeywords.contains { pattern.contains($0) }
    }

    private func compressDescriptiveFields(_ code: String) -> String {
        var processed = code

        // Remove descriptive and metadata fields
        let descriptivePatterns = [
            #""description":\s*"[^"]*",?\s*"#,
            #""keywords":\s*\[[^\]]*\],?\s*"#,
            #""homepage":\s*"[^"]*",?\s*"#,
            #""bugs":\s*(?:"[^"]*"|\{[^}]*\}),?\s*"#,
            #""readme":\s*"[^"]*",?\s*"#,
            #""funding":\s*(?:"[^"]*"|\{[^}]*\}|\[[^\]]*\]),?\s*"#,
            #""author":\s*(?:"[^"]*"|\{[^}]*\}),?\s*"#,
            #""contributors":\s*\[[^\]]*\],?\s*"#
        ]

        for pattern in descriptivePatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        // Clean up trailing commas
        processed = processed.replacingOccurrences(
            of: #",\s*([}\]])"#,
            with: "$1",
            options: .regularExpression
        )

        return processed
    }
}
