import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
@main
struct BabyTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        BabyTimerLiveActivity()
    }
}
