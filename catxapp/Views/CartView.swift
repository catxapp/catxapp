import SwiftUI

private enum CartSortColumn: String, CaseIterable {
    case code
    case price
    case quantity
    case brand

    var title: String {
        switch self {
        case .code: "Code"
        case .price: "Unit Price USD"
        case .quantity: "Quantity"
        case .brand: "Brand"
        }
    }
}

private enum CartTableLayout {
    static let activeWidth: CGFloat = 76
    static let codeWidth: CGFloat = 130
    static let priceWidth: CGFloat = 108
    static let quantityWidth: CGFloat = 64
    static let brandWidth: CGFloat = 88
    static let columnSpacing: CGFloat = 12
    static let minTableWidth: CGFloat = 560
}

private enum SortDirection {
    case ascending
    case descending

    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

struct CartView: View {
    @Environment(AppModel.self) private var app

    @State private var searchText = ""
    @State private var selectedIDs: Set<UUID> = []
    @State private var sortColumn: CartSortColumn?
    @State private var sortDirection: SortDirection = .ascending
    @State private var pageSize = 10
    @State private var currentPage = 0
    @State private var showDeleteListConfirm = false
    @State private var showAdjustTotalSheet = false
    @State private var isRefreshingCartPrices = false
    @State private var cartPriceRefreshMessage: String?

