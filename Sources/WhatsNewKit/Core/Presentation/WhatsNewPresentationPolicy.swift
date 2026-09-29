import Foundation

enum WhatsNewPresentationPolicy {

    // MARK: - Internal Methods

    static func presentation(
        currentVersion: String,
        releases: [WhatsNewRelease],
        storage: WhatsNewStorage,
        canPresent: Bool = true,
        trigger: WhatsNewPresentationTrigger = .appLaunch
    ) -> WhatsNewPresentation? {
        switch trigger {
        case .manual:
            return presentation(for: sortedByVersion(releases))

        case .appLaunch:
            return automaticPresentation(
                currentVersion: currentVersion,
                releases: releases,
                storage: storage,
                canPresent: canPresent
            )
        }
    }

    static func register(
        _ presentation: WhatsNewPresentation,
        storage: WhatsNewStorage
    ) {
        let latestVersion = presentation.releases
            .compactMap { SemanticVersion($0.version) }
            .max()

        guard let latestVersion else {
            return
        }

        advanceLastPresentedVersion(to: latestVersion, storage: storage)
    }

    static func markCurrentVersionAsBaseline(
        currentVersion: String,
        storage: WhatsNewStorage
    ) {
        guard let current = SemanticVersion(currentVersion) else {
            return
        }

        advanceLastPresentedVersion(to: current, storage: storage)
    }

    // MARK: - Private Methods

    /// A missing or unreadable stored version means the app was just installed: the
    /// current version becomes the baseline and nothing is presented, even when
    /// `canPresent` is `false`, so the next update is compared against it.
    private static func automaticPresentation(
        currentVersion: String,
        releases: [WhatsNewRelease],
        storage: WhatsNewStorage,
        canPresent: Bool
    ) -> WhatsNewPresentation? {
        guard let current = SemanticVersion(currentVersion) else {
            return nil
        }

        guard let lastPresented = storage.lastPresentedVersion.flatMap(SemanticVersion.init) else {
            storage.lastPresentedVersion = current.rawValue
            return nil
        }

        guard canPresent else {
            return nil
        }

        let pendingReleases = releases.filter { release in
            guard let version = SemanticVersion(release.version) else {
                return false
            }

            return lastPresented < version && version <= current
        }

        return presentation(for: sortedByVersion(pendingReleases))
    }

    private static func advanceLastPresentedVersion(
        to version: SemanticVersion,
        storage: WhatsNewStorage
    ) {
        let lastPresented = storage.lastPresentedVersion.flatMap(SemanticVersion.init)

        if let lastPresented, version <= lastPresented {
            return
        }

        storage.lastPresentedVersion = version.rawValue
    }

    private static func sortedByVersion(_ releases: [WhatsNewRelease]) -> [WhatsNewRelease] {
        releases
            .compactMap { release in
                SemanticVersion(release.version).map { (version: $0, release: release) }
            }
            .sorted { $0.version < $1.version }
            .map(\.release)
    }

    private static func presentation(for releases: [WhatsNewRelease]) -> WhatsNewPresentation? {
        guard releases.isEmpty == false else {
            return nil
        }

        return WhatsNewPresentation(releases: releases)
    }
}
