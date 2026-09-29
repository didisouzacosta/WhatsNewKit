import Foundation

public struct WhatsNewRelease: Identifiable, Equatable, Sendable {

    // MARK: - Public Properties

    public let version: String
    public let pages: [WhatsNewPage]

    public var id: String {
        version
    }

    public var title: String {
        pages.first?.title ?? ""
    }

    public var media: WhatsNewMedia? {
        pages.first?.media
    }

    public var topics: [WhatsNewTopic] {
        pages.first?.topics ?? []
    }

    // MARK: - Initializers

    public init(
        version: String,
        pages: [WhatsNewPage]
    ) {
        self.version = version
        self.pages = pages
    }

    public init(
        version: String,
        title: String,
        media: WhatsNewMedia? = nil,
        topics: [WhatsNewTopic]
    ) {
        self.init(
            version: version,
            pages: [
                WhatsNewPage(
                    title: title,
                    media: media,
                    topics: topics
                ),
            ]
        )
    }
}
