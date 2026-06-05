import AppKit
import ClipboardManagerCore
import Foundation

@MainActor
protocol ClipboardWriting {
    func write(_ item: ClipboardItem) throws
}

@MainActor
protocol TargetApplicationActivating {
    func activateTargetApplication()
}

@MainActor
protocol FocusHandoffWaiting {
    func waitForFocusHandoff()
}

@MainActor
protocol PastePerforming {
    func pasteIntoFrontmostApplication() throws
}

@MainActor
protocol PanelDismissing {
    func dismissPanel()
}

@MainActor
struct SelectionCoordinator {
    let clipboardWriter: ClipboardWriting
    let targetApplicationActivator: TargetApplicationActivating
    let focusHandoffWaiter: FocusHandoffWaiting
    let pastePerformer: PastePerforming
    let panelDismissor: PanelDismissing

    func select(_ item: ClipboardItem, shouldAutoPaste: Bool) throws {
        try clipboardWriter.write(item)

        // Dismiss panel first so keyboard events reach the target app.
        // Since the panel uses .nonactivatingPanel, the target app never
        // lost focus, so we can paste immediately after hiding the panel.
        panelDismissor.dismissPanel()

        if shouldAutoPaste {
            try pastePerformer.pasteIntoFrontmostApplication()
        }
    }
}

final class FrontmostApplicationActivator: TargetApplicationActivating {
    private weak var targetApplication: NSRunningApplication?

    func rememberCurrentApplication() {
        guard let current = NSWorkspace.shared.frontmostApplication, current != NSRunningApplication.current else {
            return
        }

        targetApplication = current
    }

    func activateTargetApplication() {
        targetApplication?.activate(options: .activateIgnoringOtherApps)
    }
}

@MainActor
final class FocusHandoffWaiter: FocusHandoffWaiting {
    private let duration: TimeInterval

    init(duration: TimeInterval = 0.4) {
        self.duration = duration
    }

    func waitForFocusHandoff() {
        RunLoop.current.run(until: Date().addingTimeInterval(duration))
    }
}
