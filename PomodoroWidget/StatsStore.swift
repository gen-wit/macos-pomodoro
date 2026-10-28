import Foundation
import Observation

/// Jedna zapisana sesja pracy.
struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let endedAt: Date
    /// Faktycznie przepracowany czas w sekundach.
    let focusSeconds: Double
    /// Czy odliczanie doszło do końca.
    let completed: Bool
    /// Czy sesja była przerwana (pauza lub reset przed końcem).
    let interrupted: Bool
}

/// Przechowuje historię sesji (plik JSON w Application Support) i liczy statystyki.
@MainActor
@Observable
final class StatsStore {
    static let shared = StatsStore()

    private(set) var records: [SessionRecord] = []
    private let fileURL: URL

    private init() {
        fileURL = Self.makeFileURL()
        load()
    }

    // MARK: - Statystyki

    var totalSessions: Int { records.count }

    var uninterruptedSessions: Int {
        records.filter { $0.completed && !$0.interrupted }.count
    }

    /// % sesji ukończonych bez przerwania.
    var uninterruptedPercentText: String {
        guard totalSessions > 0 else { return "–" }
        let percent = Double(uninterruptedSessions) / Double(totalSessions) * 100
        return "\(Int(percent.rounded()))%"
    }

    /// Średni przepracowany czas sesji.
    var averageLengthText: String {
        guard totalSessions > 0 else { return "–" }
        let average = records.reduce(0) { $0 + $1.focusSeconds } / Double(totalSessions)
        let total = Int(average.rounded())
        let minutes = total / 60
        let seconds = total % 60
        return minutes == 0 ? "\(seconds) s" : "\(minutes) min \(seconds) s"
    }

    // MARK: - Zapis

    func add(_ record: SessionRecord) {
        records.append(record)
        save()
    }

    func clear() {
        records = []
        save()
    }

    private static func makeFileURL() -> URL {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = base.appendingPathComponent("PomodoroWidget", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("sessions.json")
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        records = (try? decoder.decode([SessionRecord].self, from: data)) ?? []
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
