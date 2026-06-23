import SwiftUI

extension View {
    @ViewBuilder
    func cartBadge(_ count: Int) -> some View {
        if count > 0 {
            badge(count)
        } else {
            self
        }
    }
}

struct MainTabView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var app = app

        TabView(selection: $app.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(AppTab.cart)
                .cartBadge(app.cart.totalQuantity)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
        .sheet(isPresented: $app.showPaywall) {
            PaywallView()
        }
        .sheet(item: $app.addToCartConverter) { converter in
            AddToCartSheet(converter: converter)
        }
    }
}
