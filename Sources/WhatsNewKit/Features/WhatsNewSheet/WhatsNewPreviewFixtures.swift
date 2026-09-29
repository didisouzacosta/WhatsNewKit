#if DEBUG
    import Foundation

    enum WhatsNewPreviewFixtures {

        // MARK: - Topics

        static let topics = [
            WhatsNewTopic(
                id: "highlights",
                title: "Clear release highlights",
                description: "Important updates are grouped into focused sections.",
                icon: .systemImage("sparkles")
            ),
            WhatsNewTopic(
                id: "history",
                title: "Unified history",
                description: "Important events now appear in a single chronological list.",
                icon: .systemImage("clock.arrow.circlepath")
            ),
        ]

        // MARK: - Releases

        static let firstRelease = WhatsNewRelease(
            version: "1.1.0",
            title: "What's new in the app",
            topics: topics
        )

        static let secondRelease = WhatsNewRelease(
            version: "2.0.0",
            title: "New activity center",
            topics: Array(topics.reversed())
        )

        // MARK: - Presentations

        static let singleRelease = WhatsNewPresentation(releases: [firstRelease])

        static let multipleReleases = WhatsNewPresentation(releases: [
            firstRelease,
            secondRelease,
        ])
    }
#endif
