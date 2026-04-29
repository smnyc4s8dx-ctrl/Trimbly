import Foundation
import UniformTypeIdentifiers

class FileProcessor {
    private let maxFileSize = 25_000_000
    private let smartAnalyzer = SmartFileAnalyzer()
    var gitIgnoreParser: GitIgnoreParser?
    var projectRootPath: String?

    /// Validates that a resolved path stays within the allowed base directory
    /// Prevents path traversal attacks via symlinks or ".." components
    private func isPathWithinBounds(_ path: String, basePath: String) -> Bool {
        let resolvedPath = URL(fileURLWithPath: path).standardized.path
        let resolvedBase = URL(fileURLWithPath: basePath).standardized.path
        return resolvedPath.hasPrefix(resolvedBase)
    }

    func isTextFile(path: String) -> Bool {
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        let textExtensions: Set<String> = [
            "swift", "js", "jsx", "ts", "tsx", "py", "java", "cs", "cpp", "c", "h", "hpp",
            "php", "rb", "go", "rs", "kt", "scala", "clj", "hs", "elm", "dart", "vue",
            "svelte", "css", "scss", "sass", "less", "html", "htm", "xml", "xhtml",
            "json", "yaml", "yml", "toml", "ini", "cfg", "conf", "properties",
            "plist", "xcconfig", "gitignore", "env", "editorconfig",
            "md", "txt", "rst", "adoc", "tex", "rtf",
            "entitlements", "storyboard", "xib", "xcdatamodel", "xcworkspace", "playground",
            "xcscheme", "pbxproj", "modulemap", "podspec", "gemfile", "rakefile",
            "makefile", "cmake", "gradle", "sbt", "cabal", "mix"
        ]

        if fileExtension.isEmpty {
            let fileName = URL(fileURLWithPath: path).lastPathComponent.lowercased()
            let textFileNames = ["dockerfile", "makefile", "rakefile", "gemfile", "procfile", "podfile"]
            return textFileNames.contains(fileName)
        }

        return textExtensions.contains(fileExtension)
    }

    private static let maxRecursionDepth = 50

    func getAllFiles(at path: String, configuration: ProcessingConfiguration) throws -> [String] {
        return try getAllFiles(at: path, configuration: configuration, currentDepth: 0)
    }

