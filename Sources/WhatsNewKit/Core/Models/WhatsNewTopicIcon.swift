import Foundation

public enum WhatsNewTopicIcon: Equatable, Sendable {

    // MARK: - Cases

    case systemImage(String)
    case image(String, bundle: Bundle? = nil)

    // MARK: - Equatable

    public static func == (lhs: WhatsNewTopicIcon, rhs: WhatsNewTopicIcon) -> Bool {
        switch (lhs, rhs) {
        case let (.systemImage(lhsName), .systemImage(rhsName)):
            lhsName == rhsName

        case let (.image(lhsName, lhsBundle), .image(rhsName, rhsBundle)):
            lhsName == rhsName && lhsBundle?.bundleIdentifier == rhsBundle?.bundleIdentifier

        default:
            false
        }
    }
}
