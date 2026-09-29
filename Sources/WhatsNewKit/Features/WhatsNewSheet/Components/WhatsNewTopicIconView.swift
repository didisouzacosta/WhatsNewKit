import SwiftUI

struct WhatsNewTopicIconView: View {

    // MARK: - Properties

    let icon: WhatsNewTopicIcon

    // MARK: - Body

    var body: some View {
        switch icon {
        case let .systemImage(systemName):
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .image(name, bundle):
            Image(name, bundle: bundle)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    WhatsNewTopicIconView(icon: .systemImage("sparkles"))
        .frame(width: 32, height: 32)
}
