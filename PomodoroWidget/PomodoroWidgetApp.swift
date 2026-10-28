import SwiftUI
import AppKit
import UserNotifications

@main
struct PomodoroWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            SettingsView()
        } label: {
            MenuBarLabel(timer: PomodoroTimer.shared)
        }
        .menuBarExtraStyle(.window)
    }
}

/// Ikona w pasku menu z czasem, który pozostał do końca bieżącej fazy.
struct MenuBarLabel: View {
    let timer: PomodoroTimer
    @AppStorage(PomodoroSettings.showMenuBarTimeKey) private var showTime = true

    var body: some View {
        let text = (showTime && timer.state != .idle) ? timer.timeString : nil
        let symbol = timer.state == .paused ? "pause.fill" : "timer"
        Image(nsImage: MenuBarImage.make(symbol: symbol, text: text))
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private let timer = PomodoroTimer.shared
    private var panelController: WidgetPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Aplikacja bez ikony w Docku (tylko widżet + ikona w pasku menu).
        NSApp.setActivationPolicy(.accessory)

        UNUserNotificationCenter.current().delegate = self
        NotificationService.requestAuthorization()

        let controller = WidgetPanelController(timer: timer)
        controller.show()
        panelController = controller
    }

    /// Pokazuj powiadomienia także wtedy, gdy aplikacja jest na wierzchu.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
