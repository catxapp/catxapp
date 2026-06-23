import SwiftUI
import UIKit

enum SavedCartPDFExporter {
    static func exportURL(for cart: SavedCart) -> URL? {
        guard let data = generatePDFData(for: cart) else { return nil }
        let filename = sanitizedFilename(cart.name) + ".pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private static func generatePDFData(for cart: SavedCart) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let bottomMargin: CGFloat = 48
        let rowHeight: CGFloat = 22

        let titleFont = UIFont.boldSystemFont(ofSize: 20)
        let metaFont = UIFont.systemFont(ofSize: 11)
        let headerFont = UIFont.boldSystemFont(ofSize: 11)
        let bodyFont = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        let totalFont = UIFont.boldSystemFont(ofSize: 14)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            var y = margin

            func beginPageIfNeeded(requiredHeight: CGFloat) {
                if y + requiredHeight > pageHeight - bottomMargin {
                    context.beginPage()
                    y = margin
                    drawTableHeader(at: &y, pageWidth: pageWidth, margin: margin, font: headerFont)
                }
            }

            func drawTableHeader(at y: inout CGFloat, pageWidth: CGFloat, margin: CGFloat, font: UIFont) {
                let columns = columnLayout(pageWidth: pageWidth, margin: margin)
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                "Code".draw(at: CGPoint(x: columns.code, y: y), withAttributes: attrs)
                "Price".draw(at: CGPoint(x: columns.price, y: y), withAttributes: attrs)
                "Qty".draw(at: CGPoint(x: columns.qty, y: y), withAttributes: attrs)
                "Brand".draw(at: CGPoint(x: columns.brand, y: y), withAttributes: attrs)
                "Total".draw(at: CGPoint(x: columns.lineTotal, y: y), withAttributes: attrs)
                y += rowHeight
            }

            context.beginPage()

            cart.name.draw(
                at: CGPoint(x: margin, y: y),
                withAttributes: [.font: titleFont]
            )
            y += 28

            let savedLine = "Saved \(formattedDate(cart.savedAt)) · \(cart.items.count) item\(cart.items.count == 1 ? "" : "s")"
            savedLine.draw(
                at: CGPoint(x: margin, y: y),
                withAttributes: [.font: metaFont, .foregroundColor: UIColor.gray]
            )
            y += 24

            drawTableHeader(at: &y, pageWidth: pageWidth, margin: margin, font: headerFont)

            let bodyAttrs: [NSAttributedString.Key: Any] = [.font: bodyFont]
            for item in cart.items {
                beginPageIfNeeded(requiredHeight: rowHeight)
                let columns = columnLayout(pageWidth: pageWidth, margin: margin)

                item.code.draw(at: CGPoint(x: columns.code, y: y), withAttributes: bodyAttrs)
                PriceCalculator.formatted(item.effectiveUnitPrice).draw(at: CGPoint(x: columns.price, y: y), withAttributes: bodyAttrs)
                "\(item.quantity)".draw(at: CGPoint(x: columns.qty, y: y), withAttributes: bodyAttrs)
                item.category.draw(at: CGPoint(x: columns.brand, y: y), withAttributes: bodyAttrs)
                PriceCalculator.formatted(item.lineTotal).draw(at: CGPoint(x: columns.lineTotal, y: y), withAttributes: bodyAttrs)
                y += rowHeight
            }

            beginPageIfNeeded(requiredHeight: 36)
            y += 12
            let totalLabel = "Cart Total: \(PriceCalculator.formatted(cart.total))"
            totalLabel.draw(
                at: CGPoint(x: margin, y: y),
                withAttributes: [.font: totalFont]
            )
        }
    }

    private struct ColumnLayout {
        let code: CGFloat
        let price: CGFloat
        let qty: CGFloat
        let brand: CGFloat
        let lineTotal: CGFloat
    }

    private static func columnLayout(pageWidth: CGFloat, margin: CGFloat) -> ColumnLayout {
        ColumnLayout(
            code: margin,
            price: margin + 170,
            qty: margin + 240,
            brand: margin + 280,
            lineTotal: pageWidth - margin - 70
        )
    }

    private static func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    private static func sanitizedFilename(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleaned = name.components(separatedBy: invalid).joined(separator: "_")
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "saved_cart" : trimmed
    }
}

struct CartPDFShareSheet: UIViewControllerRepresentable {
    let url: URL
    var onComplete: () -> Void = {}

    func makeUIViewController(context: Context) -> PDFShareHostViewController {
        let host = PDFShareHostViewController()
        host.configure(url: url, onComplete: onComplete)
        return host
    }

    func updateUIViewController(_ uiViewController: PDFShareHostViewController, context: Context) {}
}

final class PDFShareHostViewController: UIViewController {
    private var shareURL: URL?
    private var onComplete: (() -> Void)?
    private var didPresentShareSheet = false

    func configure(url: URL, onComplete: @escaping () -> Void) {
        shareURL = url
        self.onComplete = onComplete
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentShareSheetIfNeeded()
    }

    private func presentShareSheetIfNeeded() {
        guard !didPresentShareSheet, let shareURL else { return }
        didPresentShareSheet = true

        view.backgroundColor = .clear

        let activity = UIActivityViewController(
            activityItems: [shareURL],
            applicationActivities: nil
        )
        activity.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.onComplete?()
        }
        if let popover = activity.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(activity, animated: true)
    }
}
