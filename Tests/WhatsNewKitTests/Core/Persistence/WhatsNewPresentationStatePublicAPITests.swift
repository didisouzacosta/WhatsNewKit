import Foundation
import Testing
import WhatsNewKit

@Suite("WhatsNew presentation state public API")
struct WhatsNewPresentationStatePublicAPITests {
    @Test("public API marks current version as seen in UserDefaults")
    func publicAPIMarksCurrentVersionAsSeen() throws {
        let namespace = "WhatsNewKitTests.PublicAPI.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: namespace))
        defer {
            defaults.removePersistentDomain(forName: namespace)
        }

        WhatsNewPresentationState.markCurrentVersionAsSeen(
            currentVersion: "1.2.1",
            defaults: defaults,
            namespace: namespace
        )

        #expect(defaults.string(forKey: "\(namespace).WhatsNewKit.lastPresentedVersion") == "1.2.1")
    }
}
