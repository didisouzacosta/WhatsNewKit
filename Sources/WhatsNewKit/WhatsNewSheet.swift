import AVKit
import Combine
import Kingfisher
import SwiftUI

private let defaultMediaAspectRatio: CGFloat = 16 / 9

public struct WhatsNewSheet: View {
    private let presentation: WhatsNewPresentation
    private let onEvent: (WhatsNewAnalyticsEvent) -> Void
    private let onFinish: () -> Void

    @State private var selectedIndex = 0
    @State private var hasEmittedOpen = false
    @State private var hasEmittedClose = false
    @Environment(\.dismiss) private var dismiss

    public init(
        presentation: WhatsNewPresentation,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in },
        onFinish: @escaping () -> Void
    ) {
        self.presentation = presentation
        self.onEvent = onEvent
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
                .toolbarBackground(.visible, for: .navigationBar)
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
        .onAppear {
            emitOpenIfNeeded()
        }
        .onDisappear {
            emitCloseIfNeeded()
        }
    }

    @ViewBuilder
    private var pages: some View {
        TabView(selection: $selectedIndex) {
            releasePages
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        #endif
        .onChange(of: selectedIndex) { _, newValue in
            emitStepProgress(for: newValue)
        }
    }

    @ViewBuilder
    private var releasePages: some View {
        ForEach(Array(presentation.releases.enumerated()), id: \.element.id) { index, release in
            WhatsNewReleasePage(
                release: release,
                isActive: selectedIndex == index
            )
                .tag(index)
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            if presentation.showsStepIndicator {
                StepIndicator(
                    currentIndex: selectedIndex,
                    count: presentation.releases.count
                )
            }

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
            withAnimation {
                selectedIndex += 1
            }
            return
        }

        finish()
    }

    private func finish() {
        onFinish()
        dismiss()
    }

    private func emitOpenIfNeeded() {
        guard hasEmittedOpen == false else {
            return
        }

        hasEmittedOpen = true
        onEvent(.opened(presentation))
        emitStepProgress(for: selectedIndex)
    }

    private func emitCloseIfNeeded() {
        guard hasEmittedClose == false else {
            return
        }

        hasEmittedClose = true
        onEvent(.closed(presentation))
    }

    private func emitStepProgress(for index: Int) {
        guard presentation.releases.indices.contains(index) else {
            return
        }

        onEvent(.stepProgress(
            release: presentation.releases[index],
            index: index,
            count: presentation.releases.count
        ))
    }
}

private struct WhatsNewReleasePage: View {
    let release: WhatsNewRelease
    let isActive: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let media = release.media {
                    WhatsNewMediaView(
                        media: media,
                        isActive: isActive
                    )
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
                .padding(.bottom, 4)

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
    let isActive: Bool

    var body: some View {
        Color.clear
            .aspectRatio(defaultMediaAspectRatio, contentMode: .fit)
            .overlay {
                mediaContent
            }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var mediaContent: some View {
        switch media {
        case let .image(source):
            imageView(source)
        case let .video(url):
            WhatsNewVideoView(
                url: url,
                isActive: isActive
            )
        }
    }

    @ViewBuilder
    private func imageView(_ source: WhatsNewMedia.ImageSource) -> some View {
        switch source {
        case let .asset(name, bundle):
            Image(name, bundle: bundle)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        case let .url(url):
            remoteImageView(url)
        #if canImport(UIKit)
        case let .uiImage(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        #endif
        }
    }

    private func remoteImageView(_ url: URL) -> some View {
        KFImage(url)
            .placeholder {
                WhatsNewMediaPlaceholder(systemName: "photo")
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .fade(duration: 0.2)
            .cancelOnDisappear(true)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}

private struct WhatsNewVideoView: View {
    private let url: URL
    private let isActive: Bool

    @State private var item: AVPlayerItem
    @State private var player: AVPlayer
    @State private var isReadyToPlay = false

    init(url: URL, isActive: Bool) {
        let item = AVPlayerItem(url: url)

        self.url = url
        self.isActive = isActive
        _item = State(initialValue: item)
        _player = State(initialValue: AVPlayer(playerItem: item))
    }

    var body: some View {
        ZStack {
            WhatsNewMediaPlaceholder(systemName: "play.rectangle.fill")

            VideoPlayer(player: player)
                .opacity(isReadyToPlay ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onReceive(item.publisher(for: \.status)) { status in
            withAnimation(.easeInOut(duration: 0.2)) {
                isReadyToPlay = status == .readyToPlay
            }

            updatePlayback()
        }
        .onChange(of: isActive) { _, _ in
            updatePlayback()
        }
        .onChange(of: url) { _, newValue in
            let newItem = AVPlayerItem(url: newValue)

            isReadyToPlay = false
            item = newItem
            player.replaceCurrentItem(with: newItem)
        }
        .onDisappear {
            player.pause()
        }
    }

    private func updatePlayback() {
        guard isReadyToPlay, isActive else {
            player.pause()
            return
        }

        player.play()
    }
}

private struct WhatsNewMediaPlaceholder: View {
    let systemName: String

    var body: some View {
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
