import SwiftUI

struct ReleaseStageBadge: View {

    // MARK: - Properties

    let stage: ReleaseStage

    // MARK: - Body

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.14), in: .capsule)
    }

    // MARK: - Private Properties

    private var title: LocalizedStringKey {
        switch stage {
        case .released:
            "Released"

        case .current:
            "Current"

        case .upcoming:
            "Upcoming"
        }
    }

    private var color: Color {
        switch stage {
        case .released:
            .secondary

        case .current:
            DemoTheme.brandBlue

        case .upcoming:
            .orange
        }
    }
}

#Preview {
    HStack {
        ReleaseStageBadge(stage: .released)
        ReleaseStageBadge(stage: .current)
        ReleaseStageBadge(stage: .upcoming)
    }
}
