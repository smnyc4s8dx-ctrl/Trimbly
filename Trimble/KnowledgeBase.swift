import Foundation

struct KnowledgeBase {
    static let compressionOptionsHelp: [String: CompressionHelpItem] = [
        "removeComments": CompressionHelpItem(
            title: "Remove Comments",
            description: "Strips all code comments (// /* */ # etc.)",
            impactLevel: "High Impact",
            semanticImpact: "None",
            recommendation: "Always safe for AI consumption"
        ),
        "removeWhitespace": CompressionHelpItem(
            title: "Remove Excess Whitespace",
            description: "Removes empty lines and trims whitespace",
            impactLevel: "Medium Impact",
            semanticImpact: "None",
            recommendation: "Safe, improves token efficiency"
        ),
        "removeDocumentation": CompressionHelpItem(
            title: "Remove Documentation",
            description: "Removes docstrings, JSDoc, and similar documentation",
            impactLevel: "High Impact",
            semanticImpact: "Low",
            recommendation: "Good for code analysis, may lose API documentation"
        ),
        "skipDocumentationFiles": CompressionHelpItem(
            title: "Skip Documentation Files",
            description: "Excludes README.md, LICENSE, CHANGELOG, .txt, .rst files and similar documentation",
            impactLevel: "Medium Impact",
            semanticImpact: "None",
            recommendation: "Skip for code review, include for project documentation analysis"
        ),
        "truncateFunctions": CompressionHelpItem(
            title: "Truncate Function Bodies",
            description: "Keeps function signatures but shortens implementations",
            impactLevel: "Very High Impact",
            semanticImpact: "Medium",
            recommendation: "Good for understanding code structure"
        ),
        "signaturesOnly": CompressionHelpItem(
            title: "Signatures Only",
            description: "Extracts only function and class signatures",
            impactLevel: "Extreme Impact",
            semanticImpact: "High",
            recommendation: "Best for API analysis and code understanding"
        ),
        "shortenIdentifiers": CompressionHelpItem(
            title: "Shorten Identifiers",
            description: "Maps long variable names to shorter versions (myVariable → v1)",
            impactLevel: "Medium Impact",
            semanticImpact: "Medium",
            recommendation: "Use when token budget is tight"
        ),
        "structureOnly": CompressionHelpItem(
            title: "Structure Only",
            description: "Outputs only high-level metrics and counts",
            impactLevel: "Maximum Impact",
            semanticImpact: "Very High",
            recommendation: "For high-level project analysis only"
        ),
        "respectGitignore": CompressionHelpItem(
            title: "Respect .gitignore",
            description: "Automatically excludes files and directories specified in .gitignore files throughout your project",
            impactLevel: "Variable Impact",
            semanticImpact: "None",
            recommendation: "Usually recommended - respects your project's existing file exclusion rules"
        ),
        "removeImports": CompressionHelpItem(
            title: "Remove Imports",
            description: "Strips import/include statements",
            impactLevel: "Low Impact",
            semanticImpact: "Low",
            recommendation: "Safe if dependencies aren't important for your task"
        ),
        "skipLibraryFolders": CompressionHelpItem(
            title: "Skip Library/Vendor Folders",
            description: "Excludes node_modules, Pods, vendor directories and similar",
            impactLevel: "Very High Impact",
            semanticImpact: "None",
            recommendation: "Essential for meaningful compression of application code"
        ),
        "skipLocalizationFiles": CompressionHelpItem(
            title: "Skip Localization Files",
            description: "Excludes .strings, .po, .xliff, i18n JSON files and locale directories",
            impactLevel: "High Impact",
            semanticImpact: "None",
            recommendation: "Skip unless analyzing internationalization"
        ),
        "skipTestFiles": CompressionHelpItem(
            title: "Skip Test Files",
            description: "Excludes files with 'test', 'spec' in name or path",
            impactLevel: "Medium Impact",
            semanticImpact: "Low",
            recommendation: "Skip for production code analysis"
        ),
        "skipConfigFiles": CompressionHelpItem(
            title: "Skip Config Files",
            description: "Excludes XML, PLIST, JSON config files",
            impactLevel: "Medium Impact",
            semanticImpact: "Low",
            recommendation: "Skip unless analyzing configuration patterns"
        ),
        "limits": CompressionHelpItem(
            title: "Line & Token Limits",
            description: "Smart limits that preserve important code while reducing size",
            impactLevel: "Variable Impact",
            semanticImpact: "Low to Medium",
            recommendation: "Use optional limits for very large files, prioritizes public APIs"
        ),
        "strategies": CompressionHelpItem(
            title: "Compression Strategies",
            description: "Pre-configured combinations optimized for different scenarios",
            impactLevel: "Variable Impact",
            semanticImpact: "Variable",
            recommendation: "Start with Balanced, adjust based on your AI task requirements"
        ),
        "xcodeFiles": CompressionHelpItem(
            title: "Xcode Project Files",
            description: "Includes .entitlements, .storyboard, .xib, .xcdatamodel, and other Xcode-specific files for complete project analysis",
            impactLevel: "High Impact",
            semanticImpact: "Low",
            recommendation: "Essential for understanding app capabilities, UI structure, and data models"
        ),
        "entitlements": CompressionHelpItem(
            title: "App Entitlements",
            description: "Security permissions and capabilities that define what services your app can access",
            impactLevel: "Critical",
            semanticImpact: "None",
            recommendation: "Always include for security analysis and capability understanding"
        ),
        "storyboards": CompressionHelpItem(
            title: "Storyboard Files",
            description: "UI layout files showing screen flow and navigation patterns in your app",
            impactLevel: "High Impact",
            semanticImpact: "Medium",
            recommendation: "Include for UI analysis, can compress to structure-only for overview"
        )
    ]

