import Foundation

enum PanelKeyboardCommand: Equatable {
    case moveUp
    case moveDown
    case confirmSelection
    case dismissPanel
}

struct PanelKeyboardCommandMapper {
    func command(for keyCode: UInt16) -> PanelKeyboardCommand? {
        switch keyCode {
        case 126:
            return .moveUp
        case 125:
            return .moveDown
        case 36:
            return .confirmSelection
        case 53:
            return .dismissPanel
        default:
            return nil
        }
    }
}
