import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var isRestoring = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(headline)
                        .font(.largeTitle.bold())

                    Text(subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 10) {
                        featureRow("Unlimited converter search")
                        featureRow("Live PGM-adjusted prices")
                        featureRow("Cart with gain/loss tracking")
                        featureRow("Profit margin calculator")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))

                    if app.subscription.products.isEmpty {
                        #if DEBUG
                        Text("Connect App Store products in App Store Connect to enable purchases. For Simulator testing, select Products.storekit in your Xcode scheme.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        #else
                        Text("Subscription options are loading. Check your connection and try again.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        #endif
                    } else {
                        if let monthly = app.subscription.monthlyProduct {
                            purchaseButton(product: monthly)
                        }

                        if let annual = app.subscription.annualProduct {
                            purchaseButton(product: annual)
                        }
                    }

                    Button {
                        Task {
                            isRestoring = true
                            errorMessage = nil
                            await app.subscription.restorePurchases()
                            isRestoring = false
                            if app.subscription.hasFullAccess {
                                dismiss()
                            } else {
                                errorMessage = "No active subscription found."
                            }
                        }
                    } label: {
                        if isRestoring {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Restore Purchases")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.bordered)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start a 14-day free trial through the App Store. Payment is charged to your Apple ID after the trial unless you cancel earlier. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Link("Privacy Policy", destination: AppLinks.privacyPolicy)
                            Link("Support", destination: AppLinks.support)
                        }
                        .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Subscribe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headline: String {
        if app.subscription.accessStatus == .expired {
            return "Start your free trial"
        }
        return "Subscribe to CatXapp"
    }

    private var subheadline: String {
        "Get live PGM-adjusted pricing and yard tools with a 14-day free trial, managed by Apple."
    }

    private func featureRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.secondary)
    }

    private func purchaseButton(product: Product) -> some View {
        Button {
            Task {
                errorMessage = nil
                do {
                    try await app.subscription.purchase(product)
                    if app.subscription.hasFullAccess {
                        dismiss()
                    }
                } catch {
                    errorMessage = "Purchase could not be completed."
                }
            }
        } label: {
            Text(app.subscription.purchaseButtonTitle(for: product))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    PaywallView()
        .environment(AppModel())
}
