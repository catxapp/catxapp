import SwiftUI

struct PricingSettingsView: View {
    @Environment(AppModel.self) private var app

    private var examplePrice: String {
        let sample = PriceCalculator.displayPrice(
            anchorPrice: 100,
            marginPercent: app.settings.marginPercent,
            anchorIndex: 1,
            currentIndex: 1
        )
        return PriceCalculator.formatted(sample)
    }

    var body: some View {
        @Bindable var settings = app.settings

        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Profit margin: \(signedPercent(settings.marginPercent))")
                        .font(.headline)

                    HStack {
                        Text("Pay more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("More profit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $settings.marginPercent, in: -50...50, step: 1)

                    Text("Move right to keep more profit — you pay the seller less. Move left to pay more than the catalog price.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Example: $100 catalog cat → \(examplePrice) at \(signedPercent(settings.marginPercent))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } footer: {
                Text("Changes apply to search results and new cart items.")
            }
        }
        .navigationTitle("Pricing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signedPercent(_ value: Double) -> String {
        let rounded = Int(value.rounded())
        if rounded > 0 { return "+\(rounded)%" }
        return "\(rounded)%"
    }
}

#Preview {
    NavigationStack {
        PricingSettingsView()
            .environment(AppModel())
    }
}
