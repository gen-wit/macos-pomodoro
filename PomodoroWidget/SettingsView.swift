import SwiftUI
import AppKit

/// Zawartość okienka otwieranego z ikony w pasku menu: ustawienia i statystyki.
struct SettingsView: View {
    @AppStorage(PomodoroSettings.focusKey) private var focusMinutes = PomodoroSettings.defaultFocus
    @AppStorage(PomodoroSettings.breakKey) private var breakMinutes = PomodoroSettings.defaultBreak
    @AppStorage(PomodoroSettings.longBreakKey) private var longBreakMinutes = PomodoroSettings.defaultLongBreak
    @AppStorage(ScreenEdge.defaultsKey) private var edgeRaw = ScreenEdge.left.rawValue
    @AppStorage(PomodoroSettings.sizeReductionKey) private var sizeReduction = PomodoroSettings.defaultSizeReduction
    @AppStorage(PomodoroSettings.showMenuBarTimeKey) private var showMenuBarTime = true
    @AppStorage(PomodoroSettings.compactModeKey) private var compactMode = true
    @AppStorage(PomodoroSettings.startCompactKey) private var startCompact = true
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchError: String?

    private let stats = StatsStore.shared
    @State private var confirmClear = false

    /// Wersja i numer kompilacji z Info.plist (np. „Version 1.0 (1)").
    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pomodoro")
                .font(.headline)

            Stepper(value: $focusMinutes, in: 1...180) {
                Text("Session: \(focusMinutes) min")
            }

            Stepper(value: $breakMinutes, in: 1...60) {
                Text("Break: \(breakMinutes) min")
            }

            VStack(alignment: .leading, spacing: 4) {
                Stepper(value: $longBreakMinutes, in: 0...60, step: 5) {
                    Text(longBreakMinutes == 0 ? "Long break: off" : "Long break: \(longBreakMinutes) min")
                }
                Text("After every \(PomodoroTimer.cycleLength) sessions. Set to 0 to turn it off.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Size reduction: \(Int(sizeReduction))%")
                Slider(value: $sizeReduction, in: PomodoroSettings.sizeReductionRange, step: 5)
            }

            Picker("Screen edge", selection: $edgeRaw) {
                ForEach(ScreenEdge.allCases) { edge in
                    Text(edge.title).tag(edge.rawValue)
                }
            }
            .pickerStyle(.menu)

            Toggle("Show time in menu bar", isOn: $showMenuBarTime)
            Toggle("Compact mode (auto-collapse)", isOn: $compactMode)
            Toggle("Start collapsed after launch", isOn: $startCompact)
                .disabled(!compactMode)

            VStack(alignment: .leading, spacing: 6) {
                Text("Drag the widget to move it along the edge.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Center widget on edge") {
                    UserDefaults.standard.removeObject(forKey: ScreenEdge.positionKey(edgeRaw))
                }
            }

            Toggle("Launch at login", isOn: Binding(
                get: { launchAtLogin },
                set: { newValue in
                    do {
                        try LaunchAtLogin.set(newValue)
                        launchError = nil
                    } catch {
                        launchError = "Could not change this setting. It works best when the app is in the Applications folder."
                    }
                    launchAtLogin = LaunchAtLogin.isEnabled
                }
            ))

            if let launchError {
                Text(launchError)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Text("Statistics")
                .font(.headline)

            StatRow(title: "Total sessions", value: "\(stats.totalSessions)")
            StatRow(title: "Without interruption", value: stats.uninterruptedPercentText)
            StatRow(title: "Average length", value: stats.averageLengthText)

            Button(confirmClear ? "Click again to confirm" : "Reset statistics") {
                if confirmClear {
                    stats.clear()
                    confirmClear = false
                } else {
                    confirmClear = true
                }
            }

            Divider()

            Button("Quit Pomodoro") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")

            Text(versionText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(width: 260)
        .onAppear { launchAtLogin = LaunchAtLogin.isEnabled }
        .onDisappear { confirmClear = false }
    }
}

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
