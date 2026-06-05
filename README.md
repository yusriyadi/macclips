# MacClips

[![macOS](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)](https://www.swift.org/)
[![License](https://img.shields.io/badge/license-Open%20Source-blue)](LICENSE)

MacClips is an open-source clipboard history app for macOS.

It runs quietly in the background, keeps a local history of copied text and images, and lets you bring items back with a fast global shortcut.

## Features

- Clipboard history for text and images
- Global shortcut: `Command + Shift + V`
- Searchable floating panel
- Quick paste into the active app
- Local-only storage on your Mac
- Launch at Login support
- Automatic deduplication of repeated clipboard items
- Retention for the 500 most recent items

## How It Works

1. Copy something on macOS.
2. MacClips saves it to local clipboard history.
3. Press `Command + Shift + V`.
4. Search or browse your recent items.
5. Select an item to copy it back and paste it into the active app.

## Requirements

- macOS 13 or newer
- Xcode / Swift toolchain for building from source
- Accessibility permission for auto-paste

## Build From Source

```bash
git clone https://github.com/yusriyadi/macclips.git
cd macclips
bash scripts/build_app_bundle.sh
```

The built app bundle will be available at:

```bash
dist/ClipboardManager.app
```

## Run

Open the app bundle after building:

```bash
open dist/ClipboardManager.app
```

Then press `Command + Shift + V` to open the clipboard panel.

## Screenshot

> Add a product screenshot here once you're ready to publish the first release.
>
> A good first screenshot shows the floating clipboard panel, search bar, and recent clipboard items.

## Launch at Login

Open the app settings panel and enable **Launch at Login**.

If macOS asks for approval, open:

**System Settings → General → Login Items**

and approve MacClips there.

## Privacy

- All clipboard history stays on your device.
- No account is required.
- No cloud sync is used.
- No analytics or telemetry are included in v1.

## Project Structure

- `Sources/ClipboardManagerApp` — app lifecycle, panel UI, hotkey handling, and system integration
- `Sources/ClipboardManagerCore` — clipboard models, history storage, persistence, and retention logic
- `Tests` — unit tests for core history logic and app coordination

## Contributing

Contributions are welcome.

If you want to help, a good starting point is:

- fix UI polish
- improve keyboard navigation
- add tests around clipboard edge cases
- improve accessibility labels

## License

Open-source project. Add the `LICENSE` file you want to use, then link it here.
