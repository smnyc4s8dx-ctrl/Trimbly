import SwiftUI

struct HelpView: View {
    @Environment(\.theme) private var theme
    let topic: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory = .semanticLevels

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Help Topics")
                    .font(.headline)
                    .padding()

                List(HelpCategory.allCases, id: \.self, selection: $selectedCategory) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
                .listStyle(.sidebar)
            }
            .frame(width: 250)

            Divider()

            VStack(spacing: 0) {
                HStack {
                    Text(selectedCategory.rawValue)
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(theme.primaryButtonStyle())
                }
                .padding()
                .background(theme.secondaryBackground)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.textSecondary)
                    TextField("Search help...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(theme.secondaryBackground.opacity(0.5))

                Divider()

                SearchableContent(category: selectedCategory, searchText: searchText)
            }
        }
        .frame(minWidth: 900, minHeight: 700)
        .onAppear {
            if let initialCategory = HelpCategory.allCases.first(where: { $0.rawValue.lowercased().contains(topic.lowercased()) }) {
                selectedCategory = initialCategory
            }
        }
    }
}

enum HelpCategory: String, CaseIterable {
    case semanticLevels = "Semantic Compression Levels"
    case smartExclusion = "Smart Auto-Exclusion"
    case aiModels = "AI Model Optimization"
    case bestPractices = "Best Practices"
    case useCases = "Use Cases"
    case troubleshooting = "Troubleshooting"
    case privacy = "Privacy Policy"
    case faq = "FAQ"

    var icon: String {
        switch self {
        case .semanticLevels: return "brain.head.profile"
        case .smartExclusion: return "eye.slash"
        case .aiModels: return "cpu"
        case .bestPractices: return "checkmark.circle"
        case .useCases: return "lightbulb"
        case .troubleshooting: return "wrench.and.screwdriver"
        case .privacy: return "lock.shield"
        case .faq: return "questionmark.circle"
        }
    }
}

