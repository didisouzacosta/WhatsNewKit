import SwiftUI

struct ReleaseIconTile: View {

    // MARK: - Properties

    let symbolName: String
    let isUpcoming: Bool

    @ScaledMetric(relativeTo: .headline) private var size = 44

    // MARK: - Body

    var body: some View {
        Image(systemName: symbolName)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(background, in: .rect(cornerRadius: size * 0.26))
            .accessibilityHidden(true)
    }

    // MARK: - Private Properties

    private var background: AnyShapeStyle {
        isUpcoming ? AnyShapeStyle(Color.gray.gradient) : AnyShapeStyle(DemoTheme.brandGradient)
    }
}

#Preview {
    HStack {
        ReleaseIconTile(symbolName: "sparkles", isUpcoming: false)
        ReleaseIconTile(symbolName: "clock.arrow.circlepath", isUpcoming: true)
    }
}
