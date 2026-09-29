import SwiftUI

struct WhatsNewTriggeredPresentationModifier: ViewModifier {

    // MARK: - Properties

    @Binding var isTriggered: Bool

    let releases: [WhatsNewRelease]
    let currentVersion: String
    let onEvent: (WhatsNewAnalyticsEvent) -> Void

    @State private var viewModel = WhatsNewPresentationViewModel()

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onChange(of: isTriggered) { _, newValue in
                presentIfTriggered(newValue)
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

    private func presentIfTriggered(_ isTriggered: Bool) {
        guard isTriggered else {
            return
        }

        viewModel.presentManually(
            releases: releases,
            currentVersion: currentVersion
        )
        self.isTriggered = false
    }
}
