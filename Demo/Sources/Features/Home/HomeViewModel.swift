import Foundation
import Observation
import WhatsNewKit

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - Public Properties

    let releases: [WhatsNewRelease]
    let currentVersion: String

    var canPresentWhatsNew: Bool
    var isWhatsNewTriggered = false

    // MARK: - Private Properties

    @ObservationIgnored private let accessStore: DemoAccessStore

    // MARK: - Initializer

    init(
        releases: [WhatsNewRelease] = DemoReleaseCatalog.releases,
        currentVersion: String = WhatsNewAppVersion.current,
        accessStore: DemoAccessStore = DemoAccessStore()
    ) {
        self.releases = releases
        self.currentVersion = currentVersion
        self.accessStore = accessStore
        self.canPresentWhatsNew = accessStore.isReturningUser
    }

    // MARK: - Public Methods

    func registerInitialAccessIfNeeded() {
        accessStore.registerInitialAccessIfNeeded()
    }

    func openWhatsNewManually() {
        isWhatsNewTriggered = true
    }

    func track(_ event: WhatsNewAnalyticsEvent) {
        switch event {
        case let .opened(presentation):
            print("WhatsNew opened: \(presentation.id)")

        case let .closed(presentation):
            print("WhatsNew closed: \(presentation.id)")

        case let .stepProgress(release, _, index, count):
            print("WhatsNew step: \(index + 1)/\(count) - \(release.version)")
        }
    }
}
