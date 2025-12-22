import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionName: String
        var totalSeconds: Int
        var remainingSeconds: Int
        var endTimestamp: Int
    }

    // No fixed attributes for now, all data is dynamic
}
