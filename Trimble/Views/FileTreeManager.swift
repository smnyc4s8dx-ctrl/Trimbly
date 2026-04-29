import Foundation
import SwiftUI

class FileTreeManager: ObservableObject {
    enum CompressionLevel: String, CaseIterable {
        case none = "Skip"
        case light = "Light"
        case medium = "Medium"
        case aggressive = "Aggressive"
        case maximum = "Maximum"

        var color: Color {
            switch self {
            case .none: return .gray
            case .light: return .green
            case .medium: return .blue
            case .aggressive: return .orange
            case .maximum: return .red
            }
        }

        var icon: String {
            switch self {
            case .none: return "xmark.circle"
            case .light: return "leaf"
            case .medium: return "scale.3d"
            case .aggressive: return "bolt"
            case .maximum: return "flame"
            }
        }
    }

    class FileTreeNode: ObservableObject, Identifiable {
        let id = UUID()
        let name: String
        let path: String
        let isDirectory: Bool
        @Published var compressionLevel: CompressionLevel
        @Published var isExpanded: Bool = false
        @Published var isSelected: Bool = true {
            didSet {
                if oldValue != isSelected {
                    updateChildrenSelection()
                    notifySelectionChange()
                }
            }
        }
        @Published var children: [FileTreeNode] = []
        @Published var isLoading: Bool = false
        private var hasLoadedChildren: Bool = false
        private var canHaveChildren: Bool = true
        private var hasCheckedForChildren: Bool = false
        weak var fileTreeManager: FileTreeManager?

        init(name: String, path: String, isDirectory: Bool, compressionLevel: CompressionLevel, fileTreeManager: FileTreeManager? = nil) {
            self.name = name
            self.path = path
            self.isDirectory = isDirectory
            self.compressionLevel = compressionLevel
            self.fileTreeManager = fileTreeManager
        }

        private func updateChildrenSelection() {
            for child in children {
                child.isSelected = isSelected
            }
        }

        private func notifySelectionChange() {
            fileTreeManager?.selectionDidChange()
        }

        func toggleExpansion(fileTreeManager: FileTreeManager) {
            if isExpanded {
                isExpanded = false
            } else {
                isExpanded = true
                if !hasLoadedChildren {
                    loadChildrenIfNeeded()
                }
            }
        }

        private func loadChildrenIfNeeded() {
            guard !hasLoadedChildren && !hasCheckedForChildren else { return }
            isLoading = true
            hasCheckedForChildren = true

            Task {
                let loadedChildren = await loadChildren()
                await MainActor.run {
                    self.children = loadedChildren
                    self.hasLoadedChildren = true
                    self.isLoading = false
                    self.canHaveChildren = !loadedChildren.isEmpty

                    if let fileTreeManager = self.fileTreeManager {
                        fileTreeManager.applyCurrentPresetToChildren(loadedChildren)
                    }
                }
            }
        }

        func loadChildren() async -> [FileTreeNode] {
            guard isDirectory else { return [] }

            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: path)
                let limitedContents = Array(contents.prefix(200))

