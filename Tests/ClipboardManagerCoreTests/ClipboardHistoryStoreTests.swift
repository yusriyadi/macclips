import Foundation
import Testing
@testable import ClipboardManagerCore

struct ClipboardHistoryStoreTests {
    @Test
    func addsNewItemsInReverseChronologicalOrder() {
        let clock = TestClock()
        let store = ClipboardHistoryStore(
            maximumItemCount: 5,
            clock: clock.now
        )

        store.record(ClipboardPayload.text("first"), sourceAppName: "Notes")
        clock.advance()
        store.record(ClipboardPayload.text("second"), sourceAppName: "Xcode")

        let items = store.items

        #expect(items.count == 2)
        #expect(items[0].textValue == "second")
        #expect(items[1].textValue == "first")
    }

    @Test
    func deduplicatesExistingItemsAndRefreshesTimestamp() {
        let clock = TestClock()
        let store = ClipboardHistoryStore(
            maximumItemCount: 5,
            clock: clock.now
        )

        store.record(ClipboardPayload.text("duplicate"), sourceAppName: "Notes")
        let originalCreatedAt = store.items[0].createdAt
        clock.advance()
        store.record(ClipboardPayload.text("duplicate"), sourceAppName: "Safari")

        let items = store.items

        #expect(items.count == 1)
        #expect(items[0].createdAt == originalCreatedAt)
        #expect(items[0].lastSeenAt > originalCreatedAt)
        #expect(items[0].sourceAppName == "Safari")
    }

    @Test
    func prunesOldestItemsBeyondRetentionLimit() {
        let clock = TestClock()
        let store = ClipboardHistoryStore(
            maximumItemCount: 2,
            clock: clock.now
        )

        store.record(ClipboardPayload.text("one"), sourceAppName: nil)
        clock.advance()
        store.record(ClipboardPayload.text("two"), sourceAppName: nil)
        clock.advance()
        store.record(ClipboardPayload.text("three"), sourceAppName: nil)

        let texts = store.items.compactMap { $0.textValue }

        #expect(texts == ["three", "two"])
    }

    @Test
    func ranksPrefixMatchesAboveContainsMatchesAndRecency() {
        let clock = TestClock()
        let store = ClipboardHistoryStore(
            maximumItemCount: 10,
            clock: clock.now
        )

        store.record(ClipboardPayload.text("clipboard search"), sourceAppName: "Terminal")
        clock.advance()
        store.record(ClipboardPayload.text("my clipboard note"), sourceAppName: "Notes")
        clock.advance()
        store.record(ClipboardPayload.text("search elsewhere"), sourceAppName: "Safari")

        let results = store.search(query: "clip")

        #expect(results.map { $0.textValue } == ["clipboard search", "my clipboard note"])
    }
}

private final class TestClock {
    private var currentDate = Date(timeIntervalSince1970: 1_000)

    func now() -> Date {
        currentDate
    }

    func advance(by interval: TimeInterval = 1) {
        currentDate.addTimeInterval(interval)
    }
}
