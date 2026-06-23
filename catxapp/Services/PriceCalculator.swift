import Foundation

enum PriceCalculator {
    /// Built-in reduction on live market prices so displayed pay prices leave room for yard profit.
    static let catalogPayDiscountPercent = 7.0

    static func displayPrice(
        anchorPrice: Double,
        marginPercent: Double,
        anchorIndex: Double,
        currentIndex: Double?
    ) -> Double {
        let base: Double
        if let currentIndex, anchorIndex > 0 {
            base = anchorPrice * (currentIndex / anchorIndex)
        } else {
            base = anchorPrice
        }

        let discountedBase = base * (1 - catalogPayDiscountPercent / 100)

        // Positive margin = more profit for the yard = lower pay price.
        // Negative margin = pay the seller more than the adjusted catalog price.
        let raw = max(0, discountedBase * (1 - marginPercent / 100))
        return raw.rounded()
    }

    static func formattedPrice(anchorPrice: Double, displayPrice: Double) -> String {
        formatted(displayPrice)
    }

    static func formatted(_ value: Double) -> String {
        if value <= 0 {
            return "$0"
        }
        return value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }

    static func formattedCartUnitPrice(_ value: Double) -> String {
        formatted(value.rounded())
    }
}
