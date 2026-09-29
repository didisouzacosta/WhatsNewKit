import Foundation
import WhatsNewKit

struct DemoAccessStore {

    // MARK: - Private Properties

    private static let hasAccessedAppKey = "WhatsNewKitDemo.hasAccessedApp"

    private let defaults: UserDefaults

    // MARK: - Public Properties

    var isReturningUser: Bool {
        defaults.bool(forKey: Self.hasAccessedAppKey)
    }

    // MARK: - Initializer

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Public Methods

    func registerInitialAccessIfNeeded() {
        guard isReturningUser == false else {
            return
        }

        WhatsNewPresentationState.markCurrentVersionAsSeen(defaults: defaults)
        defaults.set(true, forKey: Self.hasAccessedAppKey)
    }
}