    static let aiModelGuidance: [AIModel: ModelGuidance] = [
        .openai: ModelGuidance(
            contextWindow: 128000,
            recommendedTokenBudget: 100000,
            strengths: ["Code understanding", "Complex reasoning", "Multi-language support"],
            weaknesses: ["Token limit management"],
            compressionTips: "Focus on removing comments and whitespace. OpenAI Models handle compressed code well."
        ),
        .claude: ModelGuidance(
            contextWindow: 200000,
            recommendedTokenBudget: 50000,
            strengths: ["Large context", "Code analysis", "Documentation"],
            weaknesses: ["Project knowledge has stricter limits"],
            compressionTips: "For project knowledge: use extreme compression, stay under 50k tokens. Regular chat can handle more."
        ),
        .claudeCodeCLI: ModelGuidance(
            contextWindow: 100000,
            recommendedTokenBudget: 60000,
            strengths: ["Agentic coding", "File editing", "Multi-step tasks", "Tool use"],
            weaknesses: ["Per-file size limits (~500KB)", "Per-turn context constraints", "Large single files may truncate"],
            compressionTips: "Split large files across multiple messages. Keep individual file content under 50k tokens. Medium compression recommended for full codebase context."
        ),
        .codellama: ModelGuidance(
            contextWindow: 16384,
            recommendedTokenBudget: 12000,
            strengths: ["Code completion", "Syntax understanding"],
            weaknesses: ["Small context window"],
            compressionTips: "Aggressive compression needed. Use signatures-only mode."
        ),
        .gemini: ModelGuidance(
            contextWindow: 1000000,
            recommendedTokenBudget: 800000,
            strengths: ["Massive context", "Multi-modal", "Complex analysis"],
            weaknesses: ["May be overkill for simple tasks"],
            compressionTips: "Can handle full content. Light compression is sufficient."
        )
    ]

    static let bestPractices = [
        BestPractice(
            title: "Start Conservative",
            description: "Begin with light compression (comments + whitespace) and increase as needed.",
            applicableWhen: "First time using the tool or uncertain about requirements"
        ),
        BestPractice(
            title: "Know Your Task",
            description: "Code review needs full functions; API analysis only needs signatures.",
            applicableWhen: "You have a specific AI task in mind"
        ),
        BestPractice(
            title: "Monitor Token Budget",
            description: "Keep 20% buffer below your AI model's context window for responses.",
            applicableWhen: "Working with context-limited models"
        ),
        BestPractice(
            title: "Preserve Public APIs",
            description: "Always keep public function signatures for library analysis.",
            applicableWhen: "Analyzing libraries or frameworks"
        ),
        BestPractice(
            title: "Test Incrementally",
            description: "Try different compression levels on small samples first.",
            applicableWhen: "Working with large codebases"
        ),
        BestPractice(
            title: "Use Project Knowledge Preset for Claude",
            description: "Claude's project knowledge feature has much lower practical limits than regular chat.",
            applicableWhen: "Adding content to Claude's project knowledge"
        ),
        BestPractice(
            title: "Filter Aggressively",
            description: "Skip library folders, tests, and config files unless specifically needed.",
            applicableWhen: "Analyzing application logic rather than full project structure"
        ),
        BestPractice(
            title: "Use Smart Limits",
            description: "Optional line/token limits preserve important code while reducing large files.",
            applicableWhen: "Processing codebases with very large files"
        ),
        BestPractice(
            title: "Include Xcode Project Files",
            description: "Always include .entitlements, .storyboard, .xib files for complete iOS/macOS project analysis.",
            applicableWhen: "Working with Xcode projects and iOS/macOS development"
        )
    ]

