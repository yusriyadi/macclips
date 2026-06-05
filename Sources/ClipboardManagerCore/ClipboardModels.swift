import Foundation

public enum ClipboardPayload: Equatable, Sendable {
    case text(String)
    case image(Data)
}

public enum ClipboardItemKind: String, Codable, Sendable {
    case text
    case image
}

public struct ClipboardItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let kind: ClipboardItemKind
    public let contentHash: String
    public let createdAt: Date
    public let lastSeenAt: Date
    public let sourceAppName: String?
    public let previewText: String
    public let textValue: String?
    public let imageData: Data?
    public let thumbnailData: Data?

    public init(
        id: UUID = UUID(),
        kind: ClipboardItemKind,
        contentHash: String,
        createdAt: Date,
        lastSeenAt: Date,
        sourceAppName: String?,
        previewText: String,
        textValue: String?,
        imageData: Data?,
        thumbnailData: Data?
    ) {
        self.id = id
        self.kind = kind
        self.contentHash = contentHash
        self.createdAt = createdAt
        self.lastSeenAt = lastSeenAt
        self.sourceAppName = sourceAppName
        self.previewText = previewText
        self.textValue = textValue
        self.imageData = imageData
        self.thumbnailData = thumbnailData
    }
}

public extension ClipboardItem {
    var searchableText: String {
        [
            previewText,
            textValue,
            sourceAppName,
            kind.rawValue,
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: "\n")
    }
}
