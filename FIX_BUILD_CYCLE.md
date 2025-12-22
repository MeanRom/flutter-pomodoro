# Fix Xcode Build Cycle Error

## The Problem
The build cycle occurs because the PomodoroWidget extension might have an incorrect dependency on the Runner target.

## Solution - Follow These Steps in Xcode:

### Step 1: Remove Widget Extension Dependency on Runner

1. In Xcode, click on the **Runner project** (blue icon at the top of Project Navigator)
2. Select the **PomodoroWidget** target (or PomodoroWidgetExtension) from the target list
3. Go to the **Build Phases** tab
4. Look for **Dependencies** section
5. **If you see "Runner" listed there, DELETE IT**:
   - Click on "Runner" in the dependencies list
   - Press the `-` (minus) button to remove it
6. The PomodoroWidget should **NOT** depend on Runner - they're independent

### Step 2: Check Target Dependencies in Runner

1. Still in the project settings, select the **Runner** target
2. Go to **Build Phases** tab
3. Look for **Dependencies** section
4. You should **NOT** see PomodoroWidget listed here either
5. If it is, remove it with the `-` button

### Step 3: Verify Embed App Extensions

1. Still on **Runner** target, **Build Phases** tab
2. Look for a phase called **Embed Foundation Extensions** or **Embed App Extensions**
3. **PomodoroWidget** (or PomodoroWidgetExtension.appex) **SHOULD** be listed here - this is correct
4. Make sure "Code Sign On Copy" is checked

### Step 4: Clean and Build

1. In Xcode menu: **Product → Clean Build Folder** (⇧⌘K)
2. Close Xcode completely
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
4. Reopen Xcode
5. Build the project (⌘B)

### Step 5: If Still Having Issues

The issue might be the "Thin Binary" script phase. Try this:

1. Select **Runner** target
2. Go to **Build Phases**
3. Find the **"Thin Binary"** script phase
4. **Drag it to be AFTER** the "Embed Foundation Extensions" phase
5. Clean and rebuild

## Alternative: Simpler Approach - Use Flutter to Build

Instead of building in Xcode directly, use Flutter:

```bash
flutter build ios --debug --no-codesign
```

Then open Xcode just to deploy to device:
1. Open Xcode
2. Select your device
3. Just hit Run (⌘R) - don't build first

## Quick Automated Fix

Run this in Terminal to clean everything:

```bash
cd /Users/thomasmoerman/Documents/flutter/pomodoro
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter pub get
```

Then open Xcode and try building again.
