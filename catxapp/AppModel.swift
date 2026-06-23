import Foundation

enum AppTab: Hashable {
    case search
    case cart
    case settings
}

@MainActor
@Observable
final class AppModel {
    let catalog = CatalogStore()
    let pgm = PGMPriceService()
    let settings = SettingsStore()
    let cart = CartStore()
    let savedCarts = SavedCartsStore()
    let subscription = SubscriptionManager()
    let recent = RecentSearchStore()

    var searchQuery = ""
    var selectedTab: AppTab = .search
    var showPaywall = false
    var showSaveCartSheet = false
    var addToCartConverter: CatalyticConverter?
    var openPricingSettings = false

    func bootstrap() async {
        subscription.startListeningForTransactions()
        await catalog.load()
        pgm.loadConfig()
        await pgm.refreshIfNeeded()
        await subscription.loadProducts()
    }

    func price(for converter: CatalyticConverter) -> Double {
        PriceCalculator.displayPrice(
            anchorPrice: converter.anchorPrice,
            marginPercent: settings.marginPercent,
            anchorIndex: pgm.config?.anchorIndex ?? 1,
            currentIndex: pgm.currentIndex()
        )
    }

    func priceLabel(for converter: CatalyticConverter) -> String {
        PriceCalculator.formattedPrice(
            anchorPrice: converter.anchorPrice,
            displayPrice: price(for: converter)
        )
    }

    func searchResults() -> [CatalyticConverter] {
        catalog.search(query: searchQuery)
    }

    @discardableResult
    func performSearch() -> Bool {
        guard subscription.hasFullAccess else {
            showPaywall = true
            return false
        }
        return true
    }

    func presentAddToCart(_ converter: CatalyticConverter) {
        guard subscription.hasFullAccess else {
            showPaywall = true
            return
        }
        addToCartConverter = converter
    }

    func confirmAddToCart(unitPrice: Double, quantity: Int, integrityPercent: Double) {
        guard let converter = addToCartConverter else { return }
        cart.add(
            code: converter.code,
            category: converter.category,
            addedAnchorPrice: converter.anchorPrice,
            unitPrice: unitPrice,
            quantity: quantity,
            integrityPercent: integrityPercent
        )
        selectedTab = .search
        addToCartConverter = nil
    }

    func dismissAddToCart() {
        addToCartConverter = nil
    }

    func saveCurrentCart(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !cart.items.isEmpty else { return }
        savedCarts.save(name: trimmed, items: cart.items)
        showSaveCartSheet = false
    }

    func loadSavedCart(_ savedCart: SavedCart) {
        cart.load(items: savedCart.items)
    }

    func refreshCartWithLiveMarketPrices() async -> Int {
        await pgm.refresh()
        return cart.applyLiveMarketPrices { code in
            guard let converter = catalog.converter(for: code) else { return nil }
            return price(for: converter)
        }
    }

    func openPricingSettingsScreen() {
        guard subscription.hasFullAccess else {
            showPaywall = true
            return
        }
        selectedTab = .settings
        openPricingSettings = true
    }
}
