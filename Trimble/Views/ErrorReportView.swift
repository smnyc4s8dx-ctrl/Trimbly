//  ErrorReportView.swift
import SwiftUI
import UniformTypeIdentifiers

struct ErrorReportView: View {
    @Environment(\.theme) private var theme
    @ObservedObject var reporter: ErrorReporter
    @Environment(\.dismiss) private var dismiss
    @State private var reportText = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Error Report")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(theme.primaryButtonStyle())
            }

            ScrollView {
                Text(reportText)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .background(theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
            }

            HStack {
                Button("Copy to Clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(reportText, forType: .string)
                }
                .buttonStyle(theme.secondaryButtonStyle())

                Button("Save to File") {
                    saveReportToFile()
                }
                .buttonStyle(theme.secondaryButtonStyle())

                Spacer()

                Text("Report ID: \(reporter.currentReport?.id ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(theme.textSecondary)
            }

            Text("This report contains no personal data and can be safely shared for debugging.")
                .font(.caption)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            reportText = reporter.exportReportAsText()
        }
    }

    private func saveReportToFile() {
        let panel = NSSavePanel()
        panel.title = "Save Error Report"
        panel.nameFieldStringValue = "trimble-error-\(reporter.currentReport?.id ?? "report").txt"
        panel.allowedContentTypes = [.plainText]

        Task {
            if await panel.begin() == .OK, let url = panel.url {
                try? reportText.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
