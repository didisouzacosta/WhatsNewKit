import Testing
@testable import WhatsNewKit

@Suite("WhatsNew topics")
struct WhatsNewTopicTests {
    @Test("topics can provide a system image icon")
    func topicsCanProvideSystemImageIcon() {
        let topic = WhatsNewTopic(
            title: "Fast loading",
            description: "Images are cached after the first load.",
            icon: .systemImage("photo")
        )

        #expect(topic.icon == .systemImage("photo"))
    }

    @Test("topics can provide an asset image icon")
    func topicsCanProvideAssetImageIcon() {
        let topic = WhatsNewTopic(
            title: "Custom icon",
            description: "Assets are rendered with SwiftUI Image.",
            icon: .image("custom-icon")
        )

        #expect(topic.icon == .image("custom-icon"))
    }
}
