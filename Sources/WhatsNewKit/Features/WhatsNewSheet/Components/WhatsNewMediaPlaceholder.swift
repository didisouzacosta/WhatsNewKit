import SwiftUI

struct WhatsNewMediaPlaceholder: View {

    // MARK: - Properties

    let systemName: String

    // MARK: - Body

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.secondary.opacity(0.12))

            Image(systemName: systemName)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WhatsNewMediaPlaceholder(systemName: "photo")
        .aspectRatio(WhatsNewSheetLayout.mediaAspectRatio, contentMode: .fit)
        .padding()
}
