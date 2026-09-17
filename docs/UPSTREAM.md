# Upstream provenance

- Project: https://github.com/p0deje/Maccy
- Version: 2.7.1
- Commit: eb03ebac3bbf24044c797c06f4304b74e3187835
- License: MIT; original license retained at the repository root.

The complete application, assets, translations, Xcode project, unit tests, UI tests, and locked dependencies were imported from this release. Internal Maccy module/scheme names remain to minimize merge conflicts. Copy Cat changes product branding, bundle identifiers, storage paths, support links, and distribution configuration. Original acknowledgments are retained.

Do not point SUFeedURL at Maccy's feed. A future Copy Cat updater needs its own release feed and signing keys.

Copy Cat uses direct-distribution, non-sandboxed entitlements, matching the original prototype. This keeps its existing Application Support location accessible for migration. macOS Accessibility permission is still required for automatic paste. Upstream Mac App Store sandbox entitlements are not used.
