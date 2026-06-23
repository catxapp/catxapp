import Foundation

@MainActor
@Observable
final class CartStore {
    private(set) var items: [CartItem] = []

    private let storageKey = "cart.items"

    init() {
        restore()
    }

    func add(
        code: String,
        category: String,
        addedAnchorPrice: Double,
        unitPrice: Double,
        quantity: Int,
        integrityPercent: Double
    ) {
        items.append(CartItem(
            code: code,
            category: category,
            addedAnchorPrice: addedAnchorPrice,
            unitPrice: unitPrice,
            quantity: quantity,
            integrityPercent: integrityPercent
        ))
        persist()
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    func remove(ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        items.removeAll { ids.contains($0.id) }
        persist()
    }

    func updateQuantity(for item: CartItem, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            var updated = items[index]
            updated.quantity = quantity
            items[index] = updated
        }
        persist()
    }

    var total: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    @discardableResult
    func applyEvenTotalAdjustment(newTotal: Double) -> Bool {
        guard !items.isEmpty, newTotal >= 0 else { return false }

        let targetTotal = newTotal.rounded()
        let currentTotal = total
        guard currentTotal > 0.005 else { return false }
        if abs(targetTotal - currentTotal) < 0.5 { return true }

        let ratio = targetTotal / currentTotal

        for index in items.indices {
            var item = items[index]
            item.unitPrice = max(0, (item.unitPrice * ratio).rounded())
            items[index] = item
        }

        reconcileTotal(to: targetTotal)
        persist()
        return abs(total - targetTotal) < 0.5
    }

    private func reconcileTotal(to targetTotal: Double) {
        var remaining = Int((targetTotal - total).rounded())
        guard remaining != 0 else { return }

        let orderedIndices = items.indices.sorted { items[$0].lineTotal > items[$1].lineTotal }
        var pass = 0

        while remaining != 0, pass < orderedIndices.count * 200 {
            let index = orderedIndices[pass % orderedIndices.count]
            let before = items[index].lineTotal
            var item = items[index]

            let step = remaining > 0 ? 1 : -1
            let newUnit = item.unitPrice + Double(step)
            guard newUnit >= 0 else {
                pass += 1
                continue
            }

            item.unitPrice = newUnit
            items[index] = item
            let actualDelta = Int((items[index].lineTotal - before).rounded())
            guard actualDelta != 0 else {
                pass += 1
                continue
            }

            remaining -= actualDelta
            pass += 1
        }
    }

    func adjustmentSummary(for delta: Double) -> String? {
        guard abs(delta) >= 0.5, !items.isEmpty else { return nil }
        let direction = delta >= 0 ? "increase" : "decrease"
        return "Spread \(direction) of \(PriceCalculator.formatted(abs(delta))) across all \(items.count) item\(items.count == 1 ? "" : "s") proportionally."
    }

    func load(items: [CartItem]) {
        self.items = items
        persist()
    }

    func applyLiveMarketPrices(priceForCode: (String) -> Double?) -> Int {
        var updatedCount = 0
        for index in items.indices {
            let code = items[index].code
            guard let price = priceForCode(code) else { continue }
            items[index].unitPrice = price.rounded()
            updatedCount += 1
        }
        if updatedCount > 0 {
            persist()
        }
        return updatedCount
    }

    func clear() {
        items.removeAll()
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CartItem].self, from: data) else { return }
        items = decoded
    }
}
