import Foundation

enum PGMHTMLFetcher {
    static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 CatXapp/1.0"

    static func downloadString(from url: URL) async -> String? {
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

    static func firstCapture(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }

    static func parseNextDataBids(in html: String) -> (pt: Double, pd: Double, rh: Double)? {
        guard let scriptRange = html.range(of: #"<script id="__NEXT_DATA__"[^>]*>"#, options: .regularExpression) else {
            return nil
        }

        let tail = html[scriptRange.upperBound...]
        guard let end = tail.range(of: "</script>") else { return nil }
        let jsonText = String(tail[..<end.lowerBound])

        var bids: [String: Double] = [:]
        for (metal, key) in [("Platinum", "pt"), ("Palladium", "pd"), ("Rhodium", "rh")] {
            guard let metalRange = jsonText.range(of: "\"\(metal)\"") else { continue }
            let snippet = String(jsonText[metalRange.lowerBound...].prefix(220))
            guard let value = firstCapture(in: snippet, pattern: #""bid":\s*([\d.]+)"#),
                  let bid = Double(value), bid > 0 else { continue }
            bids[key] = bid
        }

        guard let pt = bids["pt"], let pd = bids["pd"], let rh = bids["rh"] else { return nil }
        return (pt, pd, rh)
    }
}
