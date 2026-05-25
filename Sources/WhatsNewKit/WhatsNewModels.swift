import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct WhatsNewRelease: Identifiable, Equatable, Sendable {
    public let version: String
    public let pages: [WhatsNewPage]

    public var id: String { version }

    public var title: String {
        pages.first?.title ?? ""
    }

    public var media: WhatsNewMedia? {
        pages.first?.media
    }

    public var topics: [WhatsNewTopic] {
        pages.first?.topics ?? []
    }

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
                )
            ]
        )
    }
}

public struct WhatsNewPage: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let media: WhatsNewMedia?
    public let topics: [WhatsNewTopic]

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

public enum WhatsNewMedia: Equatable, @unchecked Sendable {
    case image(ImageSource)
    case video(URL)

    public static func image(_ url: URL) -> WhatsNewMedia {
        .image(.url(url))
    }

    public enum ImageSource: Equatable, @unchecked Sendable {
        case asset(String, bundle: Bundle? = nil)
        case url(URL)
        #if canImport(UIKit)
        case uiImage(UIImage)
        #endif

        public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
            switch (lhs, rhs) {
            case let (.asset(lhsName, lhsBundle), .asset(rhsName, rhsBundle)):
                lhsName == rhsName && lhsBundle?.bundleIdentifier == rhsBundle?.bundleIdentifier
            case let (.url(lhsURL), .url(rhsURL)):
                lhsURL == rhsURL
            case (.asset, .url), (.url, .asset):
                false
            #if canImport(UIKit)
            case let (.uiImage(lhsImage), .uiImage(rhsImage)):
                lhsImage === rhsImage
            case (.asset, .uiImage), (.url, .uiImage), (.uiImage, .asset), (.uiImage, .url):
                false
            #endif
            }
        }
    }
}

extension WhatsNewMedia.ImageSource: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .asset(value)
    }
}

public struct WhatsNewPresentation: Identifiable, Equatable, Sendable {
    public let releases: [WhatsNewRelease]

    public var id: String {
        releases
            .map { release in
                let pageIDs = release.pages.map(\.id).joined(separator: ",")
                return "\(release.version):\(pageIDs)"
            }
            .joined(separator: "|")
    }

    var showsStepIndicator: Bool {
        steps.count > 1
    }

    var steps: [WhatsNewPresentationStep] {
        releases.flatMap { release in
            release.pages.map { page in
                WhatsNewPresentationStep(
                    release: release,
                    page: page
                )
            }
        }
    }

    public init(releases: [WhatsNewRelease]) {
        self.releases = releases
    }
}

struct WhatsNewPresentationStep: Identifiable, Equatable, Sendable {
    let release: WhatsNewRelease
    let page: WhatsNewPage

    var id: String {
        "\(release.version)|\(page.id)"
    }
}

public enum WhatsNewAnalyticsEvent: Equatable, Sendable {
    case opened(WhatsNewPresentation)
    case closed(WhatsNewPresentation)
    case stepProgress(release: WhatsNewRelease, page: WhatsNewPage, index: Int, count: Int)

    public var presentation: WhatsNewPresentation? {
        switch self {
        case let .opened(presentation), let .closed(presentation):
            presentation
        case .stepProgress:
            nil
        }
    }

    public var zeroBasedStepIndex: Int? {
        switch self {
        case let .stepProgress(_, _, index, _):
            index
        case .opened, .closed:
            nil
        }
    }

    public var oneBasedStepIndex: Int? {
        zeroBasedStepIndex.map { $0 + 1 }
    }

    public var totalStepCount: Int? {
        switch self {
        case let .stepProgress(_, _, _, count):
            count
        case .opened, .closed:
            nil
        }
    }
}

enum WhatsNewPresentationTrigger: Equatable, Sendable {
    case appLaunch
    case manual
}
