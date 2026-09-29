import SwiftUI

struct WhatsNewStepIndicator: View {

    // MARK: - Properties

    let currentIndex: Int
    let count: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: index == currentIndex ? 20 : 8, height: 8)
                    .animation(.snappy, value: currentIndex)
            }
        }
        .accessibilityLabel(WhatsNewLocalized.stepIndicatorAccessibilityLabel(
            current: currentIndex + 1,
            count: count
        ))
    }
}

#Preview {
    WhatsNewStepIndicator(currentIndex: 1, count: 3)
}
