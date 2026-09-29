import SwiftUI

struct HomeHeader: View {

    // MARK: - Properties

    let currentVersion: String

    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize = 76

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: badgeSize, height: badgeSize)
                .background(DemoTheme.brandGradient, in: .rect(cornerRadius: badgeSize * 0.28))
                .shadow(color: DemoTheme.brandPurple.opacity(0.35), radius: 12, y: 6)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("WhatsNewKit")
                    .font(.title2.bold())

                Text("Release notes that show up right after an update.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Label("Installed version \(currentVersion)", systemImage: "app.badge.checkmark")
                .font(.footnote.weight(.semibold).monospacedDigit())
                .labelStyle(CompactLabelStyle())
                .foregroundStyle(DemoTheme.brandBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DemoTheme.brandBlue.opacity(0.12), in: .capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeHeader(currentVersion: "2.5.1")
        .padding()
}
