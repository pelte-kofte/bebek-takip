import WidgetKit
import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
#endif

@available(iOS 16.1, *)
struct BabyTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BabyTimerAttributes.self) { context in
            // Lock Screen / Banner presentation
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    activityIcon(for: context.attributes.activityType)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(activityTitle(for: context.attributes.activityType))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.startDate, style: .timer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let side = context.state.side {
                        Text(sideLabel(side))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Color(red: 0.898, green: 0.878, blue: 0.969)
                                    .clipShape(Capsule())
                            )
                    }
                }
            } compactLeading: {
                activityIcon(for: context.attributes.activityType)
                    .font(.caption)
            } compactTrailing: {
                Text(context.state.startDate, style: .timer)
                    .monospacedDigit()
                    .font(.caption)
                    .frame(width: 48)
            } minimal: {
                activityIcon(for: context.attributes.activityType)
                    .font(.caption)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func activityIcon(for type: String) -> some View {
        if type == "sleep" {
            Image(systemName: "moon.zzz.fill")
                .foregroundColor(Color(red: 0.478, green: 0.455, blue: 0.620)) // Lavender-ish
        } else {
            Image(systemName: "drop.fill")
                .foregroundColor(Color(red: 1.0, green: 0.600, blue: 0.541)) // Peach
        }
    }

    private func activityTitle(for type: String) -> String {
        type == "sleep" ? "Uyku" : "Emzirme"
    }

    private func sideLabel(_ side: String) -> String {
        side == "sol" ? "SOL" : "SAĞ"
    }
}

// MARK: - Lock Screen View

@available(iOS 16.1, *)
struct LockScreenView: View {
    let context: ActivityViewContext<BabyTimerAttributes>

    private let peachColor = Color(red: 1.0, green: 0.706, blue: 0.635)     // #FFB4A2
    private let lavenderColor = Color(red: 0.898, green: 0.878, blue: 0.969) // #E5E0F7
    private let darkText = Color(red: 0.176, green: 0.102, blue: 0.094)      // #2D1A18

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 50, height: 50)

                if context.attributes.activityType == "sleep" {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.478, green: 0.455, blue: 0.620))
                } else {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(peachColor)
                }
            }

            // Title + Side
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.activityType == "sleep" ? "Uyku" : "Emzirme")
                    .font(.headline)
                    .foregroundColor(darkText)

                if let side = context.state.side {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(peachColor)
                            .frame(width: 6, height: 6)
                        Text(side == "sol" ? "Sol taraf" : "Sağ taraf")
                            .font(.caption)
                            .foregroundColor(darkText.opacity(0.6))
                    }
                }
            }

            Spacer()

            // Timer
            Text(context.state.startDate, style: .timer)
                .font(.system(.title, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(context.attributes.activityType == "sleep"
                    ? Color(red: 0.478, green: 0.455, blue: 0.620)
                    : peachColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(red: 1.0, green: 0.984, blue: 0.961)) // #FFFBF5 warm cream
    }

    private var iconBackground: Color {
        if context.attributes.activityType == "sleep" {
            return lavenderColor.opacity(0.5)
        } else {
            return peachColor.opacity(0.2)
        }
    }
}
