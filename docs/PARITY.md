# Maccy 2.7.1 parity baseline

Copy Cat uses the complete upstream 2.7.1 implementation. This is source-level parity for the clipboard workflow, not a claim that every behavior has been manually tested on every macOS version.

| Area | Implementation |
| --- | --- |
| Clipboard formats and restoration | Upstream Clipboard, HistoryItem, and HistoryItemContent |
| Automatic paste / unformatted paste | Upstream clipboard and modifier-key handling |
| Search and highlighting | Upstream exact, fuzzy, regexp, and mixed search |
| Pins, ordering, names, shortcut letters | Upstream history and pin preferences |
| Keyboard / mouse navigation | Upstream key handling, global shortcuts, navigation manager |
| Previews, OCR, images, colors, source icons | Upstream preview, Vision, and rendering |
| History limits / sorting / clear behavior | Upstream SwiftData storage and preferences |
| Exclusions / allowlist / ignore next copy | Upstream clipboard capture and ignore preferences |
| Appearance / popup placement / menu bar | Upstream appearance and advanced settings |
| Login startup | Upstream LaunchAtLogin integration |
| Apple Shortcuts | Upstream App Intents |
| Localization | Upstream translation resources, with Copy Cat naming |
| Tests | Complete upstream unit and UI suites retained |

Intentional fork differences: Copy Cat branding, identifiers, database location, support URLs, disabled App Store review prompts, and automatic updates disabled pending an independently signed feed. The default shortcut is now upstream's Command-Shift-C, replacing the prototype's Command-Shift-V.

Maccy's experimental multi-selection/paste-stack feature is disabled in upstream 2.7.1 and remains disabled here. Its presence in source is not advertised as a working feature.

Copy Cat uses direct-distribution, non-sandboxed entitlements, matching the original prototype. This keeps its existing Application Support location accessible for migration. macOS Accessibility permission is still required for automatic paste. Upstream Mac App Store sandbox entitlements are not used.
