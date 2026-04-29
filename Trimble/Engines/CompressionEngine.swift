class CompressionEngine {
    let semanticAnalyzer = SemanticAnalyzer()
    private let smartAnalyzer = SmartFileAnalyzer()
    private var optimizerCache: [ProgrammingLanguage: LanguageOptimizer] = [:]

    func compressContent(content: String, language: ProgrammingLanguage, options: CompressionOptions) -> CompressedCode {
        let tokenizer = options.tokenizerType
        let originalTokens = TokenCounter.countTokens(in: content, using: tokenizer)

        if let optimizer = getCachedLanguageOptimizer(for: language) {
            let result = optimizer.optimizeCompression(content, options: options)
            let compressedTokens = TokenCounter.countTokens(in: result.content, using: tokenizer)
            return CompressedCode(
                content: result.content,
                originalTokens: originalTokens,
                compressedTokens: compressedTokens,
                compressionRatio: Double(originalTokens) / Double(max(compressedTokens, 1)),
                tokensRemoved: originalTokens - compressedTokens,
                semanticAccuracy: result.semanticAccuracy
            )
        }

        return applyGenericCompression(content, options: options)
    }

    private func getCachedLanguageOptimizer(for language: ProgrammingLanguage) -> LanguageOptimizer? {
        if let cached = optimizerCache[language] {
            return cached
        }

        let optimizer = createLanguageOptimizer(for: language)
        if let optimizer = optimizer {
            optimizerCache[language] = optimizer
        }
        return optimizer
    }

    private func createLanguageOptimizer(for language: ProgrammingLanguage) -> LanguageOptimizer? {
        switch language {
        case .swift:
            return SwiftOptimizer()
        case .javascript:
            return TypeScriptOptimizer()
        case .typescript:
            return TypeScriptOptimizer()
        case .python:
            return PythonOptimizer()
        case .java:
            return JavaOptimizer()
        case .csharp:
            return CSharpOptimizer()
        case .cpp:
            return CppOptimizer()
        case .kotlin:
            return KotlinOptimizer()
        case .ruby:
            return RubyOptimizer()
        case .php:
            return PHPOptimizer()
        case .rust:
            return RustOptimizer()
        case .go:
            return GoOptimizer()
        case .objectivec:
            return ObjectiveCOptimizer()
        case .css:
            return CSSOptimizer()
        case .html:
            return HTMLTemplateOptimizer()
        case .json:
            return JSONOptimizer()
        case .sql:
            return SQLOptimizer()
        case .dockerfile:
            return DockerfileOptimizer()
        case .jupyter:
            return JupyterNotebookOptimizer()
        case .shell:
            return ShellScriptOptimizer()
        case .yaml:
            return YAMLOptimizer()
        default:
            return nil
        }
    }

    private func applyGenericCompression(_ content: String, options: CompressionOptions) -> CompressedCode {
        let tokenizer = options.tokenizerType
        let originalTokens = TokenCounter.countTokens(in: content, using: tokenizer)
        var processed = content

        if options.removeComments {
            processed = processed.replacingOccurrences(of: "//.*", with: "", options: .regularExpression)
            processed = processed.replacingOccurrences(of: "/\\*[\\s\\S]*?\\*/", with: "", options: .regularExpression)
        }

        if options.removeWhitespace {
            processed = processed.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }

        let compressedTokens = TokenCounter.countTokens(in: processed, using: tokenizer)
        let compressionRatio = Double(originalTokens) / Double(max(compressedTokens, 1))

        return CompressedCode(
            content: processed,
            originalTokens: originalTokens,
            compressedTokens: compressedTokens,
            compressionRatio: compressionRatio,
            tokensRemoved: originalTokens - compressedTokens,
            semanticAccuracy: 0.8
        )
    }
}
