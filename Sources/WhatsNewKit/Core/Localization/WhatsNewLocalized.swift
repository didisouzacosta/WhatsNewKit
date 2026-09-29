import Foundation

enum WhatsNewLocalized {

    // MARK: - Strings

    static let navigationTitle = string(
        key: "whatsnew.navigation.title",
        value: "What's New",
        comment: "Navigation title for the WhatsNew sheet."
    )

    static let closeAccessibilityLabel = string(
        key: "whatsnew.close.accessibility_label",
        value: "Close",
        comment: "Accessibility label for the close button."
    )

    static let continueButtonTitle = string(
        key: "whatsnew.continue_button.title",
        value: "Continue",
        comment: "Button title used to advance to the next release page."
    )

    static let finishButtonTitle = string(
        key: "whatsnew.finish_button.title",
        value: "Done",
        comment: "Button title used to finish and dismiss the WhatsNew sheet."
    )

    // MARK: - Formatted Strings

    static func versionTitle(_ version: String) -> String {
        String(
            format: string(
                key: "whatsnew.version.title",
                value: "Version %@",
                comment: "Version label. The placeholder is the app release version."
            ),
            version
        )
    }

    static func stepIndicatorAccessibilityLabel(current: Int, count: Int) -> String {
        String(
            format: string(
                key: "whatsnew.step_indicator.accessibility_label",
                value: "Step %d of %d",
                comment: """
                Accessibility label for the page step indicator. \
                The placeholders are the current step and total step count.
                """
            ),
            current,
            count
        )
    }

    // MARK: - Private Methods

    private static func string(
        key: String,
        value: String,
        comment: String
    ) -> String {
        NSLocalizedString(
            key,
            bundle: .module,
            value: value,
            comment: comment
        )
    }
}
