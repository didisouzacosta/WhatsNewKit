import Testing
@testable import WhatsNewKit

@Suite("Semantic version")
struct SemanticVersionTests {

    // MARK: - Tests

    @Test("versions without numeric components are invalid")
    func versionsWithoutNumericComponentsAreInvalid() {
        #expect(SemanticVersion("") == nil)
        #expect(SemanticVersion("beta") == nil)
        #expect(SemanticVersion("-1") == nil)
    }

    @Test("missing trailing components are equal to zero")
    func missingTrailingComponentsAreEqualToZero() throws {
        let minor = try #require(SemanticVersion("1.2"))
        let patch = try #require(SemanticVersion("1.2.0"))

        #expect(minor == patch)
        #expect((minor < patch) == false)
        #expect((patch < minor) == false)
    }

    @Test("pre-release versions come before the release")
    func preReleaseVersionsComeBeforeTheRelease() throws {
        let orderedVersions = [
            "1.0.0-alpha",
            "1.0.0-alpha.1",
            "1.0.0-alpha.beta",
            "1.0.0-beta",
            "1.0.0-beta.2",
            "1.0.0-beta.11",
            "1.0.0-rc.1",
            "1.0.0",
        ]

        let versions = try orderedVersions.map { try #require(SemanticVersion($0)) }

        for index in versions.indices.dropLast() {
            #expect(versions[index] < versions[index + 1])
        }
    }

    @Test("build metadata does not affect the order")
    func buildMetadataDoesNotAffectTheOrder() throws {
        let release = try #require(SemanticVersion("1.0.0"))
        let build = try #require(SemanticVersion("1.0.0+42"))

        #expect(release == build)
    }

    @Test("oversized components keep their position")
    func oversizedComponentsKeepTheirPosition() throws {
        let oversized = try #require(SemanticVersion("1.99999999999999999999.0"))
        let regular = try #require(SemanticVersion("1.5.9"))

        #expect(regular < oversized)
    }
}
