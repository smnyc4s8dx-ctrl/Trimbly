//  JupyterNotebookOptimizer.swift
import Foundation

class JupyterNotebookOptimizer: LanguageOptimizer {

    // MARK: - Main Entry Point
    func optimizeCompression(_ code: String, options: CompressionOptions) -> CompressedResult {
        let originalTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        let processedContent = preserveLanguageSemantics(code, options: options)
        let compressedTokens = TokenCounter.countTokens(in: processedContent, using: options.tokenizerType)
        let semanticAccuracy = calculateSemanticAccuracy(options: options)
        let patterns = identifyCriticalPatterns(code)

        return CompressedResult(
            content: processedContent,
            originalTokens: originalTokens,
            compressedTokens: compressedTokens,
            semanticAccuracy: semanticAccuracy,
            preservedPatterns: patterns
        )
    }

    // MARK: - Core Compression Logic
    func preserveLanguageSemantics(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Step 1: Apply basic compression options first
        processed = applyBasicCompressionOptions(processed, options: options)

        // Step 2: Apply semantic level-specific compression
        processed = applySemanticLevelCompression(processed, options: options)

        // Step 3: Apply advanced compression options
        processed = applyAdvancedCompressionOptions(processed, options: options)

        return processed
    }

    // MARK: - Basic Compression Options
    private func applyBasicCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeComments {
            processed = removeJupyterComments(processed)
        }

        if options.removeWhitespace {
            processed = removeExcessWhitespace(processed, options: options)
        }

        if options.removeEmptyLines {
            processed = removeEmptyLines(processed, options: options)
        }

        if options.removeImports {
            processed = removeImportStatements(processed, options: options)
        }

        if options.removeDocumentation {
            processed = removeDocumentation(processed, options: options)
        }

        if options.removeDebugStatements {
            processed = removeDebugStatements(processed)
        }

