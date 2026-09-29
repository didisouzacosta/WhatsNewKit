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
        releases
            .flatMap { release in
                release.pages.map { page in
                    (release: release, page: page)
                }
            }
            .enumerated()
            .map { index, step in
                WhatsNewPresentationStep(
                    index: index,
                    release: step.release,
                    page: step.page
                )
            }
    }

    // MARK: - Initializer

    public init(releases: [WhatsNewRelease]) {
        self.releases = releases
    }
}
