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
        case .expired: "Trial Ended"
        }
    }
}

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var accessStatus: AccessStatus = .trialActive
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var isSubscribed = false
    private(set) var activeProductID: String?

    private let firstLaunchKey = "subscription.firstLaunchDate"
    private let trialLengthDays = 14
    private var updatesTask: Task<Void, Never>?

    var hasFullAccess: Bool {
        accessStatus == .trialActive || accessStatus == .subscribed
    }

    var trialDaysRemaining: Int? {
        guard accessStatus == .trialActive, let firstLaunch = firstLaunchDate else { return nil }
        let elapsed = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return max(0, trialLengthDays - elapsed)
    }

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionProductID.monthly }
    }

    var annualProduct: Product? {
        products.first { $0.id == SubscriptionProductID.annual }
    }

    init() {
        recordFirstLaunchIfNeeded()
        refreshAccessStatus()
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
        refreshAccessStatus()
    }

    func refreshEntitlements() async {
        var subscribed = false
        var productID: String?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionProductID.all.contains(transaction.productID) else { continue }
            subscribed = true
            productID = transaction.productID
        }

        isSubscribed = subscribed
        activeProductID = productID
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

    #if DEBUG
    func setDebugAccessStatus(_ status: AccessStatus) {
        accessStatus = status
        if status == .subscribed {
            isSubscribed = true
        } else if status == .expired {
            isSubscribed = false
        }
    }
    #endif

    private var firstLaunchDate: Date? {
        UserDefaults.standard.object(forKey: firstLaunchKey) as? Date
    }

    private func recordFirstLaunchIfNeeded() {
        guard UserDefaults.standard.object(forKey: firstLaunchKey) == nil else { return }
        UserDefaults.standard.set(Date(), forKey: firstLaunchKey)
    }

    private func refreshAccessStatus() {
        if isSubscribed {
            accessStatus = .subscribed
            return
        }

        guard let firstLaunch = firstLaunchDate else {
            accessStatus = .trialActive
            return
        }

        let elapsed = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        accessStatus = elapsed < trialLengthDays ? .trialActive : .expired
    }
}
