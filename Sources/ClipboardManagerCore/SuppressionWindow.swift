import Foundation

public final class SuppressionWindow {
    public typealias Clock = () -> Date

    public var isSuppressed: Bool {
        guard let suppressedUntil else {
            return false
        }

        return clock() < suppressedUntil
    }

    private let clock: Clock
    private var suppressedUntil: Date?

    public init(clock: @escaping Clock = Date.init) {
        self.clock = clock
    }

    public func begin(duration: TimeInterval) {
        suppressedUntil = clock().addingTimeInterval(duration)
    }
}
