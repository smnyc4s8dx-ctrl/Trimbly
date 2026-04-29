// TokenCounter.swift
import Foundation

class TokenCounter {

    // Simplified enum for practical model support
    enum TokenizerType: String, CaseIterable {
        case openai = "openai"
        case claude = "claude"
        case qwen = "qwen"
        case deepseek = "deepseek"
        case codellama = "codellama"
        case gemini = "gemini"
        case llama = "llama"  // Keep for backward compatibility

        var displayName: String {
            switch self {
            case .openai: return "OpenAI (GPT)"
            case .claude: return "Claude"
            case .qwen: return "Qwen"
            case .deepseek: return "DeepSeek"
            case .codellama: return "CodeLlama"
            case .gemini: return "Gemini"
            case .llama: return "Llama"
            }
        }

        var contextWindow: Int {
            switch self {
            case .openai: return 128000
            case .claude: return 200000
            case .qwen: return 32000
            case .deepseek: return 64000
            case .codellama: return 16384
            case .gemini: return 1000000
            case .llama: return 32000
            }
        }
    }

    enum TokenizerError: Error, LocalizedError {
        case invalidInput(String)
        case estimationFailed(String)

        var errorDescription: String? {
            switch self {
            case .invalidInput(let reason):
                return "Invalid input: \(reason)"
            case .estimationFailed(let reason):
                return "Token estimation failed: \(reason)"
            }
        }
    }

    // Simple cache for repeated calculations
    private static var estimationCache = NSCache<NSString, NSNumber>()
    private static let cacheSize = 1000

    static func clearCache() {
        estimationCache.removeAllObjects()
    }

    // Main token counting method - fast and accurate for real-world use
    static func countTokens(in text: String, using tokenizerType: TokenizerType) -> Int {
        // Create cache key
        let cacheKey = "\(tokenizerType.rawValue)_\(text.count)_\(text.hashValue)" as NSString

        // Check cache first
        if let cached = estimationCache.object(forKey: cacheKey) {
            return cached.intValue
        }

        let estimate = estimateTokensForModel(text, model: tokenizerType)

        // Cache the result
        estimationCache.setObject(NSNumber(value: estimate), forKey: cacheKey)

        return estimate
    }

    // Optimized token estimation based on real model behavior
    private static func estimateTokensForModel(_ text: String, model: TokenizerType) -> Int {
        let charCount = text.count

        // Handle edge cases
        if charCount == 0 { return 0 }
        if charCount < 4 { return 1 }

        // Get base ratio for the model
        let baseRatio = getModelRatio(for: model)

        // Apply content-type adjustments
        let adjustedRatio = applyContentAdjustments(to: baseRatio, for: text)

        // Calculate tokens
        let estimatedTokens = Int(Double(charCount) * adjustedRatio)

        return max(1, estimatedTokens)
    }

    // Model-specific ratios tuned for code content
    private static func getModelRatio(for model: TokenizerType) -> Double {
        switch model {
        case .openai:
            return 0.25      // GPT models: ~4 chars per token for code
        case .claude:
            return 0.20      // Claude is efficient with code: ~5 chars per token
        case .qwen:
            return 0.25      // Similar to GPT: ~4 chars per token
        case .deepseek:
            return 0.23      // Code-optimized: ~4.3 chars per token
        case .codellama:
            return 0.18      // Highly optimized for code: ~5.5 chars per token
        case .gemini:
            return 0.22      // Efficient tokenization: ~4.5 chars per token
        case .llama:
            return 0.25      // Standard ratio: ~4 chars per token
        }
    }

