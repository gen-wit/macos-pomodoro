# macOS Pomodoro

A minimalist Pomodoro timer for macOS, built as a glass widget docked to the edge of your screen. The app is written natively in Swift and SwiftUI (with AppKit where SwiftUI is not enough), has no Dock icon and lives in the menu bar.

## Features

- **Session and break timer** with pause and reset. You set the session length (1–180 min) and break length (1–60 min) in the menu.
- **Long break** after four sessions (15 min by default, 0 turns it off).
- **Session dots** showing progress through the four-session cycle.
- **Widget docked to a screen edge** (left, right, top or bottom) that you can drag along that edge so it does not cover content in other apps. The position is remembered separately for each edge.
- **Compact mode:** while the timer is running or ready to start (but not while paused, so it stays visible as a hint to resume), the widget smoothly collapses to just the ring with the time and dots after 3 seconds without the cursor, and expands again when you hover over it. After the app starts (for example at login) the widget also starts collapsed and expands on hover.
- **Adjustable size** of the widget (reduced by 0–50%).
- **Glass look:** blurred background, red tint for work sessions and teal for breaks, a progress ring with a glow.
- **Menu bar icon** showing the time remaining in the current phase.
- **System notifications** at the end of a session and a break.
- **Statistics:** number of sessions, percentage of sessions completed without interruption, and average session length.
- **Launch at login** to macOS.

## Requirements

- macOS 14 (Sonoma) or later for the code (the Xcode project may be set to a higher deployment target, which you can lower in the target settings)
- Xcode 15 or later

## Running from source

1. Open `Pomodoro-app.xcodeproj` in Xcode.
2. Run the app (⌘R).

After launch no regular window appears. You will see the widget at the edge of the screen and a clock icon in the menu bar. You can quit the app from the settings popover (*Quit Pomodoro*) or with the Stop button in Xcode.

If you want to recreate the project from the sources instead:

1. In Xcode: *File → New → Project → macOS → App*. Name: `PomodoroWidget`, interface: SwiftUI, language: Swift.
2. Delete the generated `PomodoroWidgetApp.swift` and `ContentView.swift` files.
3. Drag all files from the `PomodoroWidget/` folder into the project (tick *Copy items if needed* and the right target).
4. In `Assets.xcassets`, replace `AppIcon` with the `Design/AppIcon.appiconset` folder.
5. In the target settings, set *Minimum Deployments* to macOS 14.0 or higher.

### Exporting to `.app`

*Product → Archive → Distribute App → Copy App*, then drag the app to the *Applications* folder. The app is not signed or notarized, so macOS may block it the first time you launch it. Open it with a right-click (*Open*) or allow it in *System Settings → Privacy & Security*. Launch at login works best for the app located in the *Applications* folder.

## Usage

- **START / PAUSE / RESUME** starts, pauses and resumes the countdown, **RESET** returns to the ready state.
- **Drag** the widget by its background, ring or labels to move it along the edge.
- The **clock icon in the menu bar** opens a popover with settings and statistics.

### Settings

| Setting | Description |
| --- | --- |
| Session | Length of a work session, 1–180 min |
| Break | Length of a regular break, 1–60 min |
| Long break | Length of the long break after 4 sessions, 5–60 min (0 = off) |
| Size reduction | Shrinks the widget by 0–50% |
| Screen edge | The screen edge the widget is docked to |
| Show time in menu bar | Time next to the icon in the menu bar |
| Compact mode | Automatically collapses the widget while the timer is running |
| Start collapsed after launch | The widget starts in compact form and expands when you hover over it |
| Center widget on edge | Moves the widget back to the middle of the current edge |
| Launch at login | Starts the app when you log in |

### Statistics

- A pause during a work session counts as an interruption of that session.
- A reset before the end of a session records it as interrupted. Interrupted sessions shorter than 10 seconds are ignored.
- Data is stored locally in `~/Library/Application Support/PomodoroWidget/sessions.json`. The *Reset statistics* button in the menu clears the history.

## Troubleshooting

### Generic icon in notifications

If notifications show a blank, generic icon instead of the app icon, macOS has cached the icon from before it existed (or from another copy of the app with the same bundle identifier). The icon set itself is fine. Try, in order:

1. Quit the app and keep only one copy of it (remove old copies from *Applications* or DerivedData). In Xcode run *Product → Clean Build Folder* (⇧⌘K).
2. Refresh the system caches:
   ```
   killall NotificationCenter usernoted Dock Finder
   ```
3. If that is not enough, clear the icon cache and restart the Mac (macOS rebuilds it automatically):
   ```
   sudo rm -rf /Library/Caches/com.apple.iconservices.store
   ```
4. As a last resort, set your own *Bundle Identifier* in *target → Signing & Capabilities*. Note that this resets notification permission, settings and statistics, because the sandbox container depends on the identifier.

## Repository structure

```
macos-pomodoro/
├── README.md
├── .gitignore
├── Pomodoro-app.xcodeproj/        # Xcode project
├── Design/
│   ├── AppIcon.appiconset/        # complete app icon set for Assets.xcassets
│   └── icon_1024_master.png       # icon at 1024 px
└── PomodoroWidget/
    ├── Assets.xcassets/               # asset catalog with the app icon
    ├── PomodoroWidgetApp.swift        # entry point, icon and time in the menu bar
    ├── PomodoroTimer.swift            # timer logic, phases, session cycle and long break
    ├── PomodoroSettings.swift         # setting keys and values (UserDefaults)
    ├── WidgetView.swift               # widget: glass, ring, buttons, compact mode
    ├── WidgetPanelController.swift    # borderless window docked to an edge, dragging
    ├── ScreenEdge.swift               # screen edges and widget shape
    ├── SettingsView.swift             # settings and statistics popover in the menu bar
    ├── StatsStore.swift               # saving and computing statistics (JSON)
    ├── NotificationService.swift      # system notifications
    ├── MenuBarImage.swift             # fixed-width icon and time in the menu bar
    └── LaunchAtLogin.swift            # launch at login (SMAppService)
```

## Technical notes

- The widget is a borderless `NSPanel` (always on top, does not take focus) with a SwiftUI view embedded in it. This lets it dock to any edge of the visible screen area.
- The glass is an `NSVisualEffectView` with background blur, tinted with the color of the current phase.
- The countdown is based on an end date, so it is resilient to delays of the app's timer.

## License

Not specified.
