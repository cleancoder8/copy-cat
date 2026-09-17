# Copy Cat

A native macOS clipboard manager based on the complete [Maccy 2.7.1](https://github.com/p0deje/Maccy/tree/2.7.1) source, under its MIT license. Copy Cat is an independent fork, not an official Maccy release. Requires macOS 14 or newer.

The original prototype is preserved in the `prototype-0.1.0` Git tag. The current app uses Maccy's actual implementation and test suites instead of approximating its features.

## Use

Open Copy Cat from the menu bar or press **⌘⇧C** (Maccy's default; configurable in Settings). Type to search, then Return to copy. Option-Return pastes; Option-Shift-Return pastes without formatting. Automatic paste requires Accessibility permission, which macOS asks you to grant yourself.

- Text, HTML, rich text, files, PNG, TIFF, JPEG, and HEIC clipboard content
- Exact, fuzzy, regular-expression, and mixed search
- Pins with editable titles, shortcut letters, and ordering
- Copy, automatic paste, and paste without formatting
- Full previews, image text recognition, color swatches, and source-app icons
- Configurable shortcuts, popup location and size, appearance, and sorting
- Launch at login, history limits, clear-on-quit, and system clipboard clearing
- App allow/deny lists, regex exclusions, and custom ignored clipboard types
- Pause capture, ignore-next-copy, and confidential/transient type filtering
- Apple Shortcuts intents and upstream translations

See [usage and keyboard shortcuts](docs/MACCY-UPSTREAM.md) and the [parity notes](docs/PARITY.md).

## Build and test

Full Xcode is required (Command Line Tools alone cannot compile asset catalogs or run XCTest).

```sh
./scripts/build-app.sh
open "dist/Copy Cat.app"
./scripts/test.sh -only-testing:MaccyTests
./scripts/test.sh -only-testing:MaccyUITests
```

You can also open `Maccy.xcodeproj` and use the `Maccy` scheme. These internal names are retained for maintainable upstream merges; the built product is **Copy Cat.app**, bundle identifier `local.copycat.app`.

GitHub Actions builds a universal app and runs the upstream unit/UI suites. Download the `Copy-Cat` artifact from a successful [workflow run](https://github.com/cleancoder8/copy-cat/actions). Builds are ad-hoc signed, not Developer ID signed or notarized. The build scripts disable hardened runtime for these ad-hoc development builds so embedded frameworks can load; Developer ID distribution should enable hardened runtime and sign every component with the same team.

## Storage and fork differences

History is local, unencrypted, and separate from Maccy: `~/Library/Application Support/CopyCat/Storage.sqlite`. Preferences use `local.copycat.app`. Copy Cat does not read or modify Maccy's database or preferences. On first launch, prototype text/image history and pins are imported automatically; the original `history.json` remains as a backup. History limits and app exclusions are migrated as well.

The upstream updater engine is retained, but automatic updates are disabled until a signed Copy Cat feed is configured. “Check now” opens this repository's releases. It never installs official Maccy over Copy Cat. App Store review prompts are disabled because this fork has no App Store listing. These distribution differences mean this is not a byte-for-byte or service-for-service identical release.

## Attribution

Maccy copyright © Alexey Rodionov and contributors. See [LICENSE](LICENSE) and [upstream provenance](docs/UPSTREAM.md).

Copy Cat uses direct-distribution, non-sandboxed entitlements, matching the original prototype. This keeps its existing Application Support location accessible for migration. macOS Accessibility permission is still required for automatic paste. Upstream Mac App Store sandbox entitlements are not used.
