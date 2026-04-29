# Project Index: Trimbly

Generated: 2026-04-27

## Overview

Trimbly is a native macOS (SwiftUI) app that compresses source code into token-efficient representations for AI/LLM consumption. It walks a project tree, applies per-language semantic optimizers, counts tokens against multiple model tokenizers, and previews/exports the compressed result. Pure-Swift, no external runtime dependencies.

- Platform: macOS 14+ (SwiftUI, Swift 5.9)
- Build: SwiftPM (`Package.swift`) for the `TrimbleCore` library + Xcode project (`Trimble.xcodeproj`) for the app shell
- ~26k LOC of Swift across ~60 files

## Project Structure

```
Trimbly/
├── Package.swift              SPM manifest (TrimbleCore lib, macOS 14+)
├── Trimble.xcodeproj          App shell (entry point, assets, Info.plist)
└── Trimble/                   All source (target: TrimbleCore)
    ├── TrimbleApp.swift       @main App, hosts ContentView
    ├── Models.swift           Core domain types (CompressionOptions, ProcessingConfiguration, ...)
    ├── Extensions.swift       Foundation/SwiftUI extensions
    ├── KnowledgeBase.swift    Static in-app help/FAQ/best-practices content
    ├── ErrorReporter.swift    ObservableObject for sanitized error reporting
    ├── Engines/               Core processing pipeline
    ├── SmartAnalyzers/        Semantic analysis + tokenization
    ├── LanguageOptimizers/    Per-language compression strategies (19 languages)
    ├── Theming/               Theme system (protocol + 2 themes + themed components)
    └── Views/                 SwiftUI views (ContentView + panels)
```

## Entry Points

- App: `Trimble/TrimbleApp.swift` — `@main TrimbleApp` → `ContentView`
- Root view: `Trimble/Views/ContentView.swift` — composes all panels and drives processing
- Public library: `TrimbleCore` target in `Package.swift` (everything under `Trimble/` except `TrimbleApp.swift`, `Info.plist`, `Assets.xcassets`, `Preview Content`)

## Core Modules

### Engines (`Trimble/Engines/`)
- `FileProcessor.swift` — Filesystem walk, text-file detection, path-traversal guard, integrates `GitIgnoreParser` and `SmartFileAnalyzer`
- `ContentProcessor.swift` — `ObservableObject` orchestrator. `actor TokenProcessingQueue`, `TokenProcessingProgress`, `TokenResult`. Drives async pipeline and publishes UI state
- `CompressionEngine.swift` — Dispatches per-language optimizers (cached by `ProgrammingLanguage`), falls back to generic compression
- `GitIgnoreParser.swift` — `.gitignore` glob → regex, supports negation and nested gitignores

### SmartAnalyzers (`Trimble/SmartAnalyzers/`)
- `TokenCounter.swift` — `TokenizerType` enum (openai/claude/qwen/deepseek/codellama/gemini/llama), heuristic token counts per family
- `SemanticAnalyzer.swift` — Extracts imports, classes, functions, public APIs, metrics, identifier map, dependencies; produces `CodeStructure`
- `SmartFileAnalyzer.swift` — Auto-exclusion rules (build dirs, lockfiles, binaries, node_modules, etc.)

### LanguageOptimizers (`Trimble/LanguageOptimizers/`)
- `LanguageOptimizer.swift` — `protocol LanguageOptimizer`, `enum CriticalPattern`, `struct CompressedResult`
- `LanguageTemplate.swift` — `class TemplateOptimizer: LanguageOptimizer` shared base behavior
- 19 concrete optimizers: Swift, TypeScript, Python, Java, Kotlin, CSharp, Cpp, Go, Rust, Ruby, PHP, ObjectiveC, ShellScript, SQL, CSS, HTMLTemplate, JSON, YAML, Dockerfile, JupyterNotebook
- Largest: `JupyterNotebookOptimizer` (~1.2k LOC), `PythonOptimizer` (~1.1k), `SwiftOptimizer` (~1k)

