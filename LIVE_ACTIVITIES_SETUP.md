# iOS Live Activities Setup Guide

This guide will help you complete the setup for iOS Live Activities, which will display the Pomodoro timer on the lock screen and in the Dynamic Island (iPhone 14 Pro and later).

## Prerequisites
- macOS with Xcode 14.1 or later
- iOS 16.1 or later target device
- Valid Apple Developer account for code signing

## Setup Steps

### 1. Create a Widget Extension in Xcode

1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode, go to **File > New > Target**

3. Select **Widget Extension** and click **Next**

4. Configure the extension:
   - **Product Name**: `PomodoroWidget`
   - **Include Configuration Intent**: ✅ (unchecked)
   - **Include Live Activity**: ✅ (checked) - **IMPORTANT**
   - Click **Finish**

5. When prompted "Activate 'PomodoroWidget' scheme?", click **Activate**

### 2. Update the Widget Extension Code

1. In the Project Navigator, expand the **PomodoroWidget** folder

2. Open `PomodoroWidget.swift`

3. Replace its contents with:

```swift
import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct PomodoroActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(context.state.sessionName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(timerText(from: context.state.remainingSeconds))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                ProgressView(value: Double(context.state.remainingSeconds),
                           total: Double(context.state.totalSeconds))
                    .tint(.blue)
            }
            .padding()
            .activityBackgroundTint(Color.white.opacity(0.9))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            // Dynamic Island configuration
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.sessionName, systemImage: "timer")
                        .font(.caption)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText(from: context.state.remainingSeconds))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        ProgressView(value: Double(context.state.remainingSeconds),
                                   total: Double(context.state.totalSeconds))
                            .tint(.blue)

                        Text("Remaining time")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                Label {
                    Text(timerText(from: context.state.remainingSeconds))
                } icon: {
                    Image(systemName: "timer")
                }
                .font(.caption2)
            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                Text(timerText(from: context.state.remainingSeconds))
                    .font(.caption2)
                    .fontWeight(.semibold)
            } minimal: {
                // Minimal presentation (when multiple activities are active)
                Image(systemName: "timer")
            }
        }
    }

    private func timerText(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
```

4. Make sure the `PomodoroActivityAttributes.swift` file is included in **both** targets:
   - In Project Navigator, select `PomodoroActivityAttributes.swift`
   - In the File Inspector (right panel), under **Target Membership**, ensure both `Runner` and `PomodoroWidget` are checked

### 3. Update Deployment Target

1. In Xcode, select the project in the Project Navigator
2. Select the **PomodoroWidget** target
3. In the **General** tab, set **Deployment Info > iOS** to **16.1** or later

### 4. Configure App Groups (Required for Data Sharing)

1. Select the **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Click **+** under App Groups and create: `group.com.yourcompany.pomodoro`
5. Repeat steps 1-4 for the **PomodoroWidget** target, using the **same** group name

### 5. Build and Run

1. Select your iOS device (not simulator - Live Activities don't work in simulator)
2. Build and run the app: **Product > Run** or **⌘R**
3. Start a Pomodoro timer
4. Lock your device or go to the home screen
5. You should see the timer on the lock screen and in the Dynamic Island (if supported)

## Troubleshooting

### Live Activity doesn't appear
- Ensure your device is running iOS 16.1 or later
- Check that Live Activities are enabled: **Settings > Face ID & Passcode > Allow Access When Locked > Live Activities**
- Verify the app has the correct entitlements and code signing

### Build errors
- Clean the build folder: **Product > Clean Build Folder** (⇧⌘K)
- Delete derived data: **Xcode > Settings > Locations > Derived Data > Delete**
- Run `flutter clean && flutter pub get` in terminal

### Widget Extension not found
- Make sure you created the Widget Extension target with "Include Live Activity" checked
- Verify `PomodoroActivityAttributes.swift` is included in both targets

## Testing

1. **Start Timer**: Launch the app and start a Pomodoro session
2. **Lock Screen**: Lock your device - the timer should appear on the lock screen
3. **Home Screen**: Swipe up to go home - the timer should appear in the Dynamic Island (iPhone 14 Pro+)
4. **Pause/Resume**: Pause and resume the timer - the Live Activity should end when paused
5. **Session Changes**: Let the timer complete - the Live Activity should update for the next session

## Features

- ✅ **Lock Screen Display**: Shows timer countdown on the lock screen
- ✅ **Dynamic Island**: Displays timer in the Dynamic Island (iPhone 14 Pro and later)
- ✅ **Real-time Updates**: Updates every 5 seconds to show remaining time
- ✅ **Session Tracking**: Shows current session type (Focus, Short Break, Long Break)
- ✅ **Progress Bar**: Visual progress indicator
- ✅ **Auto-dismiss**: Live Activity ends when timer is paused or completed

## Notes

- Live Activities are **only available on physical iOS devices running iOS 16.1+**
- They **do not work in the iOS Simulator**
- The Dynamic Island is only available on iPhone 14 Pro, iPhone 14 Pro Max, and later models
- On other devices, the Live Activity appears on the lock screen and as a banner notification

---

For more information, see:
- [Apple's Live Activities Documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [live_activities Flutter Package](https://pub.dev/packages/live_activities)
