import Testing
@testable import WhatsNewKit

@Suite("WhatsNew presentation policy baseline")
struct WhatsNewPresentationPolicyBaselineTests {

    // MARK: - Tests

    @Test("first evaluation of a new install records the current version without presenting")
    func firstEvaluationOfNewInstallRecordsCurrentVersionWithoutPresenting() {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.0.0", title: "Previous", topics: []),
            WhatsNewRelease(version: "1.2.0", title: "Current", topics: []),
        ]

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.0",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.lastPresentedVersion == "1.2.0")
    }

    @Test("first evaluation of a new install records the current version even when canPresent is false")
    func firstEvaluationOfNewInstallRecordsCurrentVersionWhenBlocked() {
        let storage = InMemoryWhatsNewStorage()

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.0",
            releases: [WhatsNewRelease(version: "1.2.0", title: "Current", topics: [])],
            storage: storage,
            canPresent: false,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.lastPresentedVersion == "1.2.0")
    }

    @Test("a new install sees the release of the next app version")
    func newInstallSeesReleaseOfNextAppVersion() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.0.0", title: "Installed", topics: []),
            WhatsNewRelease(version: "2.0.0", title: "Update", topics: []),
        ]

        let installPresentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.0.0",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        )

        #expect(installPresentation == nil)

        let updatePresentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "2.0.0",
            releases: releases,
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(updatePresentation.releases.map(\.version) == ["2.0.0"])
    }

    @Test("an invalid stored version is treated as a new install")
    func invalidStoredVersionIsTreatedAsNewInstall() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "corrupted"

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "1.2.0",
            releases: [WhatsNewRelease(version: "1.2.0", title: "Current", topics: [])],
            storage: storage,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.lastPresentedVersion == "1.2.0")
    }

    @Test("an invalid current version presents nothing and keeps the stored version")
    func invalidCurrentVersionPresentsNothing() {
        let storage = InMemoryWhatsNewStorage()

        let presentation = WhatsNewPresentationPolicy.presentation(
            currentVersion: "unknown",
            releases: [WhatsNewRelease(version: "1.0.0", title: "One", topics: [])],
            storage: storage,
            trigger: .appLaunch
        )

        #expect(presentation == nil)
        #expect(storage.lastPresentedVersion == nil)
    }

    @Test("releases with an invalid version are ignored")
    func releasesWithInvalidVersionAreIgnored() throws {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        let presentation = try #require(WhatsNewPresentationPolicy.presentation(
            currentVersion: "2.0.0",
            releases: [
                WhatsNewRelease(version: "next", title: "Invalid", topics: []),
                WhatsNewRelease(version: "2.0.0", title: "Two", topics: []),
            ],
            storage: storage,
            trigger: .appLaunch
        ))

        #expect(presentation.releases.map(\.version) == ["2.0.0"])
    }

    @Test("new users can mark the current version as baseline without presenting current or older releases")
    func newUsersCanMarkCurrentVersionAsBaseline() {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.0", title: "Previous", topics: []),
            WhatsNewRelease(version: "1.2.1", title: "Current", topics: []),
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
        #expect(storage.lastPresentedVersion == "1.2.1")
    }

    @Test("releases newer than a new user baseline are eligible on the next app version")
    func releasesNewerThanBaselineAreEligible() throws {
        let storage = InMemoryWhatsNewStorage()
        let releases = [
            WhatsNewRelease(version: "1.2.1", title: "Baseline", topics: []),
            WhatsNewRelease(version: "1.2.2", title: "Next", topics: []),
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

    @Test("marking the baseline never moves the stored version backwards")
    func markingBaselineNeverMovesStoredVersionBackwards() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "2.0.0"

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: "1.0.0",
            storage: storage
        )

        #expect(storage.lastPresentedVersion == "2.0.0")
    }

    @Test("marking an invalid version as baseline keeps the stored version")
    func markingInvalidBaselineKeepsStoredVersion() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "1.0.0"

        WhatsNewPresentationPolicy.markCurrentVersionAsBaseline(
            currentVersion: "unknown",
            storage: storage
        )

        #expect(storage.lastPresentedVersion == "1.0.0")
    }

    @Test("registering never moves the stored version backwards")
    func registeringNeverMovesStoredVersionBackwards() {
        let storage = InMemoryWhatsNewStorage()
        storage.lastPresentedVersion = "3"

        let presentation = WhatsNewPresentation(releases: [
            WhatsNewRelease(version: "2", title: "Two", topics: []),
        ])

        WhatsNewPresentationPolicy.register(presentation, storage: storage)

        #expect(storage.lastPresentedVersion == "3")
    }
}
