# Trimbly

> **⚠️ Archived / Deprecated** — This project is no longer maintained. It was previously distributed on the Mac App Store and has since been withdrawn. The source is published here for reference and forking under the MIT license. **No support, no issues, no pull requests.** Use at your own risk.

A native macOS app for compressing source code into token-efficient representations for consumption by Large Language Models (Claude, GPT, Gemini, CodeLlama, etc.). Trimbly walks a project tree, applies per-language semantic optimizations, counts tokens against multiple model tokenizers, and previews/exports the compressed result.

## Features

- **19 language-specific optimizers** — Swift, TypeScript, Python, Java, Kotlin, C#, C++, Go, Rust, Ruby, PHP, Objective-C, Shell, SQL, CSS, HTML, JSON, YAML, Dockerfile, Jupyter Notebook
- **7 tokenizer families** — heuristic counts for OpenAI / Claude / Qwen / DeepSeek / CodeLlama / Gemini / Llama
- **Configurable compression strategies** — remove comments, whitespace, documentation, debug statements; semantic compression with adjustable accuracy/savings trade-off
- **`.gitignore`-aware traversal** — respects nested gitignores, with sensible auto-exclusions (`node_modules`, `build/`, `Pods/`, etc.)
- **Themeable UI** — Classic and Liquid Glass themes built on a `TrimbleTheme` protocol
- **Live preview + token estimates** before export
- **Multiple output formats** — text, JSON, minimal, markdown
- **Pure Swift / SwiftUI** — no external runtime dependencies

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16 or later (Swift 5.9)

## Build & Run

### Xcode (app)

```sh
open Trimble.xcodeproj
```

Select the `Trimbly` scheme and ⌘R. Code signing is set to Automatic with no team — set your own team in **Signing & Capabilities** before building, or disable signing for a local debug build.

### Swift Package Manager (library only)

The `TrimbleCore` library target builds independently of the app shell:

```sh
swift build
```

This compiles the engines, optimizers, analyzers, models, and theme system, but not the SwiftUI app entry point.

## Architecture

See [`PROJECT_INDEX.md`](./PROJECT_INDEX.md) for a complete map of the codebase. High-level layout:

```
Trimble/
├── TrimbleApp.swift       App @main entry
├── Models.swift           Domain types
├── Engines/               File walk, gitignore, dispatch
├── SmartAnalyzers/        Token counting + semantic analysis
├── LanguageOptimizers/    Per-language compression (19 implementations)
├── Theming/               Theme protocol + 2 themes + themed components
└── Views/                 SwiftUI views
```

Compression flow: `FileProcessor` walks the project → `ContentProcessor` orchestrates async work → `CompressionEngine` dispatches to a `LanguageOptimizer` chosen by file extension → `SemanticAnalyzer` extracts structure → `TokenCounter` reports savings.

## License

MIT — see [LICENSE](./LICENSE).

## Acknowledgements

Trimbly was developed by Aeon Digital LLC. The architecture is intentionally simple and self-contained so this codebase can serve as a reference for anyone interested in source-code compression for LLM contexts.
