import AppKit
import ClipboardManagerCore
import Foundation
import SwiftUI

@MainActor
final class ClipboardAppController: ObservableObject, PanelDismissing {
    @Published var query = ""
    @Published private(set) var visibleItems: [ClipboardItem] = []
    @Published private(set) var accessibilityEnabled = PasteCoordinator.accessibilityPermissionEnabled
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var selectedItemID: ClipboardItem.ID?

    private let historyStore: ClipboardHistoryStore
    private let persistence: HistoryPersisting
    private let clipboard: SystemClipboard
    private let suppressionWindow = SuppressionWindow()
    private let pasteCoordinator = PasteCoordinator()
    private let appActivator = FrontmostApplicationActivator()
    private let focusHandoffWaiter = FocusHandoffWaiter()
    private let panelSelectionState = PanelSelectionState()
    private var isPerformingSelection = false
    private lazy var panelKeyboardCommandHandler = PanelKeyboardCommandHandler(
        moveUp: { [weak self] in self?.moveSelectionUp() },
        moveDown: { [weak self] in self?.moveSelectionDown() },
        confirmSelection: { [weak self] in self?.confirmSelection() },
        dismissPanel: { [weak self] in self?.dismissPanel() }
    )
    private lazy var panelController = FloatingPanelController(appController: self)
    private lazy var clipboardMonitor = ClipboardMonitor { [weak self] in
        Task { @MainActor [weak self] in
            self?.captureClipboardIfNeeded()
        }
    }
    private lazy var hotKeyService = HotKeyService { [weak self] in
        Task { @MainActor [weak self] in
            self?.togglePanel()
        }
    }

    init(
        historyStore: ClipboardHistoryStore = ClipboardHistoryStore(maximumItemCount: 500),
        persistence: HistoryPersisting = JSONHistoryPersistence(
            fileURL: FileManager.default.clipboardHistoryURL
        ),
        clipboard: SystemClipboard = SystemClipboard()
    ) {
        self.historyStore = historyStore
        self.persistence = persistence
        self.clipboard = clipboard
    }

    func start() {
        loadPersistedItems()
        visibleItems = historyStore.items
        clipboardMonitor.start()
        hotKeyService.register()
    }

    func togglePanel() {
        if panelController.isVisible {
            dismissPanel()
            return
        }

        panelSelectionState.resetSelection()
        refreshVisibleItems()
        accessibilityEnabled = PasteCoordinator.accessibilityPermissionEnabled
        appActivator.rememberCurrentApplication()
        panelController.show()
    }

    func refreshVisibleItems() {
        visibleItems = historyStore.search(query: query)
        panelSelectionState.replaceItems(visibleItems)
        selectedItemID = panelSelectionState.selectedItemID
    }

    func select(_ item: ClipboardItem) {
        guard !isPerformingSelection else { return }
        isPerformingSelection = true

        do {
            suppressionWindow.begin(duration: 1.0)
            try performSelection(item, shouldAutoPaste: accessibilityEnabled)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }

        isPerformingSelection = false
    }

    func requestAccessibilityPermission() {
        accessibilityEnabled = PasteCoordinator.requestAccessibilityPermission()
    }

    func clearError() {
        lastErrorMessage = nil
    }

    func moveSelectionDown() {
        panelSelectionState.moveSelectionDown()
        selectedItemID = panelSelectionState.selectedItemID
    }

    func moveSelectionUp() {
        panelSelectionState.moveSelectionUp()
        selectedItemID = panelSelectionState.selectedItemID
    }

    func confirmSelection() {
        guard !isPerformingSelection else { return }
        guard let item = panelSelectionState.selectedItem() else {
            return
        }

        isPerformingSelection = true

        do {
            suppressionWindow.begin(duration: 1.0)
            try performSelection(item, shouldAutoPaste: accessibilityEnabled)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }

        isPerformingSelection = false
    }

    func setSelectedItem(id: ClipboardItem.ID) {
        panelSelectionState.selectItem(id: id)
        selectedItemID = panelSelectionState.selectedItemID
    }

    func dismissPanel() {
        panelController.hide()
        clearError()
    }

    func handleKeyboardCommand(_ command: PanelKeyboardCommand) -> Bool {
        panelKeyboardCommandHandler.handle(command)
    }

    var keyboardCommandHandler: PanelKeyboardCommandHandler {
        panelKeyboardCommandHandler
    }

    private func captureClipboardIfNeeded() {
        guard suppressionWindow.isSuppressed == false else {
            return
        }

        guard let payload = clipboard.currentPayload() else {
            return
        }

        _ = historyStore.record(payload, sourceAppName: NSWorkspace.shared.frontmostApplication?.localizedName)
        persistItems()
        refreshVisibleItems()
    }

    private func loadPersistedItems() {
        do {
            let items = try persistence.loadItems()
            historyStore.replaceAll(with: items)
        } catch {
            lastErrorMessage = "Failed to load clipboard history."
        }
    }

    private func persistItems() {
        do {
            try persistence.saveItems(historyStore.items)
        } catch {
            lastErrorMessage = "Failed to save clipboard history."
        }
    }

    private func performSelection(_ item: ClipboardItem, shouldAutoPaste: Bool) throws {
        let coordinator = SelectionCoordinator(
            clipboardWriter: clipboard,
            targetApplicationActivator: appActivator,
            focusHandoffWaiter: focusHandoffWaiter,
            pastePerformer: pasteCoordinator,
            panelDismissor: self
        )
        try coordinator.select(item, shouldAutoPaste: shouldAutoPaste)
    }
}

private extension FileManager {
    var clipboardHistoryURL: URL {
        let appSupportURL = urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupportURL
            .appendingPathComponent("ClipboardManager", isDirectory: true)
            .appendingPathComponent("history.json")
    }
}
