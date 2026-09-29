import Testing
@testable import WhatsNewKit

@Suite("WhatsNew presentation")
struct WhatsNewPresentationTests {
    @Test("step indicator is hidden when presentation has one release")
    func stepIndicatorIsHiddenForSingleRelease() {
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "1.0.0", title: "Single", topics: [])
        ])

        #expect(presentation.showsStepIndicator == false)
    }

    @Test("step indicator is visible when presentation has multiple releases")
    func stepIndicatorIsVisibleForMultipleReleases() {
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "1.0.0", title: "One", topics: []),
            WhatsNewRelease(version: "1.1.0", title: "Two", topics: [])
        ])

        #expect(presentation.showsStepIndicator)
    }

    @Test("single release can present multiple pages")
    func singleReleaseCanPresentMultiplePages() {
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "1.2.0", pages: [
                WhatsNewPage(id: "cover", title: "Cover", topics: []),
                WhatsNewPage(id: "teleprompter", title: "Teleprompter", topics: [])
            ])
        ])

        #expect(presentation.releases.map(\.version) == ["1.2.0"])
        #expect(presentation.steps.map(\.release.version) == ["1.2.0", "1.2.0"])
        #expect(presentation.steps.map(\.page.title) == ["Cover", "Teleprompter"])
        #expect(presentation.showsStepIndicator)
    }
}
