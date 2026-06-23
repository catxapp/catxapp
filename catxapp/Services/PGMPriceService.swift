import Foundation

@MainActor
@Observable
final class PGMPriceService {
    private(set) var quote: PGMQuote?
    private(set) var config: PGMConfigDocument?
    private(set) var isRefreshing = false
    private(set) var lastError: String?
    private(set) var quoteSource: String?

    private let cacheKey = "pgm.quote.cache.v2"
    private let sourceKey = "pgm.quote.source"

    func loadConfig() {
        guard config == nil else { return }
        guard let url = Bundle.main.url(forResource: "pgm_config", withExtension: "json") else { return }

        do {
            let data = try Data(contentsOf: url)
            config = try JSONDecoder().decode(PGMConfigDocument.self, from: data)
            restoreCache()
            if quote == nil, let anchorDate = config?.anchorDate,
               let anchor = config?.historical[anchorDate] {
                quote = PGMQuote(pt: anchor.pt, pd: anchor.pd, rh: anchor.rh, updatedAt: Date())
                quoteSource = "Catalog anchor (\(anchorDate))"
            }
        } catch {
            lastError = "Failed to load PGM config."
        }
    }

    func refreshIfNeeded() async {
        loadConfig()
        guard quote == nil || shouldRefresh else { return }
        await refresh()
    }

    func refresh() async {
        loadConfig()
        isRefreshing = true
        defer { isRefreshing = false }

        if let fetched = await fetchLiveQuote() {
            quote = fetched
            quoteSource = "Kitco"
            persistCache(fetched)
            lastError = nil
        } else if quote == nil,
                  let anchorDate = config?.anchorDate,
                  let anchor = config?.historical[anchorDate] {
            quote = PGMQuote(pt: anchor.pt, pd: anchor.pd, rh: anchor.rh, updatedAt: Date())
            quoteSource = "Catalog anchor (\(anchorDate))"
            lastError = "Could not reach Kitco. Using catalog anchor prices from \(anchorDate)."
        } else if quote != nil {
            lastError = "Could not refresh Kitco prices. Showing last known values."
        }
    }

    func index(for quote: PGMQuote) -> Double? {
        guard let weights = config?.weights else { return nil }
        return weights.pt * quote.pt + weights.pd * quote.pd + weights.rh * quote.rh
    }

    func currentIndex() -> Double? {
        guard let quote else { return config?.anchorIndex }
        return index(for: quote)
    }

    private var shouldRefresh: Bool {
        guard let quote else { return true }
        return Date().timeIntervalSince(quote.updatedAt) > 60 * 60 * 6
    }

    private func fetchLiveQuote() async -> PGMQuote? {
        await KitcoPriceClient.fetchPGMQuote()
    }

    private func restoreCache() {
        guard quote == nil,
              let data = UserDefaults.standard.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedQuote.self, from: data) else { return }
        quote = PGMQuote(pt: cached.pt, pd: cached.pd, rh: cached.rh, updatedAt: cached.updatedAt)
        quoteSource = UserDefaults.standard.string(forKey: sourceKey) ?? "Cached"
    }

    private func persistCache(_ quote: PGMQuote) {
        let cached = CachedQuote(pt: quote.pt, pd: quote.pd, rh: quote.rh, updatedAt: quote.updatedAt)
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        if let source = quoteSource {
            UserDefaults.standard.set(source, forKey: sourceKey)
        }
    }
}

private struct CachedQuote: Codable {
    let pt: Double
    let pd: Double
    let rh: Double
    let updatedAt: Date
}
