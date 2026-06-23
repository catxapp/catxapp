import Foundation

@MainActor
@Observable
final class RecentSearchStore {
    private(set) var codes: [String] = []
    private let key = "recent.searches"
    private let limit = 12

    init() {
        codes = UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func add(_ code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        codes.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        codes.insert(trimmed, at: 0)
        if codes.count > limit {
            codes = Array(codes.prefix(limit))
        }
        UserDefaults.standard.set(codes, forKey: key)
    }
}
