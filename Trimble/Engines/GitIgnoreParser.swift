//  GitIgnoreParser.swift
import Foundation

class GitIgnoreParser {
    private var patterns: [GitIgnorePattern] = []

    struct GitIgnorePattern {
        let pattern: String
        let isNegation: Bool
        let isDirectory: Bool
        let regex: NSRegularExpression?

        init(pattern: String) {
            let trimmed = pattern.trimmingCharacters(in: .whitespaces)
            self.isNegation = trimmed.hasPrefix("!")
            let cleanPattern = isNegation ? String(trimmed.dropFirst()) : trimmed
            self.isDirectory = cleanPattern.hasSuffix("/")
            self.pattern = isDirectory ? String(cleanPattern.dropLast()) : cleanPattern

            var regexPattern = self.pattern
            regexPattern = regexPattern.replacingOccurrences(of: ".", with: "\\.")
            regexPattern = regexPattern.replacingOccurrences(of: "**", with: "<<DOUBLESTAR>>")
            regexPattern = regexPattern.replacingOccurrences(of: "*", with: "[^/]*")
            regexPattern = regexPattern.replacingOccurrences(of: "<<DOUBLESTAR>>", with: ".*")
            regexPattern = regexPattern.replacingOccurrences(of: "?", with: "[^/]")

            if self.pattern.hasPrefix("/") {
                regexPattern = "^" + String(regexPattern.dropFirst()) + "$"
            } else {
                regexPattern = "(^|/)?" + regexPattern + "$"
            }

            self.regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        }
    }

    func loadGitIgnore(from projectPath: String) {
        patterns.removeAll()
        loadGitIgnoreFile(at: projectPath)
        loadGitIgnoreFromSubdirectories(projectPath: projectPath)
    }

    private func loadGitIgnoreFile(at path: String) {
        let gitignorePath = (path as NSString).appendingPathComponent(".gitignore")
        guard let content = try? String(contentsOfFile: gitignorePath, encoding: .utf8) else { return }

        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                patterns.append(GitIgnorePattern(pattern: trimmed))
            }
        }
    }

    private func loadGitIgnoreFromSubdirectories(projectPath: String) {
        let gitIgnoreFiles = findGitIgnoreFiles(in: projectPath)
        for gitIgnorePath in gitIgnoreFiles {
            let dirPath = (gitIgnorePath as NSString).deletingLastPathComponent
            loadGitIgnoreFile(at: dirPath)
        }
    }

    private func findGitIgnoreFiles(in path: String) -> [String] {
        var gitIgnoreFiles: [String] = []
        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return gitIgnoreFiles }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == ".gitignore" {
                gitIgnoreFiles.append(fileURL.path)
            }
            if gitIgnoreFiles.count > 100 {
                break
            }
        }
        return gitIgnoreFiles
    }

    func shouldIgnore(path: String, relativeTo projectPath: String) -> Bool {
        let relativePath = path.replacingOccurrences(of: projectPath + "/", with: "")
        var isIgnored = false

        for pattern in patterns {
            if let regex = pattern.regex {
                let range = NSRange(relativePath.startIndex..., in: relativePath)
                let matches = regex.firstMatch(in: relativePath, options: [], range: range) != nil

                if matches {
                    if pattern.isNegation {
                        isIgnored = false
                    } else {
                        isIgnored = true
                    }
                }
            }
        }

        return isIgnored
    }
}
