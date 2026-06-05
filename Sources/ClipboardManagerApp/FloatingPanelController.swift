import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController {
    var isVisible: Bool {
        panel.isVisible
    }

    private let panel: NSPanel
    private let keyboardCommandMapper = PanelKeyboardCommandMapper()
    private weak var appController: ClipboardAppController?
    private var keyboardMonitor: Any?

    init(appController: ClipboardAppController) {
        self.appController = appController
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.center()
        panel.contentView = NSHostingView(rootView: ClipboardPanelView(appController: appController))
    }

    func show() {
        // Don't activate our app — .nonactivatingPanel lets the panel
        // become key without stealing focus from the target application.
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        installKeyboardMonitor()
    }

    func hide() {
        uninstallKeyboardMonitor()
        panel.orderOut(nil)
    }

    private func installKeyboardMonitor() {
        guard keyboardMonitor == nil else {
            return
        }

        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else {
                return event
            }

            guard let command = self.keyboardCommandMapper.command(for: event.keyCode) else {
                return event
            }

            guard self.appController?.handleKeyboardCommand(command) == true else {
                return event
            }

            return nil
        }
    }

    private func uninstallKeyboardMonitor() {
        if let keyboardMonitor {
            NSEvent.removeMonitor(keyboardMonitor)
            self.keyboardMonitor = nil
        }
    }
}
