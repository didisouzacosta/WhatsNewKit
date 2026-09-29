import Foundation

struct SemanticVersion: Comparable {

    // MARK: - Internal Properties

    let rawValue: String

    // MARK: - Private Properties

    private let components: [Int]
    private let preReleaseIdentifiers: [String]

    // MARK: - Initializer

    /// Parses `rawValue` following SemVer precedence. Missing numeric components are
    /// treated as zero, a `-` suffix marks a pre-release and a `+` suffix is build
    /// metadata that does not affect the order. Returns `nil` when the numeric core
    /// has no digits.
    init?(_ rawValue: String) {
        let precedencePart = rawValue.prefix { $0 != "+" }
        let core = precedencePart.prefix { $0 != "-" }
        let components = core
            .split { character in
                (character.isASCII && character.isNumber) == false
            }
            .map { Int($0) ?? .max }

        guard components.isEmpty == false else {
            return nil
        }

        let preRelease = precedencePart.dropFirst(core.count + 1)

        self.rawValue = rawValue
        self.components = components
        self.preReleaseIdentifiers = preRelease.isEmpty ? [] : preRelease.split(separator: ".").map(String.init)
    }

    // MARK: - Comparable

    static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        compare(lhs, rhs) == .orderedSame
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        compare(lhs, rhs) == .orderedAscending
    }

    // MARK: - Private Methods

    private static func compare(_ lhs: SemanticVersion, _ rhs: SemanticVersion) -> ComparisonResult {
        let count = max(lhs.components.count, rhs.components.count)

        for index in 0..<count {
            let left = lhs.components.indices.contains(index) ? lhs.components[index] : 0
            let right = rhs.components.indices.contains(index) ? rhs.components[index] : 0

            if left != right {
                return left < right ? .orderedAscending : .orderedDescending
            }
        }

        return comparePreRelease(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers)
    }

    private static func comparePreRelease(_ lhs: [String], _ rhs: [String]) -> ComparisonResult {
        switch (lhs.isEmpty, rhs.isEmpty) {
        case (true, true):
            return .orderedSame

        case (true, false):
            return .orderedDescending

        case (false, true):
            return .orderedAscending

        case (false, false):
            break
        }

        for (left, right) in zip(lhs, rhs) {
            let result = compareIdentifier(left, right)

            if result != .orderedSame {
                return result
            }
        }

        if lhs.count == rhs.count {
            return .orderedSame
        }

        return lhs.count < rhs.count ? .orderedAscending : .orderedDescending
    }

    private static func compareIdentifier(_ lhs: String, _ rhs: String) -> ComparisonResult {
        switch (numericIdentifier(lhs), numericIdentifier(rhs)) {
        case let (left?, right?):
            if left == right {
                return .orderedSame
            }

            return left < right ? .orderedAscending : .orderedDescending

        case (.some, nil):
            return .orderedAscending

        case (nil, .some):
            return .orderedDescending

        case (nil, nil):
            return lhs.compare(rhs, options: .literal)
        }
    }

    private static func numericIdentifier(_ identifier: String) -> Int? {
        guard identifier.isEmpty == false, identifier.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            return nil
        }

        return Int(identifier) ?? .max
    }
}
