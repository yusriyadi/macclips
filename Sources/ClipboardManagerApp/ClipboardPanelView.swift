import ClipboardManagerCore
import SwiftUI
import AppKit

struct ClipboardPanelView: View {
    @ObservedObject var appController: ClipboardAppController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clipboard History")
                        .font(.title3.weight(.semibold))
                    Text(appController.accessibilityEnabled ? "Ready to paste into the active app." : "Accessibility permission is needed for auto-paste.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if appController.accessibilityEnabled == false {
                    Button("Enable Auto-Paste") {
                        appController.requestAccessibilityPermission()
                    }
                }
            }

            TextField("Search clipboard", text: $appController.query)
                .textFieldStyle(.roundedBorder)
                .onChange(of: appController.query) { _ in
                    appController.refreshVisibleItems()
                }

            if let lastErrorMessage = appController.lastErrorMessage {
                Text(lastErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if appController.visibleItems.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No clipboard items yet")
                        .font(.headline)
                    Text("Copy text or an image, then press Command+Shift+V.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List(appController.visibleItems) { item in
                        ClipboardItemRow(
                            item: item,
                            isSelected: appController.selectedItemID == item.id
                        )
                        .id(item.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appController.select(item)
                        }
                        .listRowBackground(
                            appController.selectedItemID == item.id
                                ? Color.accentColor.opacity(0.12)
                                : Color.clear
                        )
                    }
                    .listStyle(.plain)
                    .onChange(of: appController.selectedItemID) { newID in
                        guard let newID else { return }
                        withAnimation {
                            proxy.scrollTo(newID, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 560, height: 420)
        .background(.ultraThinMaterial)
        .onExitCommand {
            appController.dismissPanel()
        }
    }
}

private struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnailView
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .font(.body)
                    .lineLimit(2)
                Text(item.sourceAppName ?? "Unknown App")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.lastSeenAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if item.kind == .image, let data = item.thumbnailData ?? item.imageData {
            if let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                imagePlaceholder
            }
        } else {
            textPlaceholder
        }
    }

    private var textPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.accentColor.opacity(0.12))
            .overlay {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(Color.accentColor)
            }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.orange.opacity(0.18))
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Color.orange)
            }
    }
}
