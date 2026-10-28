import AppKit
import SwiftUI

/// Bezramkowy panel, który może przyjmować kliknięcia, ale nie aktywuje aplikacji.
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

extension ScreenEdge {
    /// Klucz UserDefaults z pozycją widżetu wzdłuż danej krawędzi.
    static func positionKey(_ rawValue: String) -> String { "dockPosition.\(rawValue)" }
    var positionKey: String { Self.positionKey(rawValue) }
}

@MainActor
final class WidgetPanelController {
    private let timer: PomodoroTimer
    private let panel: FloatingPanel
    private let hostingView: NSHostingView<WidgetView>
    private var currentEdge: ScreenEdge
    private var currentScale: CGFloat
    /// Pozycja środka widżetu wzdłuż krawędzi: 0 = początek (dół/lewo), 1 = koniec (góra/prawo).
    private var currentPosition: CGFloat
    private var observers: [NSObjectProtocol] = []

    /// Odświeża cień okna podczas animacji zwijania/rozwijania.
    private var shadowTimer: Timer?

    // Stan przeciągania
    private var dragStartMouse: NSPoint?
    private var dragStartOrigin: NSPoint = .zero

    init(timer: PomodoroTimer) {
        self.timer = timer
        let edge = ScreenEdge.stored
        let scale = PomodoroSettings.scale
        self.currentEdge = edge
        self.currentScale = scale
        self.currentPosition = WidgetPanelController.storedPosition(for: edge)
        self.hostingView = NSHostingView(rootView: WidgetView(timer: timer, edge: edge, scale: scale))
        self.panel = FloatingPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.contentView = hostingView

        let center = NotificationCenter.default

        // Zmiana krawędzi, rozmiaru lub pozycji w ustawieniach (zapis do UserDefaults).
        observers.append(center.addObserver(
            forName: UserDefaults.didChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshIfSettingsChanged() }
        })

        // Zmiana rozdzielczości / układu ekranów.
        observers.append(center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reposition() }
        })
    }

    func show() {
        updateLayout()
        panel.orderFrontRegardless()
    }

    // MARK: - Ustawienia

    private static func storedPosition(for edge: ScreenEdge) -> CGFloat {
        let raw = UserDefaults.standard.object(forKey: edge.positionKey) as? Double ?? 0.5
        return CGFloat(min(max(raw, 0), 1))
    }

    private func refreshIfSettingsChanged() {
        let edge = ScreenEdge.stored
        let scale = PomodoroSettings.scale
        let position = Self.storedPosition(for: edge)
        guard edge != currentEdge || scale != currentScale || position != currentPosition else { return }
        currentEdge = edge
        currentScale = scale
        currentPosition = position
        updateLayout()
    }

    // MARK: - Układ

    /// Odtwarza widok z aktualną krawędzią i skalą, a potem ustawia okno.
    private func updateLayout() {
        hostingView.rootView = WidgetView(
            timer: timer,
            edge: currentEdge,
            scale: currentScale,
            onSizeChange: { [weak self] in
                // Wywoływane z aktualizacji widoku — ustawiamy okno chwilę później.
                Task { @MainActor [weak self] in self?.reposition() }
            },
            onDrag: { [weak self] phase in
                MainActor.assumeIsolated { self?.handleDrag(phase) }
            },
            onTransition: { [weak self] in
                MainActor.assumeIsolated { self?.refreshShadowDuringTransition() }
            }
        )
        reposition()
    }

    private var visibleArea: NSRect? {
        (panel.screen ?? NSScreen.main ?? NSScreen.screens.first)?.visibleFrame
    }

    /// Początek zakresu `lo` ... `lo + length` dla okna o rozmiarze `size`,
    /// z środkiem w miejscu `currentPosition` (ograniczonym do widocznego obszaru).
    private func along(lo: CGFloat, length: CGFloat, size: CGFloat) -> CGFloat {
        let desired = lo + currentPosition * length - size / 2
        return min(max(desired, lo), lo + max(0, length - size))
    }

    /// Dopasowuje rozmiar okna do widżetu i przykleja je do wybranej krawędzi.
    private func reposition() {
        hostingView.layoutSubtreeIfNeeded()
        let size = hostingView.fittingSize
        guard size.width > 0, size.height > 0, let area = visibleArea else { return }

        let origin: NSPoint
        switch currentEdge {
        case .left:
            origin = NSPoint(x: area.minX,
                             y: along(lo: area.minY, length: area.height, size: size.height))
        case .right:
            origin = NSPoint(x: area.maxX - size.width,
                             y: along(lo: area.minY, length: area.height, size: size.height))
        case .top:
            origin = NSPoint(x: along(lo: area.minX, length: area.width, size: size.width),
                             y: area.maxY - size.height)
        case .bottom:
            origin = NSPoint(x: along(lo: area.minX, length: area.width, size: size.width),
                             y: area.minY)
        }

        let frame = NSRect(origin: origin, size: size)
        guard frame != panel.frame else { return }
        panel.setFrame(frame, display: true)
        panel.invalidateShadow()
    }

    /// Cień okna wynika z kształtu treści, więc podczas animacji trzeba go odświeżać na bieżąco.
    private func refreshShadowDuringTransition() {
        shadowTimer?.invalidate()
        let end = Date().addingTimeInterval(0.6)
        shadowTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            MainActor.assumeIsolated {
                self?.panel.invalidateShadow()
                if Date() >= end {
                    timer.invalidate()
                    self?.shadowTimer = nil
                }
            }
        }
    }

    // MARK: - Przeciąganie

    /// Przesuwa okno tylko wzdłuż krawędzi (góra–dół przy bocznych, lewo–prawo przy górnej i dolnej).
    private func handleDrag(_ phase: WidgetDragPhase) {
        guard let area = visibleArea else { return }

        switch phase {
        case .changed:
            let mouse = NSEvent.mouseLocation
            if dragStartMouse == nil {
                dragStartMouse = mouse
                dragStartOrigin = panel.frame.origin
            }
            guard let start = dragStartMouse else { return }

            let size = panel.frame.size
            var origin = dragStartOrigin
            switch currentEdge {
            case .left, .right:
                let y = dragStartOrigin.y + (mouse.y - start.y)
                origin.y = min(max(y, area.minY), area.minY + max(0, area.height - size.height))
            case .top, .bottom:
                let x = dragStartOrigin.x + (mouse.x - start.x)
                origin.x = min(max(x, area.minX), area.minX + max(0, area.width - size.width))
            }
            panel.setFrameOrigin(origin)

        case .ended:
            guard dragStartMouse != nil else { return }
            dragStartMouse = nil
            savePosition(in: area)
        }
    }

    /// Zapisuje pozycję środka widżetu jako ułamek długości widocznej krawędzi.
    private func savePosition(in area: NSRect) {
        let frame = panel.frame
        let fraction: CGFloat
        switch currentEdge {
        case .left, .right:
            fraction = area.height > 0 ? (frame.midY - area.minY) / area.height : 0.5
        case .top, .bottom:
            fraction = area.width > 0 ? (frame.midX - area.minX) / area.width : 0.5
        }
        let clamped = min(max(fraction, 0), 1)
        currentPosition = clamped   // najpierw stan lokalny, żeby zapis nie wywołał ponownego układu
        UserDefaults.standard.set(Double(clamped), forKey: currentEdge.positionKey)
    }
}
