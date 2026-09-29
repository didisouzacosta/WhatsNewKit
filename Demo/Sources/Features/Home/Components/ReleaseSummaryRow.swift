import SwiftUI

struct ReleaseSummaryRow: View {

    // MARK: - Properties

    let summary: ReleaseSummary

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            ReleaseIconTile(
                symbolName: summary.symbolName,
                isUpcoming: summary.stage == .upcoming
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(summary.title)
                        .font(.headline)

                    Spacer(minLength: 0)

                    ReleaseStageBadge(stage: summary.stage)
                }

                Text("Version \(summary.version)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)

                details
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Private Views

    private var details: some View {
        HStack(spacing: 12) {
            Label("^[\(summary.topicCount) topic](inflect: true)", systemImage: "list.bullet")

            if let media = mediaLabel {
                Label(media.title, systemImage: media.symbol)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .labelStyle(CompactLabelStyle())
    }

    // MARK: - Private Properties

    private var mediaLabel: (title: LocalizedStringKey, symbol: String)? {
        switch summary.mediaKind {
        case .none:
            nil

        case .image:
            ("Image", "photo")

        case .video:
            ("Video", "play.rectangle")
        }
    }
}

#Preview {
    List {
        ReleaseSummaryRow(summary: ReleaseSummary(release: DemoReleaseCatalog.releases[1], currentVersion: "2.5.1"))
        ReleaseSummaryRow(summary: ReleaseSummary(release: DemoReleaseCatalog.releases[2], currentVersion: "2.0.0"))
    }
}
