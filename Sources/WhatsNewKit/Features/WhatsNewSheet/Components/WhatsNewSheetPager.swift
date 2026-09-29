import SwiftUI

struct WhatsNewSheetPager: View {

    // MARK: - Properties

    let steps: [WhatsNewPresentationStep]

    @Binding var selectedIndex: Int

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(steps) { step in
                WhatsNewReleasePage(
                    release: step.release,
                    page: step.page,
                    isActive: selectedIndex == step.index
                )
                .tag(step.index)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        #endif
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var selectedIndex = 0

        WhatsNewSheetPager(
            steps: WhatsNewPreviewFixtures.multipleReleases.steps,
            selectedIndex: $selectedIndex
        )
    }
#endif
