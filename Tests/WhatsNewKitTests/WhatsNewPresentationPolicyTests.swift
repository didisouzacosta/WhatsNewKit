import Testing
@testable import WhatsNewKit

@Suite("WhatsNew presentation policy")
struct WhatsNewPresentationPolicyTests {
    @Test("first app launch never presents the sheet")
    func firstAppLaunchDoesNotPresent() {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1", title: "Initial", topics: [])
        ]

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.hasCompletedFirstLaunch)
    }

    @Test("first app launch does not store the current version as presented")
    func firstAppLaunchDoesNotStoreLastPresentedVersion() {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.0", title: "Current", topics: [])
        ]

        _ = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.0",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        )

        #expect(storage.hasCompletedFirstLaunch)
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("second app launch presents current release when no release has been registered")
    func secondAppLaunchPresentsCurrentReleaseWhenNoReleaseHasBeenRegistered() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        let releases = [
            WhatsNewRelease(version: "1.2.0", title: "Current", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.0",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["1.2.0"])
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("new users can mark the current version as baseline without presenting current or older releases")
    func newUsersCanMarkCurrentVersionAsBaseline() {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.0", title: "Previous", topics: []),
            WhatsNewRelease(version: "1.2.1", title: "Current", topics: [])
        ]

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: "1.2.1",
            storage: storage
        )

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.1",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.hasCompletedFirstLaunch)
        #expect(storage.lastPresentedVersion == "1.2.1")
    }

    @Test("releases newer than a new user baseline are eligible on the next app version")
    func releasesNewerThanBaselineAreEligible() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.1", title: "Baseline", topics: []),
            WhatsNewRelease(version: "1.2.2", title: "Next", topics: [])
        ]

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: "1.2.1",
            storage: storage
        )

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.2",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["1.2.2"])
        #expect(storage.lastPresentedVersion == "1.2.1")
    }

    @Test("existing users without a baseline can still see the current release")
    func existingUsersWithoutBaselineCanStillSeeCurrentRelease() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        let releases = [
            WhatsNewRelease(version: "1.2.1", title: "Current", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.1",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["1.2.1"])
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("manual trigger presents releases even before automatic baseline exists")
    func manualTriggerPresentsBeforeAutomaticBaselineExists() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1", title: "Initial", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1",
            releases: releases,
            storage: storage,
            trigger: .manual
        ))

        #expect(presentation.releases.map(\.version) == ["1"])
        #expect(storage.hasCompletedFirstLaunch == false)
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("manual trigger presents every release even after current releases were already registered")
    func manualTriggerPresentsEveryReleaseAfterCurrentReleasesWereRegistered() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "2"
        let releases = [
            WhatsNewRelease(version: "1", title: "One", topics: []),
            WhatsNewRelease(version: "2", title: "Two", topics: []),
            WhatsNewRelease(version: "3", title: "Future", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "2",
            releases: releases,
            storage: storage,
            trigger: .manual
        ))

        #expect(presentation.releases.map(\.version) == ["1", "2", "3"])
    }

    @Test("manual trigger presents releases newer than the current app version")
    func manualTriggerPresentsReleasesNewerThanCurrentAppVersion() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1", title: "Current", topics: []),
            WhatsNewRelease(version: "2", title: "Next", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1",
            releases: releases,
            storage: storage,
            trigger: .manual
        ))

        #expect(presentation.releases.map(\.version) == ["1", "2"])
    }

    @Test("manual trigger presents every release without changing a new user baseline")
    func manualTriggerPresentsEveryReleaseWithoutChangingNewUserBaseline() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.0", title: "Previous", topics: []),
            WhatsNewRelease(version: "1.2.1", title: "Current", topics: []),
            WhatsNewRelease(version: "1.2.2", title: "Future", topics: [])
        ]

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: "1.2.1",
            storage: storage
        )

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.1",
            releases: releases,
            storage: storage,
            trigger: .manual
        ))

        #expect(presentation.releases.map(\.version) == ["1.2.0", "1.2.1", "1.2.2"])
        #expect(storage.lastPresentedVersion == "1.2.1")
    }

    @Test("existing users see every missed release up to the current app version")
    func existingUsersSeeMissedReleases() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "2"

        let releases = [
            WhatsNewRelease(version: "5", title: "Five", topics: []),
            WhatsNewRelease(version: "3", title: "Three", topics: []),
            WhatsNewRelease(version: "4", title: "Four", topics: []),
            WhatsNewRelease(version: "6", title: "Future", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "5",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["3", "4", "5"])
        #expect(storage.lastPresentedVersion == "2")
    }

    @Test("completed presentations are registered at the latest displayed version")
    func completedPresentationsRegisterLatestDisplayedVersion() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "2"
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "3", title: "Three", topics: []),
            WhatsNewRelease(version: "4", title: "Four", topics: [])
        ])

        WhatsNewPresentationPolicy.register(presentation, storage: storage)

        #expect(storage.lastPresentedVersion == "4")
    }

    @Test("semantic versions with x.x.x structure are filtered and sorted numerically")
    func semanticPatchVersionsAreFilteredAndSortedNumerically() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "1.0.0"

        let releases = [
            WhatsNewRelease(version: "2.5.1", title: "Two five one", topics: []),
            WhatsNewRelease(version: "1.1.0", title: "One one zero", topics: []),
            WhatsNewRelease(version: "1.0.1", title: "One zero one", topics: []),
            WhatsNewRelease(version: "2.5.2", title: "Future patch", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "2.5.1",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["1.0.1", "1.1.0", "2.5.1"])
    }

    @Test("semantic versions with x.x structure are treated as equivalent to x.x.0")
    func semanticMinorVersionsAreEquivalentToZeroPatchVersions() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "1.0"

        let releases = [
            WhatsNewRelease(version: "1.0.0", title: "Equivalent baseline", topics: []),
            WhatsNewRelease(version: "1.0.1", title: "Patch", topics: []),
            WhatsNewRelease(version: "1.1.0", title: "Minor", topics: []),
            WhatsNewRelease(version: "1.1.1", title: "Future patch", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.1",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["1.0.1", "1.1.0"])
    }

    @Test("completed semantic version presentations register the highest numeric version")
    func completedSemanticVersionPresentationsRegisterHighestNumericVersion() {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "1.0.0"
        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "2.5.1", title: "Two five one", topics: []),
            WhatsNewRelease(version: "1.10.0", title: "One ten zero", topics: []),
            WhatsNewRelease(version: "1.1.0", title: "One one zero", topics: [])
        ])

        WhatsNewPresentationPolicy.register(presentation, storage: storage)

        #expect(storage.lastPresentedVersion == "2.5.1")
    }

    @Test("completed automatic presentations continue registering the latest displayed version")
    func completedAutomaticPresentationsContinueRegisteringLatestDisplayedVersion() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.hasCompletedFirstLaunch = true
        storage.lastPresentedVersion = "1.2.1"
        let releases = [
            WhatsNewRelease(version: "1.2.2", title: "Next", topics: [])
        ]

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.2",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        WhatsNewPresentationPolicy.register(presentation, storage: storage)

        #expect(storage.lastPresentedVersion == "1.2.2")
    }
}

private final class InMemoryWhatsNewStorage: WhatsNewStorage {
    var hasCompletedFirstLaunch = false
    var lastPresentedVersion: String?
}
