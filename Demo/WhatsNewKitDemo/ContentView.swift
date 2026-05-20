import SwiftUI
import WhatsNewKit

struct ContentView: View {
    @State private var showWhatsNew = false

    private let releases = DemoReleaseCatalog.releases

    var body: some View {
        NavigationStack {
            List {
                Section("Demo status") {
                    LabeledContent("Current version", value: WhatsNewAppVersion.current)
                }

                Section("Actions") {
                    Button("Open What's New manually") {
                        showWhatsNew = true
                    }
                }

                Section("Configured releases") {
                    ForEach(releases) { release in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(release.title)
                                .font(.headline)
                            Text("Version \(release.version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("WhatsNewKit Demo")
            .whatsNewSheet(releases: releases)
            .whatsNewSheet(
                isTriggered: $showWhatsNew,
                releases: releases
            )
        }
    }
}

enum DemoReleaseCatalog {
    static let releases = [
        WhatsNewRelease(
            version: "1.1.0",
            title: "What's new in the app",
            topics: [
                WhatsNewTopic(
                    title: "Clear release highlights",
                    description: "Important product updates are grouped into focused sections with concise titles and descriptions.",
                    icon: .systemImage("sparkles")
                ),
                WhatsNewTopic(
                    title: "Smarter presentation",
                    description: "Returning users only see releases they have not reviewed yet, keeping the update flow relevant.",
                    icon: .systemImage("checkmark.seal.fill")
                )
            ]
        ),
        WhatsNewRelease(
            version: "2.0.0",
            title: "New activity center",
            media: WhatsNewMedia(
                url: URL(string: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80")!,
                kind: .image
            ),
            topics: [
                WhatsNewTopic(
                    title: "Unified history",
                    description: "Important events now appear in a single chronological list.",
                    icon: .systemImage("clock.arrow.circlepath")
                ),
                WhatsNewTopic(
                    title: "Context filters",
                    description: "Use quick filters to find changes by product area.",
                    icon: .systemImage("line.3.horizontal.decrease.circle.fill")
                )
            ]
        ),
        WhatsNewRelease(
            version: "2.5.1",
            title: "Fixes and media in the sheet",
            media: WhatsNewMedia(
                url: URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4")!,
                kind: .video
            ),
            topics: [
                WhatsNewTopic(
                    title: "Video support",
                    description: "Each version can present an image or video URL.",
                    icon: .systemImage("play.rectangle.fill")
                ),
                WhatsNewTopic(
                    title: "Semantic comparison",
                    description: "Versions like 1.1.0, 1.0.0, and 2.5.1 are ordered numerically.",
                    icon: .systemImage("number.circle.fill")
                )
            ]
        )
    ]
}

#Preview {
    ContentView()
}
