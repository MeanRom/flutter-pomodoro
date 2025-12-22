//
//  PomodoroWidgetLiveActivity.swift
//  PomodoroWidget
//
//  Created by Thomas Moerman on 22/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PomodoroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            // Lock screen/banner UI
            HStack(spacing: 16) {
                // Timer icon with session color
                ZStack {
                    Circle()
                        .fill(sessionColor(for: context.state.sessionName).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "timer")
                        .font(.title2)
                        .foregroundColor(sessionColor(for: context.state.sessionName))
                }

                VStack(alignment: .leading, spacing: 6) {
                    // Session name
                    Text(context.state.sessionName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    // Time remaining
                    Text(timerText(from: context.state.remainingSeconds))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(sessionColor(for: context.state.sessionName))
                        .monospacedDigit()

                    // Progress bar
                    ProgressView(value: Double(context.state.totalSeconds - context.state.remainingSeconds),
                               total: Double(context.state.totalSeconds))
                        .tint(sessionColor(for: context.state.sessionName))
                        .scaleEffect(x: 1, y: 1.2, anchor: .center)
                }

                Spacer()

                // "Tap to open" indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .activityBackgroundTint(Color(white: 0.95))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            // Dynamic Island configuration
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.title3)
                                .foregroundColor(sessionColor(for: context.state.sessionName))

                            Text(context.state.sessionName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text("Pomodoro Timer")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timerText(from: context.state.remainingSeconds))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(sessionColor(for: context.state.sessionName))
                            .monospacedDigit()

                        Text("remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)

                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(sessionColor(for: context.state.sessionName))
                                    .frame(
                                        width: geometry.size.width * CGFloat(Double(context.state.totalSeconds - context.state.remainingSeconds) / Double(context.state.totalSeconds)),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        HStack {
                            Text("\(Int((Double(context.state.totalSeconds - context.state.remainingSeconds) / Double(context.state.totalSeconds)) * 100))% complete")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("Tap to open")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 6)
                }

            } compactLeading: {
                // Compact leading
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundColor(sessionColor(for: context.state.sessionName))
                }

            } compactTrailing: {
                // Compact trailing - show time
                Text(timerText(from: context.state.remainingSeconds))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(sessionColor(for: context.state.sessionName))
                    .monospacedDigit()

            } minimal: {
                // Minimal - just timer icon
                Image(systemName: "timer")
                    .foregroundColor(sessionColor(for: context.state.sessionName))
            }
        }
    }

    // Helper: Format time as MM:SS
    private func timerText(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // Helper: Get color based on session type
    private func sessionColor(for sessionName: String) -> Color {
        switch sessionName.lowercased() {
        case "focus":
            return Color.red
        case "short break":
            return Color.green
        case "long break":
            return Color.blue
        default:
            return Color.blue
        }
    }
}

extension PomodoroActivityAttributes {
    fileprivate static var preview: PomodoroActivityAttributes {
        PomodoroActivityAttributes()
    }
}

extension PomodoroActivityAttributes.ContentState {
    fileprivate static var focus: PomodoroActivityAttributes.ContentState {
        PomodoroActivityAttributes.ContentState(
            sessionName: "Focus",
            totalSeconds: 1500,
            remainingSeconds: 900,
            endTimestamp: Int(Date().timeIntervalSince1970) + 900
        )
    }

    fileprivate static var shortBreak: PomodoroActivityAttributes.ContentState {
        PomodoroActivityAttributes.ContentState(
            sessionName: "Short Break",
            totalSeconds: 300,
            remainingSeconds: 180,
            endTimestamp: Int(Date().timeIntervalSince1970) + 180
        )
    }
}

#Preview("Notification", as: .content, using: PomodoroActivityAttributes.preview) {
   PomodoroWidgetLiveActivity()
} contentStates: {
    PomodoroActivityAttributes.ContentState.focus
    PomodoroActivityAttributes.ContentState.shortBreak
}