struct SearchableContent: View {
    @Environment(\.theme) private var theme
    let category: HelpCategory
    let searchText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch category {
                case .semanticLevels:
                    semanticLevelsContent
                case .smartExclusion:
                    smartExclusionContent
                case .aiModels:
                    aiModelsContent
                case .bestPractices:
                    bestPracticesContent
                case .useCases:
                    useCasesContent
                case .troubleshooting:
                    troubleshootingContent
                case .privacy:
                    privacyContent
                case .faq:
                    faqContent
                }
            }
            .padding()
        }
    }

    private var semanticLevelsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Semantic Compression Levels")
                .font(.title2)
                .fontWeight(.bold)

            Text("Trimbly uses AI-optimized semantic compression that preserves meaning while maximizing token efficiency. Each level is designed for specific use cases:")
                .foregroundColor(.secondary)

            ForEach(SemanticCompressionLevel.allCases, id: \.self) { level in
                SemanticLevelHelpCard(level: level)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Choosing the Right Level")
                    .font(.headline)
                    .foregroundColor(theme.primaryAccent)

                VStack(alignment: .leading, spacing: 8) {
                    helpItem(icon: "lightbulb", title: "Code Review & Bug Detection", description: "Use Medium or Aggressive - preserves logic while removing noise")
                    helpItem(icon: "eye", title: "Architecture Analysis", description: "Use Aggressive or Maximum - focuses on structure and relationships")
                    helpItem(icon: "brain", title: "Claude Project Knowledge", description: "Use Maximum - stays under 50k token limit with high-level overview")
                    helpItem(icon: "gear", title: "General AI Assistance", description: "Use Light or Medium - maintains full context with minimal loss")
                }
            }
        }
    }

    private var smartExclusionContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Smart Auto-Exclusion")
                .font(.title2)
                .fontWeight(.bold)

            Text("Automatically identifies and excludes files that provide zero semantic value for AI analysis, while preserving dependency information:")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                exclusionCategory(
                    title: "Always Excluded",
                    icon: "🚫",
                    color: .red,
                    items: [
                        "node_modules/ (npm packages - can be 50K+ files)",
                        "Pods/ (CocoaPods dependencies)",
                        "build/, dist/, target/ (compiled outputs)",
                        ".git/, .svn/ (version control)",
                        "Binary files (.dylib, .so, .dll, images, media)"
                    ]
                )

                exclusionCategory(
                    title: "Always Included",
                    icon: "📋",
                    color: .green,
                    items: [
                        "package.json, Podfile (dependency definitions)",
                        "Package.swift, requirements.txt",
                        "project.pbxproj (Xcode project structure)",
                        "Configuration files critical to project understanding"
                    ]
                )

                exclusionCategory(
                    title: "Smart Reference",
                    icon: "👁️",
                    color: .blue,
                    items: [
                        "Excluded directories shown in hierarchical map",
                        "Library dependencies extracted and summarized",
                        "File counts and sizes for context",
                        "Primary packages listed for reference"
                    ]
                )
            }

            Text("Result: 99.9% token reduction on irrelevant files while maintaining complete project context.")
                .padding()
                .background(theme.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
        }
    }

    private var aiModelsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI Model Optimization")
                .font(.title2)
                .fontWeight(.bold)

            Text("Different AI models have varying strengths and context limits. Trimbly optimizes compression for each:")
                .foregroundColor(.secondary)

            ForEach(AIModel.allCases, id: \.self) { model in
                aiModelCard(model: model)
            }
        }
    }

    private var bestPracticesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Best Practices")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                practiceSection(
                    title: "Before Processing",
                    items: [
                        "Review the preview to understand token impact",
                        "Choose semantic level based on your AI task",
                        "Enable Smart Auto-Exclusion for better efficiency",
                        "Check excluded directories to ensure nothing important is missed"
                    ]
                )

                practiceSection(
                    title: "During Processing",
                    items: [
                        "Monitor semantic accuracy in real-time",
                        "Watch for files that fail to process",
                        "Use cancellation if results don't meet expectations"
                    ]
                )

                practiceSection(
                    title: "After Processing",
                    items: [
                        "Review the hierarchical map for project overview",
                        "Check semantic accuracy against your needs",
                        "Generate error report if issues occurred",
                        "Adjust compression level for future runs"
                    ]
                )
            }
        }
    }

    private var useCasesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Common Use Cases")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                useCaseCard(
                    title: "Code Review & Debugging",
                    level: .medium,
                    description: "AI needs to understand logic and flow to identify bugs and suggest improvements.",
                    settings: "Medium level preserves all logic while removing human-oriented documentation."
                )

                useCaseCard(
                    title: "Architecture Analysis",
                    level: .aggressive,
                    description: "Understanding system design, component relationships, and patterns.",
                    settings: "Aggressive level focuses on structure, interfaces, and high-level flow."
                )

                useCaseCard(
                    title: "Claude Project Knowledge",
                    level: .maximum,
                    description: "Adding codebase overview to Claude's project knowledge for ongoing reference.",
                    settings: "Maximum level stays under 50k tokens with essential structure and APIs only."
                )

                useCaseCard(
                    title: "Migration Planning",
                    level: .aggressive,
                    description: "Understanding code patterns for language or framework migration.",
                    settings: "Aggressive level preserves logic patterns while reducing implementation details."
                )
            }
        }
    }

    private var troubleshootingContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Troubleshooting")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                troubleshootingItem(
                    problem: "Output too large for AI model",
                    solution: "Increase semantic compression level or enable more file exclusions"
                )

                troubleshootingItem(
                    problem: "Important files missing from output",
                    solution: "Check Smart Auto-Exclusion settings and excluded directories list"
                )

                troubleshootingItem(
                    problem: "Semantic accuracy too low",
                    solution: "Lower compression level - prioritize accuracy over token reduction"
                )

                troubleshootingItem(
                    problem: "Processing takes too long",
                    solution: "Enable more exclusions or process smaller directory subsets"
                )

                troubleshootingItem(
                    problem: "Files fail to process",
                    solution: "Check error report for specific issues and file permissions"
                )
            }
        }
    }

    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy Policy")
                .font(.title2)
                .fontWeight(.bold)

            Text("Trimbly operates entirely locally on your machine:")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                privacyItem(icon: "lock.fill", title: "No Data Transmission", description: "Your code never leaves your computer")
                privacyItem(icon: "eye.slash", title: "No Analytics", description: "No usage tracking or telemetry")
                privacyItem(icon: "server.rack", title: "No Cloud Processing", description: "All compression happens locally")
                privacyItem(icon: "folder.badge.minus", title: "No File Storage", description: "Processed files saved only where you choose")
            }
        }
    }

    private var faqContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Frequently Asked Questions")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                faqItem(
                    question: "What's the difference between semantic levels?",
                    answer: "Each level trades semantic accuracy for token reduction. Light preserves 100% accuracy, Medium <5% loss, Aggressive 10-20% loss, Maximum 70-80% loss for overview only."
                )

                faqItem(
                    question: "How accurate are token estimates?",
                    answer: "Within ±15% for most content. Different AI models tokenize slightly differently, so we provide conservative estimates."
                )

                faqItem(
                    question: "Why is Smart Auto-Exclusion recommended?",
                    answer: "Dependencies like node_modules can contain 50K+ files with zero semantic value. Smart exclusion provides 99.9% token savings while preserving project context."
                )

                faqItem(
                    question: "Can I undo compression?",
                    answer: "No - compression is lossy by design. Always keep your original files. Trimbly only saves compressed output to new files."
                )

                faqItem(
                    question: "Which level for Claude project knowledge?",
                    answer: "Use Maximum level. Claude's project knowledge has much stricter practical limits than its chat context window."
                )
            }
        }
    }

    // MARK: - Helper Components

    private func helpItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(theme.primaryAccent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func exclusionCategory(title: String, icon: String, color: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
    }

    private func aiModelCard(model: AIModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(model.rawValue)
                    .font(.headline)
                    .foregroundColor(theme.primaryAccent)

                Spacer()

                Text("\(model.contextWindow/1000)K context")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.primaryAccent.opacity(0.2))
                    .clipShape(Capsule())
            }

            if let guidance = KnowledgeBase.aiModelGuidance[model] {
                Text(guidance.compressionTips)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Recommended budget: \(guidance.recommendedTokenBudget) tokens")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
    }

    private func practiceSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.primaryAccent)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func useCaseCard(title: String, level: SemanticCompressionLevel, description: String, settings: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(level.color.opacity(0.2))
                    .foregroundColor(level.color)
                    .clipShape(Capsule())
            }

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(settings)
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(12)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
    }

    private func troubleshootingItem(problem: String, solution: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(theme.warning)
                Text(problem)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(theme.success)
                Text(solution)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
    }

    private func privacyItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(theme.success)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.primaryAccent)

            Text(answer)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
    }
}

