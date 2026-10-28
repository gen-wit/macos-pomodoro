import AppKit

/// Rysuje ikonę i czas jako jeden obrazek o stałych proporcjach.
/// Pasek menu ignoruje `monospacedDigit()` w tekście SwiftUI, przez co zmieniająca się
/// szerokość cyfr przesuwała całą etykietę. Tu cyfry mają stałą szerokość, a ikona
/// ma stały „slot", więc nic nie skacze.
enum MenuBarImage {
    static func make(symbol: String, text: String?) -> NSImage {
        let height: CGFloat = 18
        let iconSlot: CGFloat = 18   // stała szerokość miejsca na ikonę
        let gap: CGFloat = 3
        let fontSize: CGFloat = 13

        // Szerokość tekstu (cyfry o stałej szerokości, więc zmienia się tylko przy
        // przejściu np. z 99:59 na 100:00).
        let measureFont = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        let textWidth = text.map {
            ceil(($0 as NSString).size(withAttributes: [.font: measureFont]).width)
        } ?? 0
        let width = iconSlot + (text != nil ? gap + textWidth : 0)

        let image = NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
            // Rysujemy na czarno; jako obraz szablonowy macOS dopasuje kolor do paska menu.
            let color = NSColor.black

            let symbolConfig = NSImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
                .applying(NSImage.SymbolConfiguration(paletteColors: [color]))
            if let icon = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
                .withSymbolConfiguration(symbolConfig) {
                let iconRect = NSRect(
                    x: (iconSlot - icon.size.width) / 2,
                    y: (rect.height - icon.size.height) / 2,
                    width: icon.size.width,
                    height: icon.size.height
                )
                icon.draw(in: iconRect)
            }

            if let text {
                let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let size = (text as NSString).size(withAttributes: attributes)
                (text as NSString).draw(
                    at: NSPoint(x: iconSlot + gap, y: (rect.height - size.height) / 2),
                    withAttributes: attributes
                )
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
