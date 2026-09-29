import SwiftUI

enum DemoTheme {

    // MARK: - Colors

    static let brandBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let brandPurple = Color(red: 0.45, green: 0.24, blue: 0.93)

    // MARK: - Gradients

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [brandBlue, brandPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
