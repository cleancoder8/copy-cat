# Copy Cat

A native macOS clipboard manager inspired by [Maccy](https://maccy.app/), independently implemented in Swift, SwiftUI, and AppKit. Requires macOS 14 or newer. No third-party dependencies.

## Run

```sh
./scripts/build-app.sh
open "dist/Copy Cat.app"
```

Copy Cat lives in the menu bar. Press **⌘⇧V** or click the clipboard icon to open it. Search by text or source app, use arrow keys to select a clip, and press Return to copy it. Then use **⌘V** in your destination app. Click the pin to preserve a clip; right-click to delete it. The gear menu contains pause, settings, clear, and quit.

## Included

- Text and image clipboard history, with image thumbnails
- Case-insensitive search and a pinned-only filter
- Duplicate detection that preserves pins
- Local persistence, configurable history count, and app exclusions
- Confidential and transient clipboard type filtering
- Global shortcut, native light/dark appearance, and keyboard navigation

History is stored at `~/Library/Application Support/CopyCat/history.json` with owner-only file permissions. It is not encrypted. Apps must mark sensitive copies confidential for automatic filtering to work; excluded app bundle identifiers can be entered in Settings. Capture starts with the next clipboard change after launch. Text entries over 2 MB and images over 10 MB are skipped. Pinned entries are exempt from the history count limit.

This first version copies plain text and images. Rich text, file objects, automatic pasting, launch at login, and configurable shortcuts are not implemented. The bundle is locally ad-hoc signed, not notarized for distribution.

## Development

```sh
swift build
swift test # requires Xcode with XCTest
./scripts/test.sh # standalone checks with Command Line Tools
```

`Sources/CopyCat/History.swift` handles capture and storage. `HistoryView.swift` contains the interface. `CopyCat.swift` owns the menu bar item and global shortcut.
