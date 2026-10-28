import SwiftUI

enum ScreenEdge: String, CaseIterable, Identifiable {
    case left, right, top, bottom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .left: "Left edge"
        case .right: "Right edge"
        case .top: "Top edge"
        case .bottom: "Bottom edge"
        }
    }

    static let defaultsKey = "dockEdge"

    /// Aktualnie wybrana krawędź (zapisana w UserDefaults).
    static var stored: ScreenEdge {
        ScreenEdge(rawValue: UserDefaults.standard.string(forKey: defaultsKey) ?? "") ?? .left
    }

    /// Kształt widżetu: zaokrąglone tylko rogi zwrócone w stronę wnętrza ekranu.
    func shape(radius r: CGFloat) -> UnevenRoundedRectangle {
        switch self {
        case .left:
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0,
                                   bottomTrailingRadius: r, topTrailingRadius: r)
        case .right:
            UnevenRoundedRectangle(topLeadingRadius: r, bottomLeadingRadius: r,
                                   bottomTrailingRadius: 0, topTrailingRadius: 0)
        case .top:
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: r,
                                   bottomTrailingRadius: r, topTrailingRadius: 0)
        case .bottom:
            UnevenRoundedRectangle(topLeadingRadius: r, bottomLeadingRadius: 0,
                                   bottomTrailingRadius: 0, topTrailingRadius: r)
        }
    }
}
