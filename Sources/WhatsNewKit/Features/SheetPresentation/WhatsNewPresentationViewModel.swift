import Foundation
import Observation

@MainActor
@Observable
final class WhatsNewPresentationViewModel {

    // MARK: - Public Properties

    private(set) var activePresentation: WhatsNewPresentation?

    // MARK: - Private Properties

    @ObservationIgnored private let storage: WhatsNewStorage

    @ObservationIgnored private var activeTrigger: WhatsNewPresentationTrigger?

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

        present(
            WhatsNewPresentationPolicy.presentation(
                currentVersion: currentVersion,
                releases: releases,
                storage: storage,
                canPresent: canPresent,
                trigger: .appLaunch
            ),
            trigger: .appLaunch
        )
    }

    func presentManually(
        releases: [WhatsNewRelease],
        currentVersion: String
    ) {
        guard activePresentation == nil else {
            return
        }

        present(
            WhatsNewPresentationPolicy.presentation(
                currentVersion: currentVersion,
                releases: releases,
                storage: storage,
                trigger: .manual
            ),
            trigger: .manual
        )
    }

    /// Ends the active presentation however it was closed (button or interactive
    /// dismissal). Only automatic presentations are registered as seen; a manual
    /// presentation leaves the stored version untouched.
    func finish() {
        guard let activePresentation else {
            return
        }

        if activeTrigger == .appLaunch {
            WhatsNewPresentationPolicy.register(activePresentation, storage: storage)
        }

        self.activePresentation = nil
        activeTrigger = nil
    }

    // MARK: - Private Methods

    private func present(
        _ presentation: WhatsNewPresentation?,
        trigger: WhatsNewPresentationTrigger
    ) {
        guard let presentation else {
            return
        }

        activeTrigger = trigger
        activePresentation = presentation
    }
}
