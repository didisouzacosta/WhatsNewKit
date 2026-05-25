import Foundation

enum WhatsNewPresentationPolicy {
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
        guard let latestVersion = presentation.releases
            .map(\.version)
            .max(by: { SemanticVersion($0) < SemanticVersion($1) })
        else {
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

private struct SemanticVersion: Comparable {
    private let rawValue: String
    private let components: [Int]

    init(_ rawValue: String) {
        self.rawValue = rawValue
        self.components = rawValue
            .split { character in
                character.isNumber == false
            }
            .compactMap { Int($0) }
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)

        for index in 0..<count {
            let left = lhs.components.indices.contains(index) ? lhs.components[index] : 0
            let right = rhs.components.indices.contains(index) ? rhs.components[index] : 0

            if left != right {
                return left < right
            }
        }

        return false
    }
}
