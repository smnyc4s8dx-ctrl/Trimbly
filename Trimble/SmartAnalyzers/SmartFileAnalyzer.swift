//  SmartFileAnalyzer.swift
import Foundation

class SmartFileAnalyzer {

    // MARK: - Auto-Exclusion Logic

    static let autoExcludeDirs: Set<String> = [
        // Package managers
        "node_modules", "Pods", "vendor", "packages",
        // Build outputs
        "build", "dist", "target", "out", "bin", "obj",
        // Version control
        ".git", ".svn", ".hg", ".bzr",
        // Cache directories
        "__pycache__", ".pytest_cache", ".mypy_cache",
        ".xcworkspace/xcuserdata", ".xcodeproj/xcuserdata",
        "Carthage/Checkouts", "DerivedData",
        // Other
        "external", "third_party", "3rdparty", "dependencies"
    ]

    static let autoExcludePatterns: Set<String> = [
        // Compiled libraries
        "dylib", "so", "dll", "a", "lib",
        // Archives
        "zip", "tar", "gz", "bz2", "7z", "rar",
        // Media files
        "png", "jpg", "jpeg", "gif", "bmp", "tiff", "ico", "svg",
        "mp4", "mov", "avi", "mkv", "wmv", "mp3", "wav", "flac",
        // Documents
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx"
    ]

    static let alwaysIncludeFiles: Set<String> = [
        // Package definitions
        "package.json", "package-lock.json", "yarn.lock",
        "podfile", "podfile.lock", "cartfile", "cartfile.resolved",
        "package.swift", "package.resolved",
        "requirements.txt", "pipfile", "poetry.lock",
        "gemfile", "gemfile.lock",
        "go.mod", "go.sum",
        "cargo.toml", "cargo.lock",
        "pom.xml", "build.gradle", "build.gradle.kts",
        // Project configs
        "project.pbxproj", "info.plist",
        "tsconfig.json", "babel.config.js", "webpack.config.js",
        "dockerfile", "docker-compose.yml",
        "makefile", "cmake.txt"
    ]

    func categorizeFile(path: String) -> FileCategory {
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.lowercased()
        let fileExtension = url.pathExtension.lowercased()
        let pathComponents = path.lowercased().components(separatedBy: "/")

        // Always include critical project files
        if Self.alwaysIncludeFiles.contains(fileName) {
            return .alwaysInclude
        }

        // Auto-exclude directories
        for component in pathComponents {
            if Self.autoExcludeDirs.contains(component) {
                return .excludeWithReference
            }
        }

        // Auto-exclude file types
        if Self.autoExcludePatterns.contains(fileExtension) {
            return .autoExclude
        }

        // Hidden files (except known important ones)
        if fileName.hasPrefix(".") && !Self.alwaysIncludeFiles.contains(fileName) {
            return .autoExclude
        }

        return .normalCompression
    }

    func extractLibraryDependencies(from projectPath: String) -> [LibraryDependency] {
        var dependencies: [LibraryDependency] = []

        // Check various package files
        dependencies.append(contentsOf: extractNpmDependencies(from: projectPath))
        dependencies.append(contentsOf: extractPodDependencies(from: projectPath))
        dependencies.append(contentsOf: extractSwiftPackageDependencies(from: projectPath))
        dependencies.append(contentsOf: extractPythonDependencies(from: projectPath))

        return dependencies
    }

