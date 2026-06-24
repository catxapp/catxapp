import Foundation

/// Plan A — Kitco spot and chart pages.
enum KitcoPriceClient {
    static let spotMarketURL = URL(string: "https://www.kitco.com/price/precious-metals")!
    static let platinumChartURL = URL(string: "https://www.kitco.com/charts/platinum")!
    static let palladiumChartURL = URL(string: "https://www.kitco.com/charts/palladium")!
    static let rhodiumChartURL = URL(string: "https://www.kitco.com/charts/liverhodium.html")!

    static let sourceName = "Kitco"

    static func fetchPGMQuote() async -> PGMQuote? {
        if let html = await PGMHTMLFetcher.downloadString(from: spotMarketURL) {
            if let quote = parseQuote(from: html) {
                return quote
            }
        }

        async let platinumHTML = PGMHTMLFetcher.downloadString(from: platinumChartURL)
        async let palladiumHTML = PGMHTMLFetcher.downloadString(from: palladiumChartURL)
        async let rhodiumHTML = PGMHTMLFetcher.downloadString(from: rhodiumChartURL)

        guard let platinumHTML = await platinumHTML,
              let palladiumHTML = await palladiumHTML,
              let rhodiumHTML = await rhodiumHTML else {
            return nil
        }

        let combined = platinumHTML + palladiumHTML + rhodiumHTML
        return parseQuote(from: combined)
    }

    private static func parseQuote(from html: String) -> PGMQuote? {
        if let bids = PGMHTMLFetcher.parseNextDataBids(in: html) {
            return PGMQuote(pt: bids.pt, pd: bids.pd, rh: bids.rh, updatedAt: Date())
        }

        guard let platinum = parseMetalBid(in: html, name: "Platinum"),
              let palladium = parseMetalBid(in: html, name: "Palladium"),
              let rhodium = parseMetalBid(in: html, name: "Rhodium"),
              platinum > 0, palladium > 0, rhodium > 0 else {
            return nil
        }

        return PGMQuote(pt: platinum, pd: palladium, rh: rhodium, updatedAt: Date())
    }

    private static func parseMetalBid(in html: String, name: String) -> Double? {
        let patterns = [
            #""name":"\#(name)","results":\[\{"ID":0,"ask":[\d.]+,"bid":([\d.]+)"#,
            #""\#(name)","results":\[\{"ID":0,"ask":[\d.]+,"bid":([\d.]+)"#,
            #""\#(name)", "results": \[\{"ID": 0, "ask": [\d.]+, "bid": ([\d.]+)"#
        ]

        for pattern in patterns {
            if let value = PGMHTMLFetcher.firstCapture(in: html, pattern: pattern),
               let number = Double(value), number > 0 {
                return number
            }
        }
        return nil
    }
}
