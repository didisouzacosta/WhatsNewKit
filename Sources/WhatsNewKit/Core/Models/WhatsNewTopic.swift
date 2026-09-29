import Foundation

public struct WhatsNewTopic: Identifiable, Equatable, Sendable {

    // MARK: - Public Properties

    public let id: String
    public let title: String
    public let description: String
    public let icon: WhatsNewTopicIcon?

    // MARK: - Initializer

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        icon: WhatsNewTopicIcon? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
    }
}
