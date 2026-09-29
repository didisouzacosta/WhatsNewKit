import SwiftUI

struct WhatsNewAutoPresentationModifier: ViewModifier {

    // MARK: - Properties

    let releases: [WhatsNewRelease]
    let canPresent: Bool
    let currentVersion: String
    let onEvent: (WhatsNewAnalyticsEvent) -> Void

    @State private var viewModel = WhatsNewPresentationViewModel()

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                evaluatePresentation()
            }
            .onChange(of: canPresent) {
                evaluatePresentation()
            }
            .sheet(item: $viewModel.activePresentation) { presentation in
                WhatsNewSheet(
                    presentation: presentation,
                    onEvent: onEvent
                ) {
                    viewModel.finish(presentation)
                }
            }
    }

    // MARK: - Private Methods

    private func evaluatePresentation() {
        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: currentVersion,
            canPresent: canPresent
        )
    }
}