### Theming (`Trimble/Theming/`)
- `ThemeProtocol.swift` — `protocol TrimbleTheme`, `enum AlertSeverity`, button-style wrappers
- `ThemeManager.swift` — Theme switching/persistence
- `ThemeEnvironment.swift` — SwiftUI `EnvironmentValues` plumbing
- `Themes/ClassicTheme.swift`, `Themes/LiquidGlassTheme.swift`
- `Components/` — `ThemedAlert`, `ThemedCard`, `ThemedInputField`, `ThemedProgressContainer`, `ThemedSectionHeader`, `ThemedStatCard`, `ThemeSettingsView`

### Views (`Trimble/Views/`)
- `ContentView.swift` — Top-level composition (202 LOC)
- `HelpView.swift` — Largest view (~660 LOC), in-app docs surface for `KnowledgeBase`
- `AdvancedFileTreeView.swift` + `FileTreeManager.swift` — Hierarchical file selection
- `PreviewPanelView.swift`, `CompressionControlsView.swift`, `OutputConfigurationView.swift`, `SourceSelectionView.swift`
- `ProcessingStatusView.swift`, `ActionButtonsView.swift`, `HeaderView.swift`, `ErrorDisplayView.swift`, `ErrorReportView.swift`

### Domain Models (`Trimble/Models.swift`, 606 LOC)
Key types: `OutputFormat`, `AIModel`, `ProgrammingLanguage`, `SemanticCompressionLevel`, `FileCategory`, `CompressionOptions`, `CompressionStrategy`, `ProcessingConfiguration`, `CompressedCode`, `CompressionPreview`, `ProcessingError`, `CodeStructure`, `XcodeProjectStructure`, `CodeMetrics`, `HierarchicalMap`, `ProjectStructure`, `DirectoryNode`, `FileNode`, `DependencyGraph`, `LibraryDependency`, `Dependency`, `CircularDependency`, `FileMetrics`, `ProjectSummary`.

## Configuration

- `Package.swift` — SPM, macOS 14+, no external deps. Declares `TrimbleCore` library and `TrimbleTests` test target at `Tests/TrimbleTests` (directory not present on disk — test target stub)
- `Trimble.xcodeproj/` — Xcode project with `Info.plist`, `Assets.xcassets`
- `.claude/settings.local.json` — local Claude Code permissions
- `.gitignore` — root

## Documentation

No top-level README or `docs/` directory currently. Prior `docs/implementation/PHASE_*` files and `CLAUDE.md` were removed (see git status: `D` entries) during the recent simplification (`a553f76 Major simplification: Remove MLX/AI middleware, add themeable UI`). In-app help is sourced from `Trimble/KnowledgeBase.swift` and rendered by `Views/HelpView.swift`.

## Tests

- `Tests/TrimbleTests` referenced by `Package.swift` but the directory does not exist — test target is currently empty/unimplemented.
- No `*.test.swift` / `*Tests.swift` files in the working tree.

## Dependencies

- Runtime: none (pure Swift + SwiftUI + Foundation + UniformTypeIdentifiers)
- `.build/checkouts/` shows historical SPM checkouts (`NetworkImage`, `SQLite.swift`, `swift-markdown-ui`) from before the MLX/AI removal — not declared in current `Package.swift`. `Package.resolved` is deleted in the working tree.

## Quick Start

1. Open `Trimble.xcodeproj` in Xcode (macOS 14+ required)
2. Build & run the `Trimble` scheme — launches the SwiftUI app
3. Library-only build: `swift build` from repo root (compiles `TrimbleCore`)
4. SPM tests: `swift test` (currently no-op — no test files)

## Recent Direction (from git log)

- `a553f76` — Removed MLX/AI middleware; added themeable UI
- `842b27a` — Phase 6: Production tokenizer integration via HuggingFace swift-transformers (now reverted in `a553f76`)
- `e8602bb` — Fixed Query Mode missing source-directory selection
- `01ad7b5` — Fixed `EXC_BREAKPOINT` in `SimpleTokenizer.decode()` (file no longer present — code consolidated into `TokenCounter`)
