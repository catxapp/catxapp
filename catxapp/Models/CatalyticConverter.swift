import Foundation

struct CatalyticConverter: Identifiable, Codable, Hashable, Sendable {
    var id: String { code }
    let code: String
    let category: String
    let anchorPrice: Double
}

struct CatalogDocument: Codable, Sendable {
    let supplier: String
    let anchorDate: String
    let entryCount: Int
    let entries: [CatalyticConverter]
}

struct PGMWeights: Codable, Sendable {
    let pt: Double
    let pd: Double
    let rh: Double
}

struct PGMPriceListAnchor: Codable, Sendable {
    let date: String
    let pdfFile: String
    let kitcoSpot: PGMSpot
    let kitcoNotes: String?
}

struct PGMConfigDocument: Codable, Sendable {
    let weights: PGMWeights
    let anchorDate: String
    let anchorIndex: Double
    let priceType: String?
    let indexFormula: String?
    let livePriceFormula: String?
    let historical: [String: PGMSpot]
    let priceLists: [PGMPriceListAnchor]?
    let calibrationRMSE: Double?
    let matchedPairs: Int?
}

struct PGMSpot: Codable, Sendable {
    let pt: Double
    let pd: Double
    let rh: Double
}

struct PGMQuote: Sendable {
    let pt: Double
    let pd: Double
    let rh: Double
    let updatedAt: Date
}

struct CartItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let code: String
    let category: String
    let addedAnchorPrice: Double
    let addedAt: Date
    var quantity: Int
    var unitPrice: Double
    var integrityPercent: Double

    var lineTotal: Double {
        unitPrice * Double(quantity) * (integrityPercent / 100)
    }

    /// Pay price per unit after integrity adjustment.
    var effectiveUnitPrice: Double {
        unitPrice * (integrityPercent / 100)
    }

    init(
        code: String,
        category: String,
        addedAnchorPrice: Double,
        unitPrice: Double,
        quantity: Int = 1,
        integrityPercent: Double = 100
    ) {
        self.id = UUID()
        self.code = code
        self.category = category
        self.addedAnchorPrice = addedAnchorPrice
        self.addedAt = Date()
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.integrityPercent = integrityPercent
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        category = try container.decode(String.self, forKey: .category)
        addedAnchorPrice = try container.decode(Double.self, forKey: .addedAnchorPrice)
        addedAt = try container.decode(Date.self, forKey: .addedAt)
        quantity = try container.decode(Int.self, forKey: .quantity)
        integrityPercent = try container.decodeIfPresent(Double.self, forKey: .integrityPercent) ?? 100
        unitPrice = try container.decodeIfPresent(Double.self, forKey: .unitPrice) ?? addedAnchorPrice
    }
}

struct SavedCart: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    let savedAt: Date
    var items: [CartItem]

    var total: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    init(name: String, items: [CartItem]) {
        self.id = UUID()
        self.name = name
        self.savedAt = Date()
        self.items = items
    }
}
