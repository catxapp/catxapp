import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var app
    @FocusState private var isSearchFocused: Bool
    @State private var isSearchSubmitted = false
    @State private var selectedResultCode: String?

    private let suggestionsMaxHeight: CGFloat = 280

    var body: some View {
        @Bindable var app = app

        NavigationStack {
            VStack(spacing: 16) {
                CatXappWordmark()
                    .frame(maxWidth: .infinity, alignment: .leading)

                searchSection(query: $app.searchQuery)

                if isSearchSubmitted, !showSuggestions {
                    submittedResultsSection
                }

                selectedDetailSection

                if app.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    placeholderSection
                }

                if !app.recent.codes.isEmpty, !isSearchFocused, !isSearchSubmitted {
                    recentSection
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Pricing") {
                        app.openPricingSettingsScreen()
                    }
                    .font(.subheadline.weight(.medium))
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func searchSection(query: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            searchBar(query: query)

            PGMMarketStripView(
                quote: app.pgm.quote,
                isRefreshing: app.pgm.isRefreshing,
                onRefresh: {
                    Task { await app.pgm.refresh() }
                }
            )

            HStack {
                if let days = app.subscription.trialDaysRemaining, app.subscription.accessStatus == .trialActive {
                    Text("\(days) day\(days == 1 ? "" : "s") left in free trial")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if app.subscription.accessStatus == .expired {
                    Text("Trial ended — subscribe to continue")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Spacer()
            }

            if let loadError = app.catalog.loadError {
                Text(loadError)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if app.catalog.isLoaded && app.catalog.converters.isEmpty {
                Text("Catalog is empty — delete the app and rebuild in Xcode.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .overlay(alignment: .topLeading) {
            if showSuggestions {
                suggestionsDropdown
                    .padding(.top, searchBarHeight + 4)
            }
        }
        .zIndex(1)
    }

    private let searchBarHeight: CGFloat = 48

    private func searchBar(query: Binding<String>) -> some View {
        HStack(spacing: 10) {
            TextField("Enter code or brand", text: query)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.title3.monospaced())
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    submitSearch()
                }
                .onChange(of: app.searchQuery) { _, _ in
                    if isSearchFocused {
                        isSearchSubmitted = false
                        selectedResultCode = nil
                    }
                }

            if !app.searchQuery.isEmpty {
                Button {
                    clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(height: searchBarHeight)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isSearchFocused ? Color.accentColor : Color(.separator),
                    lineWidth: isSearchFocused ? 1.5 : 1
                )
        }
    }

    private var suggestionsDropdown: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 0) {
                ForEach(suggestions) { converter in
                    Button {
                        selectSuggestion(converter)
                    } label: {
                        suggestionRow(for: converter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if converter.id != suggestions.last?.id {
                        Divider()
                            .padding(.leading, 14)
                    }
                }
            }
        }
        .frame(height: suggestionsDropdownHeight)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .allowsHitTesting(true)
    }

    private func suggestionRow(for converter: CatalyticConverter) -> some View {
        HStack(spacing: 6) {
            HighlightedSearchText(
                text: converter.code,
                query: app.searchQuery,
                font: .subheadline.monospaced()
            )
            Text("|")
                .foregroundStyle(.tertiary)
            HighlightedSearchText(
                text: converter.category,
                query: app.searchQuery,
                font: .subheadline
            )
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }

    private var suggestionsDropdownHeight: CGFloat {
        let rowHeight: CGFloat = 44
        let contentHeight = CGFloat(suggestions.count) * rowHeight
        return min(contentHeight, suggestionsMaxHeight)
    }

    @ViewBuilder
    private var submittedResultsSection: some View {
        if submittedResults.isEmpty {
            ContentUnavailableView.search(text: app.searchQuery)
                .frame(maxHeight: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(submittedResultsHeader)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(submittedResults) { converter in
                            Button {
                                selectResult(converter)
                            } label: {
                                SearchResultRow(
                                    converter: converter,
                                    query: app.searchQuery,
                                    priceLabel: app.priceLabel(for: converter),
                                    isSelected: selectedResultCode == converter.code
                                )
                            }
                            .buttonStyle(.plain)

                            if converter.id != submittedResults.last?.id {
                                Divider()
                                    .padding(.leading, 14)
                            }
                        }
                    }
                }
                .frame(maxHeight: submittedResultsListHeight)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private var selectedDetailSection: some View {
        if let converter = selectedConverter, !showSuggestions, shouldShowDetail {
            ConverterRow(converter: converter)
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                }
        }
    }

    @ViewBuilder
    private var placeholderSection: some View {
        if !app.catalog.isLoaded {
            ProgressView("Loading catalog…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else if !isSearchFocused, !isSearchSubmitted, app.searchQuery.isEmpty {
            ContentUnavailableView(
                "Search converters",
                systemImage: "text.magnifyingglass",
                description: Text("Type a full or partial code from your catalog.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(app.recent.codes, id: \.self) { code in
                        Button(code) {
                            openRecentCode(code)
                        }
                        .font(.caption.monospaced())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var showSuggestions: Bool {
        isSearchFocused
            && !app.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
            && !suggestions.isEmpty
    }

    private var submittedResultsListHeight: CGFloat {
        let rowHeight: CGFloat = 52
        let contentHeight = CGFloat(submittedResults.count) * rowHeight
        return min(max(contentHeight, rowHeight), 360)
    }

    private var shouldShowDetail: Bool {
        !isSearchSubmitted || selectedResultCode != nil
    }

    private var suggestions: [CatalyticConverter] {
        app.searchResults()
    }

    private var submittedResults: [CatalyticConverter] {
        app.searchResults()
    }

    private var submittedResultsHeader: String {
        let count = submittedResults.count
        let query = app.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let noun = count == 1 ? "code" : "codes"
        return "\(count) \(noun) matching \"\(query)\""
    }

    private var selectedConverter: CatalyticConverter? {
        if let code = selectedResultCode {
            return app.catalog.converter(for: code)
        }
        if !isSearchSubmitted {
            return app.catalog.converter(for: app.searchQuery)
        }
        return nil
    }

    private func clearSearch() {
        app.searchQuery = ""
        isSearchSubmitted = false
        selectedResultCode = nil
    }

    private func submitSearch() {
        guard app.performSearch() else { return }
        isSearchFocused = false
        isSearchSubmitted = true
        selectedResultCode = nil
    }

    private func selectSuggestion(_ converter: CatalyticConverter) {
        guard app.subscription.hasFullAccess else {
            app.showPaywall = true
            return
        }
        isSearchFocused = false
        app.searchQuery = converter.code
        selectedResultCode = converter.code
        isSearchSubmitted = false
        app.recent.add(converter.code)
    }

    private func selectResult(_ converter: CatalyticConverter) {
        guard app.subscription.hasFullAccess else {
            app.showPaywall = true
            return
        }
        selectedResultCode = converter.code
        app.recent.add(converter.code)
    }

    private func openRecentCode(_ code: String) {
        guard app.performSearch() else { return }
        isSearchFocused = false
        app.searchQuery = code
        selectedResultCode = code
        isSearchSubmitted = false
        app.recent.add(code)
    }
}

private struct SearchResultRow: View {
    let converter: CatalyticConverter
    let query: String
    let priceLabel: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HighlightedSearchText(
                    text: converter.code,
                    query: query,
                    font: .body.monospaced().weight(.medium)
                )
                Text(converter.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(priceLabel)
                .font(.body.bold())
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
    }
}

struct ConverterRow: View {
    @Environment(AppModel.self) private var app
    let converter: CatalyticConverter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(converter.code)
                    .font(.headline.monospaced())
                Text(converter.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(app.priceLabel(for: converter))
                    .font(.title2.bold())
            }

            if app.subscription.hasFullAccess {
                Button {
                    app.presentAddToCart(converter)
                } label: {
                    Image(systemName: "cart.badge.plus")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard app.subscription.hasFullAccess else {
                app.showPaywall = true
                return
            }
            app.recent.add(converter.code)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppModel())
}
