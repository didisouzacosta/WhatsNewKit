import Foundation

protocol WhatsNewStorage: AnyObject {
    var lastPresentedVersion: String? { get set }
}

final class UserDefaultsWhatsNewStorage: WhatsNewStorage {
    private let defaults: UserDefaults
    private let lastPresentedVersionKey: String

    init(
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit"
    ) {
        self.defaults = defaults
        self.lastPresentedVersionKey = "\(namespace).WhatsNewKit.lastPresentedVersion"
    }

    var lastPresentedVersion: String? {
        get { defaults.string(forKey: lastPresentedVersionKey) }
        set { defaults.set(newValue, forKey: lastPresentedVersionKey) }
    }
}