    // Apply adjustments based on content characteristics
    private static func applyContentAdjustments(to baseRatio: Double, for text: String) -> Double {
        var adjustedRatio = baseRatio

        // Whitespace ratio adjustment
        let whitespaceCount = text.filter { $0.isWhitespace }.count
        let whitespaceRatio = Double(whitespaceCount) / Double(text.count)

        if whitespaceRatio > 0.4 {
            // High whitespace = fewer tokens
            adjustedRatio *= 0.85
        } else if whitespaceRatio < 0.1 {
            // Dense text = more tokens
            adjustedRatio *= 1.1
        }

        // Code-specific patterns
        let codePatterns = [
            "import ", "function ", "class ", "def ", "var ", "let ", "const ",
            "public ", "private ", "protected ", "static ", "override "
        ]

        let codePatternCount = codePatterns.reduce(0) { count, pattern in
            count + text.components(separatedBy: pattern).count - 1
        }

        if codePatternCount > text.count / 500 {
            // High code density = slightly fewer tokens due to common patterns
            adjustedRatio *= 0.95
        }

        // Comments adjustment
        let commentCount = text.components(separatedBy: "//").count - 1 +
                          text.components(separatedBy: "/*").count - 1 +
                          text.components(separatedBy: "#").count - 1

        if commentCount > text.count / 1000 {
            // Many comments = natural language = more tokens
            adjustedRatio *= 1.05
        }

        return adjustedRatio
    }

    // Batch processing for large directories
    static func estimateTokensForFiles(_ files: [String: String], using model: TokenizerType) -> [String: Int] {
        var results: [String: Int] = [:]
        let queue = DispatchQueue(label: "token.estimation.queue", attributes: .concurrent)
        let lock = NSLock()

        let group = DispatchGroup()

        for (filePath, content) in files {
            group.enter()
            queue.async {
                let tokens = countTokens(in: content, using: model)

                lock.lock()
                results[filePath] = tokens
                lock.unlock()

                group.leave()
            }
        }

        group.wait()
        return results
    }

    // Utility method for quick estimation without caching
    static func quickEstimate(_ text: String, for model: TokenizerType) -> Int {
        return estimateTokensForModel(text, model: model)
    }

    // Get human-readable size information
    static func getTokenInfo(for count: Int, model: TokenizerType) -> String {
        let contextWindow = model.contextWindow
        let percentage = Double(count) / Double(contextWindow) * 100

        let formattedCount = formatTokenCount(count)
        let formattedWindow = formatTokenCount(contextWindow)

        if percentage > 100 {
            return "\(formattedCount) tokens (⚠️ Exceeds \(formattedWindow) limit by \(String(format: "%.0f", percentage - 100))%)"
        } else if percentage > 90 {
            return "\(formattedCount) tokens (⚠️ \(String(format: "%.0f", percentage))% of \(formattedWindow) limit)"
        } else if percentage > 75 {
            return "\(formattedCount) tokens (⚡ \(String(format: "%.0f", percentage))% of \(formattedWindow) limit)"
        } else {
            return "\(formattedCount) tokens (✅ \(String(format: "%.0f", percentage))% of \(formattedWindow) limit)"
        }
    }

    // Format token counts for display
    private static func formatTokenCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        } else {
            return "\(count)"
        }
    }

    // Validate if content fits in model's context window
    static func fitsInContext(_ tokenCount: Int, for model: TokenizerType, withBuffer bufferPercent: Double = 0.1) -> Bool {
        let maxTokens = Double(model.contextWindow) * (1.0 - bufferPercent)
        return Double(tokenCount) <= maxTokens
    }

    // Get recommended model for a given token count
    static func recommendedModel(for tokenCount: Int) -> TokenizerType? {
        let sortedModels = TokenizerType.allCases.sorted { $0.contextWindow < $1.contextWindow }

        for model in sortedModels {
            if fitsInContext(tokenCount, for: model) {
                return model
            }
        }

        return .gemini // Fallback to largest context window
    }
}

// MARK: - Extensions for backward compatibility

extension TokenCounter {
    // Maintain compatibility with existing code that expects these methods
    @available(*, deprecated, message: "Use countTokens(in:using:) instead")
    static func estimateTokensFast(_ text: String, model: TokenizerType) -> Int {
        return countTokens(in: text, using: model)
    }
}

// MARK: - ModelType compatibility (for the proposed TokenScope UI)

enum ModelType: String, CaseIterable {
    case openai, claude, qwen, deepseek, codellama, gemini

    var tokenizerType: TokenCounter.TokenizerType {
        switch self {
        case .openai: return .openai
        case .claude: return .claude
        case .qwen: return .qwen
        case .deepseek: return .deepseek
        case .codellama: return .codellama
        case .gemini: return .gemini
        }
    }

    func estimateTokens(data: Data) -> Int {
        guard let text = String(data: data, encoding: .utf8) else { return 0 }
        return TokenCounter.countTokens(in: text, using: tokenizerType)
    }
}
