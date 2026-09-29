import Foundation

struct WhatsNewPresentationStep: Identifiable, Equatable, Sendable {
    let index: Int
    let release: WhatsNewRelease
    let page: WhatsNewPage

    var id: String {
        "\(index)|\(release.version)|\(page.id)"
    }
}
