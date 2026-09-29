import Foundation
import Testing

@Suite("WhatsNew sheet source")
struct WhatsNewSheetSourceTests {

    // MARK: - Tests

    @Test("content uses standard navigation and safe area aware scroll spacing")
    func contentUsesStandardNavigationAndSafeAreaAwareScrollSpacing() throws {
        let sheet = try sourceFile(at: "Features/WhatsNewSheet/WhatsNewSheet.swift")
        let releasePage = try sourceFile(at: "Features/WhatsNewSheet/Components/WhatsNewReleasePage.swift")

        #expect(sheet.contains("NavigationStack"))
        #expect(sheet.contains(".navigationTitle(WhatsNewLocalized.navigationTitle)"))
        #expect(sheet.contains(".toolbarBackground(.hidden, for: .navigationBar)"))
        #expect(sheet.contains("private var header: some View") == false)
        #expect(sheet.contains(".toolbarBackground(.visible, for: .navigationBar)") == false)
        #expect(releasePage.contains("proxy.safeAreaInsets.top + WhatsNewSheetLayout.pageTopContentSpacing"))
        #expect(releasePage.contains("proxy.safeAreaInsets.bottom + WhatsNewSheetLayout.pageBottomContentSpacing"))
    }

    @Test("page content starts at the top and only scrolls when it does not fit")
    func pageContentStartsAtTopAndOnlyScrollsWhenNeeded() throws {
        let releasePage = try sourceFile(at: "Features/WhatsNewSheet/Components/WhatsNewReleasePage.swift")
        let layout = try sourceFile(at: "Features/WhatsNewSheet/WhatsNewSheetLayout.swift")

        #expect(releasePage.contains(".scrollBounceBehavior(.basedOnSize)"))
        #expect(layout.contains("pageTopContentSpacing: CGFloat = 96") == false)
        #expect(layout.contains("pageBottomContentSpacing: CGFloat = 144") == false)
    }

    @Test("footer keeps the prominent button over a transparent background")
    func footerHasTransparentBackground() throws {
        let footer = try sourceFile(at: "Features/WhatsNewSheet/Components/WhatsNewSheetFooter.swift")

        #expect(footer.contains(".whatsNewGlassProminentButtonStyle()"))
        #expect(footer.contains("Material") == false)
        #expect(footer.contains(".background") == false)
    }

    // MARK: - Private Methods

    private func sourceFile(at relativePath: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = packageRoot
            .appendingPathComponent("Sources/WhatsNewKit")
            .appendingPathComponent(relativePath)

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
