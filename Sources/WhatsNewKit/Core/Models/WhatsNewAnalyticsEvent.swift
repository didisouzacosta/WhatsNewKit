import Foundation

public enum WhatsNewAnalyticsEvent: Equatable, Sendable {

    // MARK: - Cases

    case opened(WhatsNewPresentation)
    case closed(WhatsNewPresentation)
    case stepProgress(release: WhatsNewRelease, page: WhatsNewPage, index: Int, count: Int)

    // MARK: - Public Properties

    public var presentation: WhatsNewPresentation? {
        switch self {
        case let .opened(presentation), let .closed(presentation):
            presentation

        case .stepProgress:
            nil
        }
    }

    public var zeroBasedStepIndex: Int? {
        switch self {
        case let .stepProgress(_, _, index, _):
            index

        case .opened, .closed:
            nil
        }
    }

    public var oneBasedStepIndex: Int? {
        zeroBasedStepIndex.map { $0 + 1 }
    }

    public var totalStepCount: Int? {
        switch self {
        case let .stepProgress(_, _, _, count):
            count

        case .opened, .closed:
            nil
        }
    }
}
