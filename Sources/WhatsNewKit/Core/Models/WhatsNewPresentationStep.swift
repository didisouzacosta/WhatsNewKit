import Foundation

struct WhatsNewPresentationStep: Identifiable, Equatable, Sendable {
    let release: WhatsNewRelease
    let page: WhatsNewPage

    var id: String {
        "\(release.version)|\(page.id)"
    }
}
