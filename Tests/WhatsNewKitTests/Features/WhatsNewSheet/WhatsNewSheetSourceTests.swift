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
