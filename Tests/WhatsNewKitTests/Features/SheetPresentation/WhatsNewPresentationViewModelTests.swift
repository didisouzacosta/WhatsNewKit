import Testing
@testable import WhatsNewKit

@MainActor
@Suite("WhatsNew presentation view model")
struct WhatsNewPresentationViewModelTests {

    // MARK: - Tests

    @Test("automatic evaluation presents pending releases only when allowed")
    func automaticEvaluationPresentsOnlyWhenAllowed() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.1.0"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)
        let releases = [WhatsNewRelease(version: "1.2.0", title: "Current", topics: [])]

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: "1.2.0",
            canPresent: false
        )

        #expect(viewModel.activePresentation == nil)

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: "1.2.0",
            canPresent: true
        )

        #expect(viewModel.activePresentation?.releases.map(\.version) == ["1.2.0"])
        #expect(storage.lastPresentedVersion == "1.1.0")
    }

    @Test("automatic evaluation on a new install presents nothing")
    func automaticEvaluationOnNewInstallPresentsNothing() {
        let storage = InMemoryWhatsNewStorage()
        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.evaluateAutomaticPresentation(
            releases: [
                WhatsNewRelease(version: "1.0.0", title: "One", topics: []),
                WhatsNewRelease(version: "2.0.0", title: "Two", topics: []),
            ],
            currentVersion: "2.0.0",
            canPresent: true
        )

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "2.0.0")
    }

    @Test("automatic evaluation keeps an active presentation")
    func automaticEvaluationKeepsActivePresentation() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "0.1"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.evaluateAutomaticPresentation(
            releases: [WhatsNewRelease(version: "1", title: "One", topics: [])],
            currentVersion: "2",
            canPresent: true
        )

        viewModel.evaluateAutomaticPresentation(
            releases: [WhatsNewRelease(version: "2", title: "Two", topics: [])],
            currentVersion: "2",
            canPresent: true
        )

        #expect(viewModel.activePresentation?.releases.map(\.version) == ["1"])
    }

    @Test("manual presentation shows every release without registering it")
    func manualPresentationShowsEveryRelease() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "2"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.presentManually(
            releases: [
                WhatsNewRelease(version: "3", title: "Future", topics: []),
                WhatsNewRelease(version: "1", title: "One", topics: []),
            ],
            currentVersion: "2"
        )

        #expect(viewModel.activePresentation?.releases.map(\.version) == ["1", "3"])
        #expect(storage.lastPresentedVersion == "2")
    }

    @Test("finishing a manual presentation keeps future releases eligible")
    func finishingManualPresentationKeepsFutureReleasesEligible() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)
        let releases = [
            WhatsNewRelease(version: "1.0.0", title: "Current", topics: []),
            WhatsNewRelease(version: "2.0.0", title: "Future", topics: []),
        ]

        viewModel.presentManually(releases: releases, currentVersion: "1.0.0")
        viewModel.finish()

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "1.0.0")

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: "2.0.0",
            canPresent: true
        )

        #expect(viewModel.activePresentation?.releases.map(\.version) == ["2.0.0"])
    }

    @Test("manual presentation does not replace an active presentation")
    func manualPresentationDoesNotReplaceActivePresentation() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.evaluateAutomaticPresentation(
            releases: [WhatsNewRelease(version: "2", title: "Two", topics: [])],
            currentVersion: "2",
            canPresent: true
        )

        viewModel.presentManually(
            releases: [WhatsNewRelease(version: "3", title: "Three", topics: [])],
            currentVersion: "2"
        )

        #expect(viewModel.activePresentation?.releases.map(\.version) == ["2"])

        viewModel.finish()

        #expect(storage.lastPresentedVersion == "2")
    }

    @Test("finishing registers the latest displayed version and dismisses")
    func finishingRegistersLatestVersionAndDismisses() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.evaluateAutomaticPresentation(
            releases: [
                WhatsNewRelease(version: "1.10.0", title: "Ten", topics: []),
                WhatsNewRelease(version: "1.2.0", title: "Two", topics: []),
            ],
            currentVersion: "1.10.0",
            canPresent: true
        )

        #expect(viewModel.activePresentation != nil)

        viewModel.finish()

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "1.10.0")
    }

    @Test("a dismissed automatic presentation is not presented again")
    func dismissedAutomaticPresentationIsNotPresentedAgain() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)
        let releases = [WhatsNewRelease(version: "2.0.0", title: "Two", topics: [])]

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: "2.0.0",
            canPresent: true
        )

        viewModel.finish()

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: "2.0.0",
            canPresent: true
        )

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "2.0.0")
    }

    @Test("finishing without an active presentation changes nothing")
    func finishingWithoutActivePresentationChangesNothing() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.finish()

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "1.0.0")
    }
}
