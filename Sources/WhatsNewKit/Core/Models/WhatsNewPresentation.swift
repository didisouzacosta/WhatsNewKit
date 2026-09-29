import Foundation

public struct WhatsNewPresentation: Identifiable, Equatable, Sendable {

    // MARK: - Public Properties

    public let releases: [WhatsNewRelease]

    public var id: String {
        releases
            .map { release in
                let pageIDs = release.pages.map(\.id).joined(separator: ",")

                return "\(release.version):\(pageIDs)"
            }
            .joined(separator: "|")
    }

    // MARK: - Internal Properties

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

    // MARK: - Initializer

    public init(releases: [WhatsNewRelease]) {
        self.releases = releases
    }
}
