import ClipboardManagerCore
import Foundation

@MainActor
final class PanelSelectionState {
    private(set) var items: [ClipboardItem] = []
    private(set) var selectedItemID: ClipboardItem.ID?

    func replaceItems(_ items: [ClipboardItem]) {
        self.items = items

        guard items.isEmpty == false else {
            selectedItemID = nil
            return
        }

        if let selectedItemID, items.contains(where: { $0.id == selectedItemID }) {
            return
        }

        self.selectedItemID = items[0].id
    }

    func resetSelection() {
        selectedItemID = nil
    }

    func moveSelectionDown() {
        moveSelection(offset: 1)
    }

    func moveSelectionUp() {
        moveSelection(offset: -1)
    }

    func selectedItem() -> ClipboardItem? {
        guard let selectedItemID else {
            return nil
        }

        return items.first(where: { $0.id == selectedItemID })
    }

    func selectItem(id: ClipboardItem.ID) {
        guard items.contains(where: { $0.id == id }) else {
            return
        }

        selectedItemID = id
    }

    private func moveSelection(offset: Int) {
        guard items.isEmpty == false else {
            selectedItemID = nil
            return
        }

        let currentIndex = items.firstIndex(where: { $0.id == selectedItemID }) ?? 0
        let nextIndex = min(max(currentIndex + offset, 0), items.count - 1)
        selectedItemID = items[nextIndex].id
    }
}
