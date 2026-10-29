import SwiftUI
import AppKit

/// Rozmycie tego, co jest za oknem (prawdziwy efekt szkła macOS).
struct GlassBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow          // alternatywy: .popover, .underWindowBackground, .sidebar
        view.blendingMode = .behindWindow   // rozmywa pulpit i okna za widżetem
        view.state = .active                // nie szarzeje, gdy aplikacja jest nieaktywna
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

/// Wykrywa wejście i wyjście kursora, także gdy aplikacja jest nieaktywna.
/// (`onHover` w SwiftUI bywa zawodny w panelu, który nie przejmuje fokusu.)
struct HoverTracker: NSViewRepresentable {
    let onChange: (Bool) -> Void

    func makeNSView(context: Context) -> TrackingView {
        let view = TrackingView()
        view.onChange = onChange
        return view
    }

    func updateNSView(_ view: TrackingView, context: Context) {
        view.onChange = onChange
    }

    final class TrackingView: NSView {
        var onChange: (Bool) -> Void = { _ in }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            for area in trackingAreas { removeTrackingArea(area) }
            addTrackingArea(NSTrackingArea(
                rect: .zero,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self,
                userInfo: nil
            ))
        }

        override func mouseEntered(with event: NSEvent) { onChange(true) }
        override func mouseExited(with event: NSEvent) { onChange(false) }

        /// Nie przechwytuje kliknięć — przyciski pod spodem działają normalnie.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }
}

/// Etapy przeciągania widżetu myszą (obsługuje je kontroler panelu).
enum WidgetDragPhase {
    case changed
    case ended
}

/// Przekazuje naturalny (nieskalowany) rozmiar rozwiniętego widżetu.
private struct FullSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

struct WidgetView: View {
    let timer: PomodoroTimer
    let edge: ScreenEdge
    /// Skala widżetu (np. 0.75 = o 25% mniejszy).
    var scale: CGFloat = 1
    /// Wywoływane, gdy zmieni się rozmiar okna widżetu (panel dopasowuje wtedy okno).
    var onSizeChange: () -> Void = {}
    /// Przeciąganie widżetu wzdłuż krawędzi ekranu.
    var onDrag: (WidgetDragPhase) -> Void = { _ in }
    /// Wywoływane na początku animacji zwijania/rozwijania (odświeżanie cienia okna).
    var onTransition: () -> Void = {}

    @AppStorage(PomodoroSettings.compactModeKey) private var compactMode = true
    @AppStorage(PomodoroSettings.startCompactKey) private var startCompact = true
    /// Po uruchomieniu aplikacji widżet startuje zwinięty (także w stanie gotowości),
    /// dopóki użytkownik nie najedzie na niego kursorem.
    @State private var startupCompact = UserDefaults.standard.object(forKey: PomodoroSettings.startCompactKey) as? Bool ?? true

    /// Zmierzony rozmiar rozwiniętego widżetu.
    @State private var fullSize = CGSize(width: 280, height: 332)
    @State private var isHovering = false
    /// Czy widżet jest (lub właśnie się staje) zwinięty — steruje animacją.
    @State private var isCompact = false
    /// Czy samo okno jest już zmniejszone. Przy zwijaniu okno zmniejsza się dopiero po animacji,
    /// a przy rozwijaniu powiększa się od razu, żeby animacja miała miejsce.
    @State private var windowCompact = false
    @State private var compactTask: Task<Void, Never>?
    @State private var shrinkTask: Task<Void, Never>?

    // MARK: - Parametry wyglądu (tu dostroisz efekt)

    // Tryb kompaktowy
    private let collapseDelay: Double = 3          // sekundy bez kursora przed zwinięciem
    private let compactDiameter: CGFloat = 124     // średnica pierścienia po zwinięciu
    private let transitionDuration: Double = 0.28  // czas animacji zwijania/rozwijania

    // Poświata paska postępu
    private let glowRadius: CGFloat = 9
    private let glowOpacity: Double = 0.8

    // Szkło i kolory faz
    private let tintOpacity: Double = 0.78         // 0 = czyste szkło, 1 = pełny kolor
    private let cornerRadius: CGFloat = 36
    private let compactCornerRadius: CGFloat = 28
    private let focusColors = [Color(red: 0.97, green: 0.30, blue: 0.26),
                               Color(red: 0.72, green: 0.10, blue: 0.16)]
    private let breakColors = [Color(red: 0.14, green: 0.78, blue: 0.66),
                               Color(red: 0.04, green: 0.42, blue: 0.50)]

    // Pierścień (wartości dla średnicy 200, przy zwinięciu skalowane proporcjonalnie)
    private let trackWidth: CGFloat = 5
    private let progressWidth: CGFloat = 8

