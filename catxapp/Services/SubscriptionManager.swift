import Foundation
import StoreKit

enum SubscriptionProductID {
    static let monthly = "quantumficial.catxapp.monthly"
    static let annual = "quantumficial.catxapp.annual"

    static let all = [monthly, annual]
}

enum AccessStatus: String, CaseIterable, Identifiable, Sendable {
    case trialActive
    case subscribed
    case expired

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trialActive: "Free Trial"
        case .subscribed: "Subscribed"
        case .expired: "Subscription Required"
        }
    }
}

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var accessStatus: AccessStatus = .expired
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var isSubscribed = false
    private(set) var isInIntroOfferPeriod = false
    private(set) var activeProductID: String?
    private(set) var subscriptionExpirationDate: Date?

    private var updatesTask: Task<Void, Never>?

    var hasFullAccess: Bool {
        isSubscribed
    }

    var trialDaysRemaining: Int? {
        guard accessStatus == .trialActive, let expiration = subscriptionExpirationDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiration).day ?? 0
        return max(0, days)
    }

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionProductID.monthly }
    }

    var annualProduct: Product? {
        products.first { $0.id == SubscriptionProductID.annual }
    }

    func startListeningForTransactions() {
        guard updatesTask == nil else { return }

        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        products = (try? await Product.products(for: SubscriptionProductID.all)) ?? []
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var entitled = false
        var productID: String?
        var inIntro = false
        var expiration: Date?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionProductID.all.contains(transaction.productID) else { continue }

            entitled = true
            productID = transaction.productID
            inIntro = transaction.offer?.type == .introductory
            if let transactionExpiration = transaction.expirationDate {
                expiration = transactionExpiration
            }
        }

        isSubscribed = entitled
        isInIntroOfferPeriod = entitled && inIntro
        activeProductID = productID
        subscriptionExpirationDate = expiration
        refreshAccessStatus()
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlements()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    func requiresPaywall() -> Bool {
        !hasFullAccess
    }

    func purchaseButtonTitle(for product: Product) -> String {
        if let intro = product.subscription?.introductoryOffer, intro.paymentMode == .freeTrial {
            return "Start \(introPeriodLabel(intro)) Free Trial — then \(product.displayPrice)"
        }

        switch product.id {
        case SubscriptionProductID.monthly:
            return "Subscribe — \(product.displayPrice)/mo"
        case SubscriptionProductID.annual:
            return "Subscribe — \(product.displayPrice)/yr"
        default:
            return "Subscribe — \(product.displayPrice)"
        }
    }

    #if DEBUG
    func setDebugAccessStatus(_ status: AccessStatus) {
        accessStatus = status
        switch status {
        case .trialActive:
            isSubscribed = true
            isInIntroOfferPeriod = true
            subscriptionExpirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        case .subscribed:
            isSubscribed = true
            isInIntroOfferPeriod = false
        case .expired:
            isSubscribed = false
            isInIntroOfferPeriod = false
            subscriptionExpirationDate = nil
            activeProductID = nil
        }
    }
    #endif

    private func refreshAccessStatus() {
        guard isSubscribed else {
            accessStatus = .expired
            return
        }

        accessStatus = isInIntroOfferPeriod ? .trialActive : .subscribed
    }

    private func introPeriodLabel(_ offer: Product.SubscriptionOffer) -> String {
        let totalDays = offer.period.value * offer.periodCount
        switch offer.period.unit {
        case .day where totalDays == 14:
            return "14-Day"
        case .day:
            return "\(totalDays)-Day"
        case .week:
            return totalDays == 1 ? "1-Week" : "\(totalDays)-Week"
        case .month:
            return totalDays == 1 ? "1-Month" : "\(totalDays)-Month"
        case .year:
            return totalDays == 1 ? "1-Year" : "\(totalDays)-Year"
        @unknown default:
            return "14-Day"
        }
    }
}