        return processed
    }

    // MARK: - Semantic Level Compression
    private func applySemanticLevelCompression(_ code: String, options: CompressionOptions) -> String {
        switch options.semanticLevel {
        case .light:
            return preserveJupyterStructure(code, options: options)
        case .medium:
            return preserveJupyterLogic(code, options: options)
        case .aggressive:
            return preserveJupyterArchitecture(code, options: options)
        case .maximum:
            return extractJupyterSignatures(code, options: options)
        }
    }

    // MARK: - Advanced Compression Options
    private func applyAdvancedCompressionOptions(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if options.removeTypeAnnotations {
            processed = removeTypeAnnotations(processed, options: options)
        }

        if options.truncateFunctions {
            processed = truncateFunctionBodies(processed, options: options)
        }

        if options.shortenIdentifiers {
            processed = shortenIdentifiers(processed, options: options)
        }

        if options.signaturesOnly {
            processed = extractSignaturesOnly(processed, options: options)
        }

        if options.structureOnly {
            processed = extractStructureOnly(processed, options: options)
        }

        // Apply file size limits if specified
        if let maxLines = options.maxLinesPerFile {
            processed = limitFileLines(processed, maxLines: maxLines, options: options)
        }

        if let maxTokens = options.maxTokensPerFile {
            processed = limitFileTokens(processed, maxTokens: maxTokens, options: options)
        }

        return processed
    }

    // MARK: - Jupyter-Specific Implementation Methods

    private func removeJupyterComments(_ code: String) -> String {
        var processed = code

        // Remove Python comments but preserve magic commands and special comments
        processed = processed.replacingOccurrences(
            of: #"#(?!\s*(?:TODO|FIXME|NOTE|IMPORTANT|%|!))(?!.*CELL)[^\n]*"#,
            with: "",
            options: .regularExpression
        )

        // Handle notebook JSON structure - remove comment cells if present
        if let data = code.data(using: .utf8),
           var notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           var cells = notebook["cells"] as? [[String: Any]] {

            for i in 0..<cells.count {
                if cells[i]["cell_type"] as? String == "code",
                   var source = cells[i]["source"] as? [String] {
                    source = source.map { line in
                        line.replacingOccurrences(
                            of: #"#(?!\s*(?:TODO|FIXME|NOTE|IMPORTANT|%|!))[^\n]*"#,
                            with: "",
                            options: .regularExpression
                        )
                    }
                    cells[i]["source"] = source
                }
            }

            notebook["cells"] = cells

            if let compressedData = try? JSONSerialization.data(withJSONObject: notebook, options: .prettyPrinted),
               let compressedString = String(data: compressedData, encoding: .utf8) {
                return compressedString
            }
        }

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Python preserves significant whitespace - only remove trailing whitespace
        if options.preserveSignificantWhitespace {
            processed = processed.replacingOccurrences(
                of: #"[ \t]+$"#,
                with: "",
                options: [.regularExpression]
            )
        } else {
            processed = processed.replacingOccurrences(
                of: #"\n\s*\n\s*\n+"#,
                with: "\n\n",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        // For Jupyter notebooks, preserve some empty lines for readability
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Preserve critical data science imports if prioritizing public APIs
        if options.prioritizePublicAPIs {
            let criticalImports = extractCriticalImports(code)
            var preservedImports: [String: String] = [:]

            for (index, importStatement) in criticalImports.enumerated() {
                let placeholder = "/* PRESERVED_IMPORT_\(index) */"
                preservedImports[placeholder] = importStatement
                processed = processed.replacingOccurrences(of: importStatement, with: placeholder)
            }

            // Remove remaining imports
            processed = removeStandardImports(processed)

            // Restore critical imports
            for (placeholder, importStatement) in preservedImports {
                processed = processed.replacingOccurrences(of: placeholder, with: importStatement)
            }
        } else {
            processed = removeStandardImports(processed)
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove markdown cells in notebooks if not prioritizing documentation
        if let data = code.data(using: .utf8),
           var notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {

            let filteredCells = cells.filter { cell in
                guard let cellType = cell["cell_type"] as? String else { return true }

                if cellType == "markdown" && !options.prioritizePublicAPIs {
                    if let source = cell["source"] as? [String] {
                        let content = source.joined(separator: "").lowercased()
                        // Keep headers and important documentation
                        return content.hasPrefix("#") ||
                               content.contains("important") ||
                               content.contains("note:") ||
                               content.contains("analysis") ||
                               content.contains("result")
                    }
                    return false
                }
                return true
            }

            notebook["cells"] = filteredCells

            if let compressedData = try? JSONSerialization.data(withJSONObject: notebook, options: .prettyPrinted),
               let compressedString = String(data: compressedData, encoding: .utf8) {
                return compressedString
            }
        }

        // Remove Python docstrings
        processed = processed.replacingOccurrences(
            of: #"\"\"\"[\s\S]*?\"\"\""#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Jupyter-specific debug patterns
        let debugPatterns = [
            #"print\([^)]*\)"#,                    // Print statements
            #"display\([^)]*\)"#,                  // IPython display
            #"\.head\(\s*\d*\s*\)"#,               // DataFrame head for inspection
            #"\.tail\(\s*\d*\s*\)"#,               // DataFrame tail for inspection
            #"\.info\(\s*\)"#,                     // DataFrame info
            #"\.describe\(\s*\)"#,                 // DataFrame describe (keep for analysis)
            #"\.shape(?!\s*\[)"#,                  // Shape inspection
            #"len\([^)]*\)"#,                      // Length checks
            #"type\([^)]*\)"#,                     // Type checking
            #"\.dtype(?:s)?"#,                     // Data type inspection
        ]

        for pattern in debugPatterns {
            processed = processed.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeTypeAnnotations(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Python type hints removal (keep if prioritizing APIs)
        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #":\s*(?:int|float|str|bool|list|dict|tuple|set|Union|Optional|List|Dict|Tuple|Set)\s*(?=\s*[=,\)])"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical data science patterns first
        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate function bodies
        processed = processed.replacingOccurrences(
            of: #"(def\s+\w+\([^)]*\)[^:]*:)[\s\S]*?(?=\n(?:\s*def|\s*class|\s*$|\Z))"#,
            with: "$1\n    # implementation",
            options: .regularExpression
        )

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func shortenIdentifiers(_ code: String, options: CompressionOptions) -> String {
        var processed = code
        var identifierMap: [String: String] = [:]
        var counter = 1

        // Extract identifiers and create mapping
        let identifierPattern = #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    // Don't shorten critical data science identifiers
                    if !isCriticalDataScienceIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "v\(counter)"
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in identifier shortening: \(error)")
        }

        // Apply identifier mapping
        for (original, shortened) in identifierMap {
            processed = processed.replacingOccurrences(
                of: "\\b\(NSRegularExpression.escapedPattern(for: original))\\b",
                with: shortened,
                options: .regularExpression
            )
        }

        return processed
    }

    private func extractSignaturesOnly(_ code: String, options: CompressionOptions) -> String {
        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {

            var signatures: [String] = []

            for (index, cell) in cells.enumerated() {
                if let cellType = cell["cell_type"] as? String,
                   cellType == "code",
                   let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    let cellSignatures = extractCodeSignatures(content)
                    if !cellSignatures.isEmpty {
                        signatures.append("# CELL \(index)")
                        signatures.append(cellSignatures)
                    }
                }
            }

            return signatures.joined(separator: "\n")
        }

        return extractCodeSignatures(code)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        // Return high-level metrics and structure for Jupyter notebooks
        let metrics = calculateJupyterMetrics(code)
        let structure = extractJupyterStructure(code, options: options)

        return formatJupyterStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveJupyterStructure(_ code: String, options: CompressionOptions) -> String {
        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {
            return preserveNotebookCells(cells, compressionLevel: .light)
        }

        // Handle as plain Python code
        return removeExcessiveWhitespace(code)
    }

    private func preserveJupyterLogic(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {
            return preserveNotebookLogic(cells)
        }

        // Handle as plain Python code with pattern preservation
        let allPatterns = [
            extractDataLoading(code),
            extractAnalysisPatterns(code),
            extractVisualizationPatterns(code),
            extractModelingPatterns(code),
            extractCriticalImports(code),
            extractDataTransformation(code)
        ].flatMap { $0 }

        // Preserve patterns using placeholders
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in allPatterns.enumerated() {
            let placeholder = "# JUPYTER_PATTERN_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Remove excessive outputs and debug prints
        processed = compressOutputs(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveJupyterArchitecture(_ code: String, options: CompressionOptions) -> String {
        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {
            return preserveNotebookArchitecture(cells)
        }

        return preserveCodeArchitecture(code)
    }

    private func extractJupyterSignatures(_ code: String, options: CompressionOptions) -> String {
        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {

            var signatures: [String] = []

            for (index, cell) in cells.enumerated() {
                guard let cellType = cell["cell_type"] as? String else { continue }

                if cellType == "code" {
                    if let source = cell["source"] as? [String] {
                        let content = source.joined(separator: "")
                        let essential = extractEssentialCode(content)
                        if !essential.isEmpty {
                            signatures.append("# CELL \(index): \(essential)")
                        }
                    }
                }
            }

            return signatures.joined(separator: "\n")
        }

        return extractEssentialCode(code)
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let dataLoading = extractDataLoading(code)
        patterns.append(contentsOf: dataLoading.map { .lifecycle($0) })

        let analysis = extractAnalysisPatterns(code)
        patterns.append(contentsOf: analysis.map { .macro($0) })

        let visualization = extractVisualizationPatterns(code)
        patterns.append(contentsOf: visualization.map { .interface($0) })

        let modeling = extractModelingPatterns(code)
        patterns.append(contentsOf: modeling.map { .trait($0) })

        let imports = extractCriticalImports(code)
        patterns.append(contentsOf: imports.map { .trait($0) })

        let dataTransformation = extractDataTransformation(code)
        patterns.append(contentsOf: dataTransformation.map { .macro($0) })

        return patterns
    }

    // MARK: - Enhanced Pattern Extraction

    private func extractDataLoading(_ code: String) -> [String] {
        let patterns = [
            #"pd\.read_(?:csv|json|excel|sql|parquet|hdf|feather|pickle|table|clipboard|html)\([^)]+\)"#,  // Pandas readers
            #"np\.load(?:txt|z)?\([^)]+\)"#,  // NumPy loaders
            #"(?:import|from)\s+(?:pandas|numpy|scipy|sklearn|matplotlib|seaborn|plotly|torch|tensorflow)(?:\s+as\s+\w+)?"#,  // Critical imports
            #"\.load_dataset\([^)]+\)"#,  // HuggingFace datasets
            #"torch\.load\([^)]+\)"#,  // PyTorch model loading
            #"joblib\.load\([^)]+\)"#,  // Joblib loading
            #"pickle\.load\([^)]+\)"#,  // Pickle loading
            #"with\s+open\([^)]+\)\s+as\s+\w+:"#,  // File reading contexts
            #"requests\.get\([^)]+\)"#,  // API data loading
            #"urllib\.request\.urlopen\([^)]+\)"#,  // URL data loading
            #"sqlalchemy\.create_engine\([^)]+\)"#,  // Database connections
            #"pymongo\.MongoClient\([^)]+\)"#,  // MongoDB connections
            #"redis\.Redis\([^)]+\)"#  // Redis connections
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractAnalysisPatterns(_ code: String) -> [String] {
        let patterns = [
            #"\.groupby\([^)]+\)\.(?:agg|sum|mean|count|max|min|std|var|median|quantile|size|nunique)\([^)]*\)"#,  // Groupby operations
            #"\.merge\([^)]+\)"#,  // DataFrame merging
            #"\.join\([^)]+\)"#,  // DataFrame joining
            #"\.concat\([^)]+\)"#,  // DataFrame concatenation
            #"\.pivot_table\([^)]+\)"#,  // Pivot tables
            #"\.pivot\([^)]+\)"#,  // Pivot operations
            #"\.melt\([^)]+\)"#,  // Melting operations
            #"\.apply\([^)]+\)"#,  // Apply functions
            #"\.map\([^)]+\)"#,  // Map functions
            #"\.transform\([^)]+\)"#,  // Transform functions
            #"\.filter\([^)]+\)"#,  // Filter operations
            #"\.query\([^)]+\)"#,  // Query operations
            #"\.sort_values\([^)]+\)"#,  // Sorting
            #"\.sort_index\([^)]+\)"#,  // Index sorting
            #"\.dropna\([^)]*\)"#,  // Drop missing values
            #"\.fillna\([^)]+\)"#,  // Fill missing values
            #"\.drop_duplicates\([^)]*\)"#,  // Remove duplicates
            #"\.reset_index\([^)]*\)"#,  // Reset index
            #"\.set_index\([^)]+\)"#,  // Set index
            #"sklearn\.preprocessing\.\w+\([^)]*\)"#,  // Preprocessing
            #"\.fit_transform\([^)]+\)"#,  // Fit and transform
            #"\.value_counts\([^)]*\)"#,  // Value counting
            #"\.describe\([^)]*\)"#,  // Statistical description
            #"\.corr\([^)]*\)"#,  // Correlation analysis
            #"\.cov\([^)]*\)"#  // Covariance analysis
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractVisualizationPatterns(_ code: String) -> [String] {
        let patterns = [
            #"plt\.(?:plot|scatter|bar|barh|hist|boxplot|violinplot|heatmap|imshow|contour|pie|polar)\([^)]*\)"#,  // Matplotlib plots
            #"sns\.(?:scatterplot|lineplot|barplot|countplot|histplot|boxplot|violinplot|heatmap|clustermap|pairplot|jointplot|distplot|regplot|lmplot|catplot|relplot|displot|facetgrid)\([^)]*\)"#,  // Seaborn plots
            #"plt\.(?:xlabel|ylabel|title|legend|grid|tight_layout|subplots_adjust|figsize)\([^)]*\)"#,  // Plot customization
            #"plt\.(?:show|savefig|close)\([^)]*\)"#,  // Plot display/save
            #"fig,\s*ax(?:es)?\s*=\s*plt\.subplots\([^)]*\)"#,  // Subplot creation
            #"\.plot\([^)]*\)"#,  // DataFrame plotting
            #"plotly\.(?:express|graph_objects)\.\w+\([^)]*\)"#,  // Plotly visualizations
            #"go\.(?:Scatter|Bar|Histogram|Box|Violin|Heatmap|Surface|Mesh3d)\([^)]*\)"#,  // Plotly graph objects
            #"alt\.Chart\([^)]*\)"#,  // Altair charts
            #"bokeh\.plotting\.\w+\([^)]*\)"#,  // Bokeh plotting
            #"holoviews\.\w+\([^)]*\)"#,  // HoloViews
            #"dash\.\w+\([^)]*\)"#  // Dash components
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractModelingPatterns(_ code: String) -> [String] {
        let patterns = [
            #"(?:Linear|Logistic|Ridge|Lasso|ElasticNet)Regression\([^)]*\)"#,  // Linear models
            #"Random(?:Forest|)(?:Classifier|Regressor)\([^)]*\)"#,  // Tree models
            #"(?:SVM|SVC|SVR|LinearSVC|LinearSVR)\([^)]*\)"#,  // Support vector models
            #"(?:KMeans|DBSCAN|AgglomerativeClustering|SpectralClustering)\([^)]*\)"#,  // Clustering
            #"(?:PCA|TruncatedSVD|FastICA|FactorAnalysis)\([^)]*\)"#,  // Dimensionality reduction
            #"(?:GradientBoosting|XGBoost|LightGBM|CatBoost)(?:Classifier|Regressor)?\([^)]*\)"#,  // Boosting models
            #"(?:KNeighbors|Radius(?:Neighbors)?)(?:Classifier|Regressor)\([^)]*\)"#,  // Nearest neighbors
            #"(?:GaussianNB|MultinomialNB|BernoulliNB)\([^)]*\)"#,  // Naive Bayes
            #"\.fit\([^)]+\)"#,  // Model fitting
            #"\.predict\([^)]+\)"#,  // Predictions
            #"\.predict_proba\([^)]+\)"#,  // Probability predictions
            #"\.score\([^)]+\)"#,  // Model scoring
            #"\.transform\([^)]+\)"#,  // Data transformation
            #"train_test_split\([^)]+\)"#,  // Data splitting
            #"cross_val_score\([^)]+\)"#,  // Cross validation
            #"GridSearchCV\([^)]+\)"#,  // Hyperparameter tuning
            #"RandomizedSearchCV\([^)]+\)"#,  // Random search
            #"Pipeline\([^)]+\)"#,  // ML pipelines
            #"torch\.nn\.\w+\([^)]*\)"#,  // PyTorch neural networks
            #"tf\.keras\.(?:layers|models)\.\w+\([^)]*\)"#,  // TensorFlow/Keras
            #"model\.(?:compile|fit|evaluate|predict)\([^)]*\)"#,  // Keras model methods
            #"optim\.\w+\([^)]*\)"#,  // Optimizers
            #"nn\.(?:functional\.)?\w+\([^)]*\)"#  // Neural network functions
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        let patterns = [
            #"(?:import|from)\s+(?:pandas|numpy|scipy|sklearn|matplotlib|seaborn|plotly|torch|tensorflow|keras)(?:\s+as\s+\w+)?(?:\s*\n|$)"#,  // Core data science imports
            #"(?:import|from)\s+(?:warnings|sys|os|re|json|pickle|joblib)(?:\s+as\s+\w+)?(?:\s*\n|$)"#,  // Utility imports
            #"from\s+sklearn\.\w+\s+import\s+[^\n]+"#,  // Scikit-learn specific imports
            #"from\s+torch\.\w+\s+import\s+[^\n]+"#,  // PyTorch specific imports
            #"from\s+tensorflow\.\w+\s+import\s+[^\n]+"#,  // TensorFlow specific imports
            #"%(?:matplotlib|config|load_ext|run|time|timeit|who|whos|reset)\s*[^\n]*"#  // Magic commands
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractDataTransformation(_ code: String) -> [String] {
        let patterns = [
            #"pd\.get_dummies\([^)]+\)"#,  // One-hot encoding
            #"pd\.cut\([^)]+\)"#,  // Binning
            #"pd\.qcut\([^)]+\)"#,  // Quantile binning
            #"pd\.to_datetime\([^)]+\)"#,  // Date conversion
            #"pd\.to_numeric\([^)]+\)"#,  // Numeric conversion
            #"\.astype\([^)]+\)"#,  // Type conversion
            #"\.str\.\w+\([^)]*\)"#,  // String operations
            #"\.dt\.\w+(?:\([^)]*\))?"#,  // Datetime operations
            #"\.cat\.\w+\([^)]*\)"#,  // Categorical operations
            #"StandardScaler\([^)]*\)"#,  // Standard scaling
            #"MinMaxScaler\([^)]*\)"#,  // Min-max scaling
            #"RobustScaler\([^)]*\)"#,  // Robust scaling
            #"LabelEncoder\([^)]*\)"#,  // Label encoding
            #"OneHotEncoder\([^)]*\)"#,  // One-hot encoding
            #"SimpleImputer\([^)]*\)"#,  // Missing value imputation
            #"PolynomialFeatures\([^)]*\)"#  // Feature engineering
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return true  // Python preserves significant whitespace
    }

    private func removeStandardImports(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"(?:import|from)\s+(?!(?:pandas|numpy|scipy|sklearn|matplotlib|seaborn|plotly|torch|tensorflow|keras))[^\n]+\n?"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract data science patterns that should be preserved even when truncating functions
        return [
            extractDataLoading(code),
            extractAnalysisPatterns(code),
            extractModelingPatterns(code),
            extractVisualizationPatterns(code)
        ].flatMap { $0 }
    }

    private func isCriticalDataScienceIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        let criticalIdentifiers = [
            "pd", "np", "plt", "sns", "df", "X", "y", "model", "scaler",
            "train", "test", "fit", "predict", "transform", "data", "target",
            "features", "labels", "score", "accuracy", "precision", "recall"
        ]

        return criticalIdentifiers.contains(identifier) ||
               identifier.count <= 2 ||  // Keep short variable names
               options.prioritizePublicAPIs
    }

    private func extractCodeSignatures(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("def ") ||
               trimmed.hasPrefix("class ") ||
               trimmed.hasPrefix("import ") ||
               trimmed.hasPrefix("from ") ||
               containsCriticalPattern(trimmed) {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        // Prioritize important lines if specified
        if options.prioritizeTopLevel {
            return prioritizeTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        // Iteratively remove content until under token limit
        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        // Prioritize imports, function definitions, and critical data science operations
        var prioritized: [String] = []
        var others: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") ||
               trimmed.hasPrefix("from ") ||
               trimmed.hasPrefix("def ") ||
               trimmed.hasPrefix("class ") ||
               containsCriticalPattern(trimmed) {
                prioritized.append(line)
            } else {
                others.append(line)
            }
        }

        let remainingLines = maxLines - prioritized.count
        if remainingLines > 0 {
            prioritized.append(contentsOf: Array(others.prefix(remainingLines)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        var currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)

        // Step 1: Remove outputs first
        if currentTokens > maxTokens {
            processed = compressOutputs(processed)
            currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        }

        // Step 2: Remove less critical cells
        if currentTokens > maxTokens {
            processed = removeLessCriticalCells(processed)
            currentTokens = TokenCounter.countTokens(in: processed, using: options.tokenizerType)
        }

        // Step 3: Truncate remaining content
        if currentTokens > maxTokens {
            let lines = processed.components(separatedBy: .newlines)
            let targetLines = Int(Double(lines.count) * Double(maxTokens) / Double(currentTokens))
            processed = prioritizeTopLevelLines(lines, maxLines: targetLines)
        }

        return processed
    }

    private func removeLessCriticalCells(_ code: String) -> String {
        if let data = code.data(using: .utf8),
           var notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {

            let filteredCells = cells.filter { cell in
                guard let cellType = cell["cell_type"] as? String else { return true }

                if cellType == "code" {
                    if let source = cell["source"] as? [String] {
                        let content = source.joined(separator: "")
                        return containsCriticalPattern(content)
                    }
                    return false // Remove code cells without source
                }

                return cellType != "code"  // Keep non-code cells for now
            }

            notebook["cells"] = filteredCells

            if let compressedData = try? JSONSerialization.data(withJSONObject: notebook, options: .prettyPrinted),
               let compressedString = String(data: compressedData, encoding: .utf8) {
                return compressedString
            }
        }

        return code
    }

    private func calculateJupyterMetrics(_ code: String) -> [String: Any] {
        var metrics: [String: Any] = [:]

        if let data = code.data(using: .utf8),
           let notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let cells = notebook["cells"] as? [[String: Any]] {

            var codeCells = 0
            var markdownCells = 0
            var totalLines = 0

            for cell in cells {
                if let cellType = cell["cell_type"] as? String {
                    switch cellType {
                    case "code":
                        codeCells += 1
                        if let source = cell["source"] as? [String] {
                            totalLines += source.count
                        }
                    case "markdown":
                        markdownCells += 1
                    default:
                        break
                    }
                }
            }

            metrics["codeCells"] = codeCells
            metrics["markdownCells"] = markdownCells
            metrics["totalLines"] = totalLines
        }

        return metrics
    }

    private func extractJupyterStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        var structure: [String: Any] = [:]

        let patterns = identifyCriticalPatterns(code)
        structure["criticalPatterns"] = patterns.count
        structure["dataLoading"] = extractDataLoading(code).count
        structure["analysis"] = extractAnalysisPatterns(code).count
        structure["visualization"] = extractVisualizationPatterns(code).count
        structure["modeling"] = extractModelingPatterns(code).count

        return structure
    }

    private func formatJupyterStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var output: [String] = []

        output.append("# Jupyter Notebook Structure")

        if let codeCells = metrics["codeCells"] as? Int {
            output.append("Code Cells: \(codeCells)")
        }

        if let markdownCells = metrics["markdownCells"] as? Int {
            output.append("Markdown Cells: \(markdownCells)")
        }

        if let dataLoading = structure["dataLoading"] as? Int {
            output.append("Data Loading Operations: \(dataLoading)")
        }

        if let analysis = structure["analysis"] as? Int {
            output.append("Analysis Operations: \(analysis)")
        }

        if let visualization = structure["visualization"] as? Int {
            output.append("Visualization Operations: \(visualization)")
        }

        if let modeling = structure["modeling"] as? Int {
            output.append("Modeling Operations: \(modeling)")
        }

        return output.joined(separator: "\n")
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.95    // Preserves all notebook structure and code
        case .medium: return 0.87   // Removes outputs, preserves analysis logic
        case .aggressive: return 0.78  // Compresses to essential data science patterns
        case .maximum: return 0.56  // Overview of workflow only
        }
    }

    private func extractPatternMatches(_ code: String, patterns: [String]) -> [String] {
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    // MARK: - Existing Helper Methods (preserved from original implementation)

    private func preserveNotebookCells(_ cells: [[String: Any]], compressionLevel: SemanticCompressionLevel) -> String {
        var result: [String] = []

        for (index, cell) in cells.enumerated() {
            guard let cellType = cell["cell_type"] as? String else { continue }

            switch cellType {
            case "markdown":
                if let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    if shouldIncludeMarkdown(content, level: compressionLevel) {
                        result.append("# MARKDOWN CELL \(index)")
                        result.append(content)
                    }
                }
            case "code":
                if let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    if shouldIncludeCode(content, level: compressionLevel) {
                        result.append("# CODE CELL \(index)")
                        result.append(compressCodeCell(content, level: compressionLevel))

                        if compressionLevel == .light {
                            if let executionCount = cell["execution_count"] as? Int {
                                result.append("# Execution: \(executionCount)")
                            }
                            if let outputs = cell["outputs"] as? [[String: Any]], !outputs.isEmpty {
                                result.append("# Output: \(outputs.count) items")
                            }
                        }
                    }
                }
            case "raw":
                if compressionLevel == .light {
                    if let source = cell["source"] as? [String] {
                        let content = source.joined(separator: "")
                        result.append("# RAW CELL \(index)")
                        result.append(content)
                    }
                }
            default:
                break
            }
        }

        return result.joined(separator: "\n\n")
    }

    private func shouldIncludeMarkdown(_ content: String, level: SemanticCompressionLevel) -> Bool {
        switch level {
        case .light: return true
        case .medium:
            let analysisKeywords = ["analysis", "model", "data", "result", "conclusion", "hypothesis", "method", "approach"]
            return analysisKeywords.contains { keyword in
                content.lowercased().contains(keyword)
            }
        case .aggressive, .maximum:
            return content.hasPrefix("#") || content.lowercased().contains("important") || content.lowercased().contains("note:")
        }
    }

    private func shouldIncludeCode(_ content: String, level: SemanticCompressionLevel) -> Bool {
        switch level {
        case .light: return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .medium, .aggressive, .maximum:
            return containsCriticalPattern(content)
        }
    }

    private func compressCodeCell(_ content: String, level: SemanticCompressionLevel) -> String {
        switch level {
        case .light: return content
        case .medium: return removeComments(content)
        case .aggressive: return compressImplementation(content)
        case .maximum: return extractCriticalLines(content)
        }
    }

    private func preserveNotebookLogic(_ cells: [[String: Any]]) -> String {
        var result: [String] = []

        for (index, cell) in cells.enumerated() {
            guard let cellType = cell["cell_type"] as? String else { continue }

            switch cellType {
            case "markdown":
                if let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    if shouldIncludeMarkdown(content, level: .medium) {
                        result.append("# MARKDOWN CELL \(index)")
                        result.append(content)
                    }
                }
            case "code":
                if let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    if containsCriticalPattern(content) {
                        result.append("# CODE CELL \(index)")
                        result.append(compressCodeCell(content, level: .medium))
                    }
                }
            default:
                break
            }
        }

        return result.joined(separator: "\n\n")
    }

    private func preserveNotebookArchitecture(_ cells: [[String: Any]]) -> String {
        var result: [String] = []

        for (index, cell) in cells.enumerated() {
            guard let cellType = cell["cell_type"] as? String else { continue }

            if cellType == "code" {
                if let source = cell["source"] as? [String] {
                    let content = source.joined(separator: "")
                    if containsCriticalPattern(content) {
                        result.append("# CODE CELL \(index)")
                        result.append(compressCodeCell(content, level: .aggressive))
                    }
                }
            }
        }

        return result.joined(separator: "\n\n")
    }

    private func containsCriticalPattern(_ content: String) -> Bool {
        let criticalPatterns = [
            "import", "from", "pd.read", "np.load", ".fit(", ".predict(",
            "plt.", "sns.", ".groupby", ".merge", ".apply", "train_test_split",
            "sklearn", "torch", "tensorflow", "keras"
        ]
        return criticalPatterns.contains { content.contains($0) }
    }

    private func removeComments(_ content: String) -> String {
        return content.replacingOccurrences(
            of: #"#(?!\s*(?:TODO|FIXME|NOTE|IMPORTANT))[^\n]*"#,
            with: "",
            options: .regularExpression
        )
    }

    private func compressImplementation(_ content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if containsCriticalPattern(trimmed) ||
               trimmed.hasPrefix("def ") ||
               trimmed.hasPrefix("class ") ||
               trimmed.contains("=") && !trimmed.hasPrefix("#") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    private func extractCriticalLines(_ content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") || trimmed.hasPrefix("from ") {
                result.append("import ...")
            } else if trimmed.contains("pd.read") || trimmed.contains("np.load") {
                result.append("data_load")
            } else if trimmed.contains(".fit(") {
                result.append("model_train")
            } else if trimmed.contains(".predict(") {
                result.append("model_predict")
            } else if trimmed.contains("plt.") || trimmed.contains("sns.") {
                result.append("visualization")
            } else if trimmed.contains(".groupby") || trimmed.contains(".agg") {
                result.append("analysis")
            }
        }

        return result.joined(separator: ", ")
    }

    private func preserveCodeArchitecture(_ code: String) -> String {
        var processed = code

        // Extract architectural patterns (imports, data loading, modeling)
        let architecturalPatterns = [
            extractCriticalImports(code),
            extractDataLoading(code),
            extractModelingPatterns(code),
            extractCriticalVisualization(code)
        ].flatMap { $0 }

        // Preserve architectural patterns
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "# ARCH_\(index)"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Compress implementation details
        processed = compressImplementation(processed)

        // Restore architectural patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractCriticalVisualization(_ code: String) -> [String] {
        // Only extract essential visualization patterns
        let patterns = [
            #"plt\.(?:plot|scatter|hist|boxplot)\([^)]*\)"#,  // Basic plots
            #"sns\.(?:scatterplot|histplot|boxplot|heatmap)\([^)]*\)"#,  // Essential seaborn
            #"plt\.(?:xlabel|ylabel|title)\([^)]*\)"#,  // Labels
            #"plt\.show\(\)"#  // Display
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func compressOutputs(_ code: String) -> String {
        if let data = code.data(using: .utf8),
           var notebook = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           var cells = notebook["cells"] as? [[String: Any]] {

            for i in 0..<cells.count {
                if cells[i]["cell_type"] as? String == "code" {
                    cells[i]["outputs"] = []
                    cells[i]["execution_count"] = NSNull()
                }
            }

            notebook["cells"] = cells

            if let compressedData = try? JSONSerialization.data(withJSONObject: notebook, options: .prettyPrinted),
               let compressedString = String(data: compressedData, encoding: .utf8) {
                return compressedString
            }
        }

        // For plain Python code, remove print statements and debug output
        return code.replacingOccurrences(
            of: #"print\([^)]*\)\s*\n?"#,
            with: "",
            options: .regularExpression
        )
    }

    private func extractEssentialCode(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        var essential: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("import ") || trimmed.hasPrefix("from ") {
                essential.append("import")
            } else if trimmed.contains("pd.read") || trimmed.contains("np.load") {
                essential.append("data_load")
            } else if trimmed.contains(".fit(") {
                essential.append("model_train")
            } else if trimmed.contains(".predict(") {
                essential.append("model_predict")
            } else if trimmed.contains("plt.") || trimmed.contains("sns.") {
                essential.append("visualization")
            } else if trimmed.contains(".groupby") || trimmed.contains(".agg") {
                essential.append("analysis")
            } else if trimmed.contains("def ") {
                essential.append("function")
            } else if trimmed.contains("class ") {
                essential.append("class")
            }
        }

        return essential.joined(separator: ", ")
    }

    private func removeExcessiveWhitespace(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )
    }
}
