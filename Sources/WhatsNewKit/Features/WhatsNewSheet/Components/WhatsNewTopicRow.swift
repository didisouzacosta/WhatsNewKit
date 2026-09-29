import SwiftUI

struct WhatsNewTopicRow: View {

    // MARK: - Properties

    let topic: WhatsNewTopic

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let icon = topic.icon {
                WhatsNewTopicIconView(icon: icon)
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(topic.title)
                    .font(.headline)

                Text(topic.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
    #Preview {
        WhatsNewTopicRow(topic: WhatsNewPreviewFixtures.topics[0])
            .padding()
    }
#endif
