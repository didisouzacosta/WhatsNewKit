import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public extension WhatsNewMedia {

    // MARK: - Image Source

    enum ImageSource: Equatable, Sendable {

        // MARK: - Cases

        case asset(String, bundle: Bundle? = nil)
        case url(URL)
        #if canImport(UIKit)
            case uiImage(UIImage)
        #endif

        // MARK: - Equatable

        public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
            switch (lhs, rhs) {
            case let (.asset(lhsName, lhsBundle), .asset(rhsName, rhsBundle)):
                lhsName == rhsName && lhsBundle?.bundleIdentifier == rhsBundle?.bundleIdentifier

            case let (.url(lhsURL), .url(rhsURL)):
                lhsURL == rhsURL

            case (.asset, .url), (.url, .asset):
                false

            #if canImport(UIKit)
                case let (.uiImage(lhsImage), .uiImage(rhsImage)):
                    lhsImage === rhsImage

                case (.asset, .uiImage), (.url, .uiImage), (.uiImage, .asset), (.uiImage, .url):
                    false
            #endif
            }
        }
    }
}

extension WhatsNewMedia.ImageSource: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .asset(value)
    }
}
