import ClipboardManagerCore
import Foundation
import Testing
@testable import ClipboardManagerApp

struct PanelSelectionStateTests {
    @Test
    @MainActor
    func resetsSelectionToFirstItemWhenItemsAppear() {
        let state = PanelSelectionState()
        let items = sampleItems(count: 3)

        state.replaceItems(items)

        #expect(state.selectedItemID == items[0].id)
    }

    @Test
    @MainActor
    func resetSelectionClearsSelectedItem() {
        let state = PanelSelectionState()
        let items = sampleItems(count: 3)
        state.replaceItems(items)
        state.moveSelectionDown()
        #expect(state.selectedItemID == items[1].id)

        state.resetSelection()

        #expect(state.selectedItemID == nil)
    }

    @Test
    @MainActor
    func replaceItemsAfterResetSelectsFirstItem() {
        let state = PanelSelectionState()
        state.replaceItems(sampleItems(count: 3))
        state.moveSelectionDown()
        state.resetSelection()

        let newItems = sampleItems(count: 2)
        state.replaceItems(newItems)

        #expect(state.selectedItemID == newItems[0].id)
    }

    @Test
    @MainActor
    func movesSelectionDownAndUpWithinBounds() {
        let state = PanelSelectionState()
        let items = sampleItems(count: 3)
        state.replaceItems(items)

        state.moveSelectionDown()
        #expect(state.selectedItemID == items[1].id)

        state.moveSelectionDown()
        #expect(state.selectedItemID == items[2].id)

        state.moveSelectionDown()
        #expect(state.selectedItemID == items[2].id)

        state.moveSelectionUp()
        #expect(state.selectedItemID == items[1].id)

        state.moveSelectionUp()
        state.moveSelectionUp()
        #expect(state.selectedItemID == items[0].id)
    }

    @Test
    @MainActor
    func returnsCurrentlySelectedItemForEnterAction() {
        let state = PanelSelectionState()
        let items = sampleItems(count: 2)
        state.replaceItems(items)
        state.moveSelectionDown()

        #expect(state.selectedItem() == items[1])
    }
}

private func sampleItems(count: Int) -> [ClipboardItem] {
    (0..<count).map { index in
        ClipboardItem(
            kind: .text,
            contentHash: "hash-\(index)",
            createdAt: Date(timeIntervalSince1970: TimeInterval(index)),
            lastSeenAt: Date(timeIntervalSince1970: TimeInterval(index)),
            sourceAppName: "Notes",
            previewText: "Item \(index)",
            textValue: "Item \(index)",
            imageData: nil,
            thumbnailData: nil
        )
    }
}
