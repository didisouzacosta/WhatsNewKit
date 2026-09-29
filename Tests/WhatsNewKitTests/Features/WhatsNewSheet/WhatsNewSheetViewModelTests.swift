import Testing
@testable import WhatsNewKit

@MainActor
@Suite("WhatsNew sheet view model")
struct WhatsNewSheetViewModelTests {

    // MARK: - Tests

    @Test("opening emits the opened event and the first step progress only once")
    func openingEmitsOpenedAndFirstStepOnce() {
        let recorder = EventRecorder()
        let presentation = makePresentation(versions: ["1.0.0", "1.1.0"])
        let viewModel = WhatsNewSheetViewModel(
            presentation: presentation,
            onEvent: recorder.record
        )

        viewModel.open()
        viewModel.open()

        #expect(recorder.events == [
            .opened(presentation),
            .stepProgress(
                release: presentation.releases[0],
                page: presentation.releases[0].pages[0],
                index: 0,
                count: 2
            ),
        ])
    }

    @Test("closing emits the closed event only once")
    func closingEmitsClosedOnce() {
        let recorder = EventRecorder()
        let presentation = makePresentation(versions: ["1.0.0"])
        let viewModel = WhatsNewSheetViewModel(
            presentation: presentation,
            onEvent: recorder.record
        )

        viewModel.close()
        viewModel.close()

        #expect(recorder.events == [.closed(presentation)])
    }

    @Test("selecting a different step updates the index and emits its progress")
    func selectingDifferentStepEmitsProgress() {
        let recorder = EventRecorder()
        let presentation = makePresentation(versions: ["1.0.0", "1.1.0", "1.2.0"])
        let viewModel = WhatsNewSheetViewModel(
            presentation: presentation,
            onEvent: recorder.record
        )

        viewModel.selectStep(2)

        #expect(viewModel.selectedIndex == 2)
        #expect(recorder.events == [
            .stepProgress(
                release: presentation.releases[2],
                page: presentation.releases[2].pages[0],
                index: 2,
                count: 3
            ),
        ])
    }

    @Test("selecting the current or an out of range step is ignored")
    func selectingCurrentOrOutOfRangeStepIsIgnored() {
        let recorder = EventRecorder()
        let viewModel = WhatsNewSheetViewModel(
            presentation: makePresentation(versions: ["1.0.0", "1.1.0"]),
            onEvent: recorder.record
        )

        viewModel.selectStep(0)
        viewModel.selectStep(5)
        viewModel.selectStep(-1)

        #expect(viewModel.selectedIndex == 0)
        #expect(recorder.events.isEmpty)
    }

    @Test("showing the next step advances until the last page")
    func showingNextStepAdvancesUntilLastPage() {
        let recorder = EventRecorder()
        let viewModel = WhatsNewSheetViewModel(
            presentation: makePresentation(versions: ["1.0.0", "1.1.0"]),
            onEvent: recorder.record
        )

        #expect(viewModel.isLastPage == false)

        viewModel.showNextStep()

        #expect(viewModel.selectedIndex == 1)
        #expect(viewModel.isLastPage)
        #expect(recorder.events.map(\.zeroBasedStepIndex) == [1])

        viewModel.showNextStep()

        #expect(viewModel.selectedIndex == 1)
        #expect(recorder.events.count == 1)
    }

    @Test("step indicator and step count follow the presentation pages")
    func stepIndicatorFollowsPresentationPages() {
        let single = WhatsNewSheetViewModel(presentation: makePresentation(versions: ["1.0.0"]))
        let multiple = WhatsNewSheetViewModel(presentation: makePresentation(versions: ["1.0.0", "2.0.0"]))

        #expect(single.showsStepIndicator == false)
        #expect(single.stepCount == 1)
        #expect(single.isLastPage)
        #expect(multiple.showsStepIndicator)
        #expect(multiple.stepCount == 2)
    }

    // MARK: - Private Methods

    private func makePresentation(versions: [String]) -> WhatsNewPresentation {
        WhatsNewPresentation(releases: versions.map { version in
            WhatsNewRelease(version: version, title: "Release \(version)", topics: [])
        })
    }
}

@MainActor
private final class EventRecorder {
    private(set) var events: [WhatsNewAnalyticsEvent] = []

    func record(_ event: WhatsNewAnalyticsEvent) {
        events.append(event)
    }
}
