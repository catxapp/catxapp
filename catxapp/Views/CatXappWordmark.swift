import SwiftUI

struct CatXappWordmark: View {
    var font: Font = .largeTitle.bold()

    private let brandBlue = Color(red: 0.231, green: 0.510, blue: 0.965)

    var body: some View {
        HStack(spacing: 0) {
            Text("cat")
            Text("X")
                .foregroundStyle(brandBlue)
            Text("app")
        }
        .font(font)
        .tracking(-0.4)
        .accessibilityLabel("CatXapp")
    }
}

#Preview {
    CatXappWordmark()
        .padding()
        .preferredColorScheme(.dark)
}
