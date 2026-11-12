import AppKit
import AVFoundation
import OSLog
import UserNotifications

/// Dźwięki dołączone do aplikacji (folder `Sounds`), niezależne od zasobów systemu macOS.
enum AppSound: String {
    case sessionComplete = "session_complete"
    case breakOver = "break_over"
}

enum SoundPlayer {
    private static let log = Logger(subsystem: "Pomodoro", category: "sound")
    private static var player: AVAudioPlayer?
    private static var fallback: NSSound?

    /// Odtwarza dźwięk dołączony do aplikacji (MP3 w folderze `Sounds`).
    @MainActor
    static func play(_ sound: AppSound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            log.error("Sound file \(sound.rawValue, privacy: .public) not found in app bundle")
            NSSound.beep()
            return
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = 1.0
            player = p
            if p.play() {
                log.info("Playing \(url.lastPathComponent, privacy: .public)")
                return
            }
            log.error("AVAudioPlayer.play() returned false")
        } catch {
            log.error("AVAudioPlayer failed: \(error.localizedDescription, privacy: .public)")
        }

        // Rezerwa: NSSound.
        if let ns = NSSound(contentsOf: url, byReference: false), ns.play() {
            fallback = ns
            return
        }
        NSSound.beep()
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