    private func getAllFiles(at path: String, configuration: ProcessingConfiguration, currentDepth: Int) throws -> [String] {
        guard currentDepth < Self.maxRecursionDepth else { return [] }

        var files: [String] = []
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path) {
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: path, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                let items = try fileManager.contentsOfDirectory(atPath: path)
                for item in items {
                    let itemPath = (path as NSString).appendingPathComponent(item)

                    // Security: Skip paths that escape the parent directory (path traversal prevention)
                    guard isPathWithinBounds(itemPath, basePath: path) else {
                        continue
                    }

                    let category = smartAnalyzer.categorizeFile(path: itemPath)

                    // Apply smart auto-exclusion logic
                    if configuration.compressionOptions.smartAutoExclusion &&
                       (category == .excludeWithReference || category == .autoExclude) {
                        continue
                    }

                    if !shouldExcludeItem(path: itemPath, configuration: configuration) {
                        files.append(contentsOf: try getAllFiles(at: itemPath, configuration: configuration, currentDepth: currentDepth + 1))
                    }
                }
            } else {
                let category = smartAnalyzer.categorizeFile(path: path)

                // Always include critical files even if other filters would exclude them
                if category == .alwaysInclude {
                    files.append(path)
                } else if !(configuration.compressionOptions.smartAutoExclusion &&
                           (category == .excludeWithReference || category == .autoExclude)) {
                    files.append(path)
                }
            }
        }

        return files
    }

    func shouldExcludeItem(path: String, configuration: ProcessingConfiguration) -> Bool {
        // First check smart categorization
        let category = smartAnalyzer.categorizeFile(path: path)

        if configuration.compressionOptions.smartAutoExclusion {
            switch category {
            case .excludeWithReference, .autoExclude:
                return true
            case .alwaysInclude:
                return false
            case .normalCompression:
                break // Continue with traditional filtering
            }
        }

        // Check gitignore patterns
        if configuration.compressionOptions.respectGitignore,
           let parser = gitIgnoreParser,
           let rootPath = projectRootPath {
            if parser.shouldIgnore(path: path, relativeTo: rootPath) {
                return true
            }
        }

        // Traditional filtering logic (kept for backward compatibility)
        let itemName = URL(fileURLWithPath: path).lastPathComponent
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        let pathComponents = path.components(separatedBy: "/")

        // Binary files
        let binaryExtensions: Set<String> = [
            "png", "jpg", "jpeg", "gif", "bmp", "tiff", "ico", "svg",
            "mp4", "mov", "avi", "mp3", "wav", "zip", "tar", "gz",
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
            "dylib", "so", "dll", "exe", "app", "dmg", "pkg"
        ]

        if binaryExtensions.contains(fileExtension) {
            return true
        }

        // Hidden files (except known important ones)
        if itemName.hasPrefix(".") && !SmartFileAnalyzer.alwaysIncludeFiles.contains(itemName.lowercased()) {
            return true
        }

        // System files
        if [".DS_Store", "Thumbs.db"].contains(itemName) {
            return true
        }

        // Apply user-configured filters
        if configuration.compressionOptions.skipLibraryFolders {
            let libFolderNames: Set<String> = [
                "lib", "libs", "vendor", "node_modules", "packages", "external",
                "third_party", "3rdparty", "dependencies", "Pods", "Carthage",
                ".git", ".svn", ".hg", "__pycache__", "build", "dist", "target",
                "out", "bin", "obj"
            ]

            for component in pathComponents {
                if libFolderNames.contains(component) {
                    return true
                }
            }
        }

        if configuration.compressionOptions.skipLocalizationFiles {
            let localizationExtensions: Set<String> = [
                "strings", "po", "pot", "mo", "xliff", "xlf", "resx", "properties"
            ]

            if localizationExtensions.contains(fileExtension) {
                return true
            }

            let localizationDirs: Set<String> = [
                "locales", "i18n", "translations", "lang", "languages", "Resources"
            ]

            for component in pathComponents {
                if localizationDirs.contains(component) || component.hasSuffix(".lproj") {
                    return true
                }
            }

            if fileExtension == "json" && (
                itemName.contains("i18n") ||
                itemName.contains("locale") ||
                itemName.contains("lang") ||
                pathComponents.contains("locales") ||
                pathComponents.contains("i18n")
            ) {
                return true
            }
        }

        if configuration.compressionOptions.skipTestFiles {
            let testIndicators = ["test", "spec", "Test", "Spec", "Tests", "Specs"]
            if testIndicators.contains(where: { itemName.contains($0) }) {
                return true
            }
        }

        if configuration.compressionOptions.skipConfigFiles {
            let configExtensions = ["xml", "plist", "json", "yaml", "yml", "toml", "ini"]
            let configNames = ["config", "settings", "properties", "manifest"]

            if configExtensions.contains(fileExtension) ||
               configNames.contains(where: { itemName.lowercased().contains($0) }) {
                return true
            }
        }

        if configuration.compressionOptions.skipDocumentationFiles {
            if fileExtension == "md" {
                let documentationNames = [
                    "readme", "license", "changelog", "contributing", "code_of_conduct",
                    "privacy", "terms", "authors", "credits", "acknowledgments",
                    "install", "installation", "setup", "getting_started",
                    "faq", "help", "support", "troubleshooting"
                ]

                let baseName = itemName.lowercased()
                    .replacingOccurrences(of: ".md", with: "")
                    .replacingOccurrences(of: "_", with: "")
                    .replacingOccurrences(of: "-", with: "")

                if documentationNames.contains(baseName) {
                    return true
                }
            }

            let documentationExtensions = ["txt", "rst", "adoc", "asciidoc"]
            if documentationExtensions.contains(fileExtension) {
                return true
            }
        }

        return false
    }

    func getExcludedDirectories(at path: String, configuration: ProcessingConfiguration) -> [ExcludedDirectoryInfo] {
        guard configuration.compressionOptions.smartAutoExclusion else { return [] }

        var excludedDirs: [ExcludedDirectoryInfo] = []
        let fileManager = FileManager.default

        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            for item in items {
                let itemPath = (path as NSString).appendingPathComponent(item)

                // Security: Skip paths that escape the parent directory (path traversal prevention)
                guard isPathWithinBounds(itemPath, basePath: path) else {
                    continue
                }

                var isDirectory: ObjCBool = false

                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    let category = smartAnalyzer.categorizeFile(path: itemPath)
                    if category == .excludeWithReference {
                        let info = smartAnalyzer.analyzeExcludedDirectory(at: itemPath)
                        excludedDirs.append(info)
                    }
                }
            }
        } catch {
            print("Error analyzing excluded directories: \(error)")
        }

        return excludedDirs
    }

    func processLargeFile(path: String) async throws -> String {
        let url = URL(fileURLWithPath: path)
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { fileHandle.closeFile() }

        let chunkSize = 1024 * 1024
        var content = ""
        var totalRead = 0

        while true {
            let chunk = fileHandle.readData(ofLength: chunkSize)
            if chunk.isEmpty { break }

            if let chunkString = String(data: chunk, encoding: .utf8) {
                content += chunkString
                totalRead += chunk.count
            } else {
                throw NSError(domain: "TrimbleApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode file chunk as UTF-8"])
            }

            await Task.yield()

            if totalRead > maxFileSize {
                throw NSError(domain: "TrimbleApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "File exceeded maximum size during reading"])
            }
        }

        return content
    }

    func getFileSize(at path: String) throws -> Int {
        let fileManager = FileManager.default
        let attributes = try fileManager.attributesOfItem(atPath: path)
        return (attributes[.size] as? Int) ?? 0
    }

    func isFileTooLarge(at path: String) -> Bool {
        do {
            let fileSize = try getFileSize(at: path)
            return fileSize > maxFileSize
        } catch {
            return false
        }
    }
}
