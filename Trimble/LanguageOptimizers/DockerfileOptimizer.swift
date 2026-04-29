//  DockerfileOptimizer.swift
import Foundation

class DockerfileOptimizer: LanguageOptimizer {

    // MARK: - Main Entry Point
    func optimizeCompression(_ code: String, options: CompressionOptions) -> CompressedResult {
        let originalTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        let processedContent = preserveLanguageSemantics(code, options: options)
        let compressedTokens = TokenCounter.countTokens(in: processedContent, using: options.tokenizerType)
        let semanticAccuracy = calculateDockerSemanticAccuracy(options: options)
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
            processed = removeDockerComments(processed)
        }

        if options.removeWhitespace {
            processed = removeExcessWhitespace(processed, options: options)
        }

        if options.removeEmptyLines {
            processed = removeEmptyLines(processed, options: options)
        }

        if options.removeDocumentation {
            processed = removeDockerDocumentation(processed, options: options)
        }

        return processed
    }

    // MARK: - Semantic Level Compression
    private func applySemanticLevelCompression(_ code: String, options: CompressionOptions) -> String {
        switch options.semanticLevel {
        case .light:
            return preserveDockerStructure(code, options: options)
        case .medium:
            return preserveDockerLogic(code, options: options)
        case .aggressive:
            return preserveDockerArchitecture(code, options: options)
        case .maximum:
            return extractDockerSignatures(code, options: options)
        }
    }

    // MARK: - Advanced Compression Options
    private func applyAdvancedCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

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

    // MARK: - Docker-Specific Implementation Methods

    private func removeDockerComments(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"#(?!\s*(?:TODO|FIXME|NOTE|SECURITY|OPTIMIZATION))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove trailing whitespace
        processed = processed.replacingOccurrences(
            of: #"[ \t]+$"#,
            with: "",
            options: .regularExpression
        )

        // Normalize line continuations
        processed = processed.replacingOccurrences(
            of: #"\\\s*\n\s*"#,
            with: " \\\n    ",
            options: .regularExpression
        )

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        return code.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeDockerDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove descriptive LABEL statements (keep security, version, maintainer)
        processed = processed.replacingOccurrences(
            of: #"LABEL\s+(?!(?:maintainer|version|security))[^=]+=[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let upperTrimmed = trimmed.uppercased()

            if isDockerSignature(upperTrimmed) ||
               isCriticalDockerDeclaration(trimmed, options: options) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateDockerMetrics(code)
        let structure = extractDockerStructure(code, options: options)

        return formatDockerStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveDockerStructure(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Light compression - preserve Docker structure with minimal changes
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n"#,
            with: "\n\n",
            options: .regularExpression
        )

        processed = processed.replacingOccurrences(
            of: #"\\\s*\n\s*"#,
            with: " \\\n    ",
            options: .regularExpression
        )

        return processed
    }

    private func preserveDockerLogic(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        let baseImages = extractBaseImages(code)
        let layers = extractLayerCommands(code)
        let runtime = extractRuntimeConfig(code)
        let security = extractSecurityConfig(code)
        let multiStage = extractMultiStagePatterns(code)

        var preservedPatterns: [String: String] = [:]

        // Preserve base images (critical for understanding dependencies)
        for (index, image) in baseImages.enumerated() {
            let placeholder = "# BASE_IMAGE_\(index)"
            preservedPatterns[placeholder] = image
            processed = processed.replacingOccurrences(of: image, with: placeholder)
        }

        // Preserve layer commands (build optimization)
        for (index, layer) in layers.enumerated() {
            let placeholder = "# LAYER_\(index)"
            preservedPatterns[placeholder] = layer
            processed = processed.replacingOccurrences(of: layer, with: placeholder)
        }

        // Preserve runtime configuration
        for (index, runtimeConfig) in runtime.enumerated() {
            let placeholder = "# RUNTIME_\(index)"
            preservedPatterns[placeholder] = runtimeConfig
            processed = processed.replacingOccurrences(of: runtimeConfig, with: placeholder)
        }

        // Preserve security configuration
        for (index, securityConfig) in security.enumerated() {
            let placeholder = "# SECURITY_\(index)"
            preservedPatterns[placeholder] = securityConfig
            processed = processed.replacingOccurrences(of: securityConfig, with: placeholder)
        }

        // Preserve multi-stage patterns
        for (index, multiStagePattern) in multiStage.enumerated() {
            let placeholder = "# MULTISTAGE_\(index)"
            preservedPatterns[placeholder] = multiStagePattern
            processed = processed.replacingOccurrences(of: multiStagePattern, with: placeholder)
        }

        // Apply compression
        processed = compressRepetitiveCommands(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func preserveDockerArchitecture(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        let essential = extractEssentialCommands(code)
        let multiStage = extractMultiStagePatterns(code)
        let runtime = extractRuntimeConfig(code)
        let optimizations = extractBuildOptimizations(code)

        var preservedPatterns: [String: String] = [:]

        // Only preserve essential architectural patterns
        let architecturalPatterns = essential + multiStage + runtime.filter { isEssentialRuntime($0) }

        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "# ARCH_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Preserve build optimizations
        for (index, optimization) in optimizations.enumerated() {
            let placeholder = "# OPT_\(index)"
            preservedPatterns[placeholder] = optimization
            processed = processed.replacingOccurrences(of: optimization, with: placeholder)
        }

        // Aggressive compression
        processed = compressRepetitiveCommands(processed)
        processed = compressDescriptiveElements(processed)

        // Restore preserved patterns
        for (placeholder, original) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: original)
        }

        return processed
    }

    private func extractDockerSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let upperTrimmed = trimmed.uppercased()

            if upperTrimmed.hasPrefix("FROM ") {
                result.append(line)
            }
            else if upperTrimmed.hasPrefix("EXPOSE ") || upperTrimmed.hasPrefix("VOLUME ") ||
                    upperTrimmed.hasPrefix("USER ") {
                result.append(line)
            }
            else if upperTrimmed.hasPrefix("ENTRYPOINT ") || upperTrimmed.hasPrefix("CMD ") {
                result.append(line)
            }
            else if upperTrimmed.hasPrefix("ENV ") &&
                    (trimmed.contains("PATH") || trimmed.contains("PORT") || trimmed.contains("NODE_ENV")) {
                result.append(line)
            }
            else if upperTrimmed.hasPrefix("WORKDIR ") {
                result.append(line)
            }
            else if upperTrimmed.hasPrefix("RUN ") &&
                    (trimmed.contains("install") || trimmed.contains("add") || trimmed.contains("update")) {
                result.append("RUN # dependency installation")
            }
            else if upperTrimmed.hasPrefix("COPY ") || upperTrimmed.hasPrefix("ADD ") {
                result.append("COPY # file operations")
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Docker Pattern Extraction Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let baseImages = extractBaseImages(code)
        patterns.append(contentsOf: baseImages.map { .interface($0) })

        let layers = extractLayerCommands(code)
        patterns.append(contentsOf: layers.map { .lifecycle($0) })

        let runtime = extractRuntimeConfig(code)
        patterns.append(contentsOf: runtime.map { .trait($0) })

        let security = extractSecurityConfig(code)
        patterns.append(contentsOf: security.map { .trait($0) })

        return patterns
    }

    private func extractBaseImages(_ code: String) -> [String] {
        let patterns = [
            #"FROM\s+[^\s]+(?:\s+AS\s+\w+)?"#,
            #"ARG\s+\w+(?:=[^\n]*)?"#,
            #"LABEL\s+(?:maintainer|version|description)=[^\n]*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractLayerCommands(_ code: String) -> [String] {
        let patterns = [
            #"RUN\s+(?:apt-get\s+update|apk\s+add|yum\s+install)[^\n]*"#,
            #"RUN\s+npm\s+(?:install|ci)[^\n]*"#,
            #"RUN\s+pip\s+install[^\n]*"#,
            #"RUN\s+go\s+(?:mod|get)[^\n]*"#,
            #"COPY\s+[^\s]+\s+[^\s]+"#,
            #"ADD\s+[^\s]+\s+[^\s]+"#,
            #"WORKDIR\s+[^\s]+"#,
            #"RUN\s+.*(?:&&|;).*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractRuntimeConfig(_ code: String) -> [String] {
        let patterns = [
            #"EXPOSE\s+\d+(?:/(?:tcp|udp))?"#,
            #"ENV\s+\w+(?:=|\s+)[^\n]*"#,
            #"VOLUME\s+\[[^\]]+\]|\s+[^\s]+"#,
            #"USER\s+[^\s]+"#,
            #"HEALTHCHECK\s+(?:--[^\s]+\s+)*CMD\s+[^\n]*"#,
            #"ENTRYPOINT\s+\[[^\]]+\]|\s+[^\n]*"#,
            #"CMD\s+\[[^\]]+\]|\s+[^\n]*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractSecurityConfig(_ code: String) -> [String] {
        let patterns = [
            #"USER\s+(?!root)[^\s]+"#,
            #"RUN\s+.*(?:adduser|useradd|groupadd)[^\n]*"#,
            #"RUN\s+.*chmod[^\n]*"#,
            #"RUN\s+.*chown[^\n]*"#,
            #"LABEL\s+security[^\n]*"#,
            #"ARG\s+\w+_VERSION=[^\n]*"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractMultiStagePatterns(_ code: String) -> [String] {
        let patterns = [
            #"FROM\s+[^\s]+\s+AS\s+\w+"#,
            #"COPY\s+--from=\w+\s+[^\s]+\s+[^\s]+"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractEssentialCommands(_ code: String) -> [String] {
        let patterns = [
            #"FROM\s+[^\n]+"#,
            #"COPY\s+[^\n]+"#,
            #"RUN\s+(?:apt|apk|yum|pip|npm)[^\n]*"#,
            #"EXPOSE\s+[^\n]+"#,
            #"ENV\s+[^\n]+"#,
            #"(?:ENTRYPOINT|CMD)\s+[^\n]+"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func extractBuildOptimizations(_ code: String) -> [String] {
        let patterns = [
            #"RUN\s+.*(?:&&|;).*(?:rm\s+-rf|apt-get\s+clean|apk\s+del)"#,
            #"COPY\s+package[.]json\s+[^\n]*"#,
            #"RUN\s+npm\s+ci\s+--only=production"#,
            #"FROM\s+.*alpine"#
        ]
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Docker-Specific Utility Methods

    private func isEssentialRuntime(_ runtimeConfig: String) -> Bool {
        let essential = ["EXPOSE", "ENTRYPOINT", "CMD", "USER", "WORKDIR"]
        return essential.contains { runtimeConfig.uppercased().contains($0) }
    }

    private func isDockerSignature(_ line: String) -> Bool {
        let dockerCommands = ["FROM", "RUN", "COPY", "ADD", "EXPOSE", "ENV", "CMD", "ENTRYPOINT", "WORKDIR", "USER", "VOLUME", "LABEL", "ARG", "HEALTHCHECK"]
        return dockerCommands.contains { line.hasPrefix($0) }
    }

    private func isCriticalDockerDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let upperLine = line.uppercased()

        if options.prioritizePublicAPIs {
            return upperLine.contains("EXPOSE") || upperLine.contains("ENTRYPOINT") || upperLine.contains("CMD")
        }

        return isDockerSignature(upperLine)
    }

    private func compressRepetitiveCommands(_ code: String) -> String {
        var processed = code
        processed = processed.replacingOccurrences(
            of: #"(RUN\s+[^\n]+\n)+RUN\s+"#,
            with: "RUN ",
            options: .regularExpression
        )
        return processed
    }

    private func compressDescriptiveElements(_ code: String) -> String {
        var processed = code
        processed = processed.replacingOccurrences(
            of: #"LABEL\s+(?!(?:maintainer|version|security))[^=]+=[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )
        return processed
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeDockerCommands(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceDockerToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeDockerCommands(_ lines: [String], maxLines: Int) -> String {
        let priorityCommands = ["FROM", "EXPOSE", "ENTRYPOINT", "CMD", "ENV", "WORKDIR"]
        var priorityLines: [String] = []
        var otherLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces).uppercased()
            if priorityCommands.contains(where: { trimmed.hasPrefix($0) }) {
                priorityLines.append(line)
            } else {
                otherLines.append(line)
            }
        }

        let availableLines = maxLines - priorityLines.count
        if availableLines > 0 {
            priorityLines.append(contentsOf: Array(otherLines.prefix(availableLines)))
        }

        return priorityLines.joined(separator: "\n")
    }

    private func reduceDockerToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        // Start with signatures only approach
        var reduced = extractDockerSignatures(code, options: options)

        if TokenCounter.countTokens(in: reduced, using: options.tokenizerType) <= maxTokens {
            return reduced
        }

        // Further reduce to essential commands only
        return extractStructureOnly(reduced, options: options)
    }

    private func calculateDockerMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let commands = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && !trimmed.hasPrefix("#")
        }

        return [
            "totalLines": lines.count,
            "commands": commands.count,
            "layers": commands.filter { $0.uppercased().hasPrefix("RUN") }.count,
            "exposedPorts": commands.filter { $0.uppercased().hasPrefix("EXPOSE") }.count
        ]
    }

    private func extractDockerStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        let baseImages = extractBaseImages(code)
        let runtime = extractRuntimeConfig(code)
        let multiStage = extractMultiStagePatterns(code)

        return [
            "baseImages": baseImages.count,
            "runtimeConfigs": runtime.count,
            "multiStage": !multiStage.isEmpty,
            "hasHealthcheck": code.uppercased().contains("HEALTHCHECK")
        ]
    }

    private func formatDockerStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output = "# Docker Structure Overview\n"
        output += "# Commands: \(metrics["commands"] ?? 0)\n"
        output += "# Layers: \(metrics["layers"] ?? 0)\n"
        output += "# Base Images: \(structure["baseImages"] ?? 0)\n"
        output += "# Multi-stage: \(structure["multiStage"] as? Bool == true ? "Yes" : "No")\n"
        return output
    }

    private func calculateDockerSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.98
        case .medium: return 0.92
        case .aggressive: return 0.85
        case .maximum: return 0.69
        }
    }
}
