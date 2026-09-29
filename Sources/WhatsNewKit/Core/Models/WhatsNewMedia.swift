import Foundation

public enum WhatsNewMedia: Equatable, Sendable {

    // MARK: - Cases

    case image(ImageSource)
    case video(URL)

    // MARK: - Factory Methods

    public static func image(_ url: URL) -> WhatsNewMedia {
        .image(.url(url))
    }
}
