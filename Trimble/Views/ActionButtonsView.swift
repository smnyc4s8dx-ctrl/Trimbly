// ActionButtonsView.swift
import SwiftUI

struct ActionButtonsView: View {
    @Environment(\.theme) private var theme
    let isProcessing: Bool
    let hasErrors: Bool
    let canProcess: Bool
    let onStartProcessing: () -> Void
    let onCancel: () -> Void
    let onShowHelp: () -> Void
    let onShowErrorReport: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onShowHelp) {
                Label("Help & Best Practices", systemImage: "questionmark.circle")
            }
            .buttonStyle(theme.secondaryButtonStyle())

            if hasErrors {
                Button(action: onShowErrorReport) {
                    Label("Generate Error Report", systemImage: "doc.text")
                }
                .buttonStyle(theme.secondaryButtonStyle())
            }

            Spacer()

            if isProcessing {
                Button("Cancel", action: onCancel)
                    .buttonStyle(theme.secondaryButtonStyle())
            }

            Button(action: onStartProcessing) {
                Label("Process Content", systemImage: "play.fill")
            }
            .buttonStyle(theme.primaryButtonStyle())
            .disabled(!canProcess || isProcessing)
            .controlSize(.large)
        }
    }
}
