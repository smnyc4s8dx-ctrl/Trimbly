import Foundation

class YAMLOptimizer: LanguageOptimizer {

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
            return preserveYAMLKeyPatterns(code, options: options)
        case .medium:
            return preserveYAMLArchitecture(code, options: options)
        case .aggressive:
            return preserveYAMLPublicAPIs(code, options: options)
        case .maximum:
            return extractYAMLSignatures(code, options: options)
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

    // MARK: - YAML-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        // Preserve important YAML comments while removing others
        return code.replacingOccurrences(
            of: #"(?<!^)\s*#(?!\s*(?:TODO|FIXME|NOTE|HACK|yamllint|SECURITY|IMPORTANT|K8S|KUSTOMIZE))[^\n]*"#,
            with: "",
            options: .regularExpression
        )
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // YAML preserves significant whitespace (indentation), so be careful
        if options.preserveSignificantWhitespace && languagePreservesWhitespace() {
            // Only remove trailing whitespace and excessive blank lines
            let lines = processed.components(separatedBy: .newlines)
            processed = lines.map { line in
                line.trimmingCharacters(in: CharacterSet.whitespaces.subtracting(CharacterSet(charactersIn: " \t")))
            }.joined(separator: "\n")
        } else {
            // More aggressive whitespace removal while preserving structure
            processed = processed.replacingOccurrences(
                of: #"\n\s*\n\s*\n+"#,
                with: "\n\n",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        // YAML doesn't have traditional imports, but may have references or includes
        var processed = code

        // Remove Helm chart dependencies that aren't critical
        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #"dependencies:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
                with: "# dependencies removed\n",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove documentation fields common in YAML
        let docPatterns = [
            #"description:\s*[^\n]+\n"#,
            #"documentation:\s*[^\n]+\n"#,
            #"notes?:\s*[^\n]+\n"#,
            #"help:\s*[^\n]+\n"#,
            #"example:\s*[^\n]+\n"#
        ]

        for pattern in docPatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Remove debug and development-only configurations
        let debugPatterns = [
            #"debug:\s*true\s*\n"#,
            #"verbose:\s*true\s*\n"#,
            #"dev_mode:\s*true\s*\n"#,
            #"trace:\s*enabled\s*\n"#
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
        // YAML doesn't have explicit type annotations, but may have schema references
        return code.replacingOccurrences(
            of: #"\$schema:\s*[^\n]+\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        // YAML doesn't have functions, but we can truncate large configuration blocks
        var processed = code

        // Preserve critical patterns first
        let criticalPatterns = extractCriticalConfigurationBlocks(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "# PRESERVED_CONFIG_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate large configuration sections
        processed = processed.replacingOccurrences(
            of: #"(\s*-\s+[^\n]+\n){10,}"#,
            with: "    # ... large configuration section ...\n",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenIdentifiers(_ code: String, options: CompressionOptions) -> String {
        // YAML keys and values - be selective about what to shorten
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        // Only shorten non-critical identifiers
        let identifierPattern = #"\b[a-zA-Z_][a-zA-Z0-9_-]{10,}\b"# // Only long identifiers

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    if !isCriticalYAMLIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "cfg\(counter)"
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in YAML identifier shortening: \(error)")
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
        return extractYAMLSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateYAMLMetrics(code)
        let structure = extractYAMLStructure(code, options: options)
        return formatYAMLStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveYAMLKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all YAML structure and remove only whitespace/comments
        var processed = code
        processed = removeExcessWhitespace(processed, options: options)
        if options.removeComments {
            processed = removeLanguageComments(processed)
        }
        return processed
    }

    private func preserveYAMLArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve architectural patterns
        var processed = code

        // Extract and preserve all critical YAML patterns
        let allPatterns = [
            extractKubernetesPatterns(code),
            extractCICDPatterns(code),
            extractConfigPatterns(code),
            extractInfraPatterns(code),
            extractSecurityPatterns(code),
            extractEnvironmentPatterns(code)
        ].flatMap { $0 }

        // Preserve patterns using placeholders
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in allPatterns.enumerated() {
            let placeholder = "# YAML_PATTERN_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Apply compression
        processed = removeLanguageComments(processed)
        processed = removeDocumentation(processed, options: options)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveYAMLPublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve only public/external interfaces
        var processed = code

        // Extract architectural patterns (k8s resources, CI/CD workflows, infrastructure)
        let architecturalPatterns = [
            extractKubernetesPatterns(code),
            extractSecurityPatterns(code),
            extractCriticalCICDPatterns(code),
            extractCriticalInfraPatterns(code)
        ].flatMap { $0 }

        // Preserve architectural patterns
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "# ARCH_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Compress configuration details while preserving structure
        processed = compressConfigurationDetails(processed)

        // Restore architectural patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractYAMLSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if isYAMLSignature(trimmed) || isCriticalYAMLDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - YAML Pattern Extraction (Enhanced from original)

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let k8sPatterns = extractKubernetesPatterns(code)
        patterns.append(contentsOf: k8sPatterns.map { .lifecycle($0) })

        let cicdPatterns = extractCICDPatterns(code)
        patterns.append(contentsOf: cicdPatterns.map { .lifecycle($0) })

        let configPatterns = extractConfigPatterns(code)
        patterns.append(contentsOf: configPatterns.map { .trait($0) })

        let infraPatterns = extractInfraPatterns(code)
        patterns.append(contentsOf: infraPatterns.map { .interface($0) })

        let securityPatterns = extractSecurityPatterns(code)
        patterns.append(contentsOf: securityPatterns.map { .trait($0) })

        let environmentPatterns = extractEnvironmentPatterns(code)
        patterns.append(contentsOf: environmentPatterns.map { .trait($0) })

        return patterns
    }

    private func extractKubernetesPatterns(_ code: String) -> [String] {
        let patterns = [
            #"apiVersion:\s*[^\n]+"#,
            #"kind:\s*(?:Deployment|Service|ConfigMap|Secret|Ingress|Pod|Job|CronJob|StatefulSet|DaemonSet|ReplicaSet|Namespace|PersistentVolume|PersistentVolumeClaim|StorageClass|ServiceAccount|Role|RoleBinding|ClusterRole|ClusterRoleBinding|NetworkPolicy|PodSecurityPolicy|HorizontalPodAutoscaler|VerticalPodAutoscaler)"#,
            #"metadata:\s*\n(?:\s+[^\n]+\n)*"#,
            #"spec:\s*\n(?:\s+[^\n]+\n)*"#,
            #"replicas:\s*\d+"#,
            #"image:\s*[^\n]+"#,
            #"resources:\s*\n(?:\s+[^\n]+\n)*"#,
            #"volumes?:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
            #"ports?:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
            #"selector:\s*\n(?:\s+[^\n]+\n)*"#,
            #"securityContext:\s*\n(?:\s+[^\n]+\n)*"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractCICDPatterns(_ code: String) -> [String] {
        let patterns = [
            #"on:\s*\n(?:\s+[^\n]+\n)*"#,
            #"jobs:\s*\n(?:\s+[^\n]+\n)*"#,
            #"stages?:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
            #"steps:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
            #"runs?-on:\s*[^\n]+"#,
            #"uses:\s*[^@\n]+@[^\n]+"#,
            #"strategy:\s*\n(?:\s+[^\n]+\n)*"#,
            #"matrix:\s*\n(?:\s+[^\n]+\n)*"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractConfigPatterns(_ code: String) -> [String] {
        let patterns = [
            #"version:\s*['\"]?[0-9.]+['\"]?"#,
            #"database:\s*\n(?:\s+[^\n]+\n)*"#,
            #"server:\s*\n(?:\s+[^\n]+\n)*"#,
            #"security:\s*\n(?:\s+[^\n]+\n)*"#,
            #"auth(?:entication)?:\s*\n(?:\s+[^\n]+\n)*"#,
            #"timeout:\s*[^\n]+"#,
            #"limits?:\s*\n(?:\s+[^\n]+\n)*"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractInfraPatterns(_ code: String) -> [String] {
        let patterns = [
            #"services:\s*\n(?:\s+[^\n]+\n)*"#,
            #"networks:\s*\n(?:\s+[^\n]+\n)*"#,
            #"volumes:\s*\n(?:\s+[^\n]+\n)*"#,
            #"depends_on:\s*\n(?:\s+-\s*[^\n]+\n)*"#,
            #"environment:\s*\n(?:\s+[^\n]+\n)*"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractSecurityPatterns(_ code: String) -> [String] {
        let patterns = [
            #"securityContext:\s*\n(?:\s+[^\n]+\n)*"#,
            #"runAsUser:\s*\d+"#,
            #"readOnlyRootFilesystem:\s*(?:true|false)"#,
            #"capabilities:\s*\n(?:\s+[^\n]+\n)*"#,
            #"privileged:\s*(?:true|false)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractEnvironmentPatterns(_ code: String) -> [String] {
        let patterns = [
            #"env:\s*\n(?:\s+-?\s*[^\n]+\n)*"#,
            #"environment:\s*\n(?:\s+[^\n]+\n)*"#,
            #"configMapRef:\s*\n(?:\s+[^\n]+\n)*"#,
            #"secretRef:\s*\n(?:\s+[^\n]+\n)*"#,
            #"\$\{[^}]+\}"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return true // YAML uses significant indentation
    }

    private func extractCriticalConfigurationBlocks(_ code: String, options: CompressionOptions) -> [String] {
        return [
            extractKubernetesPatterns(code),
            extractSecurityPatterns(code)
        ].flatMap { $0 }
    }

    private func isCriticalYAMLIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        let criticalKeywords = [
            "apiVersion", "kind", "metadata", "spec", "name", "namespace",
            "image", "replicas", "resources", "limits", "requests",
            "env", "volumes", "ports", "selector", "labels"
        ]
        return criticalKeywords.contains(identifier)
    }

    private func isYAMLSignature(_ line: String) -> Bool {
        return line == "---" || line == "..." ||
               (!line.hasPrefix(" ") && !line.hasPrefix("\t") && line.contains(":"))
    }

    private func isCriticalYAMLDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let criticalPatterns = [
            "apiVersion:", "kind:", "name:", "namespace:",
            "image:", "replicas:", "resources:", "env:",
            "on:", "jobs:", "services:", "volumes:"
        ]

        return criticalPatterns.contains { line.contains($0) }
    }

    private func extractPatternMatches(_ code: String, patterns: [String]) -> [String] {
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractCriticalCICDPatterns(_ code: String) -> [String] {
        let patterns = [
            #"on:\s*\n(?:\s+[^\n]+\n)*"#,
            #"jobs:\s*\n(?:\s+[^\n]+\n)*"#,
            #"strategy:\s*\n(?:\s+[^\n]+\n)*"#
        ]
        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractCriticalInfraPatterns(_ code: String) -> [String] {
        let patterns = [
            #"services:\s*\n(?:\s+[^\n]+\n)*"#,
            #"networks:\s*\n(?:\s+[^\n]+\n)*"#,
            #"depends_on:\s*\n(?:\s+-\s*[^\n]+\n)*"#
        ]
        return extractPatternMatches(code, patterns: patterns)
    }

    private func compressConfigurationDetails(_ code: String) -> String {
        var processed = code

        // Compress verbose configuration sections
        processed = processed.replacingOccurrences(
            of: #"(\s*-\s+[^\n]+\n){5,}"#,
            with: "    # ... multiple items ...\n",
            options: .regularExpression
        )

        // Remove descriptive fields
        let descriptivePatterns = [
            #"description:\s*[^\n]+\n"#,
            #"documentation:\s*[^\n]+\n"#,
            #"notes?:\s*[^\n]+\n"#
        ]

        for pattern in descriptivePatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeTopLevelYAMLLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceYAMLToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelYAMLLines(_ lines: [String], maxLines: Int) -> String {
        var result: [String] = []
        var currentLines = 0

        // Prioritize document separators and top-level keys
        for line in lines {
            if currentLines >= maxLines { break }

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" || trimmed == "..." ||
               (!line.hasPrefix(" ") && line.contains(":")) ||
               line.contains("apiVersion:") || line.contains("kind:") {
                result.append(line)
                currentLines += 1
            }
        }

        // Fill remaining space with other lines
        for line in lines {
            if currentLines >= maxLines { break }
            if !result.contains(line) {
                result.append(line)
                currentLines += 1
            }
        }

        return result.joined(separator: "\n")
    }

    private func reduceYAMLToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code

        // Progressive reduction
        while TokenCounter.countTokens(in: processed, using: options.tokenizerType) > maxTokens {
            // Remove comments first
            processed = removeLanguageComments(processed)

            // Then compress verbose sections
            processed = compressConfigurationDetails(processed)

            // Finally truncate if still too large
            let lines = processed.components(separatedBy: .newlines)
            processed = Array(lines.prefix(lines.count * 9 / 10)).joined(separator: "\n")
        }

        return processed
    }

    private func calculateYAMLMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let documents = code.components(separatedBy: "---").count - 1
        let services = code.matches(of: #"kind:\s*(?:Service|Deployment|Pod)"#).count

        return [
            "lines": lines.count,
            "documents": documents,
            "services": services,
            "hasKubernetes": code.contains("apiVersion:"),
            "hasCICD": code.contains("jobs:") || code.contains("steps:")
        ]
    }

    private func extractYAMLStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        let k8sResources = extractKubernetesPatterns(code).count
        let cicdSteps = extractCICDPatterns(code).count
        let configSections = extractConfigPatterns(code).count

        return [
            "kubernetes_resources": k8sResources,
            "cicd_patterns": cicdSteps,
            "config_sections": configSections,
            "infrastructure": !extractInfraPatterns(code).isEmpty
        ]
    }

    private func formatYAMLStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        let lines = metrics["lines"] as? Int ?? 0
        let docs = metrics["documents"] as? Int ?? 0
        let k8s = structure["kubernetes_resources"] as? Int ?? 0
        let cicd = structure["cicd_patterns"] as? Int ?? 0

        return """
        # YAML Structure Overview
        # Lines: \(lines)
        # Documents: \(docs)
        # Kubernetes Resources: \(k8s)
        # CI/CD Patterns: \(cicd)
        """
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.92
        case .aggressive: return 0.86
        case .maximum: return 0.71
        }
    }
}