    static let useCases: [UseCase] = [
        UseCase(
            title: "Code Review",
            description: "AI assistant reviews code for bugs and improvements",
            recommendedSettings: CompressionOptions(
                semanticLevel: .medium,
                removeComments: true,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: false,
                removeTypeAnnotations: false,
                removeDebugStatements: false,
                truncateFunctions: false,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: false,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: true,
                skipConfigFiles: true,
                skipDocumentationFiles: true,
                respectGitignore: true,
                maxLinesPerFile: 100,
                maxTokensPerFile: 2000,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .balanced
            ),
            reason: "Preserves logic while removing noise"
        ),
        UseCase(
            title: "API Analysis",
            description: "Understanding public interfaces and dependencies",
            recommendedSettings: CompressionOptions(
                semanticLevel: .aggressive,
                removeComments: true,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: true,
                removeTypeAnnotations: true,
                removeDebugStatements: true,
                truncateFunctions: true,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: true,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: true,
                skipConfigFiles: true,
                skipDocumentationFiles: true,
                respectGitignore: true,
                maxLinesPerFile: 50,
                maxTokensPerFile: 1000,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .aggressive
            ),
            reason: "Focuses on interfaces rather than implementation"
        ),
        UseCase(
            title: "Documentation Generation",
            description: "AI creates documentation from code",
            recommendedSettings: CompressionOptions(
                semanticLevel: .medium,
                removeComments: false,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: false,
                removeTypeAnnotations: false,
                removeDebugStatements: true,
                truncateFunctions: true,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: false,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: true,
                skipConfigFiles: false,
                skipDocumentationFiles: false,
                respectGitignore: true,
                maxLinesPerFile: 75,
                maxTokensPerFile: 1500,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .balanced
            ),
            reason: "Keeps existing docs and function structure"
        ),
        UseCase(
            title: "Architecture Overview",
            description: "High-level understanding of codebase structure",
            recommendedSettings: CompressionOptions(
                semanticLevel: .aggressive,
                removeComments: true,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: true,
                removeTypeAnnotations: true,
                removeDebugStatements: true,
                truncateFunctions: true,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: true,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: true,
                skipConfigFiles: true,
                skipDocumentationFiles: true,
                respectGitignore: true,
                maxLinesPerFile: 30,
                maxTokensPerFile: 500,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .aggressive
            ),
            reason: "Shows relationships without implementation details"
        ),
        UseCase(
            title: "Migration Planning",
            description: "Understanding code for language/framework migration",
            recommendedSettings: CompressionOptions(
                semanticLevel: .aggressive,
                removeComments: true,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: true,
                removeTypeAnnotations: false,
                removeDebugStatements: true,
                truncateFunctions: true,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: false,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: false,
                skipConfigFiles: false,
                skipDocumentationFiles: true,
                respectGitignore: true,
                maxLinesPerFile: 80,
                maxTokensPerFile: 1500,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .aggressive
            ),
            reason: "Preserves logic patterns while reducing size"
        ),
        UseCase(
            title: "Xcode Project Analysis",
            description: "Complete iOS/macOS project understanding including UI, entitlements, and data models",
            recommendedSettings: CompressionOptions(
                semanticLevel: .aggressive,
                removeComments: true,
                removeWhitespace: true,
                removeImports: true,
                removeEmptyLines: true,
                removeDocumentation: true,
                removeTypeAnnotations: false,
                removeDebugStatements: true,
                truncateFunctions: true,
                shortenIdentifiers: false,
                simplifyExpressions: false,
                structureOnly: false,
                signaturesOnly: false,
                smartAutoExclusion: true,
                prioritizePublicAPIs: true,
                keepMainFunctions: true,
                preserveSignificantWhitespace: true,
                skipLibraryFolders: true,
                skipLocalizationFiles: true,
                skipTestFiles: true,
                skipConfigFiles: false,
                skipDocumentationFiles: false,
                respectGitignore: true,
                maxLinesPerFile: 60,
                maxTokensPerFile: 1200,
                preserveStructure: true,
                prioritizeTopLevel: true,
                compressionStrategy: .aggressive
            ),
            reason: "Includes all Xcode files for comprehensive app analysis"
        )
    ]

