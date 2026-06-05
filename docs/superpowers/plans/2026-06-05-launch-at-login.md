# Launch at Login Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a user-facing Launch at Login toggle so the app can start automatically after macOS login.

**Architecture:** Keep the ServiceManagement API behind a tiny controller protocol so the UI stays testable and the app controller only coordinates state. The settings panel will read and write a published boolean plus a short status message, while a real `SMAppService.mainApp` adapter performs the system registration work.

**Tech Stack:** Swift, SwiftUI, ServiceManagement, Swift Testing

---

### Task 1: Add a launch-at-login controller

**Files:**
- Create: `Sources/ClipboardManagerApp/LaunchAtLoginController.swift`
- Test: `Tests/ClipboardManagerAppTests/LaunchAtLoginControllerTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import Testing
@testable import ClipboardManagerApp

struct LaunchAtLoginControllerTests {
    @Test
    @MainActor
    func registersWhenEnabledAndUnregistersWhenDisabled() throws {
        let service = LaunchAtLoginServiceMock(initialEnabled: false)
        let controller = LaunchAtLoginController(service: service)

        #expect(controller.isEnabled == false)

        try controller.setEnabled(true)
        #expect(service.actions == [.register])
        #expect(controller.isEnabled == true)

        try controller.setEnabled(false)
        #expect(service.actions == [.register, .unregister])
        #expect(controller.isEnabled == false)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter LaunchAtLoginControllerTests -v`
Expected: FAIL because `LaunchAtLoginController` and `LaunchAtLoginServiceMock` do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```swift
import ServiceManagement

protocol LaunchAtLoginService {
    var isEnabled: Bool { get }
    func register() throws
    func unregister() throws
}

final class LaunchAtLoginController {
    private let service: LaunchAtLoginService

    init(service: LaunchAtLoginService) {
        self.service = service
    }

    var isEnabled: Bool {
        service.isEnabled
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }
}

extension SMAppService: LaunchAtLoginService {
    var isEnabled: Bool {
        status == .enabled
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter LaunchAtLoginControllerTests -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/ClipboardManagerApp/LaunchAtLoginController.swift Tests/ClipboardManagerAppTests/LaunchAtLoginControllerTests.swift
git commit -m "feat: add launch at login controller"
```

### Task 2: Wire the settings toggle

**Files:**
- Modify: `Sources/ClipboardManagerApp/ClipboardAppController.swift`
- Modify: `Sources/ClipboardManagerApp/ClipboardPanelView.swift`

- [ ] **Step 1: Update the controller API**

```swift
@Published private(set) var launchAtLoginEnabled = false
@Published private(set) var launchAtLoginStatusMessage: String?

private let launchAtLoginController: LaunchAtLoginController

func refreshLaunchAtLoginState() {
    launchAtLoginEnabled = launchAtLoginController.isEnabled
    launchAtLoginStatusMessage = launchAtLoginEnabled ? "Enabled" : "Disabled"
}

func setLaunchAtLoginEnabled(_ enabled: Bool) {
    do {
        try launchAtLoginController.setEnabled(enabled)
        refreshLaunchAtLoginState()
        lastErrorMessage = nil
    } catch {
        lastErrorMessage = error.localizedDescription
        refreshLaunchAtLoginState()
    }
}
```

- [ ] **Step 2: Add the toggle to Settings**

```swift
Toggle("Launch at Login", isOn: Binding(
    get: { appController.launchAtLoginEnabled },
    set: { appController.setLaunchAtLoginEnabled($0) }
))

if let launchAtLoginStatusMessage = appController.launchAtLoginStatusMessage {
    Text(launchAtLoginStatusMessage)
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

- [ ] **Step 3: Initialize the state on app start**

```swift
func start() {
    loadPersistedItems()
    refreshLaunchAtLoginState()
    visibleItems = historyStore.items
    clipboardMonitor.start()
    hotKeyService.register()
}
```

### Task 3: Verify behavior end-to-end

**Files:**
- Test: `Tests/ClipboardManagerAppTests/ClipboardAppControllerLaunchAtLoginTests.swift`

- [ ] **Step 1: Write controller tests**

```swift
@Test
@MainActor
func updatesPublishedStateWhenLaunchAtLoginChanges() {
    let service = LaunchAtLoginServiceMock(initialEnabled: false)
    let controller = ClipboardAppController(
        historyStore: ClipboardHistoryStore(maximumItemCount: 5),
        persistence: InMemoryHistoryPersistence(),
        clipboard: SystemClipboard(pasteboard: NSPasteboard())
    )

    controller.start()
    controller.setLaunchAtLoginEnabled(true)

    #expect(controller.launchAtLoginEnabled == true)
    #expect(controller.lastErrorMessage == nil)
}
```

- [ ] **Step 2: Run the focused tests**

Run: `swift test --filter LaunchAtLogin -v`
Expected: PASS.

- [ ] **Step 3: Rebuild the app bundle**

Run: `bash scripts/build_app_bundle.sh`
Expected: outputs `dist/ClipboardManager.app`.

