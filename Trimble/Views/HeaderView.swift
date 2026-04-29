//  HeaderView.swift
import SwiftUI

struct HeaderView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<7) { i in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.primaryAccent, theme.secondaryAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 4, height: 4)
                            .scaleEffect(i == 3 ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: UUID())
                    }
                }

                Spacer()

                ThemePickerButton()
            }

            VStack(spacing: 4) {
                Text("Intelligent compression for AI consumption")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
}
