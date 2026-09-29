import SwiftUI

public struct WhatsNewSheet: View {

    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss

    private let onFinish: () -> Void

    @State private var viewModel: WhatsNewSheetViewModel

    private var selection: Binding<Int> {
        Binding(
            get: { viewModel.selectedIndex },
            set: { viewModel.selectStep($0) }
        )
    }

    // MARK: - Initializer

    public init(
        presentation: WhatsNewPresentation,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in },
        onFinish: @escaping () -> Void
    ) {
        self.onFinish = onFinish
        _viewModel = State(initialValue: WhatsNewSheetViewModel(
            presentation: presentation,
            onEvent: onEvent
        ))
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            WhatsNewSheetPager(
                steps: viewModel.steps,
                selectedIndex: selection
            )
            .safeAreaInset(edge: .bottom) {
                WhatsNewSheetFooter(
                    showsStepIndicator: viewModel.showsStepIndicator,
                    currentIndex: viewModel.selectedIndex,
                    stepCount: viewModel.stepCount,
                    isLastPage: viewModel.isLastPage,
                    onAdvance: advance
                )
            }
            .navigationTitle(WhatsNewLocalized.navigationTitle)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: finish) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel(WhatsNewLocalized.closeAccessibilityLabel)
                    }
                }
        }
        .onAppear {
            viewModel.open()
        }
        .onDisappear {
            viewModel.close()
        }
    }

    // MARK: - Private Methods

    private func advance() {
        guard viewModel.isLastPage else {
            withAnimation {
                viewModel.showNextStep()
            }

            return
        }

        finish()
    }

    private func finish() {
        onFinish()
        dismiss()
    }
}

#if DEBUG
    #Preview("Single release") {
        WhatsNewSheet(presentation: WhatsNewPreviewFixtures.singleRelease) {}
    }

    #Preview("Multiple releases") {
        WhatsNewSheet(presentation: WhatsNewPreviewFixtures.multipleReleases) {}
    }
#endif
