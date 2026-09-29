import SwiftUI

/// Hosts a single What's New sheet for both automatic and manual presentation, so
/// the two sources never try to present two sheets at the same time.
struct WhatsNewPresentationModifier: ViewModifier {

    // MARK: - Properties

    @Binding var isTriggered: Bool

    let releases: [WhatsNewRelease]
    let isAutomaticPresentationEnabled: Bool
    let canPresent: Bool
    let currentVersion: String
    let onEvent: (WhatsNewAnalyticsEvent) -> Void

    @State private var viewModel: WhatsNewPresentationViewModel

    /// Any dismissal, including the interactive swipe, ends the presentation through
    /// the view model so it is registered exactly like the close button.
    private var activePresentation: Binding<WhatsNewPresentation?> {
        Binding(
            get: { viewModel.activePresentation },
            set: { presentation in
                guard presentation == nil else {
                    return
                }

                viewModel.finish()
            }
        )
    }

    // MARK: - Initializer

    init(
        isTriggered: Binding<Bool>,
        releases: [WhatsNewRelease],
        isAutomaticPresentationEnabled: Bool,
        canPresent: Bool,
        currentVersion: String,
        storage: WhatsNewStorage,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void
    ) {
        _isTriggered = isTriggered
        self.releases = releases
        self.isAutomaticPresentationEnabled = isAutomaticPresentationEnabled
        self.canPresent = canPresent
        self.currentVersion = currentVersion
        self.onEvent = onEvent
        _viewModel = State(initialValue: WhatsNewPresentationViewModel(storage: storage))
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                evaluateAutomaticPresentation()
            }
            .onChange(of: canPresent) {
                evaluateAutomaticPresentation()
            }
            .onChange(of: releases) {
                evaluateAutomaticPresentation()
            }
            .onChange(of: currentVersion) {
                evaluateAutomaticPresentation()
            }
            .onChange(of: isTriggered, initial: true) {
                presentIfTriggered()
            }
            .sheet(item: activePresentation) { presentation in
                WhatsNewSheet(
                    presentation: presentation,
                    onEvent: onEvent
                ) {
                    viewModel.finish()
                }
            }
    }

    // MARK: - Private Methods

    private func evaluateAutomaticPresentation() {
        guard isAutomaticPresentationEnabled else {
            return
        }

        viewModel.evaluateAutomaticPresentation(
            releases: releases,
            currentVersion: currentVersion,
            canPresent: canPresent
        )
    }

    private func presentIfTriggered() {
        guard isTriggered else {
            return
        }

        viewModel.presentManually(
            releases: releases,
            currentVersion: currentVersion
        )
        isTriggered = false
    }
}
