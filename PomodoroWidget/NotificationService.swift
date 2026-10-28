import UserNotifications

enum NotificationService {
    /// Prosi system o zgodę na powiadomienia (pytanie pojawia się tylko za pierwszym razem).
    static func requestAuthorization() {
        Task {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        }
    }

    static func send(title: String, body: String) {
        Task {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil   // natychmiast
            )
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}
