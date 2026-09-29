import Foundation

protocol WhatsNewStorage: AnyObject {
    var lastPresentedVersion: String? { get set }
}
