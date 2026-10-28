import Foundation
import Observation

enum Phase {
    case focus   // sesja pracy
    case rest    // przerwa
}

enum TimerState {
    case idle      // gotowy do startu
    case running   // odliczanie trwa
    case paused    // wstrzymany
}

@MainActor
@Observable
final class PomodoroTimer {
    /// Jedna wspólna instancja: korzystają z niej widżet i ikona w pasku menu.
    static let shared = PomodoroTimer()

    // Ustawienia (czytane z UserDefaults, zmieniane z okienka w pasku menu)
    private(set) var focusMinutes = PomodoroSettings.focusMinutes
    private(set) var breakMinutes = PomodoroSettings.breakMinutes
    private(set) var longBreakMinutes = PomodoroSettings.longBreakMinutes

    // Stan
    private(set) var phase: Phase = .focus
    private(set) var state: TimerState = .idle
    private(set) var remaining: TimeInterval = 0
    /// Długość bieżącej fazy ustalona w chwili jej startu (stabilny pierścień postępu).
    private(set) var totalDuration: TimeInterval = 0
    /// Liczba sesji w jednym cyklu (tyle kropek pokazuje widżet).
    static let cycleLength = 4
    /// Ile sesji pracy w bieżącym cyklu zostało ukończonych (0...cycleLength).
    private(set) var cycleCount = 0
    /// Czy bieżąca przerwa jest długą przerwą (po ukończeniu całego cyklu sesji).
    private(set) var isLongBreak = false
    /// Czy bieżąca sesja pracy została przerwana (pauza lub reset przed końcem).
    /// Wykorzystamy to w statystykach (etap 4).
    private(set) var interrupted = false

    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var ticker: Timer?
    @ObservationIgnored private var settingsObserver: NSObjectProtocol?

    init() {
        loadPhase()
        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.syncSettings() }
        }
    }

    // MARK: - Wartości pomocnicze dla widoku

    private var duration: TimeInterval {
        switch phase {
        case .focus: return Double(focusMinutes) * 60
        case .rest: return Double(isLongBreak ? longBreakMinutes : breakMinutes) * 60
        }
    }

    var progress: Double {
        totalDuration > 0 ? min(1, max(0, 1 - remaining / totalDuration)) : 0
    }

    var timeString: String {
        let total = max(0, Int(remaining.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var statusText: String {
        switch (state, phase) {
        case (.idle, _): return "READY"
        case (.paused, _): return "PAUSED"
        case (.running, .focus): return "SESSION IN PROGRESS"
        case (.running, .rest): return isLongBreak ? "LONG BREAK" : "BREAK"
        }
    }

    var nextText: String {
        switch phase {
        case .focus:
            // Ostatnia sesja cyklu kończy się długą przerwą.
            if longBreakMinutes > 0 && cycleCount == Self.cycleLength - 1 {
                return "Next: \(longBreakMinutes) min Long break"
            }
            return "Next: \(breakMinutes) min Break"
        case .rest: return "Next: \(focusMinutes) min Focus"
        }
    }

    var primaryButtonTitle: String {
        switch state {
        case .idle: return "START"
        case .running: return "PAUSE"
        case .paused: return "RESUME"
        }
    }

    // MARK: - Akcje

    func toggle() {
        state == .running ? pause() : start()
    }

    func start() {
        guard state != .running else { return }
        if state == .idle {
            // Nowy cykl zaczyna się, gdy poprzedni został w pełni ukończony.
            if phase == .focus && cycleCount >= Self.cycleLength { cycleCount = 0 }
            loadPhase()
        }
        endDate = Date().addingTimeInterval(remaining)
        state = .running
        startTicker()
    }

    func pause() {
        guard state == .running else { return }
        stopTicker()
        remaining = max(0, endDate?.timeIntervalSinceNow ?? remaining)
        state = .paused
        if phase == .focus { interrupted = true }   // pauza = przerwanie sesji
    }

    func reset() {
        // Reset w trakcie sesji pracy = przerwana sesja (zapisujemy ją w statystykach).
        if phase == .focus && state != .idle {
            let remainingNow = state == .running
                ? max(0, endDate?.timeIntervalSinceNow ?? remaining)
                : remaining
            recordSession(seconds: totalDuration - remainingNow, completed: false, interrupted: true)
        }
        stopTicker()
        phase = .focus
        state = .idle
        interrupted = false
        isLongBreak = false
        loadPhase()
    }

    // MARK: - Wnętrze

    /// Ustawia czas bieżącej fazy według aktualnych ustawień.
    private func loadPhase() {
        totalDuration = duration
        remaining = totalDuration
    }

    /// Reaguje na zmianę ustawień. W stanie gotowości od razu odświeża licznik,
    /// w trakcie sesji nowe wartości obowiązują od następnej fazy.
    private func syncSettings() {
        let focus = PomodoroSettings.focusMinutes
        let rest = PomodoroSettings.breakMinutes
        let long = PomodoroSettings.longBreakMinutes
        guard focus != focusMinutes || rest != breakMinutes || long != longBreakMinutes else { return }
        focusMinutes = focus
        breakMinutes = rest
        longBreakMinutes = long
        if state == .idle { loadPhase() }
    }

    /// Zapisuje zakończoną sesję pracy. Przerwane sesje krótsze niż 10 s są pomijane
    /// (np. przypadkowy start i natychmiastowy reset).
    private func recordSession(seconds: TimeInterval, completed: Bool, interrupted: Bool) {
        guard completed || seconds >= 10 else { return }
        StatsStore.shared.add(SessionRecord(
            id: UUID(),
            endedAt: Date(),
            focusSeconds: max(0, seconds),
            completed: completed,
            interrupted: interrupted
        ))
    }

    private func startTicker() {
        stopTicker()
        let t = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        ticker = t
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard let endDate else { return }
        remaining = max(0, endDate.timeIntervalSinceNow)
        if remaining <= 0 { finishPhase() }
    }

    private func finishPhase() {
        stopTicker()
        switch phase {
        case .focus:
            recordSession(seconds: totalDuration, completed: true, interrupted: interrupted)
            cycleCount = min(cycleCount + 1, Self.cycleLength)
            // Po ukończeniu całego cyklu następuje długa przerwa (jeśli jest włączona).
            isLongBreak = longBreakMinutes > 0 && cycleCount >= Self.cycleLength
            NotificationService.send(
                title: "Session complete",
                body: isLongBreak
                    ? "Cycle complete! Time for a \(longBreakMinutes) min long break."
                    : "Time for a \(breakMinutes) min break."
            )
            // Po sesji pracy przerwa startuje automatycznie.
            phase = .rest
            state = .idle
            loadPhase()
            start()
        case .rest:
            NotificationService.send(
                title: "Break is over",
                body: "Ready for the next \(focusMinutes) min session?"
            )
            // Po przerwie wracamy do gotowości na kolejną sesję.
            if cycleCount >= Self.cycleLength { cycleCount = 0 }
            isLongBreak = false
            phase = .focus
            state = .idle
            interrupted = false
            loadPhase()
        }
    }
}
