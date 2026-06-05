import AppKit
import Foundation

final class ClipboardMonitor: NSObject {
    private let pasteboard: NSPasteboard
    private let onChange: () -> Void
    private var timer: Timer?
    private var lastChangeCount: Int

    init(
        pasteboard: NSPasteboard = .general,
        onChange: @escaping () -> Void
    ) {
        self.pasteboard = pasteboard
        self.onChange = onChange
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        guard timer == nil else {
            return
        }

        timer = Timer.scheduledTimer(
            timeInterval: 0.6,
            target: self,
            selector: #selector(pollClipboard),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .common)
    }

    @objc
    private func pollClipboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }

        lastChangeCount = pasteboard.changeCount
        onChange()
    }
}
