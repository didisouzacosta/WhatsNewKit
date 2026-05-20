import SwiftUI

public extension View {
    func whatsNewSheet(
        releases: [WhatsNewRelease],
        currentVersion: String = WhatsNewAppVersion.current,
        onEvent: @escaping (WhatsNewAnalyticsEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            WhatsNewAutoPresentationModifier(
                releases: releases,
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

private struct WhatsNewAutoPresentationModifier: ViewModifier {
    let releases: [WhatsNewRelease]
    let currentVersion: String
    let onEvent: (WhatsNewAnalyticsEvent) -> Void

    private let storage = UserDefaultsWhatsNewStorage()

    @State private var activePresentation: WhatsNewPresentation?
    @State private var hasEvaluated = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard hasEvaluated == false else {
                    return
                }

                hasEvaluated = true
                activePresentation = WhatsNewPresentationPolicy.presentation(
                    currentVersion: currentVersion,
                    releases: releases,
                    storage: storage,
                    trigger: .appLaunch
                )
            }
            .sheet(item: $activePresentation) { presentation in
                WhatsNewSheet(
                    presentation: presentation,
                    onEvent: onEvent
                ) {
                    WhatsNewPresentationPolicy.register(presentation, storage: storage)
                    activePresentation = nil
                }
            }
    }
}

private struct WhatsNewTriggeredPresentationModifier: ViewModifier {
    @Binding var isTriggered: Bool

    let releases: [WhatsNewRelease]
    let currentVersion: String
    let onEvent: (WhatsNewAnalyticsEvent) -> Void

    private let storage = UserDefaultsWhatsNewStorage()

    @State private var activePresentation: WhatsNewPresentation?

    func body(content: Content) -> some View {
        content
            .onChange(of: isTriggered, initial: false) { _, newValue in
                guard newValue else {
                    return
                }

                activePresentation = WhatsNewPresentationPolicy.presentation(
                    currentVersion: currentVersion,
                    releases: releases,
                    storage: storage,
                    trigger: .manual
                )
                isTriggered = false
            }
            .sheet(item: $activePresentation) { presentation in
                WhatsNewSheet(
                    presentation: presentation,
                    onEvent: onEvent
                ) {
                    WhatsNewPresentationPolicy.register(presentation, storage: storage)
                    activePresentation = nil
                }
            }
    }
}

public enum WhatsNewAppVersion {
    public static var current: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }
}
