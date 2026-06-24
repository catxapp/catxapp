import SwiftUI

struct PGMMarketStripView: View {
    let quote: PGMQuote?
    let isRefreshing: Bool
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            marketLabel

            if let quote {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        metalPill(symbol: "Pt", price: quote.pt, tint: Color(red: 0.55, green: 0.72, blue: 0.95))
                        metalPill(symbol: "Pd", price: quote.pd, tint: Color(red: 0.55, green: 0.88, blue: 0.72))
                        metalPill(symbol: "Rh", price: quote.rh, tint: Color(red: 0.98, green: 0.72, blue: 0.45))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Loading spot prices…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: onRefresh) {
                Group {
                    if isRefreshing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.semibold))
                    }
                }
                .frame(width: 28, height: 28)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isRefreshing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.6), lineWidth: 1)
        }
    }

    private var marketLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.green.opacity(0.9))
                    .frame(width: 6, height: 6)
                Text("Market")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            if let updated = quote?.updatedAt {
                Text(updated.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(minWidth: 54, alignment: .leading)
    }

    private func metalPill(symbol: String, price: Double, tint: Color) -> some View {
        HStack(spacing: 5) {
            Text(symbol)
                .font(.caption2.weight(.bold))
                .foregroundStyle(tint)
            Text(formattedMetal(price))
                .font(.caption.monospacedDigit().weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }

    private func formattedMetal(_ value: Double) -> String {
        value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

#Preview {
    PGMMarketStripView(
        quote: PGMQuote(pt: 1700, pd: 1300, rh: 8700, updatedAt: Date()),
        isRefreshing: false,
        onRefresh: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
