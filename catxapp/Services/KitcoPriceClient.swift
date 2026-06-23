import Foundation

enum KitcoPriceClient {
    static let spotMarketURL = URL(string: "https://www.kitco.com/price/precious-metals")!
    static let platinumChartURL = URL(string: "https://www.kitco.com/charts/platinum")!
    static let palladiumChartURL = URL(string: "https://www.kitco.com/charts/palladium")!
    static let rhodiumChartURL = URL(string: "https://www.kitco.com/charts/liverhodium.html")!

    private static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 CatXapp/1.0"

    static func fetchPGMQuote() async -> PGMQuote? {
        if let html = await downloadString(from: spotMarketURL),
           let quote = parseSpotMarketPage(in: html) {
            return quote
        }

        async let platinumHTML = downloadString(from: platinumChartURL)
        async let palladiumHTML = downloadString(from: palladiumChartURL)
        async let rhodiumHTML = downloadString(from: rhodiumChartURL)

        guard let platinumHTML = await platinumHTML,
              let palladiumHTML = await palladiumHTML,
              let rhodiumHTML = await rhodiumHTML else {
            return nil
        }

        guard let platinum = parseMetalBid(in: platinumHTML, name: "Platinum"),
              let palladium = parseMetalBid(in: palladiumHTML, name: "Palladium"),
              let rhodium = parseMetalBid(in: rhodiumHTML, name: "Rhodium"),
              platinum > 0, palladium > 0, rhodium > 0 else {
            return nil
        }

        return PGMQuote(pt: platinum, pd: palladium, rh: rhodium, updatedAt: Date())
    }

    private static func parseSpotMarketPage(in html: String) -> PGMQuote? {
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
            #""\#(name)","results":\[\{"ID":0,"ask":[\d.]+,"bid":([\d.]+)"#
        ]

        for pattern in patterns {
            if let value = firstCapture(in: html, pattern: pattern), let number = Double(value), number > 0 {
                return number
            }
        }
        return nil
    }

    private static func downloadString(from url: URL) async -> String? {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    private static func firstCapture(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }
}
