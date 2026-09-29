import SwiftUI

struct WhatsNewSheetFooter: View {

    // MARK: - Properties

    let showsStepIndicator: Bool
    let currentIndex: Int
    let stepCount: Int
    let isLastPage: Bool
    let onAdvance: () -> Void

    private var buttonTitle: String {
        isLastPage ? WhatsNewLocalized.finishButtonTitle : WhatsNewLocalized.continueButtonTitle
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            if showsStepIndicator {
                WhatsNewStepIndicator(
                    currentIndex: currentIndex,
                    count: stepCount
                )
            }

            Button(action: onAdvance) {
                Text(buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .whatsNewGlassProminentButtonStyle()
            .controlSize(.large)
        }
        .safeAreaPadding(.horizontal, 24)
        .safeAreaPadding(.top, 16)
        .safeAreaPadding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview("Continue") {
    WhatsNewSheetFooter(
        showsStepIndicator: true,
        currentIndex: 0,
        stepCount: 3,
        isLastPage: false,
        onAdvance: {}
    )
}

#Preview("Done") {
    WhatsNewSheetFooter(
        showsStepIndicator: false,
        currentIndex: 0,
        stepCount: 1,
        isLastPage: true,
        onAdvance: {}
    )
}
