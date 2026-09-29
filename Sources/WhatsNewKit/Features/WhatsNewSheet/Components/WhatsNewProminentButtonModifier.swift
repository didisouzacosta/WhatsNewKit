import SwiftUI

struct WhatsNewProminentButtonModifier: ViewModifier {

    // MARK: - Body

    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
            if #available(iOS 26.0, *) {
                content
                    .buttonStyle(.glassProminent)
            } else {
                content
                    .buttonStyle(.borderedProminent)
            }
        #else
            content
                .buttonStyle(.borderedProminent)
        #endif
    }
}

extension View {
    func whatsNewGlassProminentButtonStyle() -> some View {
        modifier(WhatsNewProminentButtonModifier())
    }
}
