import SwiftUI

struct SavedCartsView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var previewCart: SavedCart?
    @State private var cartToLoad: SavedCart?
    @State private var cartToDelete: SavedCart?
    @State private var pdfShareItem: PDFShareItem?

    var body: some View {
        Group {
            if app.savedCarts.allCarts.isEmpty {
                ContentUnavailableView(
                    "No saved carts",
                    systemImage: "tray",
                    description: Text("Save your active cart to keep a named snapshot.")
                )
            } else {
                List {
                    ForEach(app.savedCarts.allCarts) { savedCart in
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(savedCart.name)
                                    .font(.headline)
                                Text("\(savedCart.items.count) item\(savedCart.items.count == 1 ? "" : "s") · \(PriceCalculator.formatted(savedCart.total))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(savedCart.savedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Button("Preview") {
                                        previewCart = savedCart
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Load cart") {
                                        cartToLoad = savedCart
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Download PDF") {
                                        exportPDF(savedCart)
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Delete") {
                                        cartToDelete = savedCart
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                }
                                .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Saved Carts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $previewCart) { cart in
            SavedCartPreviewSheet(savedCart: cart)
        }
        .sheet(item: $pdfShareItem) { item in
            CartPDFShareSheet(url: item.url) {
                pdfShareItem = nil
            }
            .presentationBackground(.clear)
            .interactiveDismissDisabled(false)
        }
        .alert("Load cart?", isPresented: Binding(
            get: { cartToLoad != nil },
            set: { if !$0 { cartToLoad = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                cartToLoad = nil
            }
            Button("Load") {
                if let cart = cartToLoad {
                    app.loadSavedCart(cart)
                    cartToLoad = nil
                    dismiss()
                }
            }
        } message: {
            if app.cart.items.isEmpty {
                Text("This will load the saved cart into your active cart.")
            } else {
                Text("This will replace your current active cart with the saved cart.")
            }
        }
        .alert("Delete saved cart?", isPresented: Binding(
            get: { cartToDelete != nil },
            set: { if !$0 { cartToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                cartToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let cart = cartToDelete {
                    app.savedCarts.delete(id: cart.id)
                    cartToDelete = nil
                }
            }
        } message: {
            if let cart = cartToDelete {
                Text("Delete \"\(cart.name)\" permanently?")
            }
        }
    }

    private func exportPDF(_ savedCart: SavedCart) {
        guard let url = SavedCartPDFExporter.exportURL(for: savedCart) else { return }
        pdfShareItem = PDFShareItem(url: url)
    }
}

private struct PDFShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

#Preview {
    NavigationStack {
        SavedCartsView()
            .environment(AppModel())
    }
}