struct SemanticLevelHelpCard: View {
    @Environment(\.theme) private var theme
    let level: SemanticCompressionLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundColor(level.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(level.color)

                    Text(level.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(level.tokenReduction)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(level.color)

                    Text("tokens")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("What it preserves:")
                    .font(.caption)
                    .fontWeight(.medium)

                let preservedItems = getPreservedItems(for: level)
                ForEach(preservedItems, id: \.self) { item in
                    Text("• \(item)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Text("Semantic Loss: \(level.semanticLoss)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(level.color.opacity(0.2))
                    .foregroundColor(level.color)
                    .clipShape(Capsule())

                Spacer()
            }
        }
        .padding(16)
        .background(level.color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.inputCornerRadius)
                .stroke(level.color.opacity(0.3), lineWidth: 1)
        )
    }

    private func getPreservedItems(for level: SemanticCompressionLevel) -> [String] {
        switch level {
        case .light:
            return [
                "100% code logic and semantics",
                "All function implementations",
                "All variable names and structure",
                "Language-specific syntax requirements"
            ]
        case .medium:
            return [
                "All code logic and flow",
                "Function signatures and implementations",
                "Critical type information",
                "API interfaces and contracts"
            ]
        case .aggressive:
            return [
                "Code structure and architecture",
                "Function signatures and control flow",
                "Public APIs and interfaces",
                "High-level implementation patterns"
            ]
        case .maximum:
            return [
                "Project structure overview",
                "Public API signatures only",
                "Dependency relationships",
                "High-level metrics and counts"
            ]
        }
    }
}