    private var isBreak: Bool { timer.phase == .rest }
    private var currentRadius: CGFloat { isCompact ? compactCornerRadius : cornerRadius }

    private var compactSize: CGSize {
        CGSize(width: compactDiameter + 32, height: compactDiameter + 32)
    }
    /// Rozmiar widocznego widżetu (animowany).
    private var shownSize: CGSize { isCompact ? compactSize : fullSize }
    /// Rozmiar okna (zmienia się bez animacji, patrz `windowCompact`).
    private var windowSize: CGSize { windowCompact ? compactSize : fullSize }

    /// Widżet jest przyklejony do krawędzi, a wzdłuż niej wycentrowany.
    private var edgeAlignment: Alignment {
        switch edge {
        case .left: .leading
        case .right: .trailing
        case .top: .top
        case .bottom: .bottom
        }
    }

    /// Kolor akcentu bieżącej fazy (tekst na jasnym przycisku głównym).
    private var accent: Color {
        isBreak ? Color(red: 0.03, green: 0.38, blue: 0.44)
                : Color(red: 0.74, green: 0.12, blue: 0.16)
    }

    var body: some View {
        stage
            .frame(width: windowSize.width, height: windowSize.height, alignment: edgeAlignment)
            .onPreferenceChange(FullSizeKey.self) { size in
                guard size != .zero else { return }
                fullSize = size
            }
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: windowSize.width * scale,
                   height: windowSize.height * scale,
                   alignment: .topLeading)
            .background(HoverTracker { isHovering = $0 })
            // Przeciąganie za tło, pierścień i napisy (przyciski mają pierwszeństwo).
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { _ in onDrag(.changed) }
                    .onEnded { _ in onDrag(.ended) }
            )
            .onAppear { updateCompact() }
            .onChange(of: isHovering) { updateCompact() }
            .onChange(of: timer.state) { updateCompact() }
            .onChange(of: compactMode) { updateCompact() }
            .onChange(of: windowSize) { onSizeChange() }
    }

    // MARK: - Tryb kompaktowy

    /// Zwija widżet po `collapseDelay` sekundach bez kursora, ale tylko gdy odliczanie trwa.
    /// W stanie gotowości lub pauzy widżet zostaje rozwinięty, żeby przyciski były pod ręką.
    private func updateCompact() {
        compactTask?.cancel()
        compactTask = nil

        if isHovering { startupCompact = false }

        // Zwinięty start: od razu, bez opóźnienia, tylko gdy odliczanie jeszcze nie ruszyło.
        if startCompact && startupCompact && compactMode && timer.state != .running && !isHovering {
            setCompact(true)
            return
        }

        let canCollapse = compactMode && timer.state == .running && !isHovering
        guard canCollapse else {
            setCompact(false)
            return
        }

        compactTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(collapseDelay))
            guard !Task.isCancelled else { return }
            setCompact(true)
        }
    }

    private func setCompact(_ compact: Bool) {
        guard compact != isCompact else { return }
        shrinkTask?.cancel()
        shrinkTask = nil
        onTransition()

        if compact {
            // Treść zwija się z animacją; okno zmniejsza się dopiero po jej zakończeniu.
            isCompact = true
            shrinkTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(transitionDuration + 0.05))
                guard !Task.isCancelled else { return }
                windowCompact = true
            }
        } else {
            // Okno powiększa się od razu, a treść rozwija się z animacją.
            windowCompact = false
            isCompact = false
        }
    }

    // MARK: - Układ

    /// Widoczny widżet: szkło o animowanym rozmiarze, a w nim płynna zamiana układów.
    private var stage: some View {
        ZStack {
            fullContent
                .opacity(isCompact ? 0 : 1)
                .allowsHitTesting(!isCompact)
            compactContent
                .opacity(isCompact ? 1 : 0)
                .allowsHitTesting(isCompact)
        }
        .frame(width: shownSize.width, height: shownSize.height)
        .background { glass }
        .clipShape(edge.shape(radius: currentRadius))
        .overlay { rim }
        .foregroundStyle(.white)
        .animation(.easeInOut(duration: transitionDuration), value: isCompact)
    }

    private var fullContent: some View {
        VStack(spacing: 18) {
            ring(diameter: 200, compact: false)

            HStack(spacing: 10) {
                Button("RESET") { timer.reset() }
                    .buttonStyle(SecondaryPillStyle())
                    .focusable(false)
                Button(timer.primaryButtonTitle) { timer.toggle() }
                    .buttonStyle(PrimaryPillStyle(textColor: accent))
                    .focusable(false)
            }
            .focusEffectDisabled()   // bez niebieskiej obwódki fokusu klawiatury
            .animation(.easeInOut(duration: 0.6), value: isBreak)

            Text(timer.nextText)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(width: 280)
        .fixedSize()
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: FullSizeKey.self, value: proxy.size)
            }
        )
    }

    /// Wersja zwinięta: tylko pierścień z czasem i kropkami sesji.
    private var compactContent: some View {
        ring(diameter: compactDiameter, compact: true)
            .padding(16)
            .fixedSize()
    }

    // MARK: - Szkło

    /// Rozmycie + nasycony odcień fazy (płynne przejście czerwień ↔ turkus) + połysk.
    private var glass: some View {
        ZStack {
            GlassBlur()

            tintLayer(focusColors)
                .opacity(isBreak ? 0 : 1)
            tintLayer(breakColors)
                .opacity(isBreak ? 1 : 0)

            LinearGradient(
                colors: [.white.opacity(0.22), .clear],
                startPoint: .top,
                endPoint: .center
            )
        }
        .animation(.easeInOut(duration: 0.6), value: isBreak)
    }

    private func tintLayer(_ colors: [Color]) -> some View {
        LinearGradient(
            colors: colors.map { $0.opacity(tintOpacity) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Jasna krawędź szkła (mocniejsza od góry i z lewej).
    private var rim: some View {
        edge.shape(radius: currentRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.55), .white.opacity(0.08), .white.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    // MARK: - Pierścień

    private func ring(diameter: CGFloat, compact: Bool) -> some View {
        let f = diameter / 200   // współczynnik skali względem pełnego rozmiaru
        return ZStack {
            // Tor (cieńszy od paska)
            Circle()
                .stroke(.white.opacity(0.16), lineWidth: trackWidth * f)

            // Poświata: rozmyta kopia paska pod spodem...
            progressArc(lineWidth: progressWidth * f)
                .blur(radius: glowRadius * f)
                .opacity(glowOpacity)

            // ...oraz wyraźny pasek z gradientem i wąskim, jasnym cieniem.
            progressArc(lineWidth: progressWidth * f)
                .shadow(color: .white.opacity(0.85), radius: 3 * f)

            VStack(spacing: 6 * f) {
                Text(timer.timeString)
                    .font(.system(size: 54 * f, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: diameter * 0.78)
                    .shadow(color: .black.opacity(0.18), radius: 4, y: 1)

                if !compact {
                    Text(timer.statusText)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(2)
                        .opacity(0.65)
                }

                sessionDots(compact: compact)
            }
        }
        .frame(width: diameter, height: diameter)
    }

    /// Wypełniony fragment pierścienia z gradientem: przygaszony „ogon" → jasna „głowa".
    private func progressArc(lineWidth: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: timer.progress)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.white.opacity(0.35), .white]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(max(1, 360 * timer.progress))
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .opacity(timer.progress > 0 ? 1 : 0)
            .animation(.linear(duration: 0.25), value: timer.progress)
    }

    // MARK: - Kropki sesji

    /// Kropki pokazują postęp w cyklu: pełna = ukończona sesja,
    /// obrys = sesja w toku, przygaszona = jeszcze przed Tobą.
    private func sessionDots(compact: Bool) -> some View {
        HStack(spacing: compact ? 5 : 7) {
            ForEach(0..<PomodoroTimer.cycleLength, id: \.self) { index in
                dot(index, size: compact ? 6 : 8)
            }
        }
    }

    private func dot(_ index: Int, size: CGFloat) -> some View {
        let done = index < timer.cycleCount
        let current = index == timer.cycleCount && timer.phase == .focus && timer.state != .idle
        return Circle()
            .fill(done ? Color.white : Color.white.opacity(current ? 0 : 0.25))
            .overlay(Circle().strokeBorder(.white.opacity(current ? 0.95 : 0), lineWidth: 1.5))
            .frame(width: size, height: size)
            .shadow(color: .white.opacity(done ? 0.6 : 0), radius: 3)
    }
}

// MARK: - Przyciski

/// Przycisk główny: jasna, pełna kapsuła z tekstem w kolorze fazy.
struct PrimaryPillStyle: ButtonStyle {
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(textColor)
            .frame(width: 88, height: 34)
            .background(
                Capsule().fill(.white.opacity(configuration.isPressed ? 0.78 : 0.95))
            )
            .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
    }
}

/// Przycisk drugoplanowy: subtelne tło i cienki jasny kontur.
struct SecondaryPillStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .tracking(0.5)
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 88, height: 34)
            .background(
                Capsule().fill(.white.opacity(configuration.isPressed ? 0.22 : 0.12))
            )
            .overlay(Capsule().strokeBorder(.white.opacity(0.28), lineWidth: 0.75))
    }
}
