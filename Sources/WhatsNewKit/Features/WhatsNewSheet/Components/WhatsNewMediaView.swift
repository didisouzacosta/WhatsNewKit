import Kingfisher
import SwiftUI

struct WhatsNewMediaView: View {

    // MARK: - Properties

    let media: WhatsNewMedia
    let isActive: Bool

    // MARK: - Body

    var body: some View {
        Color.clear
            .aspectRatio(WhatsNewSheetLayout.mediaAspectRatio, contentMode: .fit)
            .overlay {
                mediaContent
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Content

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