    private func extractNpmDependencies(from projectPath: String) -> [LibraryDependency] {
        let packageJsonPath = (projectPath as NSString).appendingPathComponent("package.json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: packageJsonPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }

        var deps: [LibraryDependency] = []

        if let dependencies = json["dependencies"] as? [String: String] {
            for (name, version) in dependencies {
                deps.append(LibraryDependency(name: name, version: version, source: .npm))
            }
        }

        return deps
    }

    private func extractPodDependencies(from projectPath: String) -> [LibraryDependency] {
        let podfilePath = (projectPath as NSString).appendingPathComponent("Podfile")
        guard let content = try? String(contentsOfFile: podfilePath) else { return [] }

        var deps: [LibraryDependency] = []
        let podPattern = "pod\\s+['\"]([^'\"]+)['\"](?:,\\s*['\"]([^'\"]+)['\"])?"

        do {
            let regex = try NSRegularExpression(pattern: podPattern)
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

            for match in matches {
                if let nameRange = Range(match.range(at: 1), in: content) {
                    let name = String(content[nameRange])
                    var version: String? = nil

                    if match.numberOfRanges > 2, let versionRange = Range(match.range(at: 2), in: content) {
                        version = String(content[versionRange])
                    }

                    deps.append(LibraryDependency(name: name, version: version, source: .cocoapods))
                }
            }
        } catch {
            print("Error parsing Podfile: \(error)")
        }

        return deps
    }

    private func extractSwiftPackageDependencies(from projectPath: String) -> [LibraryDependency] {
        let packageSwiftPath = (projectPath as NSString).appendingPathComponent("Package.swift")
        guard let content = try? String(contentsOfFile: packageSwiftPath) else { return [] }

        var deps: [LibraryDependency] = []
        let urlPattern = "\\.package\\(url:\\s*['\"]([^'\"]+)['\"]"

        do {
            let regex = try NSRegularExpression(pattern: urlPattern)
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

            for match in matches {
                if let urlRange = Range(match.range(at: 1), in: content) {
                    let url = String(content[urlRange])
                    let name = URL(string: url)?.lastPathComponent.replacingOccurrences(of: ".git", with: "") ?? url
                    deps.append(LibraryDependency(name: name, version: nil, source: .swift_package))
                }
            }
        } catch {
            print("Error parsing Package.swift: \(error)")
        }

        return deps
    }

    private func extractPythonDependencies(from projectPath: String) -> [LibraryDependency] {
        let requirementsPath = (projectPath as NSString).appendingPathComponent("requirements.txt")
        guard let content = try? String(contentsOfFile: requirementsPath) else { return [] }

        var deps: [LibraryDependency] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                let components = trimmed.components(separatedBy: CharacterSet(charactersIn: ">=<~!"))
                if let name = components.first?.trimmingCharacters(in: .whitespaces) {
                    let version = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : nil
                    deps.append(LibraryDependency(name: name, version: version, source: .python_pip))
                }
            }
        }

        return deps
    }

    func analyzeExcludedDirectory(at path: String) -> ExcludedDirectoryInfo {
        let url = URL(fileURLWithPath: path)
        let dirName = url.lastPathComponent

        var fileCount = 0
        var totalSize: Int64 = 0
        var primaryPackages: [String] = []

        if let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                fileCount += 1
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }

                // Extract primary packages (first few items)
                if primaryPackages.count < 5 {
                    primaryPackages.append(fileURL.lastPathComponent)
                }

                // Limit enumeration for performance
                if fileCount > 1000 {
                    break
                }
            }
        }

        let category = categorizeExcludedDirectory(dirName)
        let sizeString = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)

        return ExcludedDirectoryInfo(
            name: dirName,
            fileCount: fileCount,
            totalSize: sizeString,
            primaryPackages: Array(primaryPackages.prefix(5)),
            category: category
        )
    }

    private func categorizeExcludedDirectory(_ dirName: String) -> ExclusionCategory {
        let name = dirName.lowercased()

        if ["node_modules", "pods", "vendor", "packages"].contains(name) {
            return .dependencies
        } else if ["build", "dist", "target", "out", "bin", "obj"].contains(name) {
            return .buildArtifacts
        } else if [".git", ".svn", ".hg"].contains(name) {
            return .versionControl
        } else if ["__pycache__", ".pytest_cache", ".mypy_cache"].contains(name) {
            return .cache
        } else {
            return .dependencies
        }
    }
}
