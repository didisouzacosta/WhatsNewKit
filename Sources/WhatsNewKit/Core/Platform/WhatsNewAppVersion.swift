import Foundation

public enum WhatsNewAppVersion {
    public static var current: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }
}
