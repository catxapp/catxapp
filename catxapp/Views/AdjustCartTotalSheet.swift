import SwiftUI

struct AdjustCartTotalSheet: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var totalText = ""
    @State private var validationMessage: String?

    private var currentTotal: Double {
        app.cart.total
    }

    private var parsedTotal: Double? {
        let trimmed = totalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed), value >= 0 else { return nil }
        return value
    }

    private var delta: Double? {
        guard let newTotal = parsedTotal else { return nil }
        return newTotal - currentTotal
    }

    private var adjustmentPreview: String? {
        guard let delta, delta != 0 else { return nil }
        return app.cart.adjustmentSummary(for: delta)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                LabeledContent("Current total", value: PriceCalculator.formatted(currentTotal))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) {
                        Text("New total")
                        Text("*")
                            .foregroundStyle(.red)
                    }
                    .font(.subheadline.weight(.medium))

                    HStack {
                        TextField("0", text: $totalText)
                            .keyboardType(.decimalPad)
                            .font(.body.monospaced())
                        Text("USD")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if let adjustmentPreview {
                    Text(adjustmentPreview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Adjust Total")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { apply() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                totalText = formattedEditableTotal(currentTotal)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func formattedEditableTotal(_ value: Double) -> String {
        String(format: "%.0f", value.rounded())
    }

    private func apply() {
        guard let newTotal = parsedTotal else {
            validationMessage = "Enter a valid total of zero or more."
            return
        }

        guard app.cart.applyEvenTotalAdjustment(newTotal: newTotal) else {
            validationMessage = "Could not apply adjustment. Check item quantities and integrity."
            return
        }

        dismiss()
    }
}

#Preview {
    AdjustCartTotalSheet()
        .environment(AppModel())
}
