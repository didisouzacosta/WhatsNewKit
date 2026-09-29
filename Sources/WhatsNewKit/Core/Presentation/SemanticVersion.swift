import Foundation

struct SemanticVersion: Comparable {

    // MARK: - Private Properties

    private let rawValue: String
    private let components: [Int]

    // MARK: - Initializer

    init(_ rawValue: String) {
        self.rawValue = rawValue
        self.components = rawValue
            .split { character in
                character.isNumber == false
            }
            .compactMap { Int($0) }
    }

    // MARK: - Comparable

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)

        for index in 0..<count {
            let left = lhs.components.indices.contains(index) ? lhs.components[index] : 0
            let right = rhs.components.indices.contains(index) ? rhs.components[index] : 0

            if left != right {
                return left < right
            }
        }

        return false
    }
}
