import Foundation
import Testing

@Suite("WhatsNew sheet source")
struct WhatsNewSheetSourceTests {
    @Test("content uses standard navigation and safe area aware scroll spacing")
    func contentUsesStandardNavigationAndSafeAreaAwareScrollSpacing() throws {
        let source = try sourceFile(named: "WhatsNewSheet.swift")

        #expect(source.contains("NavigationStack"))
        #expect(source.contains(".navigationTitle(WhatsNewLocalized.navigationTitle)"))
        #expect(source.contains(".toolbarBackground(.hidden, for: .navigationBar)"))
        #expect(source.contains("proxy.safeAreaInsets.top + pageTopContentSpacing"))
        #expect(source.contains("proxy.safeAreaInsets.bottom + pageBottomContentSpacing"))
        #expect(source.contains("private var header: some View") == false)
        #expect(source.contains(".toolbarBackground(.visible, for: .navigationBar)") == false)
    }

    private func sourceFile(named fileName: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let packageRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = packageRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent("WhatsNewKit")
            .appendingPathComponent(fileName)

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
