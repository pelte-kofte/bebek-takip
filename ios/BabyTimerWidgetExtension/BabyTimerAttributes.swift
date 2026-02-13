import ActivityKit
import Foundation

/// Shared between Runner and Widget Extension targets.
struct BabyTimerAttributes: ActivityAttributes {
    /// Fixed properties set at creation time
    var babyId: String
    var activityType: String  // "sleep" or "nursing"

    /// Dynamic state that can be updated while the activity is running
    struct ContentState: Codable, Hashable {
        var startDate: Date
        var side: String?  // "sol" or "sag"; nil for sleep activities
    }
}
