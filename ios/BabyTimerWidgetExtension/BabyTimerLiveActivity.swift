import WidgetKit
import SwiftUI
import UIKit

#if canImport(ActivityKit)
import ActivityKit
#endif

private func iconImage(for type: String) -> Image {
    let name = (type == "sleep") ? "la_sleep" : "la_nursing"
    let bundle = Bundle(for: BabyTimerLiveActivity.self)
    if let uiImage = UIImage(named: name, in: bundle, compatibleWith: nil) {
        return Image(uiImage: uiImage).renderingMode(.original)
    }
    return Image(systemName: "exclamationmark.triangle.fill")
}

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
                    iconImage(for: context.attributes.activityType)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.state.localizedTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let subtitle = subtitleText(for: context), !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(context.state.startDate, style: .timer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let subtitle = subtitleText(for: context), !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Color(red: 0.898, green: 0.878, blue: 0.969)
                                    .clipShape(Capsule())
                            )
                    } else {
                        EmptyView()
                    }
                }
            } compactLeading: {
                iconImage(for: context.attributes.activityType)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } compactTrailing: {
                if let subtitle = subtitleText(for: context), !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .lineLimit(1)
                } else {
                    Text(context.state.startDate, style: .timer)
                        .monospacedDigit()
                        .font(.caption)
                        .frame(width: 48)
                }
            } minimal: {
                iconImage(for: context.attributes.activityType)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }

    // MARK: - Helpers

    private func subtitleText(for context: ActivityViewContext<BabyTimerAttributes>) -> String? {
        let babyName = context.state.babyName
        let sideLabel = context.state.localizedSubtitle ?? ""
        let hasBabyName = !babyName.isEmpty
        let hasSideLabel = !sideLabel.isEmpty

        if context.attributes.activityType == "nursing" {
            if hasBabyName && hasSideLabel {
                return "\(babyName) • \(sideLabel)"
            }
            return hasBabyName ? babyName : (hasSideLabel ? sideLabel : nil)
        }

        if hasBabyName {
            return babyName
        }
        return hasSideLabel ? sideLabel : nil
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
                iconImage(for: context.attributes.activityType)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }

            // Title + Side
            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.localizedTitle)
                    .font(.headline)
                    .foregroundColor(darkText)

                if let subtitle = subtitleText, !subtitle.isEmpty {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(peachColor)
                            .frame(width: 6, height: 6)
                        Text(subtitle)
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

    private var subtitleText: String? {
        let babyName = context.state.babyName
        let sideLabel = context.state.localizedSubtitle ?? ""
        let hasBabyName = !babyName.isEmpty
        let hasSideLabel = !sideLabel.isEmpty

        if context.attributes.activityType == "nursing" {
            if hasBabyName && hasSideLabel {
                return "\(babyName) • \(sideLabel)"
            }
            return hasBabyName ? babyName : (hasSideLabel ? sideLabel : nil)
        }

        if hasBabyName {
            return babyName
        }
        return hasSideLabel ? sideLabel : nil
    }
}
