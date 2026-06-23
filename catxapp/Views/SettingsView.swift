import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.openURL) private var openURL

    var body: some View {
        @Bindable var app = app

        NavigationStack {
            Form {
                subscriptionSection
                pricingSection
                debugSection
            }
            .navigationTitle("Settings")
            .navigationDestination(isPresented: $app.openPricingSettings) {
                PricingSettingsView()
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            LabeledContent("Status", value: app.subscription.accessStatus.title)

            if let days = app.subscription.trialDaysRemaining, app.subscription.accessStatus == .trialActive {
                LabeledContent("Trial remaining", value: "\(days) day\(days == 1 ? "" : "s")")
            }

            if app.subscription.isSubscribed, let productID = app.subscription.activeProductID {
                LabeledContent("Plan", value: planLabel(for: productID))
            }

            if !app.subscription.hasFullAccess {
                Button("Subscribe") {
                    app.showPaywall = true
                }
            } else if app.subscription.isSubscribed {
                Button("Manage Subscription") {
                    openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)
                }
            } else {
                Button("View Plans") {
                    app.showPaywall = true
                }
            }
        }
    }

    private var pricingSection: some View {
        Section("Pricing") {
            if app.subscription.hasFullAccess {
                NavigationLink {
                    PricingSettingsView()
                } label: {
                    Text("Pricing")
                }
            } else {
                Button {
                    app.showPaywall = true
                } label: {
                    HStack {
                        Text("Pricing")
                        Spacer()
                        Text("Subscribe")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var debugSection: some View {
        #if DEBUG
        Section("Debug") {
            Picker("Access", selection: Binding(
                get: { app.subscription.accessStatus },
                set: { app.subscription.setDebugAccessStatus($0) }
            )) {
                ForEach(AccessStatus.allCases) { status in
                    Text(status.title).tag(status)
                }
            }
        }
        #endif
    }

    private func planLabel(for productID: String) -> String {
        switch productID {
        case SubscriptionProductID.monthly: "Monthly"
        case SubscriptionProductID.annual: "Annual"
        default: productID
        }
    }

}

#Preview {
    SettingsView()
        .environment(AppModel())
}
