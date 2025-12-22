import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct PomodoroActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text(context.state.sessionName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(timerText(from: context.state.remainingSeconds))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .monospacedDigit()
                }

                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: Double(context.state.remainingSeconds),
                               total: Double(context.state.totalSeconds))
                        .tint(.blue)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)

                    HStack {
                        Text(progressText(current: context.state.remainingSeconds,
                                        total: context.state.totalSeconds))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int((Double(context.state.totalSeconds - context.state.remainingSeconds) / Double(context.state.totalSeconds)) * 100))% complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .activityBackgroundTint(Color.white.opacity(0.95))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            // Dynamic Island configuration
            DynamicIsland {
                // Expanded UI - when user long presses
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.title3)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.sessionName)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Pomodoro")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timerText(from: context.state.remainingSeconds))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .monospacedDigit()

                        Text("remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(value: Double(context.state.remainingSeconds),
                                   total: Double(context.state.totalSeconds))
                            .tint(.blue)
                            .scaleEffect(x: 1, y: 2, anchor: .center)

                        HStack {
                            Text(progressText(current: context.state.remainingSeconds,
                                            total: context.state.totalSeconds))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(Int((Double(context.state.totalSeconds - context.state.remainingSeconds) / Double(context.state.totalSeconds)) * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                }

            } compactLeading: {
                // Compact leading (left side when not expanded)
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)

                    Text(timerText(from: context.state.remainingSeconds))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                .foregroundColor(.blue)

            } compactTrailing: {
                // Compact trailing (right side when not expanded)
                ProgressView(value: Double(context.state.remainingSeconds),
                           total: Double(context.state.totalSeconds)) {
                    EmptyView()
                }
                .progressViewStyle(.circular)
                .tint(.blue)

            } minimal: {
                // Minimal presentation (when multiple activities are active)
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }
        }
    }

    // Helper function to format time as MM:SS
    private func timerText(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // Helper function to show progress text
    private func progressText(current: Int, total: Int) -> String {
        let elapsed = total - current
        let minutes = elapsed / 60
        let secs = elapsed % 60
        return String(format: "%02d:%02d elapsed", minutes, secs)
    }
}

@available(iOS 16.1, *)
struct PomodoroWidget_Previews: PreviewProvider {
    static let attributes = PomodoroActivityAttributes()
    static let contentState = PomodoroActivityAttributes.ContentState(
        sessionName: "Focus",
        totalSeconds: 1500,
        remainingSeconds: 900,
        endTimestamp: Int(Date().timeIntervalSince1970) + 900
    )

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")

        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")

        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
    }
}
