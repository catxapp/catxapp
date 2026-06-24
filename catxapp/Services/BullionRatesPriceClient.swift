import Foundation

/// Plan B — BullionRates spot pages for platinum and palladium.
/// Rhodium is not published here; callers supply a fallback rhodium bid.
enum BullionRatesPriceClient {
    static let platinumURL = URL(string: "https://www.bullion-rates.com/platinum/USD/spot-price.htm")!
    static let palladiumURL = URL(string: "https://www.bullion-rates.com/palladium/USD/spot-price.htm")!

    static let sourceName = "BullionRates"

    static func fetchPGMQuote(rhodiumBid: Double) async -> PGMQuote? {
        guard rhodiumBid > 0 else { return nil }

        async let platinumHTML = PGMHTMLFetcher.downloadString(from: platinumURL)
        async let palladiumHTML = PGMHTMLFetcher.downloadString(from: palladiumURL)

        guard let platinumHTML = await platinumHTML,
              let palladiumHTML = await palladiumHTML,
              let platinum = parseSpotPrice(in: platinumHTML),
              let palladium = parseSpotPrice(in: palladiumHTML) else {
            return nil
        }

        return PGMQuote(pt: platinum, pd: palladium, rh: rhodiumBid, updatedAt: Date())
    }

    private static func parseSpotPrice(in html: String) -> Double? {
        guard let raw = PGMHTMLFetcher.firstCapture(in: html, pattern: #">([\d,]{3,}\.\d{2})<"#) else {
            return nil
        }
        let normalized = raw.replacingOccurrences(of: ",", with: "")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }
}
