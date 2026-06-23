import Foundation

@MainActor
@Observable
final class SavedCartsStore {
    private(set) var carts: [SavedCart] = []

    private let storageKey = "saved.carts"

    init() {
        restore()
    }

    var allCarts: [SavedCart] {
        carts.sorted { $0.savedAt > $1.savedAt }
    }

    func cart(id: UUID) -> SavedCart? {
        carts.first { $0.id == id }
    }

    func save(name: String, items: [CartItem]) {
        carts.append(SavedCart(name: name, items: items))
        persist()
    }

    func delete(id: UUID) {
        carts.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(carts) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SavedCart].self, from: data) else { return }
        carts = decoded
    }
}
