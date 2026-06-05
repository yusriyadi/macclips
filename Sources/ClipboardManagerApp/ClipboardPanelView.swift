import ClipboardManagerCore
import SwiftUI

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
                    List(appController.visibleItems, selection: selectionBinding) { item in
                        Button {
                            appController.setSelectedItem(id: item.id)
                            appController.select(item)
                        } label: {
                            ClipboardItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .tag(item.id)
                        .id(item.id)
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

    private var selectionBinding: Binding<ClipboardItem.ID?> {
        Binding(
            get: { appController.selectedItemID },
            set: { newValue in
                guard let newValue else {
                    return
                }

                appController.setSelectedItem(id: newValue)
            }
        )
    }
}

private struct ClipboardItemRow: View {
    let item: ClipboardItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(item.kind == .text ? Color.accentColor.opacity(0.12) : Color.orange.opacity(0.18))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: item.kind == .text ? "text.alignleft" : "photo")
                        .foregroundStyle(item.kind == .text ? Color.accentColor : Color.orange)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .font(.body)
                    .lineLimit(2)
                Text(item.sourceAppName ?? "Unknown App")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(item.lastSeenAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