    var body: some View {
        @Bindable var app = app

        NavigationStack {
            Group {
                if !app.subscription.hasFullAccess {
                    subscriptionRequiredView
                } else if app.cart.items.isEmpty {
                    ContentUnavailableView(
                        "Cart is empty",
                        systemImage: "cart",
                        description: Text("Tap the cart icon on a search result to add it here.")
                    )
                } else {
                    cartContent
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                if app.subscription.hasFullAccess {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SavedCartsView()
                        } label: {
                            Text("Saved")
                        }
                    }
                }
            }
            .sheet(isPresented: $app.showSaveCartSheet) {
                SaveCartSheet()
            }
            .sheet(isPresented: $showAdjustTotalSheet) {
                AdjustCartTotalSheet()
            }
            .alert("Delete entire cart?", isPresented: $showDeleteListConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete list", role: .destructive) {
                    app.cart.clear()
                    selectedIDs.removeAll()
                    currentPage = 0
                }
            } message: {
                Text("Remove all items from the active cart?")
            }
        }
    }

    private var subscriptionRequiredView: some View {
        ContentUnavailableView {
            Label("Subscription Required", systemImage: "cart")
        } description: {
            Text("Subscribe to manage converters in your cart.")
        } actions: {
            Button("View Plans") {
                app.showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var cartContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                totalBadge
                searchBar
                cartTable
                paginationBar
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer(minLength: 0)

            bottomActionBar
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: searchText) { _, _ in
            currentPage = 0
            selectedIDs.removeAll()
        }
        .onChange(of: app.cart.totalQuantity) { _, _ in
            clampCurrentPage()
        }
    }

    private var totalBadge: some View {
        HStack {
            Spacer()
            Button {
                showAdjustTotalSheet = true
            } label: {
                HStack(spacing: 6) {
                    Text(PriceCalculator.formatted(cartTotal) + " USD")
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.systemBackground))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.label))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            }

            Button {
                deleteSelected()
            } label: {
                Image(systemName: "trash")
                    .font(.body)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color(.separator), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(selectedIDs.isEmpty)
            .foregroundStyle(selectedIDs.isEmpty ? .secondary : .primary)
        }
    }

    private var cartTable: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                tableHeader
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(pagedItems) { item in
                            CartTableRow(
                                item: item,
                                isSelected: selectedIDs.contains(item.id),
                                onToggleSelected: { toggleSelection(item.id) },
                                onQuantityChange: { newQty in
                                    app.cart.updateQuantity(for: item, quantity: newQty)
                                }
                            )
                            if item.id != pagedItems.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            .frame(minWidth: CartTableLayout.minTableWidth)
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: CartTableLayout.columnSpacing) {
            Button {
                toggleSelectAllVisible()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: allVisibleSelected ? "checkmark.square.fill" : "square")
                    Text("Active")
                }
                .frame(width: CartTableLayout.activeWidth, alignment: .leading)
            }
            .buttonStyle(.plain)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

            ForEach(CartSortColumn.allCases, id: \.self) { column in
                if column == .brand {
                    cartColumnDivider
                }

                Button {
                    toggleSort(column)
                } label: {
                    HStack(spacing: 2) {
                        Text(column.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if sortColumn == column {
                            Image(systemName: sortDirection == .ascending ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                    }
                    .frame(
                        width: columnWidth(for: column),
                        alignment: column == .price || column == .quantity ? .trailing : .leading
                    )
                }
                .buttonStyle(.plain)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    private var cartColumnDivider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1, height: 20)
    }

    private var paginationBar: some View {
        HStack {
            Button {
                currentPage = max(0, currentPage - 1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(currentPage == 0)

            Text("\(currentPage + 1)")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Button {
                currentPage = min(totalPages - 1, currentPage + 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentPage >= totalPages - 1)

            Spacer()

            Menu {
                Button("10 per page") { pageSize = 10; currentPage = 0 }
                Button("25 per page") { pageSize = 25; currentPage = 0 }
                Button("50 per page") { pageSize = 50; currentPage = 0 }
            } label: {
                HStack(spacing: 4) {
                    Text("\(pageSize)")
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .font(.subheadline)
            }

            Text(pageRangeLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    isRefreshingCartPrices = true
                    cartPriceRefreshMessage = nil
                    let updated = await app.refreshCartWithLiveMarketPrices()
                    isRefreshingCartPrices = false
                    if updated == 0 {
                        cartPriceRefreshMessage = "No items could be updated."
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if isRefreshingCartPrices {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Load live market price")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .foregroundStyle(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.accentColor, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .disabled(isRefreshingCartPrices)

            if let cartPriceRefreshMessage {
                Text(cartPriceRefreshMessage)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button("Delete list") {
                    showDeleteListConfirm = true
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .foregroundStyle(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.orange, lineWidth: 1)
                }

                Button {
                    app.showSaveCartSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var filteredItems: [CartItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var items = app.cart.items
        if !query.isEmpty {
            items = items.filter {
                $0.code.localizedCaseInsensitiveContains(query)
                    || $0.category.localizedCaseInsensitiveContains(query)
            }
        }
        guard let sortColumn else { return items }
        return items.sorted { lhs, rhs in
            let ordered: Bool
            switch sortColumn {
            case .code:
                ordered = lhs.code.localizedCaseInsensitiveCompare(rhs.code) == .orderedAscending
            case .price:
                ordered = lhs.effectiveUnitPrice < rhs.effectiveUnitPrice
            case .quantity:
                ordered = lhs.quantity < rhs.quantity
            case .brand:
                ordered = lhs.category.localizedCaseInsensitiveCompare(rhs.category) == .orderedAscending
            }
            return sortDirection == .ascending ? ordered : !ordered
        }
    }

    private var pagedItems: [CartItem] {
        let start = currentPage * pageSize
        guard start < filteredItems.count else { return [] }
        let end = min(start + pageSize, filteredItems.count)
        return Array(filteredItems[start..<end])
    }

    private var totalPages: Int {
        max(1, Int(ceil(Double(filteredItems.count) / Double(pageSize))))
    }

    private var cartTotal: Double {
        app.cart.total
    }

    private var allVisibleSelected: Bool {
        !pagedItems.isEmpty && pagedItems.allSatisfy { selectedIDs.contains($0.id) }
    }

    private var pageRangeLabel: String {
        let total = filteredItems.count
        guard total > 0 else { return "0 items" }
        let start = currentPage * pageSize + 1
        let end = min((currentPage + 1) * pageSize, total)
        return "\(start) to \(end) of \(total) items"
    }

    private func columnWidth(for column: CartSortColumn) -> CGFloat {
        switch column {
        case .code: CartTableLayout.codeWidth
        case .price: CartTableLayout.priceWidth
        case .quantity: CartTableLayout.quantityWidth
        case .brand: CartTableLayout.brandWidth
        }
    }

    private func toggleSort(_ column: CartSortColumn) {
        if sortColumn == column {
            sortDirection.toggle()
        } else {
            sortColumn = column
            sortDirection = .ascending
        }
    }

    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func toggleSelectAllVisible() {
        if allVisibleSelected {
            pagedItems.forEach { selectedIDs.remove($0.id) }
        } else {
            pagedItems.forEach { selectedIDs.insert($0.id) }
        }
    }

    private func deleteSelected() {
        app.cart.remove(ids: selectedIDs)
        selectedIDs.removeAll()
        clampCurrentPage()
    }

    private func clampCurrentPage() {
        if currentPage >= totalPages {
            currentPage = max(0, totalPages - 1)
        }
    }
}

private struct CartTableRow: View {
    let item: CartItem
    let isSelected: Bool
    let onToggleSelected: () -> Void
    let onQuantityChange: (Int) -> Void

    @State private var quantityText: String = ""

    var body: some View {
        HStack(spacing: CartTableLayout.columnSpacing) {
            Button(action: onToggleSelected) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .frame(width: CartTableLayout.activeWidth, alignment: .leading)
            }
            .buttonStyle(.plain)

            Text(item.code)
                .font(.subheadline.monospaced())
                .frame(width: CartTableLayout.codeWidth, alignment: .leading)
                .lineLimit(1)

            VStack(alignment: .trailing, spacing: 2) {
                Text(PriceCalculator.formattedCartUnitPrice(item.effectiveUnitPrice))
                    .font(.subheadline)
                if item.integrityPercent < 100 {
                    Text("\(Int(item.integrityPercent.rounded()))% integrity")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: CartTableLayout.priceWidth, alignment: .trailing)

            TextField("1", text: $quantityText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.subheadline.monospaced())
                .frame(width: CartTableLayout.quantityWidth)
                .onAppear {
                    quantityText = "\(item.quantity)"
                }
                .onChange(of: item.quantity) { _, newValue in
                    quantityText = "\(newValue)"
                }
                .onChange(of: quantityText) { _, newValue in
                    let trimmed = newValue.filter(\.isNumber)
                    if trimmed != newValue { quantityText = trimmed }
                    if let qty = Int(trimmed), qty >= 1 {
                        onQuantityChange(qty)
                    }
                }

            Rectangle()
                .fill(Color(.separator))
                .frame(width: 1, height: 20)

            Text(item.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: CartTableLayout.brandWidth, alignment: .leading)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
    }
}

#Preview {
    CartView()
        .environment(AppModel())
}
