import AVKit
import Kingfisher
import SwiftUI

private let defaultMediaAspectRatio: CGFloat = 16 / 9
private let mediaAspectRatioAnimation = Animation.smooth(duration: 0.35)

public struct WhatsNewSheet: View {
    private let presentation: WhatsNewPresentation
    private let onFinish: () -> Void

    @State private var selectedIndex = 0
    @State private var scrollPosition: Int? = 0
    @Environment(\.dismiss) private var dismiss

    public init(
        presentation: WhatsNewPresentation,
        onFinish: @escaping () -> Void
    ) {
        self.presentation = presentation
        self.onFinish = onFinish
    }

    public var body: some View {
        NavigationStack {
            pages
                .safeAreaInset(edge: .bottom, content: {
                    footer
                })
                .navigationTitle(WhatsNewLocalized.navigationTitle)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            finish()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel(WhatsNewLocalized.closeAccessibilityLabel)
                    }
                }
        }
    }

    @ViewBuilder
    private var pages: some View {
        #if os(iOS)
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                releasePages
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrollPosition)
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue else {
                return
            }

            selectedIndex = newValue
        }
        .onChange(of: selectedIndex) { _, newValue in
            scrollPosition = newValue
        }
        #else
        TabView(selection: $selectedIndex) {
            releasePages
        }
        #endif
    }

    @ViewBuilder
    private var releasePages: some View {
        ForEach(Array(presentation.releases.enumerated()), id: \.element.id) { index, release in
            WhatsNewReleasePage(release: release)
                #if os(iOS)
                .containerRelativeFrame(.horizontal)
                .id(index)
                #endif
                .tag(index)
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            StepIndicator(
                currentIndex: selectedIndex,
                count: presentation.releases.count
            )

            Button {
                advance()
            } label: {
                Text(isLastPage ? WhatsNewLocalized.finishButtonTitle : WhatsNewLocalized.continueButtonTitle)
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

    private var isLastPage: Bool {
        selectedIndex >= presentation.releases.count - 1
    }

    private func advance() {
        guard isLastPage else {
            let nextIndex = selectedIndex + 1

            withAnimation {
                selectedIndex = nextIndex
                scrollPosition = nextIndex
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

private struct WhatsNewReleasePage: View {
    let release: WhatsNewRelease

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let media = release.media {
                    WhatsNewMediaView(media: media)
                }

                VStack(alignment: .center, spacing: 8) {
                    Text(release.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text(WhatsNewLocalized.versionTitle(release.version))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(release.topics) { topic in
                        WhatsNewTopicRow(topic: topic)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .scrollClipDisabled()
    }
}

private struct WhatsNewMediaView: View {
    let media: WhatsNewMedia

    @State private var imageAspectRatio = defaultMediaAspectRatio

    var body: some View {
        Group {
            switch media.kind {
            case .image:
                imageView
            case .video:
                VideoPlayer(player: AVPlayer(url: media.url))
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(currentAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(mediaAspectRatioAnimation, value: currentAspectRatio)
        .onChange(of: media.url) { _, _ in
            imageAspectRatio = defaultMediaAspectRatio
        }
    }

    private var currentAspectRatio: CGFloat {
        switch media.kind {
        case .image:
            imageAspectRatio
        case .video:
            defaultMediaAspectRatio
        }
    }

    @ViewBuilder
    private var imageView: some View {
        kingfisherImage
    }

    private var kingfisherImage: some View {
        KFImage(media.url)
            .placeholder {
                placeholder(systemName: "photo")
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .onSuccess { result in
                updateImageAspectRatio(from: result.image.size)
            }
            .fade(duration: 0.2)
            .cancelOnDisappear(true)
            .resizable()
            .scaledToFill()
    }

    private func updateImageAspectRatio(from size: CGSize) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        withAnimation(mediaAspectRatioAnimation) {
            imageAspectRatio = size.width / size.height
        }
    }

    private func placeholder(systemName: String) -> some View {
        ZStack {
            Rectangle()
                .fill(.secondary.opacity(0.12))

            Image(systemName: systemName)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct WhatsNewTopicRow: View {
    let topic: WhatsNewTopic

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let icon = topic.icon {
                WhatsNewTopicIconView(icon: icon)
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(topic.title)
                    .font(.headline)

                Text(topic.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct WhatsNewTopicIconView: View {
    let icon: WhatsNewTopicIcon

    var body: some View {
        switch icon {
        case let .systemImage(systemName):
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .image(name, bundle):
            Image(name, bundle: bundle)
                .resizable()
                .scaledToFit()
        }
    }
}

private struct StepIndicator: View {
    let currentIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: index == currentIndex ? 20 : 8, height: 8)
                    .animation(.snappy, value: currentIndex)
            }
        }
        .accessibilityLabel(WhatsNewLocalized.stepIndicatorAccessibilityLabel(
            current: currentIndex + 1,
            count: count
        ))
    }
}

private enum WhatsNewLocalized {
    static let navigationTitle = string(
        key: "whatsnew.navigation.title",
        value: "What's New",
        comment: "Navigation title for the WhatsNew sheet."
    )

    static let closeAccessibilityLabel = string(
        key: "whatsnew.close.accessibility_label",
        value: "Close",
        comment: "Accessibility label for the close button."
    )

    static let continueButtonTitle = string(
        key: "whatsnew.continue_button.title",
        value: "Continue",
        comment: "Button title used to advance to the next release page."
    )

    static let finishButtonTitle = string(
        key: "whatsnew.finish_button.title",
        value: "Done",
        comment: "Button title used to finish and dismiss the WhatsNew sheet."
    )

    static func versionTitle(_ version: String) -> String {
        String(
            format: string(
                key: "whatsnew.version.title",
                value: "Version %@",
                comment: "Version label. The placeholder is the app release version."
            ),
            version
        )
    }

    static func stepIndicatorAccessibilityLabel(current: Int, count: Int) -> String {
        String(
            format: string(
                key: "whatsnew.step_indicator.accessibility_label",
                value: "Step %d of %d",
                comment: "Accessibility label for the page step indicator. The placeholders are the current step and total step count."
            ),
            current,
            count
        )
    }

    private static func string(
        key: String,
        value: String,
        comment: String
    ) -> String {
        NSLocalizedString(
            key,
            bundle: .module,
            value: value,
            comment: comment
        )
    }
}

private struct WhatsNewGlassProminentButtonStyleModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
        } else {
            content
                .buttonStyle(.borderedProminent)
        }
        #else
        content
            .buttonStyle(.borderedProminent)
        #endif
    }
}

private extension View {
    func whatsNewGlassProminentButtonStyle() -> some View {
        modifier(WhatsNewGlassProminentButtonStyleModifier())
    }
}
