import Foundation

protocol WhatsNewStorage: AnyObject {
    var hasCompletedFirstLaunch: Bool { get set }
    var lastPresentedVersion: String? { get set }
}

final class UserDefaultsWhatsNewStorage: WhatsNewStorage {
    private let defaults: UserDefaults
    private let hasCompletedFirstLaunchKey: String
    private let lastPresentedVersionKey: String

    init(
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit"
    ) {
        self.defaults = defaults
        self.hasCompletedFirstLaunchKey = "\(namespace).WhatsNewKit.hasCompletedFirstLaunch"
        self.lastPresentedVersionKey = "\(namespace).WhatsNewKit.lastPresentedVersion"
    }

    var hasCompletedFirstLaunch: Bool {
        get { defaults.bool(forKey: hasCompletedFirstLaunchKey) }
        set { defaults.set(newValue, forKey: hasCompletedFirstLaunchKey) }
    }

    var lastPresentedVersion: String? {
        get { defaults.string(forKey: lastPresentedVersionKey) }
        set { defaults.set(newValue, forKey: lastPresentedVersionKey) }
    }
}
