import Foundation
import CoreGraphics

/// Klucze i wartości domyślne ustawień zapisywanych w UserDefaults.
enum PomodoroSettings {
    static let focusKey = "focusMinutes"
    static let breakKey = "breakMinutes"
    static let defaultFocus = 25
    static let defaultBreak = 5

    // Długa przerwa po pełnym cyklu sesji (0 = wyłączona).
    static let longBreakKey = "longBreakMinutes"
    static let defaultLongBreak = 15

    static var focusMinutes: Int { read(focusKey, default: defaultFocus, range: 1...180) }
    static var breakMinutes: Int { read(breakKey, default: defaultBreak, range: 1...60) }
    static var longBreakMinutes: Int { read(longBreakKey, default: defaultLongBreak, range: 0...60) }

    static let showMenuBarTimeKey = "showMenuBarTime"
    static let compactModeKey = "compactMode"

    // Zmniejszenie rozmiaru widżetu w % (25 = widżet ma 75% oryginalnego rozmiaru).
    static let sizeReductionKey = "sizeReduction"
    static let defaultSizeReduction = 25.0
    static let sizeReductionRange: ClosedRange<Double> = 25...50

    /// Współczynnik skali widżetu (0.5 ... 0.75).
    static var scale: CGFloat {
        let stored = UserDefaults.standard.object(forKey: sizeReductionKey) as? Double ?? defaultSizeReduction
        let clamped = min(max(stored, sizeReductionRange.lowerBound), sizeReductionRange.upperBound)
        return CGFloat(1 - clamped / 100)
    }

    private static func read(_ key: String, default value: Int, range: ClosedRange<Int>) -> Int {
        let stored = UserDefaults.standard.object(forKey: key) as? Int ?? value
        return min(max(stored, range.lowerBound), range.upperBound)
    }
}
