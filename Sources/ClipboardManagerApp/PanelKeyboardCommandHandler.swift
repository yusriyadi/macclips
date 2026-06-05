import Foundation

@MainActor
final class PanelKeyboardCommandHandler {
    private let moveUp: @MainActor () -> Void
    private let moveDown: @MainActor () -> Void
    private let confirmSelection: @MainActor () -> Void
    private let dismissPanel: @MainActor () -> Void

    init(
        moveUp: @escaping @MainActor () -> Void,
        moveDown: @escaping @MainActor () -> Void,
        confirmSelection: @escaping @MainActor () -> Void,
        dismissPanel: @escaping @MainActor () -> Void
    ) {
        self.moveUp = moveUp
        self.moveDown = moveDown
        self.confirmSelection = confirmSelection
        self.dismissPanel = dismissPanel
    }

    func handle(_ command: PanelKeyboardCommand) -> Bool {
        switch command {
        case .moveUp:
            moveUp()
            return true
        case .moveDown:
            moveDown()
            return true
        case .confirmSelection:
            confirmSelection()
            return true
        case .dismissPanel:
            dismissPanel()
            return true
        }
    }
}
