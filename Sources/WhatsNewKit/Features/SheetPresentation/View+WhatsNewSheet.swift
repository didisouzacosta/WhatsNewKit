import SwiftUI

public extension View {

    // MARK: - Presentation

    func whatsNewSheet(
        releases: [WhatsNewRelease],
        canPresent: Bool = true,
        currentVersion: String = WhatsNewAppVersion.current,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewAutoPresentationModifier(
                releases: releases,
                canPresent: canPresent,
                currentVersion: currentVersion,
                onEvent: onEvent
            )
        )
    }

    func whatsNewSheet(
        isTriggered: Binding<Bool>,
        releases: [WhatsNewRelease],
        currentVersion: String = WhatsNewAppVersion.current,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewTriggeredPresentationModifier(
                isTriggered: isTriggered,
                releases: releases,
                currentVersion: currentVersion,
                onEvent: onEvent
            )
        )
    }
}
