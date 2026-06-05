import ClipboardManagerCore
import Foundation
import Testing
@testable import ClipboardManagerApp

struct SelectionCoordinatorTests {
    @Test
    @MainActor
    func selectingItemPastesAfterDismissingPanel() throws {
        let recorder = CallRecorder()
        let coordinator = SelectionCoordinator(
            clipboardWriter: recorder,
            targetApplicationActivator: recorder,
            focusHandoffWaiter: recorder,
            pastePerformer: recorder,
            panelDismissor: recorder
        )
        let item = ClipboardItem(
            kind: .text,
            contentHash: "hash",
            createdAt: Date(),
            lastSeenAt: Date(),
            sourceAppName: "Notes",
            previewText: "hello",
            textValue: "hello",
            imageData: nil,
            thumbnailData: nil
        )

        try coordinator.select(item, shouldAutoPaste: true)

        #expect(recorder.calls == [.writeClipboard, .dismissPanel, .paste])
    }

    @Test
    @MainActor
    func selectingItemWithoutAutoPasteOnlyCopiesAndDismisses() throws {
        let recorder = CallRecorder()
        let coordinator = SelectionCoordinator(
            clipboardWriter: recorder,
            targetApplicationActivator: recorder,
            focusHandoffWaiter: recorder,
            pastePerformer: recorder,
            panelDismissor: recorder
        )
        let item = ClipboardItem(
            kind: .text,
            contentHash: "hash",
            createdAt: Date(),
            lastSeenAt: Date(),
            sourceAppName: "Notes",
            previewText: "hello",
            textValue: "hello",
            imageData: nil,
            thumbnailData: nil
        )

        try coordinator.select(item, shouldAutoPaste: false)

        #expect(recorder.calls == [.writeClipboard, .dismissPanel])
    }
}

private final class CallRecorder: ClipboardWriting, TargetApplicationActivating, FocusHandoffWaiting, PastePerforming, PanelDismissing {
    enum Call: Equatable {
        case writeClipboard
        case activateTargetApplication
        case waitForFocusHandoff
        case paste
        case dismissPanel
    }

    private(set) var calls: [Call] = []

    func write(_ item: ClipboardItem) throws {
        calls.append(.writeClipboard)
    }

    func activateTargetApplication() {
        calls.append(.activateTargetApplication)
    }

    func waitForFocusHandoff() {
        calls.append(.waitForFocusHandoff)
    }

    func pasteIntoFrontmostApplication() throws {
        calls.append(.paste)
    }

    func dismissPanel() {
        calls.append(.dismissPanel)
    }
}
