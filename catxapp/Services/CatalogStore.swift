import Foundation

@MainActor
@Observable
final class CatalogStore {
    private(set) var converters: [CatalyticConverter] = []
    private(set) var supplier: String = ""
    private(set) var anchorDate: String = ""
    private(set) var loadError: String?
    private(set) var isLoaded = false

    private var byCode: [String: CatalyticConverter] = [:]

    init() {}

    func load() async {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json") else {
            loadError = "Catalog file missing from app bundle."
            isLoaded = true
            return
        }

        do {
            let document = try await Task.detached(priority: .userInitiated) {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(CatalogDocument.self, from: data)
            }.value

            converters = document.entries
            supplier = document.supplier
            anchorDate = document.anchorDate
            byCode = Dictionary(
                document.entries.map { (Self.normalizeCode($0.code), $0) },
                uniquingKeysWith: { first, _ in first }
            )
            loadError = nil
        } catch {
            loadError = "Failed to load catalog."
        }
        isLoaded = true
    }

    func converter(for code: String) -> CatalyticConverter? {
        byCode[normalizeQuery(code)]
    }

    func search(query: String) -> [CatalyticConverter] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let normalized = normalizeQuery(trimmed)
        let brandQuery = trimmed.uppercased()

        let results = converters.filter { converter in
            matchesCode(converter, query: normalized)
                || matchesBrand(converter, query: brandQuery, normalized: normalized)
        }

        return results
            .sorted { lhs, rhs in
                sortRank(for: lhs, query: normalized, brandQuery: brandQuery)
                    < sortRank(for: rhs, query: normalized, brandQuery: brandQuery)
            }
            .prefix(500)
            .map { $0 }
    }

    private func matchesCode(_ converter: CatalyticConverter, query: String) -> Bool {
        normalizeQuery(converter.code).contains(query)
    }

    private func matchesBrand(_ converter: CatalyticConverter, query: String, normalized: String) -> Bool {
        converter.category.uppercased().contains(query)
            || normalizeQuery(converter.category).contains(normalized)
    }

    private func sortRank(for converter: CatalyticConverter, query: String, brandQuery: String) -> (Int, Int, Int, Int, Int, String) {
        let normalizedCode = normalizeQuery(converter.code)
        if matchesCode(converter, query: query) {
            let exact = normalizedCode == query ? 0 : 1
            let prefix = normalizedCode.hasPrefix(query) ? 0 : 1
            let zeroPrice = converter.anchorPrice <= 0 ? 1 : 0
            let shortCode = normalizedCode.count < 3 ? 1 : 0
            return (0, exact, prefix, zeroPrice, shortCode, normalizedCode)
        }

        let categoryUpper = converter.category.uppercased()
        let brandExact = categoryUpper == brandQuery ? 0 : 1
        let brandPrefix = categoryUpper.hasPrefix(brandQuery) ? 0 : 1
        let zeroPrice = converter.anchorPrice <= 0 ? 1 : 0
        return (1, brandExact, brandPrefix, zeroPrice, 0, normalizedCode)
    }

    private func normalizeQuery(_ value: String) -> String {
        Self.normalizeCode(value)
    }

    private nonisolated static func normalizeCode(_ value: String) -> String {
        value
            .uppercased()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
