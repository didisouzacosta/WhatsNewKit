import Foundation
import Observation

@MainActor
@Observable
final class WhatsNewSheetViewModel {

    // MARK: - Public Properties

    let presentation: WhatsNewPresentation
    let steps: [WhatsNewPresentationStep]

    private(set) var selectedIndex = 0

    var showsStepIndicator: Bool {
        stepCount > 1
    }

    var stepCount: Int {
        steps.count
    }

    var isLastPage: Bool {
        selectedIndex >= stepCount - 1
    }

    // MARK: - Private Properties

    @ObservationIgnored private let onEvent: (WhatsNewAnalyticsEvent) -> Void

    @ObservationIgnored private var hasEmittedOpen = false
    @ObservationIgnored private var hasEmittedClose = false

    // MARK: - Initializer

    init(
        presentation: WhatsNewPresentation,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) {
        self.presentation = presentation
        self.steps = presentation.steps
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func open() {
        guard hasEmittedOpen == false else {
            return
        }

        hasEmittedOpen = true
        onEvent(.opened(presentation))
        emitStepProgress()
    }

    func close() {
        guard hasEmittedClose == false else {
            return
        }

        hasEmittedClose = true
        onEvent(.closed(presentation))
    }

    func selectStep(_ index: Int) {
        guard index != selectedIndex, steps.indices.contains(index) else {
            return
        }

        selectedIndex = index
        emitStepProgress()
    }

    func showNextStep() {
        selectStep(selectedIndex + 1)
    }

    // MARK: - Private Methods

    private func emitStepProgress() {
        guard steps.indices.contains(selectedIndex) else {
            return
        }

        let step = steps[selectedIndex]

        onEvent(.stepProgress(
            release: step.release,
            page: step.page,
            index: selectedIndex,
            count: stepCount
        ))
    }
}