                return limitedContents.compactMap { item in
                    let itemPath = (path as NSString).appendingPathComponent(item)
                    var isItemDirectory: ObjCBool = false
                    guard FileManager.default.fileExists(atPath: itemPath, isDirectory: &isItemDirectory) else {
                        return nil
                    }

                    if shouldSkipDirectory(item) {
                        return nil
                    }

                    return FileTreeNode(
                        name: item,
                        path: itemPath,
                        isDirectory: isItemDirectory.boolValue,
                        compressionLevel: .medium,
                        fileTreeManager: fileTreeManager
                    )
                }.sorted { node1, node2 in
                    if node1.isDirectory != node2.isDirectory {
                        return node1.isDirectory
                    }
                    return node1.name.localizedCaseInsensitiveCompare(node2.name) == .orderedAscending
                }
            } catch {
                print("Error loading children for \(path): \(error)")
                return []
            }
        }

        private func shouldSkipDirectory(_ name: String) -> Bool {
            let skipDirs = ["node_modules", "Pods", "build", "dist", ".git", "__pycache__"]
            return skipDirs.contains(name) || name.hasPrefix(".")
        }

        var shouldShowChevron: Bool {
            return isDirectory && (canHaveChildren || !hasCheckedForChildren)
        }
    }

    @Published var rootNode: FileTreeNode?
    @Published var compressionSettings: [String: CompressionLevel] = [:]
    @Published var isLoading: Bool = false
    @Published var selectionChangeNotifier = UUID()
    private var currentSemanticLevel: SemanticCompressionLevel = .medium

    func selectionDidChange() {
        selectionChangeNotifier = UUID()
    }

    func loadFileTree(at path: String) async -> FileTreeNode? {
        await MainActor.run {
            self.isLoading = true
        }

        let rootNode = await Task.detached {
            return FileTreeNode(
                name: URL(fileURLWithPath: path).lastPathComponent,
                path: path,
                isDirectory: true,
                compressionLevel: .medium,
                fileTreeManager: self
            )
        }.value

        await MainActor.run {
            self.rootNode = rootNode
            self.isLoading = false
        }

        return rootNode
    }

    func setCompressionLevel(_ level: CompressionLevel, for path: String) {
        compressionSettings[path] = level
    }

    func getCompressionLevel(for path: String) -> CompressionLevel {
        return compressionSettings[path] ?? .medium
    }

    func selectAllFiles() {
        setSelectionForNode(rootNode, selected: true)
    }

    func deselectAllFiles() {
        setSelectionForNode(rootNode, selected: false)
    }

    func applyCompressionPreset(_ semanticLevel: SemanticCompressionLevel) {
        currentSemanticLevel = semanticLevel
        applyPresetToNode(rootNode, semanticLevel: semanticLevel)
    }

    func applyCurrentPresetToChildren(_ children: [FileTreeNode]) {
        for child in children {
            applyPresetToNode(child, semanticLevel: currentSemanticLevel)
        }
    }

    private func applyPresetToNode(_ node: FileTreeNode?, semanticLevel: SemanticCompressionLevel) {
        guard let node = node else { return }

        if shouldIncludeFile(node.name, for: semanticLevel) {
            node.isSelected = true
            switch semanticLevel {
            case .light: node.compressionLevel = .light
            case .medium: node.compressionLevel = .medium
            case .aggressive: node.compressionLevel = .aggressive
            case .maximum: node.compressionLevel = .maximum
            }
        } else {
            node.isSelected = false
            node.compressionLevel = .none
        }

        for child in node.children {
            applyPresetToNode(child, semanticLevel: semanticLevel)
        }
    }

    private func shouldIncludeFile(_ fileName: String, for semanticLevel: SemanticCompressionLevel) -> Bool {
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        let pathComponents = fileName.components(separatedBy: "/")

        let binaryExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "svg", "ico", "mp4", "mov", "mp3", "wav", "dylib", "so", "dll", "exe", "zip", "tar", "gz"]
        if binaryExtensions.contains(fileExtension) {
            return false
        }

        let assetDirectories = ["assets", "images", "media", "resources", "static"]
        let isInAssetDirectory = pathComponents.contains { assetDirectories.contains($0.lowercased()) }

        switch semanticLevel {
        case .light:
            return !isInAssetDirectory
        case .medium:
            let docExtensions = ["md", "txt", "rst"]
            let docNames = ["readme", "license", "changelog"]
            return !(docExtensions.contains(fileExtension) ||
                    docNames.contains { fileName.lowercased().contains($0) } ||
                    isInAssetDirectory)
        case .aggressive:
            let testIndicators = ["test", "spec"]
            let configExtensions = ["json", "yaml", "xml", "plist"]
            return !(testIndicators.contains { fileName.contains($0) } ||
                    configExtensions.contains(fileExtension) ||
                    isInAssetDirectory)
        case .maximum:
            let coreExtensions = ["swift", "js", "ts", "py", "java", "cs", "cpp", "go", "rs"]
            return coreExtensions.contains(fileExtension) && !isInAssetDirectory
        }
    }

    private func setSelectionForNode(_ node: FileTreeNode?, selected: Bool) {
        guard let node = node else { return }
        node.isSelected = selected
        for child in node.children {
            setSelectionForNode(child, selected: selected)
        }
    }
}
