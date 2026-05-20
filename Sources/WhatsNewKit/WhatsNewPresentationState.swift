import Foundation

public enum WhatsNewPresentationState {
    public static func markCurrentVersionAsBaseline(
        currentVersion: String = WhatsNewAppVersion.current,
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit"
    ) {
        let storage = UserDefaultsWhatsNewStorage(
            defaults: defaults,
            namespace: namespace
        )

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: currentVersion,
            storage: storage
        )
    }

    public static func markCurrentVersionAsSeen(
        currentVersion: String = WhatsNewAppVersion.current,
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit"
    ) {
        markCurrentVersionAsBaseline(
            currentVersion: currentVersion,
            defaults: defaults,
            namespace: namespace
        )
    }
}
