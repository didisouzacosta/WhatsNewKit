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
        if trigger == .manual {
            let visibleReleases = releases.sorted {
                SemanticVersion($0.version) < SemanticVersion($1.version)
            }

            guard visibleReleases.isEmpty == false else {
                return nil
            }

            return WhatsNewPresentation(releases: visibleReleases)
        }

        guard canPresent else {
            return nil
        }

        let visibleReleases = pendingReleases(
            currentVersion: currentVersion,
            releases: releases,
            lastPresentedVersion: storage.lastPresentedVersion
        )

        guard visibleReleases.isEmpty == false else {
            return nil
        }

        return WhatsNewPresentation(releases: visibleReleases)
    }

    static func register(
        _ presentation: WhatsNewPresentation,
        storage: WhatsNewStorage
    ) {
        let versions = presentation.releases.map(\.version)

        guard let latestVersion = versions.max(by: { SemanticVersion($0) < SemanticVersion($1) }) else {
            return
        }

        storage.lastPresentedVersion = latestVersion
    }

    static func markCurrentVersionAsBaseline(
        currentVersion: String,
        storage: WhatsNewStorage
    ) {
        storage.lastPresentedVersion = currentVersion
    }

    // MARK: - Private Methods

    private static func pendingReleases(
        currentVersion: String,
        releases: [WhatsNewRelease],
        lastPresentedVersion: String?
    ) -> [WhatsNewRelease] {
        let current = SemanticVersion(currentVersion)
        let lastPresented = lastPresentedVersion.map(SemanticVersion.init)

        return releases
            .filter { release in
                let releaseVersion = SemanticVersion(release.version)
                let isAfterLastPresented = lastPresented.map { $0 < releaseVersion } ?? true

                return isAfterLastPresented && releaseVersion <= current
            }
            .sorted { SemanticVersion($0.version) < SemanticVersion($1.version) }
    }
}
