// ErrorDisplayView.swift
import SwiftUI

struct ErrorDisplayView: View {
    @Environment(\.theme) private var theme
    let errors: [ProcessingError]

    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader(
                    title: "Processing Warnings & Errors",
                    icon: "exclamationmark.triangle",
                    tint: theme.danger
                )

                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(errors) { error in
                            HStack {
                                Image(systemName: error.severity == .critical ? "exclamationmark.triangle.fill" :
                                        error.severity == .error ? "xmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundColor(error.severity.color)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(error.fileName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(error.error)
                                        .font(.caption)
                                        .foregroundColor(theme.textSecondary)
                                }

                                Spacer()
                            }
                            .padding(8)
                            .background(error.severity.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: theme.inputCornerRadius))
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
        }
    }
}
