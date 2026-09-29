import AVKit
import Combine
import SwiftUI

struct WhatsNewVideoView: View {

    // MARK: - Private Properties

    private let url: URL
    private let isActive: Bool

    @State private var item: AVPlayerItem
    @State private var player: AVPlayer
    @State private var isReadyToPlay = false

    // MARK: - Initializer

    init(url: URL, isActive: Bool) {
        let item = AVPlayerItem(url: url)

        self.url = url
        self.isActive = isActive
        _item = State(initialValue: item)
        _player = State(initialValue: AVPlayer(playerItem: item))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            WhatsNewMediaPlaceholder(systemName: "play.rectangle.fill")

            VideoPlayer(player: player)
                .opacity(isReadyToPlay ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onReceive(item.publisher(for: \.status)) { status in
            updateReadiness(for: status)
        }
        .onChange(of: isActive) {
            updatePlayback()
        }
        .onChange(of: url) { _, newValue in
            replaceItem(with: newValue)
        }
        .onDisappear {
            player.pause()
        }
    }

    // MARK: - Private Methods

    private func updateReadiness(for status: AVPlayerItem.Status) {
        withAnimation(.easeInOut(duration: 0.2)) {
            isReadyToPlay = status == .readyToPlay
        }

        updatePlayback()
    }

    private func replaceItem(with url: URL) {
        let newItem = AVPlayerItem(url: url)

        isReadyToPlay = false
        item = newItem
        player.replaceCurrentItem(with: newItem)
    }

    private func updatePlayback() {
        guard isReadyToPlay, isActive else {
            player.pause()
            return
        }

        player.play()
    }
}