    static let faq: [FAQ] = [
        FAQ(
            question: "What's the difference between 'Signatures Only' and 'Structure Only'?",
            answer: "Signatures Only keeps function declarations and class definitions but removes implementations. Structure Only reduces everything to counts and metrics."
        ),
        FAQ(
            question: "Will identifier shortening break my code analysis?",
            answer: "AI models can usually understand shortened identifiers (v1, v2) in context. However, it may reduce readability for complex analysis tasks."
        ),
        FAQ(
            question: "How accurate are the token estimates?",
            answer: "Estimates are within ±15% for most content. Different AI models have slightly different tokenization, so we provide worst-case estimates too."
        ),
        FAQ(
            question: "Should I compress test files differently?",
            answer: "Test files often benefit from more aggressive compression since their structure is more important than implementation details. You can enable 'Skip Test Files' to exclude them entirely."
        ),
        FAQ(
            question: "What if my compressed output is still too large?",
            answer: "Try Maximum compression mode, use optional line/token limits, enable more file filtering, or split your project into smaller chunks."
        ),
        FAQ(
            question: "Why does Claude have lower recommended token budgets?",
            answer: "Claude's project knowledge feature has much stricter practical limits than its regular chat context window. Stay under 50k tokens for reliable project knowledge uploads."
        ),
        FAQ(
            question: "When should I use the optional line/token limits?",
            answer: "Use limits when you have very large files that would overwhelm the context window. The smart limits preserve important code like public APIs and main functions first."
        ),
        FAQ(
            question: "Does Trimbly respect .gitignore files?",
            answer: "Yes! Trimbly automatically finds and uses .gitignore files in your project to exclude files from compression. This helps ensure you're only processing the files that matter for your codebase analysis."
        ),
        FAQ(
            question: "How does Trimbly handle very large projects?",
            answer: "Trimbly is designed for large codebases with up to 2,000 files and individual files up to 25MB. Processing may take a few minutes for very large projects, but the tool provides real-time progress updates and time estimates."
        ),
        FAQ(
            question: "How does file filtering work?",
            answer: "File filtering excludes entire categories of files before compression. This is more efficient than compressing everything and often more semantically meaningful than arbitrary limits."
        ),
        FAQ(
            question: "What Xcode files does Trimbly support?",
            answer: "Trimbly now supports all major Xcode file types including .entitlements (app permissions), .storyboard/.xib (UI layouts), .xcdatamodel (Core Data), .xcworkspace (workspaces), and .playground (Swift Playgrounds) for complete project analysis."
        ),
        FAQ(
            question: "How does Trimbly handle storyboard and XIB files?",
            answer: "Trimbly can parse storyboards and XIBs to extract UI structure including view controllers, segues, outlets, and actions. For structure-only compression, it provides counts and relationships rather than full XML content."
        ),
        FAQ(
            question: "Can Trimbly analyze my app's security permissions?",
            answer: "Yes! Trimbly can parse .entitlements files to extract and summarize your app's security capabilities like sandboxing, network access, file permissions, and keychain usage."
        )
    ]
}

struct CompressionHelpItem {
    let title: String
    let description: String
    let impactLevel: String
    let semanticImpact: String
    let recommendation: String
}

struct ModelGuidance {
    let contextWindow: Int
    let recommendedTokenBudget: Int
    let strengths: [String]
    let weaknesses: [String]
    let compressionTips: String
}

struct BestPractice {
    let title: String
    let description: String
    let applicableWhen: String
}

struct UseCase {
    let title: String
    let description: String
    let recommendedSettings: CompressionOptions
    let reason: String
}

struct FAQ {
    let question: String
    let answer: String
}
