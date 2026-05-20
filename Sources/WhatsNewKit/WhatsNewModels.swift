import Foundation

public struct WhatsNewRelease: Identifiable, Equatable, Sendable {
    public let version: String
    public let title: String
    public let media: WhatsNewMedia?
    public let topics: [WhatsNewTopic]

    public var id: String { version }

    public init(
        version: String,
        title: String,
        media: WhatsNewMedia? = nil,
        topics: [WhatsNewTopic]
    ) {
        self.version = version
        self.title = title
        self.media = media
        self.topics = topics
    }
}

public struct WhatsNewTopic: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: WhatsNewTopicIcon?

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

public enum WhatsNewTopicIcon: Equatable, @unchecked Sendable {
    case systemImage(String)
    case image(String, bundle: Bundle? = nil)

    public static func == (lhs: WhatsNewTopicIcon, rhs: WhatsNewTopicIcon) -> Bool {
        switch (lhs, rhs) {
        case let (.systemImage(lhsName), .systemImage(rhsName)):
            lhsName == rhsName
        case let (.image(lhsName, lhsBundle), .image(rhsName, rhsBundle)):
            lhsName == rhsName && lhsBundle?.bundleIdentifier == rhsBundle?.bundleIdentifier
        default:
            false
        }
    }
}

public struct WhatsNewMedia: Equatable, Sendable {
    public let url: URL
    public let kind: Kind

    public init(url: URL, kind: Kind) {
        self.url = url
        self.kind = kind
    }

    public enum Kind: Equatable, Sendable {
        case image
        case video
    }
}

public struct WhatsNewPresentation: Identifiable, Equatable, Sendable {
    public let releases: [WhatsNewRelease]

    public var id: String {
        releases.map(\.version).joined(separator: "|")
    }

    public init(releases: [WhatsNewRelease]) {
        self.releases = releases
    }
}

enum WhatsNewPresentationTrigger: Equatable, Sendable {
    case appLaunch
    case manual
}
