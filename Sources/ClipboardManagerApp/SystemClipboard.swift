import AppKit
import ClipboardManagerCore
import Foundation

enum ClipboardError: LocalizedError {
    case unsupportedItem
    case failedToWrite

    var errorDescription: String? {
        switch self {
        case .unsupportedItem:
            return "Clipboard item is not supported."
        case .failedToWrite:
            return "Failed to write clipboard item."
        }
    }
}

final class SystemClipboard: ClipboardWriting {
    private let pasteboard: NSPasteboard

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func currentPayload() -> ClipboardPayload? {
        if let text = pasteboard.string(forType: .string), text.isEmpty == false {
            return .text(text)
        }

        guard
            let image = NSImage(pasteboard: pasteboard),
            let tiffData = image.tiffRepresentation
        else {
            return nil
        }

        return .image(tiffData)
    }

    func write(_ item: ClipboardItem) throws {
        pasteboard.clearContents()

        switch item.kind {
        case .text:
            guard let textValue = item.textValue else {
                throw ClipboardError.unsupportedItem
            }

            guard pasteboard.setString(textValue, forType: .string) else {
                throw ClipboardError.failedToWrite
            }

        case .image:
            guard
                let data = item.imageData,
                let image = NSImage(data: data)
            else {
                throw ClipboardError.unsupportedItem
            }

            guard pasteboard.writeObjects([image]) else {
                throw ClipboardError.failedToWrite
            }
        }
    }
}
