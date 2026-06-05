import ApplicationServices
import Carbon.HIToolbox
import Foundation

enum PasteError: LocalizedError {
    case accessibilityPermissionMissing
    case eventSourceUnavailable

    var errorDescription: String? {
        switch self {
        case .accessibilityPermissionMissing:
            return "Accessibility permission is required for auto-paste."
        case .eventSourceUnavailable:
            return "Unable to create keyboard events for paste."
        }
    }
}

struct PasteCoordinator: PastePerforming {
    static var accessibilityPermissionEnabled: Bool {
        AXIsProcessTrusted()
    }

    static func requestAccessibilityPermission() -> Bool {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func pasteIntoFrontmostApplication() throws {
        guard Self.accessibilityPermissionEnabled else {
            throw PasteError.accessibilityPermissionMissing
        }

        guard let source = CGEventSource(stateID: .hidSystemState) else {
            throw PasteError.eventSourceUnavailable
        }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        keyDown?.flags = .maskCommand

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
