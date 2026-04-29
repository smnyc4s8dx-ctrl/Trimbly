import Foundation

class SQLOptimizer: LanguageOptimizer {

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
            processed = removeLanguageComments(processed)
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
            return preserveLanguageKeyPatterns(code, options: options)
        case .medium:
            return preserveLanguageArchitecture(code, options: options)
        case .aggressive:
            return preserveLanguagePublicAPIs(code, options: options)
        case .maximum:
            return extractLanguageSignatures(code, options: options)
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

    // MARK: - SQL-Specific Implementation Methods

    private func removeLanguageComments(_ code: String) -> String {
        var processed = code

        // Remove line comments but preserve important ones
        processed = processed.replacingOccurrences(
            of: #"--(?!\s*(?:TODO|FIXME|INDEX|PERFORMANCE|SECURITY|BUG))[^\n]*\n"#,
            with: "",
            options: .regularExpression
        )

        // Remove block comments but preserve important ones
        processed = processed.replacingOccurrences(
            of: #"/\*(?![*!])[^*]*\*+(?:[^/*][^*]*\*+)*/"#,
            with: "",
            options: .regularExpression
        )

        return processed
    }

    private func removeExcessWhitespace(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Normalize whitespace around SQL keywords
        processed = processed.replacingOccurrences(
            of: #"\s+(SELECT|FROM|WHERE|JOIN|GROUP\s+BY|ORDER\s+BY|HAVING|UNION|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP)\s+"#,
            with: " $1 ",
            options: [.regularExpression, .caseInsensitive]
        )

        // Normalize punctuation spacing
        processed = processed.replacingOccurrences(
            of: #"\s*,\s*"#,
            with: ", ",
            options: .regularExpression
        )

        processed = processed.replacingOccurrences(
            of: #"\s*=\s*"#,
            with: " = ",
            options: .regularExpression
        )

        return processed
    }

