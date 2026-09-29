import Testing
@testable import WhatsNewKit

@MainActor
@Suite("WhatsNew presentation view model")
struct WhatsNewPresentationViewModelTests {

    // MARK: - Tests

    @Test("automatic evaluation presents pending releases only when allowed")
    func automaticEvaluationPresentsOnlyWhenAllowed() {
        let storage = InMemoryWhatsNewStorage()
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
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("automatic evaluation keeps an active presentation")
    func automaticEvaluationKeepsActivePresentation() {
        let viewModel = WhatsNewPresentationViewModel(storage: InMemoryWhatsNewStorage())

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

    @Test("finishing registers the latest displayed version and dismisses")
    func finishingRegistersLatestVersionAndDismisses() throws {
        let storage = InMemoryWhatsNewStorage()
        let viewModel = WhatsNewPresentationViewModel(storage: storage)

        viewModel.evaluateAutomaticPresentation(
            releases: [
                WhatsNewRelease(version: "1.10.0", title: "Ten", topics: []),
                WhatsNewRelease(version: "1.2.0", title: "Two", topics: []),
            ],
            currentVersion: "1.10.0",
            canPresent: true
        )

        let presentation = try #require(viewModel.activePresentation)

        viewModel.finish(presentation)

        #expect(viewModel.activePresentation == nil)
        #expect(storage.lastPresentedVersion == "1.10.0")
    }
}
