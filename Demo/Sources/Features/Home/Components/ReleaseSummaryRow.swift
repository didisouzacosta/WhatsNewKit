import SwiftUI
import WhatsNewKit

struct ReleaseSummaryRow: View {

    // MARK: - Properties

    let release: WhatsNewRelease

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(release.title)
                .font(.headline)

            Text("Version \(release.version)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        ReleaseSummaryRow(release: DemoReleaseCatalog.releases[0])
    }
}
