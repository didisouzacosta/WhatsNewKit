import SwiftUI

public extension View {

    // MARK: - Presentation

    /// Presents the releases the user has not seen yet, up to `currentVersion`, when
    /// `canPresent` is `true`. On a new install nothing is presented: the current
    /// version is recorded and only later updates are shown.
    ///
    /// `defaults` and `namespace` select where the last presented version is stored
    /// and must match the values passed to `WhatsNewPresentationState`.
    func whatsNewSheet(
        releases: [WhatsNewRelease],
        canPresent: Bool = true,
        currentVersion: String = WhatsNewAppVersion.current,
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit",
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewPresentationModifier(
                isTriggered: .constant(false),
                releases: releases,
                isAutomaticPresentationEnabled: true,
                canPresent: canPresent,
                currentVersion: currentVersion,
                storage: UserDefaultsWhatsNewStorage(defaults: defaults, namespace: namespace),
                onEvent: onEvent
            )
        )
    }

    /// Presents every declared release when `isTriggered` becomes `true`. Manual
    /// presentations never change which releases are shown automatically.
    func whatsNewSheet(
        isTriggered: Binding<Bool>,
        releases: [WhatsNewRelease],
        currentVersion: String = WhatsNewAppVersion.current,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewPresentationModifier(
                isTriggered: isTriggered,
                releases: releases,
                isAutomaticPresentationEnabled: false,
                canPresent: false,
                currentVersion: currentVersion,
                storage: UserDefaultsWhatsNewStorage(),
                onEvent: onEvent
            )
        )
    }

    /// Combines automatic and manual presentation in a single sheet. Prefer this
    /// overload over applying both modifiers to the same view.
    func whatsNewSheet(
        releases: [WhatsNewRelease],
        canPresent: Bool = true,
        isTriggered: Binding<Bool>,
        currentVersion: String = WhatsNewAppVersion.current,
        defaults: UserDefaults = .standard,
        namespace: String = Bundle.main.bundleIdentifier ?? "WhatsNewKit",
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewPresentationModifier(
                isTriggered: isTriggered,
                releases: releases,
                isAutomaticPresentationEnabled: true,
                canPresent: canPresent,
                currentVersion: currentVersion,
                storage: UserDefaultsWhatsNewStorage(defaults: defaults, namespace: namespace),
                onEvent: onEvent
            )
        )
    }
}
