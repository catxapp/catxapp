import SwiftUI

struct SavedCartPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss

    let savedCart: SavedCart

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    cartTableHeader

                    ForEach(savedCart.items) { item in
                        Divider()
                        savedCartRow(item)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(PriceCalculator.formatted(savedCart.total))
                            .font(.title3.bold())
                    }

                    Text("Saved \(savedCart.savedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(savedCart.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var cartTableHeader: some View {
        HStack(spacing: 8) {
            Text("Code")
                .frame(minWidth: 90, alignment: .leading)
            Text("Price")
                .frame(width: 56, alignment: .trailing)
            Text("Qty")
                .frame(width: 36, alignment: .trailing)
            Text("Brand")
                .frame(minWidth: 60, alignment: .leading)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    private func savedCartRow(_ item: CartItem) -> some View {
        HStack(spacing: 8) {
            Text(item.code)
                .font(.subheadline.monospaced())
                .frame(minWidth: 90, alignment: .leading)
                .lineLimit(1)

            Text(PriceCalculator.formatted(item.effectiveUnitPrice))
                .font(.subheadline)
                .frame(width: 56, alignment: .trailing)

            Text("\(item.quantity)")
                .font(.subheadline)
                .frame(width: 36, alignment: .trailing)

            Text(item.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minWidth: 60, alignment: .leading)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

#Preview {
    SavedCartPreviewSheet(savedCart: SavedCart(
        name: "Morning Load",
        items: [
            CartItem(code: "9EA", category: "Ford", addedAnchorPrice: 200, unitPrice: 209, quantity: 2)
        ]
    ))
}
