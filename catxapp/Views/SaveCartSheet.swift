import SwiftUI

struct SaveCartSheet: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var cartName = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) {
                        Text("Cart name")
                        Text("*")
                            .foregroundStyle(.red)
                    }
                    .font(.subheadline.weight(.medium))

                    TextField("Enter cart name", text: $cartName)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Save Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        app.showSaveCartSheet = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submit()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func submit() {
        let trimmed = cartName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationMessage = "Enter a cart name."
            return
        }
        validationMessage = nil
        app.saveCurrentCart(name: trimmed)
        dismiss()
    }
}

#Preview {
    SaveCartSheet()
        .environment(AppModel())
}
