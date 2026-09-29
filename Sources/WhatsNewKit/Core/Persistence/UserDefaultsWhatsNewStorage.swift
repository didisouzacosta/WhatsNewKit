import Foundation

final class UserDefaultsWhatsNewStorage: WhatsNewStorage {

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private let lastPresentedVersionKey: String

    // MARK: - Initializer

    init(
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit"
    ) {
        self.defaults = defaults
        self.lastPresentedVersionKey = "\(namespace).WhatsNewKit.lastPresentedVersion"
    }

    // MARK: - WhatsNewStorage

    var lastPresentedVersion: String? {
        get {
            defaults.string(forKey: lastPresentedVersionKey)
        }

        set {
            defaults.set(newValue, forKey: lastPresentedVersionKey)
        }
    }
}
