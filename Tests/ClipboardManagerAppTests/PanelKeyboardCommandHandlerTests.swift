import Testing
@testable import ClipboardManagerApp

struct PanelKeyboardCommandHandlerTests {
    @Test
    @MainActor
    func routesArrowEnterAndEscapeCommandsToHandlers() {
        let recorder = KeyboardActionRecorder()
        let handler = PanelKeyboardCommandHandler(
            moveUp: { recorder.calls.append(.moveUp) },
            moveDown: { recorder.calls.append(.moveDown) },
            confirmSelection: { recorder.calls.append(.confirmSelection) },
            dismissPanel: { recorder.calls.append(.dismissPanel) }
        )

        #expect(handler.handle(.moveUp) == true)
        #expect(handler.handle(.moveDown) == true)
        #expect(handler.handle(.confirmSelection) == true)
        #expect(handler.handle(.dismissPanel) == true)
        #expect(handler.handle(.moveUp) == true)
        #expect(recorder.calls == [.moveUp, .moveDown, .confirmSelection, .dismissPanel, .moveUp])
    }
}

@MainActor
private final class KeyboardActionRecorder {
    enum Call: Equatable {
        case moveUp
        case moveDown
        case confirmSelection
        case dismissPanel
    }

    var calls: [Call] = []
}
