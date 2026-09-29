import Foundation
import WhatsNewKit

struct ReleaseSummary: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    let version: String
    let title: String
    let symbolName: String
    let topicCount: Int
    let mediaKind: ReleaseMediaKind
    let stage: ReleaseStage

    // MARK: - Initializer

    init(release: WhatsNewRelease, currentVersion: String) {
        self.id = release.id
        self.version = release.version
        self.title = release.title
        self.symbolName = Self.symbolName(for: release)
        self.topicCount = release.pages.reduce(0) { $0 + $1.topics.count }
        self.mediaKind = Self.mediaKind(for: release.media)
        self.stage = Self.stage(of: release.version, currentVersion: currentVersion)
    }

    // MARK: - Private Methods

    private static func symbolName(for release: WhatsNewRelease) -> String {
        for topic in release.topics {
            if case let .systemImage(name) = topic.icon {
                return name
            }
        }

        return "sparkles"
    }

    private static func mediaKind(for media: WhatsNewMedia?) -> ReleaseMediaKind {
        switch media {
        case .none:
            .none

        case .image:
            .image

        case .video:
            .video
        }
    }

    private static func stage(of version: String, currentVersion: String) -> ReleaseStage {
        switch version.compare(currentVersion, options: .numeric) {
        case .orderedAscending:
            .released

        case .orderedSame:
            .current

        case .orderedDescending:
            .upcoming
        }
    }
}
