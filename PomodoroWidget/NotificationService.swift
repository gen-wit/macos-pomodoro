import AVFoundation
import UserNotifications

/// Dźwięki dołączone do aplikacji (folder `Sounds`), niezależne od zasobów systemu macOS.
enum AppSound: String {
    case sessionComplete = "session_complete"
    case breakOver = "break_over"
}

enum SoundPlayer {
    private static var player: AVAudioPlayer?

    @MainActor
    static func play(_ sound: AppSound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

enum NotificationService {
    /// Prosi system o zgodę na powiadomienia (pytanie pojawia się tylko za pierwszym razem).
    static func requestAuthorization() {
        Task {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert])
        }
    }

    /// Wysyła powiadomienie i odtwarza własny dźwięk aplikacji (zamiast dźwięku systemowego).
    static func send(title: String, body: String, sound: AppSound) {
        Task { @MainActor in SoundPlayer.play(sound) }
        Task {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil   // natychmiast
            )
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}
