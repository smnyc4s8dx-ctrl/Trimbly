import Foundation

protocol LanguageOptimizer {
    func optimizeCompression(_ code: String, options: CompressionOptions) -> CompressedResult
    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern]
    func preserveLanguageSemantics(_ code: String, options: CompressionOptions) -> String
}

enum CriticalPattern {
    case protocolExtension(String)
    case propertyWrapper(String)
    case decorator(String)
    case genericConstraint(String)
    case typeGuard(String)
    case annotation(String)
    case macro(String)
    case trait(String)
    case interface(String)
    case lifecycle(String)
}

struct CompressedResult {
    let content: String
    let originalTokens: Int
    let compressedTokens: Int
    let semanticAccuracy: Double
    let preservedPatterns: [CriticalPattern]
}

extension String {
    func splitByCamelCase() -> [String] {
        return self.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                  .components(separatedBy: " ")
    }

    func extractBetween(_ start: String, _ end: String) -> [String] {
        var results: [String] = []
        var searchRange = self.startIndex..<self.endIndex

        while let startRange = self.range(of: start, range: searchRange),
              let endRange = self.range(of: end, range: startRange.upperBound..<self.endIndex) {
            let content = String(self[startRange.upperBound..<endRange.lowerBound])
            results.append(content)
            searchRange = endRange.upperBound..<self.endIndex
        }
        return results
    }
}
