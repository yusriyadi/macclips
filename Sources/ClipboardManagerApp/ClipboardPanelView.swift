import ClipboardManagerCore
import SwiftUI
import AppKit

struct ClipboardPanelView: View {
    @ObservedObject var appController: ClipboardAppController
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: showSettings ? "chevron.left" : "gearshape")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                if showSettings {
                    Text("Settings")
                        .font(.title3.weight(.semibold))
                } else {
                    Text(appController.accessibilityEnabled ? "Ready to paste into the active app." : "Accessibility permission required for auto-paste.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if showSettings {
                settingsView
            } else {
                clipboardListView
            }
        }
        .padding(.horizontal, 14)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 10)
        .frame(width: 560, height: 420)
        .background(.ultraThinMaterial)
        .onExitCommand {
            if showSettings {
                showSettings = false
            } else {
                appController.dismissPanel()
            }
        }
    }

    // MARK: - Settings

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Auto-Paste")
                    .font(.headline)

                Text("Auto-paste requires Accessibility permission to send keyboard events to other applications.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Circle()
                        .fill(appController.accessibilityEnabled ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(appController.accessibilityEnabled ? "Permission granted" : "Permission needed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !appController.accessibilityEnabled {
                        Button("Enable") {
                            appController.requestAccessibilityPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Launch at Login")
                    .font(.headline)

                Toggle(
                    "Open Clipboard Manager when I log in",
                    isOn: Binding(
                        get: { appController.launchAtLoginEnabled },
                        set: { appController.setLaunchAtLoginEnabled($0) }
                    )
                )
                .toggleStyle(.switch)

                Text(appController.launchAtLoginStatusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if appController.launchAtLoginNeedsApproval {
                    Button("Open Login Items in System Settings") {
                        appController.openLaunchAtLoginSystemSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            Divider()

            Spacer()
        }
    }

    // MARK: - Clipboard List

    private var clipboardListView: some View {
        Group {
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
                            isSelected: appController.selectedItemID == item.id,
                            onDelete: { appController.removeItem(item) }
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
    }
}

// MARK: - Row

private struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onDelete: () -> Void

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

            VStack(alignment: .trailing, spacing: 4) {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)

                Spacer()

                Text(item.lastSeenAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
