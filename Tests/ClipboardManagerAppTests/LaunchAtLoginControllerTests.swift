import Testing
@testable import ClipboardManagerApp

struct LaunchAtLoginControllerTests {
    @Test
    @MainActor
    func startsDisabledAndRegistersOrUnregistersOnDemand() throws {
        let service = LaunchAtLoginServiceMock(initialStatus: .notRegistered)
        let controller = LaunchAtLoginController(service: service)

        #expect(controller.isEnabled == false)
        #expect(controller.needsApproval == false)
        #expect(controller.statusMessage == "Launch at login is off.")

        try controller.setEnabled(true)
        #expect(service.actions == [.register])
        #expect(controller.isEnabled == true)
        #expect(controller.statusMessage == "Launch at login is enabled.")

        try controller.setEnabled(false)
        #expect(service.actions == [.register, .unregister])
        #expect(controller.isEnabled == false)
        #expect(controller.statusMessage == "Launch at login is off.")
    }

    @Test
    @MainActor
    func reportsApprovalNeededWhenServiceRequiresIt() {
        let service = LaunchAtLoginServiceMock(initialStatus: .requiresApproval)
        let controller = LaunchAtLoginController(service: service)

        #expect(controller.isEnabled == true)
        #expect(controller.needsApproval == true)
        #expect(controller.statusMessage == "Enabled, but macOS still needs approval in System Settings.")
    }
}

@MainActor
private final class LaunchAtLoginServiceMock: LaunchAtLoginService {
    enum Action: Equatable {
        case register
        case unregister
    }

    private(set) var actions: [Action] = []
    private var currentStatus: LaunchAtLoginServiceStatus

    init(initialStatus: LaunchAtLoginServiceStatus) {
        self.currentStatus = initialStatus
    }

    var status: LaunchAtLoginServiceStatus {
        currentStatus
    }

    func register() throws {
        actions.append(.register)
        currentStatus = .enabled
    }

    func unregister() throws {
        actions.append(.unregister)
        currentStatus = .notRegistered
    }
}
