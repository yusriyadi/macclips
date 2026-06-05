import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appController: ClipboardAppController?
    private let singleInstanceCoordinator = SingleInstanceCoordinator(instanceLock: FileInstanceLock())

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard singleInstanceCoordinator.beginLaunch() else {
            NSApp.terminate(nil)
            return
        }

        NSApp.setActivationPolicy(.accessory)

        let controller = ClipboardAppController()
        controller.start()
        appController = controller
    }
}