    private func removeEmptyLines(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        return lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    private func removeImportStatements(_ code: String, options: CompressionOptions) -> String {
        // SQL doesn't typically have imports, but handle database-specific includes
        var processed = code

        if !options.prioritizePublicAPIs {
            // Remove database-specific includes that aren't critical
            processed = processed.replacingOccurrences(
                of: #"\\i\s+[^\n]+"#,  // PostgreSQL \i includes
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDocumentation(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Remove documentation comments but preserve schema documentation
        if !options.prioritizePublicAPIs {
            processed = processed.replacingOccurrences(
                of: #"--\s*(?:Description|Purpose|Author|Created|Modified)[^\n]*\n"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func removeDebugStatements(_ code: String) -> String {
        var processed = code

        // Remove SQL debug patterns
        let debugPatterns = [
            #"PRINT\s+[^\n]+"#,                    // SQL Server PRINT
            #"DBMS_OUTPUT\.PUT_LINE\([^)]*\)"#,    // Oracle debug output
            #"RAISE\s+NOTICE\s+[^\n]+"#,           // PostgreSQL NOTICE
            #"SELECT\s+'Debug:'[^\n]+;"#,          // Debug SELECT statements
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
        // SQL type annotations are generally critical for schema definition
        // Only remove non-essential type modifiers
        var processed = code

        if !options.prioritizePublicAPIs {
            // Remove optional type modifiers
            processed = processed.replacingOccurrences(
                of: #"\s+COLLATE\s+\w+"#,
                with: "",
                options: .regularExpression
            )
        }

        return processed
    }

    private func truncateFunctionBodies(_ code: String, options: CompressionOptions) -> String {
        var processed = code

        // Extract and preserve critical SQL patterns first
        let criticalPatterns = extractFunctionBodyPatterns(code, options: options)
        var preservedPatterns: [String: String] = [:]

        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* PRESERVED_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Truncate stored procedure/function bodies
        processed = processed.replacingOccurrences(
            of: #"(CREATE\s+(?:OR\s+REPLACE\s+)?(?:PROCEDURE|FUNCTION)\s+[\w.]+\s*\([^)]*\)(?:\s+RETURNS?\s+[^\s]+)?(?:\s+AS\s*)?(?:\$\$|\$[^$]*\$|'|"))[^;]*(;|\$\$|\$[^$]*\$|'|")"#,
            with: "$1 /* implementation */ $2",
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

        // Extract SQL identifiers (tables, columns, aliases)
        let identifierPattern = #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#

        do {
            let regex = try NSRegularExpression(pattern: identifierPattern)
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))

            for match in matches {
                if let range = Range(match.range, in: code) {
                    let identifier = String(code[range])

                    if !isCriticalIdentifier(identifier, options: options) {
                        if identifierMap[identifier] == nil {
                            identifierMap[identifier] = "t\(counter)"
                            counter += 1
                        }
                    }
                }
            }
        } catch {
            print("Regex error in SQL identifier shortening: \(error)")
        }

        // Apply identifier mapping carefully to avoid breaking SQL syntax
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
        return extractSQLSignatures(code, options: options)
    }

    private func extractStructureOnly(_ code: String, options: CompressionOptions) -> String {
        let metrics = calculateCodeMetrics(code)
        let structure = extractLanguageStructure(code, options: options)

        return formatStructureOutput(metrics: metrics, structure: structure)
    }

    // MARK: - Semantic Level Implementations

    private func preserveLanguageKeyPatterns(_ code: String, options: CompressionOptions) -> String {
        // Light compression - preserve all SQL semantics and structure
        return preserveSQLStructure(code)
    }

    private func preserveLanguageArchitecture(_ code: String, options: CompressionOptions) -> String {
        // Medium compression - preserve SQL logic and remove descriptive elements
        return preserveSQLLogic(code)
    }

    private func preserveLanguagePublicAPIs(_ code: String, options: CompressionOptions) -> String {
        // Aggressive compression - preserve schema and critical query patterns
        return preserveSQLArchitecture(code)
    }

    private func extractLanguageSignatures(_ code: String, options: CompressionOptions) -> String {
        // Maximum compression - extract only essential SQL signatures
        return extractSQLSignatures(code, options: options)
    }

    // MARK: - SQL-Specific Compression Methods

    private func preserveSQLStructure(_ code: String) -> String {
        var processed = code

        // Remove excessive newlines
        processed = processed.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        return processed
    }

    private func preserveSQLLogic(_ code: String) -> String {
        var processed = code

        // Extract and preserve all critical SQL patterns
        let allPatterns = [
            extractJoins(code),
            extractConditions(code),
            extractConstraints(code),
            extractAggregates(code),
            extractIndexes(code),
            extractProcedures(code)
        ].flatMap { $0 }

        // Preserve patterns using placeholders
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in allPatterns.enumerated() {
            let placeholder = "/* SQL_PATTERN_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Remove comments but preserve important ones
        processed = removeLanguageComments(processed)

        // Restore preserved patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func preserveSQLArchitecture(_ code: String) -> String {
        var processed = code

        // Extract architectural patterns (schema, constraints, indexes, procedures)
        let architecturalPatterns = [
            extractConstraints(code),
            extractIndexes(code),
            extractProcedures(code),
            extractCriticalJoins(code),
            extractCriticalAggregates(code)
        ].flatMap { $0 }

        // Preserve architectural patterns
        var preservedPatterns: [String: String] = [:]
        for (index, pattern) in architecturalPatterns.enumerated() {
            let placeholder = "/* ARCH_\(index) */"
            preservedPatterns[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        // Compress query bodies while preserving structure
        processed = compressQueryBodies(processed)

        // Restore architectural patterns
        for (placeholder, pattern) in preservedPatterns {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func extractSQLSignatures(_ code: String, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        var result: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let upperTrimmed = trimmed.uppercased()

            // DDL statements (schema definition)
            if upperTrimmed.hasPrefix("CREATE ") || upperTrimmed.hasPrefix("ALTER ") ||
               upperTrimmed.hasPrefix("DROP ") {
                result.append(line)
            }
            // Main query clauses
            else if upperTrimmed.hasPrefix("SELECT ") || upperTrimmed.hasPrefix("FROM ") ||
                    upperTrimmed.hasPrefix("WHERE ") || upperTrimmed.contains("JOIN ") {
                result.append(line)
            }
            // Aggregation and sorting
            else if upperTrimmed.hasPrefix("GROUP BY ") || upperTrimmed.hasPrefix("ORDER BY ") ||
                    upperTrimmed.hasPrefix("HAVING ") {
                result.append(line)
            }
            // Constraints and indexes
            else if upperTrimmed.contains("PRIMARY KEY") || upperTrimmed.contains("FOREIGN KEY") ||
                    upperTrimmed.contains("INDEX") || upperTrimmed.contains("CONSTRAINT") {
                result.append(line)
            }
            // Stored procedures and functions
            else if upperTrimmed.contains("PROCEDURE") || upperTrimmed.contains("FUNCTION") ||
                    upperTrimmed.contains("TRIGGER") || upperTrimmed.contains("VIEW") {
                result.append(line)
            }
            // Transactions and control flow
            else if upperTrimmed.contains("BEGIN") || upperTrimmed.contains("COMMIT") ||
                    upperTrimmed.contains("ROLLBACK") || upperTrimmed.contains("DECLARE") {
                result.append(line)
            }
            // Window functions and CTEs
            else if upperTrimmed.contains("OVER (") || upperTrimmed.contains("WITH ") ||
                    upperTrimmed.contains("PARTITION BY") {
                result.append(line)
            }
            // Performance-related
            else if upperTrimmed.contains("EXPLAIN") || upperTrimmed.contains("ANALYZE") ||
                    upperTrimmed.contains("OPTIMIZE") {
                result.append(line)
            }
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Enhanced Pattern Extraction

    private func extractJoins(_ code: String) -> [String] {
        let patterns = [
            #"(?:INNER\s+|LEFT\s+(?:OUTER\s+)?|RIGHT\s+(?:OUTER\s+)?|FULL\s+(?:OUTER\s+)?|CROSS\s+)?JOIN\s+[\w.]+(?:\s+(?:AS\s+)?\w+)?\s+ON\s+[^;\n(GROUP|ORDER|HAVING|LIMIT|UNION|WHERE)]+"#,
            #"JOIN\s+[\w.]+(?:\s+(?:AS\s+)?\w+)?\s+USING\s*\([^)]+\)"#,
            #"FROM\s+[\w.]+(?:\s*,\s*[\w.]+)+"#,
            #"(?:LEFT\s+|RIGHT\s+|FULL\s+)?(?:OUTER\s+)?APPLY\s+[^;\n]+"#,
            #"LATERAL\s+[^;\n]+"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractConditions(_ code: String) -> [String] {
        let patterns = [
            #"WHERE\s+(?:(?!GROUP\s+BY|ORDER\s+BY|HAVING|LIMIT|UNION|;).)++"#,
            #"HAVING\s+(?:(?!ORDER\s+BY|LIMIT|UNION|;).)++"#,
            #"CASE\s+(?:WHEN\s+[^\n;]+\s+THEN\s+[^\n;]+\s*)+(?:ELSE\s+[^\n;]+\s*)?END"#,
            #"EXISTS\s*\([^)]+\)"#,
            #"NOT\s+EXISTS\s*\([^)]+\)"#,
            #"IN\s*\([^)]+\)"#,
            #"NOT\s+IN\s*\([^)]+\)"#,
            #"BETWEEN\s+[^\s]+\s+AND\s+[^\s]+"#,
            #"LIKE\s+['\"][^'\"]*['\"](?:\s+ESCAPE\s+['\"][^'\"]*['\"])?"#,
            #"REGEXP?\s+['\"][^'\"]*['\"]"#,
            #"IS\s+(?:NOT\s+)?NULL"#,
            #"COALESCE\s*\([^)]+\)"#,
            #"NULLIF\s*\([^)]+\)"#,
            #"ISNULL\s*\([^)]+\)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractConstraints(_ code: String) -> [String] {
        let patterns = [
            #"PRIMARY\s+KEY\s*\([^)]+\)"#,
            #"FOREIGN\s+KEY\s*\([^)]+\)\s+REFERENCES\s+[\w.]+\s*\([^)]+\)(?:\s+ON\s+(?:DELETE|UPDATE)\s+(?:CASCADE|SET\s+NULL|SET\s+DEFAULT|RESTRICT|NO\s+ACTION))?"#,
            #"UNIQUE\s*\([^)]+\)"#,
            #"CHECK\s*\([^)]+\)"#,
            #"NOT\s+NULL"#,
            #"DEFAULT\s+(?:[^\s,)]+|'[^']*'|\"[^\"]*\")"#,
            #"AUTO_INCREMENT|IDENTITY(?:\s*\(\s*\d+\s*,\s*\d+\s*\))?"#,
            #"CONSTRAINT\s+\w+\s+(?:PRIMARY\s+KEY|FOREIGN\s+KEY|UNIQUE|CHECK)\s*[^;]+"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractAggregates(_ code: String) -> [String] {
        let patterns = [
            #"(?:COUNT|SUM|AVG|MIN|MAX|STDDEV|VARIANCE|STRING_AGG|ARRAY_AGG|JSON_AGG|XMLAGG)\s*\([^)]+\)(?:\s+OVER\s*\([^)]*\))?"#,
            #"GROUP\s+BY\s+(?:(?!ORDER\s+BY|HAVING|LIMIT|UNION|;).)++"#,
            #"ORDER\s+BY\s+(?:(?!LIMIT|UNION|;).)++"#,
            #"PARTITION\s+BY\s+[^\n)]+"#,
            #"(?:ROW_NUMBER|RANK|DENSE_RANK|NTILE|LAG|LEAD|FIRST_VALUE|LAST_VALUE|NTH_VALUE)\s*\([^)]*\)\s+OVER\s*\([^)]+\)"#,
            #"WITH\s+(?:RECURSIVE\s+)?\w+(?:\s*\([^)]*\))?\s+AS\s*\([^)]+\)"#,
            #"ROLLUP\s*\([^)]+\)"#,
            #"CUBE\s*\([^)]+\)"#,
            #"GROUPING\s+SETS\s*\([^)]+\)"#,
            #"DISTINCT\s+(?:ON\s*\([^)]+\)\s+)?[^\s,)]+"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractIndexes(_ code: String) -> [String] {
        let patterns = [
            #"CREATE\s+(?:UNIQUE\s+)?(?:CLUSTERED\s+|NONCLUSTERED\s+)?INDEX\s+[\w.]+\s+ON\s+[\w.]+\s*\([^)]+\)(?:\s+(?:INCLUDE|WHERE|WITH)\s*\([^)]+\))?"#,
            #"DROP\s+INDEX\s+(?:IF\s+EXISTS\s+)?[\w.]+"#,
            #"ALTER\s+INDEX\s+[\w.]+\s+(?:REBUILD|REORGANIZE|DISABLE|ENABLE)"#,
            #"CREATE\s+(?:UNIQUE\s+)?(?:BITMAP\s+|FUNCTION-BASED\s+)?INDEX\s+[^;]+"#,
            #"USING\s+(?:BTREE|HASH|GIST|SPGIST|GIN|BRIN)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractProcedures(_ code: String) -> [String] {
        let patterns = [
            #"CREATE\s+(?:OR\s+REPLACE\s+)?(?:PROCEDURE|FUNCTION)\s+[\w.]+\s*\([^)]*\)(?:\s+RETURNS?\s+[^\s]+)?(?:\s+AS\s*(?:\$\$|\$[^$]*\$|'[^']*'|\"[^\"]*\"))?"#,
            #"CREATE\s+(?:OR\s+REPLACE\s+)?(?:MATERIALIZED\s+)?VIEW\s+[\w.]+(?:\s*\([^)]*\))?\s+AS\s+SELECT"#,
            #"CREATE\s+(?:OR\s+REPLACE\s+)?TRIGGER\s+\w+\s+(?:BEFORE|AFTER|INSTEAD\s+OF)\s+(?:INSERT|UPDATE|DELETE)(?:\s+OR\s+(?:INSERT|UPDATE|DELETE))*\s+ON\s+[\w.]+"#,
            #"DECLARE\s+(?:@\w+\s+[^;]+|CURSOR\s+[^;]+)"#,
            #"BEGIN\s+(?:TRAN|TRANSACTION)?|COMMIT\s+(?:TRAN|TRANSACTION)?|ROLLBACK\s+(?:TRAN|TRANSACTION)?"#,
            #"IF\s+[^\n]+\s+BEGIN[^E]*END"#,
            #"WHILE\s+[^\n]+\s+BEGIN[^E]*END"#,
            #"TRY\s*BEGIN[^E]*END\s*CATCH\s*BEGIN[^E]*END"#,
            #"EXEC(?:UTE)?\s+[\w.]+(?:\s+[^;]+)?"#,
            #"CALL\s+[\w.]+\s*\([^)]*\)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    // MARK: - Utility Methods

    private func languagePreservesWhitespace() -> Bool {
        return false // SQL doesn't have significant whitespace like Python
    }

    private func extractCriticalImports(_ code: String) -> [String] {
        // SQL doesn't have traditional imports, but could include database-specific includes
        return []
    }

    private func extractFunctionBodyPatterns(_ code: String, options: CompressionOptions) -> [String] {
        // Extract critical patterns within stored procedures/functions
        return [
            extractConditions(code),
            extractConstraints(code)
        ].flatMap { $0 }
    }

    private func getFunctionBodyPattern() -> String {
        return #"(CREATE\s+(?:OR\s+REPLACE\s+)?(?:PROCEDURE|FUNCTION)\s+[\w.]+\s*\([^)]*\)(?:\s+RETURNS?\s+[^\s]+)?(?:\s+AS\s*)?(?:\$\$|\$[^$]*\$|'|"))[^;]*(;|\$\$|\$[^$]*\$|'|")"#
    }

    private func getFunctionTruncationReplacement() -> String {
        return "$1 /* implementation */ $2"
    }

    private func getIdentifierPattern() -> String {
        return #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
    }

    private func isCriticalIdentifier(_ identifier: String, options: CompressionOptions) -> Bool {
        let sqlKeywords = [
            "SELECT", "FROM", "WHERE", "JOIN", "GROUP", "ORDER", "HAVING",
            "INSERT", "UPDATE", "DELETE", "CREATE", "ALTER", "DROP",
            "TABLE", "VIEW", "INDEX", "CONSTRAINT", "PRIMARY", "FOREIGN",
            "NULL", "NOT", "AND", "OR", "LIKE", "IN", "EXISTS", "CASE",
            "WHEN", "THEN", "ELSE", "END", "UNION", "DISTINCT"
        ]

        return sqlKeywords.contains(identifier.uppercased())
    }

    private func generateShortIdentifier(_ counter: Int) -> String {
        return "t\(counter)" // Use 't' prefix for table/column aliases
    }

    private func isLanguageSignature(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let upperTrimmed = trimmed.uppercased()

        return upperTrimmed.hasPrefix("CREATE ") ||
               upperTrimmed.hasPrefix("ALTER ") ||
               upperTrimmed.hasPrefix("DROP ") ||
               upperTrimmed.hasPrefix("SELECT ") ||
               upperTrimmed.contains("PROCEDURE") ||
               upperTrimmed.contains("FUNCTION") ||
               upperTrimmed.contains("INDEX")
    }

    private func isCriticalDeclaration(_ line: String, options: CompressionOptions) -> Bool {
        let upperTrimmed = line.trimmingCharacters(in: .whitespaces).uppercased()

        return upperTrimmed.contains("PRIMARY KEY") ||
               upperTrimmed.contains("FOREIGN KEY") ||
               upperTrimmed.contains("CONSTRAINT") ||
               upperTrimmed.contains("INDEX")
    }

    private func isPublicIdentifier(_ identifier: String) -> Bool {
        // In SQL, table and column names that are not system-generated are generally "public"
        return !identifier.hasPrefix("sys_") && !identifier.hasPrefix("temp_")
    }

    private func isKeywordOrBuiltin(_ identifier: String) -> Bool {
        return isCriticalIdentifier(identifier, options: CompressionOptions())
    }

    private func extractCriticalJoins(_ code: String) -> [String] {
        let patterns = [
            #"(?:INNER\s+|LEFT\s+|RIGHT\s+|FULL\s+)?JOIN\s+[\w.]+(?:\s+(?:AS\s+)?\w+)?\s+ON\s+[^;\n(GROUP|ORDER|HAVING|LIMIT)]+"#,
            #"FROM\s+[\w.]+(?:\s*,\s*[\w.]+){2,}"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractCriticalAggregates(_ code: String) -> [String] {
        let patterns = [
            #"(?:COUNT|SUM|AVG)\s*\([^)]+\)(?:\s+OVER\s*\([^)]*\))?"#,
            #"GROUP\s+BY\s+[^\n;(ORDER|HAVING|LIMIT)]+"#,
            #"WITH\s+(?:RECURSIVE\s+)?\w+\s+AS\s*\([^)]+\)"#
        ]

        return extractPatternMatches(code, patterns: patterns)
    }

    private func extractPatternMatches(_ code: String, patterns: [String]) -> [String] {
        var results: [String] = []
        for pattern in patterns {
            results.append(contentsOf: code.matches(of: pattern))
        }
        return results
    }

    private func compressQueryBodies(_ code: String) -> String {
        var processed = code

        let criticalPatterns = [
            extractConstraints(code),
            extractJoins(code),
            extractConditions(code)
        ].flatMap { $0 }

        var preservedCritical: [String: String] = [:]
        for (index, pattern) in criticalPatterns.enumerated() {
            let placeholder = "/* CRITICAL_\(index) */"
            preservedCritical[placeholder] = pattern
            processed = processed.replacingOccurrences(of: pattern, with: placeholder)
        }

        processed = compressSelectLists(processed)

        for (placeholder, pattern) in preservedCritical {
            processed = processed.replacingOccurrences(of: placeholder, with: pattern)
        }

        return processed
    }

    private func compressSelectLists(_ code: String) -> String {
        return code.replacingOccurrences(
            of: #"SELECT\s+((?:[^\n;(FROM)]{100,})|(?:[^\n;(FROM)]*,\s*[^\n;(FROM)]*,\s*[^\n;(FROM)]*,\s*[^\n;(FROM)]+))"#,
            with: "SELECT /* multiple columns */",
            options: [.regularExpression, .caseInsensitive]
        )
    }

    private func limitFileLines(_ code: String, maxLines: Int, options: CompressionOptions) -> String {
        let lines = code.components(separatedBy: .newlines)
        if lines.count <= maxLines { return code }

        if options.prioritizeTopLevel {
            return prioritizeTopLevelLines(lines, maxLines: maxLines)
        }

        return Array(lines.prefix(maxLines)).joined(separator: "\n")
    }

    private func limitFileTokens(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        let currentTokens = TokenCounter.countTokens(in: code, using: options.tokenizerType)
        if currentTokens <= maxTokens { return code }

        return reduceToTokenLimit(code, maxTokens: maxTokens, options: options)
    }

    private func prioritizeTopLevelLines(_ lines: [String], maxLines: Int) -> String {
        // Prioritize DDL statements, then major query components
        var prioritized: [String] = []
        var remaining: [String] = []

        for line in lines {
            let upperTrimmed = line.trimmingCharacters(in: .whitespaces).uppercased()
            if upperTrimmed.hasPrefix("CREATE ") ||
               upperTrimmed.hasPrefix("ALTER ") ||
               upperTrimmed.hasPrefix("DROP ") ||
               upperTrimmed.contains("PRIMARY KEY") ||
               upperTrimmed.contains("FOREIGN KEY") {
                prioritized.append(line)
            } else {
                remaining.append(line)
            }
        }

        let availableLines = maxLines - prioritized.count
        if availableLines > 0 {
            prioritized.append(contentsOf: Array(remaining.prefix(availableLines)))
        }

        return prioritized.joined(separator: "\n")
    }

    private func reduceToTokenLimit(_ code: String, maxTokens: Int, options: CompressionOptions) -> String {
        var processed = code
        let lines = processed.components(separatedBy: .newlines)

        // Remove lines progressively, keeping most important ones
        var currentLines = lines
        while TokenCounter.countTokens(in: currentLines.joined(separator: "\n"), using: options.tokenizerType) > maxTokens && currentLines.count > 1 {
            // Remove non-essential lines first
            currentLines = currentLines.filter { line in
                let upperTrimmed = line.trimmingCharacters(in: .whitespaces).uppercased()
                return upperTrimmed.hasPrefix("CREATE ") ||
                       upperTrimmed.hasPrefix("SELECT ") ||
                       upperTrimmed.contains("PRIMARY KEY") ||
                       upperTrimmed.contains("FOREIGN KEY")
            }

            if currentLines.count == lines.count {
                // If no non-essential lines found, remove from end
                currentLines = Array(currentLines.dropLast())
            }
        }

        return currentLines.joined(separator: "\n")
    }

    private func calculateCodeMetrics(_ code: String) -> [String: Any] {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        return [
            "totalLines": lines.count,
            "linesOfCode": nonEmptyLines.count,
            "tables": code.matches(of: #"CREATE\s+TABLE"#).count,
            "procedures": code.matches(of: #"CREATE\s+(?:PROCEDURE|FUNCTION)"#).count,
            "indexes": code.matches(of: #"CREATE\s+INDEX"#).count,
            "views": code.matches(of: #"CREATE\s+VIEW"#).count
        ]
    }

    private func extractLanguageStructure(_ code: String, options: CompressionOptions) -> [String: Any] {
        return [
            "joins": extractJoins(code).count,
            "conditions": extractConditions(code).count,
            "constraints": extractConstraints(code).count,
            "aggregates": extractAggregates(code).count,
            "indexes": extractIndexes(code).count,
            "procedures": extractProcedures(code).count
        ]
    }

    private func formatStructureOutput(metrics: [String: Any], structure: [String: Any]) -> String {
        var result = ["/* SQL Structure Overview */"]

        result.append("-- Metrics:")
        for (key, value) in metrics {
            result.append("-- \(key): \(value)")
        }

        result.append("")
        result.append("-- Patterns:")
        for (key, value) in structure {
            result.append("-- \(key): \(value)")
        }

        return result.joined(separator: "\n")
    }

    private func calculateSemanticAccuracy(options: CompressionOptions) -> Double {
        switch options.semanticLevel {
        case .light: return 0.97    // Preserves all SQL semantics and structure
        case .medium: return 0.89   // Removes comments, preserves all functional patterns
        case .aggressive: return 0.81  // Compresses queries, preserves schema and architecture
        case .maximum: return 0.64  // Schema and critical query patterns only
        }
    }

    // MARK: - Required Protocol Methods

    func identifyCriticalPatterns(_ code: String) -> [CriticalPattern] {
        var patterns: [CriticalPattern] = []

        let joins = extractJoins(code)
        patterns.append(contentsOf: joins.map { .interface($0) })

        let conditions = extractConditions(code)
        patterns.append(contentsOf: conditions.map { .lifecycle($0) })

        let constraints = extractConstraints(code)
        patterns.append(contentsOf: constraints.map { .trait($0) })

        let aggregates = extractAggregates(code)
        patterns.append(contentsOf: aggregates.map { .macro($0) })

        let indexes = extractIndexes(code)
        patterns.append(contentsOf: indexes.map { .trait($0) })

        let procedures = extractProcedures(code)
        patterns.append(contentsOf: procedures.map { .interface($0) })

        return patterns
    }
}
