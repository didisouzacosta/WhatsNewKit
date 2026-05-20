import Testing
@testable import WhatsNewKit

@Suite("WhatsNew analytics events")
struct WhatsNewAnalyticsEventTests {
    @Test("step progress includes zero and one based indexes")
    func stepProgressIncludesIndexes() {
        let release = WhatsNewRelease(version: "2.0.0", title: "Media", topics: [])
        let event = WhatsNewAnalyticsEvent.stepProgress(
            release: release,
            index: 1,
            count: 3
        )

        #expect(event == .stepProgress(release: release, index: 1, count: 3))
        #expect(event.oneBasedStepIndex == 2)
        #expect(event.totalStepCount == 3)
    }

    @Test("open and close events expose their presentation")
    func openAndCloseExposePresentation() {
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "1.0.0", title: "Start", topics: [])
        ])

        #expect(WhatsNewAnalyticsEvent.opened(presentation).presentation == presentation)
        #expect(WhatsNewAnalyticsEvent.closed(presentation).presentation == presentation)
    }
}
