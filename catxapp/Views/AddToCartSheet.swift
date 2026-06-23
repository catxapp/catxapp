import SwiftUI

struct AddToCartSheet: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    let converter: CatalyticConverter

    @State private var priceText = ""
    @State private var quantityText = "1"
    @State private var integrityValue: Double = 100
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    priceField
                    quantityField
                    integritySection

                    HStack {
                        Text("Line total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(PriceCalculator.formatted(lineTotalPreview))
                            .font(.title3.bold())
                    }

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()

                Spacer(minLength: 0)

                footerButtons
            }
            .navigationTitle("ADD TO CART: \(converter.code)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        app.dismissAddToCart()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                let price = app.price(for: converter)
                priceText = String(format: "%.0f", price.rounded())
                quantityText = "1"
                integrityValue = 100
            }
        }
        .presentationDetents([.fraction(0.78), .large])
        .presentationDragIndicator(.visible)
    }

    private var priceField: some View {
        VStack(alignment: .leading, spacing: 8) {
            requiredLabel("Price")
            HStack {
                TextField("0", text: $priceText)
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
    }

    private var quantityField: some View {
        VStack(alignment: .leading, spacing: 8) {
            requiredLabel("Quantity")
            TextField("1", text: $quantityText)
                .keyboardType(.numberPad)
                .font(.body.monospaced())
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var integritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            requiredLabel("Integrity")
            Text("How much honeycomb remains inside the cat. Burned or damaged units are often only 70% or 30%.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                TextField("100", value: $integrityValue, format: .number.precision(.fractionLength(0)))
                    .keyboardType(.numberPad)
                    .font(.body.monospaced())
                    .onChange(of: integrityValue) { _, newValue in
                        integrityValue = min(100, max(0, newValue))
                    }
                Text("%")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(spacing: 8) {
                Slider(value: $integrityValue, in: 0...100, step: 1)
                    .tint(.accentColor)

                HStack {
                    ForEach([0, 25, 50, 75, 100], id: \.self) { tick in
                        if tick > 0 { Spacer() }
                        Text("\(tick)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var footerButtons: some View {
        HStack(spacing: 12) {
            Button("Close") {
                app.dismissAddToCart()
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .foregroundStyle(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.orange, lineWidth: 1)
            }

            Button("Add to cart") {
                submit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private func requiredLabel(_ title: String) -> some View {
        HStack(spacing: 2) {
            Text(title)
            Text("*")
                .foregroundStyle(.red)
        }
        .font(.subheadline.weight(.medium))
    }

    private var lineTotalPreview: Double {
        guard let price = parsedPrice,
              let quantity = parsedQuantity else { return 0 }
        return price * Double(quantity) * (integrityValue / 100)
    }

    private var parsedPrice: Double? {
        let trimmed = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmed), value > 0 else { return nil }
        return value
    }

    private var parsedQuantity: Int? {
        let trimmed = quantityText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(trimmed), value >= 1 else { return nil }
        return value
    }

    private func submit() {
        guard let price = parsedPrice else {
            validationMessage = "Enter a valid price greater than zero."
            return
        }
        guard let quantity = parsedQuantity else {
            validationMessage = "Enter a quantity of at least 1."
            return
        }
        guard integrityValue >= 0, integrityValue <= 100 else {
            validationMessage = "Integrity must be between 0 and 100."
            return
        }

        validationMessage = nil
        app.confirmAddToCart(
            unitPrice: price.rounded(),
            quantity: quantity,
            integrityPercent: integrityValue
        )
        dismiss()
    }
}

#Preview {
    AddToCartSheet(converter: CatalyticConverter(code: "1W7C5E212AB", category: "Ford", anchorPrice: 177))
        .environment(AppModel())
}
