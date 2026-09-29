import Foundation
import Observation

@MainActor
@Observable
final class WhatsNewPresentationViewModel {

    // MARK: - Public Properties

    var activePresentation: WhatsNewPresentation?

    // MARK: - Private Properties

    @ObservationIgnored private let storage: WhatsNewStorage

    // MARK: - Initializer

    init(storage: WhatsNewStorage = UserDefaultsWhatsNewStorage()) {
        self.storage = storage
    }

    // MARK: - Public Methods

    func evaluateAutomaticPresentation(
        releases: [WhatsNewRelease],
        currentVersion: String,
        canPresent: Bool
    ) {
        guard activePresentation == nil else {
            return
        }

        activePresentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: currentVersion,
            releases: releases,
            storage: storage,
            canPresent: canPresent,
            trigger: .appLaunch
        )
    }

    func presentManually(
        releases: [WhatsNewRelease],
        currentVersion: String
    ) {
        activePresentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: currentVersion,
            releases: releases,
            storage: storage,
            trigger: .manual
        )
    }

    func finish(_ presentation: WhatsNewPresentation) {
        WhatsNewPresentationPolicy.register(presentation, storage: storage)
        activePresentation = nil
    }
}
