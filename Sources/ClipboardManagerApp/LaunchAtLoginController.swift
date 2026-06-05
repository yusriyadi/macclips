import ServiceManagement

enum LaunchAtLoginServiceStatus: Equatable {
    case notRegistered
    case enabled
    case requiresApproval
    case notFound
}

@MainActor
protocol LaunchAtLoginService {
    var status: LaunchAtLoginServiceStatus { get }
    func register() throws
    func unregister() throws
}

@MainActor
final class LaunchAtLoginController {
    private let service: LaunchAtLoginService

    init(service: LaunchAtLoginService = SMAppLaunchAtLoginService()) {
        self.service = service
    }

    var isEnabled: Bool {
        service.status == .enabled || service.status == .requiresApproval
    }

    var needsApproval: Bool {
        service.status == .requiresApproval
    }

    var statusMessage: String {
        switch service.status {
        case .enabled:
            return "Launch at login is enabled."
        case .requiresApproval:
            return "Enabled, but macOS still needs approval in System Settings."
        case .notRegistered:
            return "Launch at login is off."
        case .notFound:
            return "Launch at login is unavailable."
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

@MainActor
final class SMAppLaunchAtLoginService: LaunchAtLoginService {
    private let service: SMAppService

    init(service: SMAppService = .mainApp) {
        self.service = service
    }

    var status: LaunchAtLoginServiceStatus {
        switch service.status {
        case .enabled:
            return .enabled
        case .requiresApproval:
            return .requiresApproval
        case .notRegistered:
            return .notRegistered
        case .notFound:
            return .notFound
        @unknown default:
            return .notFound
        }
    }

    func register() throws {
        try service.register()
    }

    func unregister() throws {
        try service.unregister()
    }
}
