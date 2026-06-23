import SwiftUI

struct HighlightedSearchText: View {
    let text: String
    let query: String
    var font: Font = .subheadline

    var body: some View {
        highlightedText
            .font(font)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var highlightedText: Text {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return Text(text)
        }

        var composed = Text("")
        var searchStart = text.startIndex

        while searchStart < text.endIndex {
            let remaining = text[searchStart...]
            guard let matchRange = remaining.range(
                of: trimmedQuery,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) else {
                composed = composed + Text(String(remaining))
                break
            }

            if matchRange.lowerBound > searchStart {
                composed = composed + Text(String(text[searchStart..<matchRange.lowerBound]))
            }

            composed = composed + Text(String(text[matchRange])).bold()
            searchStart = matchRange.upperBound
        }

        return composed
    }
}
