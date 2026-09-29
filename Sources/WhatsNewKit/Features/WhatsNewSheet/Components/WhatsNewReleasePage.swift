import SwiftUI

struct WhatsNewReleasePage: View {

    // MARK: - Properties

    let release: WhatsNewRelease
    let page: WhatsNewPage
    let isActive: Bool

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let media = page.media {
                        WhatsNewMediaView(
                            media: media,
                            isActive: isActive
                        )
                    }

                    VStack(alignment: .center, spacing: 8) {
                        Text(page.title)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text(WhatsNewLocalized.versionTitle(release.version))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(page.topics) { topic in
                            WhatsNewTopicRow(topic: topic)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WhatsNewSheetLayout.pageContentPadding)
                .padding(.top, proxy.safeAreaInsets.top + WhatsNewSheetLayout.pageTopContentSpacing)
                .padding(.bottom, proxy.safeAreaInsets.bottom + WhatsNewSheetLayout.pageBottomContentSpacing)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollClipDisabled()
        }
    }
}

#if DEBUG
    #Preview {
        WhatsNewReleasePage(
            release: WhatsNewPreviewFixtures.firstRelease,
            page: WhatsNewPreviewFixtures.firstRelease.pages[0],
            isActive: true
        )
    }
#endif
