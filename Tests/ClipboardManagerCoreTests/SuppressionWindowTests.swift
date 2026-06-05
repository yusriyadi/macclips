import Foundation
import Testing
@testable import ClipboardManagerCore

struct SuppressionWindowTests {
    @Test
    func reportsSuppressedInsideWindowOnly() {
        let clock = TestClock()
        let window = SuppressionWindow(clock: clock.now)

        #expect(window.isSuppressed == false)

        window.begin(duration: 3)
        #expect(window.isSuppressed == true)

        clock.advance(by: 2)
        #expect(window.isSuppressed == true)

        clock.advance(by: 2)
        #expect(window.isSuppressed == false)
    }
}

private final class TestClock {
    private var currentDate = Date(timeIntervalSince1970: 2_000)

    func now() -> Date {
        currentDate
    }

    func advance(by interval: TimeInterval = 1) {
        currentDate.addTimeInterval(interval)
    }
}
