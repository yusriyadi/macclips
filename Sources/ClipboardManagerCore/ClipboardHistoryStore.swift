import CryptoKit
import Foundation

public final class ClipboardHistoryStore {
    public typealias Clock = () -> Date

    public private(set) var items: [ClipboardItem]

    private let maximumItemCount: Int
    private let clock: Clock

    public init(
        maximumItemCount: Int = 500,
        clock: @escaping Clock = Date.init,
        initialItems: [ClipboardItem] = []
    ) {
        self.maximumItemCount = max(1, maximumItemCount)
        self.clock = clock
        self.items = Array(initialItems.sorted(by: Self.sortItems).prefix(maximumItemCount))
    }

    @discardableResult
    public func record(_ payload: ClipboardPayload, sourceAppName: String?) -> ClipboardItem {
        let now = clock()
        let item = makeItem(from: payload, sourceAppName: sourceAppName, now: now)

        if let existingIndex = items.firstIndex(where: { $0.contentHash == item.contentHash }) {
            let existing = items.remove(at: existingIndex)
            let refreshed = ClipboardItem(
                id: existing.id,
                kind: item.kind,
                contentHash: item.contentHash,
                createdAt: existing.createdAt,
                lastSeenAt: now,
                sourceAppName: sourceAppName,
                previewText: item.previewText,
                textValue: item.textValue,
                imageData: item.imageData,
                thumbnailData: item.thumbnailData
            )
            items.insert(refreshed, at: 0)
            return refreshed
        }

        items.insert(item, at: 0)
        pruneIfNeeded()
        return item
    }

    public func search(query: String) -> [ClipboardItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.isEmpty == false else {
            return items
        }

        let normalizedQuery = trimmedQuery.lowercased()

        let matches: [(item: ClipboardItem, score: Int)] = items.compactMap { item in
                let haystack = item.searchableText
                guard haystack.contains(normalizedQuery) else {
                    return nil
                }

                return (item: item, score: score(for: item, query: normalizedQuery))
            }

        return matches.sorted { left, right in
                if left.score != right.score {
                    return left.score > right.score
                }

                return Self.sortItems(left.item, right.item)
            }
            .map(\.item)
    }

    public func replaceAll(with items: [ClipboardItem]) {
        self.items = Array(items.sorted(by: Self.sortItems).prefix(maximumItemCount))
    }

    private func pruneIfNeeded() {
        guard items.count > maximumItemCount else {
            return
        }

        items = Array(items.prefix(maximumItemCount))
    }

    private func makeItem(from payload: ClipboardPayload, sourceAppName: String?, now: Date) -> ClipboardItem {
        switch payload {
        case let .text(text):
            let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return ClipboardItem(
                kind: .text,
                contentHash: Self.hash(for: Data(normalizedText.utf8)),
                createdAt: now,
                lastSeenAt: now,
                sourceAppName: sourceAppName,
                previewText: Self.previewText(from: normalizedText),
                textValue: normalizedText,
                imageData: nil,
                thumbnailData: nil
            )

        case let .image(data):
            return ClipboardItem(
                kind: .image,
                contentHash: Self.hash(for: data),
                createdAt: now,
                lastSeenAt: now,
                sourceAppName: sourceAppName,
                previewText: "Image from \(sourceAppName ?? "Unknown App")",
                textValue: nil,
                imageData: data,
                thumbnailData: data
            )
        }
    }

    private func score(for item: ClipboardItem, query: String) -> Int {
        let candidates = [
            item.textValue?.lowercased(),
            item.previewText.lowercased(),
            item.sourceAppName?.lowercased(),
            item.kind.rawValue.lowercased(),
        ]

        if candidates.contains(where: { $0?.hasPrefix(query) == true }) {
            return 3
        }

        if candidates.contains(where: { $0?.contains(query) == true }) {
            return 2
        }

        return 1
    }

    private static func previewText(from text: String) -> String {
        let collapsedWhitespace = text.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
        return String(collapsedWhitespace.prefix(120))
    }

    private static func hash(for data: Data) -> String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    private static func sortItems(_ lhs: ClipboardItem, _ rhs: ClipboardItem) -> Bool {
        if lhs.lastSeenAt != rhs.lastSeenAt {
            return lhs.lastSeenAt > rhs.lastSeenAt
        }

        return lhs.createdAt > rhs.createdAt
    }
}
