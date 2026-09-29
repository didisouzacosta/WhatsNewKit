import Foundation

public struct WhatsNewPage: Identifiable, Equatable, Sendable {

    // MARK: - Public Properties

    public let id: String
    public let title: String
    public let media: WhatsNewMedia?
    public let topics: [WhatsNewTopic]

    // MARK: - Initializer

    public init(
        id: String? = nil,
        title: String,
        media: WhatsNewMedia? = nil,
        topics: [WhatsNewTopic]
    ) {
        self.id = id ?? title
        self.title = title
        self.media = media
        self.topics = topics
    }
}
