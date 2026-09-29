import Foundation
import Testing
@testable import WhatsNewKit

@Suite("WhatsNew media")
struct WhatsNewMediaTests {
    @Test("media can reference a local image asset")
    func mediaCanReferenceLocalImageAsset() {
        let media = WhatsNewMedia.image("ReleaseHero")

        #expect(media == .image(.asset("ReleaseHero")))
    }

    @Test("media can reference an image url")
    func mediaCanReferenceImageURL() throws {
        let url = try #require(URL(string: "https://example.com/release.png"))
        let media = WhatsNewMedia.image(url)

        #expect(media == .image(.url(url)))
    }

    @Test("media can reference a video url")
    func mediaCanReferenceVideoURL() throws {
        let url = try #require(URL(string: "https://example.com/release.mp4"))
        let media = WhatsNewMedia.video(url)

        #expect(media == .video(url))
    }
}
