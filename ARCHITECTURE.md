# Architecture

A short tour of Ajar's targets, the lifecycle of a Quick Look preview, and where to plug new behavior in.

## Targets

```
Ajar.xcodeproj
├── Ajar              (macOS application, SwiftUI)
└── AjarQuickLook     (Quick Look Preview Extension, .appex — embedded in Ajar.app)
```

- **`Ajar`** — the host app. It does almost nothing at runtime: shows a window explaining how to enable the extension, opens the System Settings pane, and (in the future) holds user preferences read by the extension via `UserDefaults` with an App Group.
- **`AjarQuickLook`** — a `.appex` bundle containing `PreviewViewController`, the SwiftUI views that render the preview, and the folder/archive scanners. This is what macOS calls when the user presses Space.

The host app *must* exist — `.appex` bundles can only ship inside a containing app. macOS extracts the extension from `Ajar.app/Contents/PlugIns/` and registers it on first launch.

## Build system

The Xcode project is generated from [`project.yml`](./project.yml) by [xcodegen](https://github.com/yonaskolb/XcodeGen). `Ajar.xcodeproj/` is **not** committed — regenerate it with:

```sh
./scripts/bootstrap.sh
```

This avoids the usual `.xcodeproj` merge-conflict pain and keeps configuration auditable as a small YAML diff.

## Quick Look preview lifecycle

The flow from Space-press to pixels on screen:

1. **User presses Space on a folder.** Finder (or any other Quick Look client) asks the system for a preview of the URL.
2. **macOS resolves the UTI.** For a folder this is `public.folder`. The system searches registered Quick Look extensions whose `Info.plist → NSExtension → NSExtensionAttributes → QLSupportedContentTypes` includes that UTI.
3. **Ajar's extension is selected.** macOS spawns the extension process and instantiates the class named in `NSExtensionPrincipalClass` (`AjarQuickLook.PreviewViewController`).
4. **`preparePreviewOfFile(at:)` is called** with the file URL. We perform the directory scan off the main actor, then on the main actor install an `NSHostingView` wrapping a SwiftUI `FolderPreviewView` populated with the scan result.
5. **Return → display.** Quick Look puts the view on screen at the size it picks. We do not block beyond the scan.

The contract is: by the time `preparePreviewOfFile(at:)` returns, the view should be ready to draw. So we **block on the scan inside preparePreview**, not inside a `.task { … }` modifier in the view — otherwise the user sees an empty preview for a frame.

## Adding a new content type

1. Add the UTI to `AjarQuickLook/Info.plist` → `NSExtension → NSExtensionAttributes → QLSupportedContentTypes`.
2. Branch on the UTI in `PreviewViewController.preparePreviewOfFile(at:)` and dispatch to the appropriate scanner.
3. Add a SwiftUI view that renders the result. Reuse `FolderPreviewView`'s layout vocabulary (header / table / footer) for consistency.

## Adding archive format support

Archives are the next milestone. The intended split:

- **`zip`, `tar`, `gz`, `bz2`** — read with system frameworks (`AppleArchive`, `Compression`) or a small MIT-licensed SPM dependency. Prefer no dependency where the system framework reaches.
- **`7z`, `rar`** — require a third-party decoder. Bundle one only after confirming its license is MIT-compatible. Note the chosen library and its license at the top of the file that wraps it.

Scanners should expose the same shape as `FolderScanner.scan`: an async function returning a "result struct" with entries + total + truncation flag + optional error string. This keeps preview views agnostic of source.

## Sandbox constraints (read carefully)

The Quick Look extension is sandboxed. Practical consequences:

- **No opening files from inside the preview.** Clicking a row in the table can't launch Finder or open a file. The host app or a separate action would be required, and even then macOS may forbid it.
- **Read-only access** to the previewed URL is granted by the system. You don't need user-selected file entitlements to read the file Quick Look hands you. You *do* need them to read anything else.
- **No network by default.** Don't add network entitlements unless absolutely necessary; previews should not phone home.
- **Restricted system interaction.** No AppleEvents, no scripting, no `NSWorkspace` operations that imply UI focus changes.
- **Tight CPU/time budget.** macOS will kill a slow preview. Cap work, run scanning off the main actor, and prefer streaming/early-exit code over "scan everything then render."

Treat the extension as a pure function from URL → view, with a strict budget.

## Versioning

Marketing version lives in `project.yml` under target settings (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`). Bump both for a release, regenerate the project, commit.

## Code layout cheatsheet

| Path | Purpose |
| --- | --- |
| `project.yml` | xcodegen spec — the source of truth for project layout |
| `scripts/bootstrap.sh` | Generates the Xcode project |
| `Ajar/AjarApp.swift` | Host app entry point |
| `Ajar/ContentView.swift` | First-run instructions UI |
| `Ajar/Ajar.entitlements` | Host app sandbox entitlements |
| `AjarQuickLook/Info.plist` | Extension manifest — UTIs, principal class |
| `AjarQuickLook/PreviewViewController.swift` | QLPreviewingController entry point |
| `AjarQuickLook/FolderScanner.swift` | Folder enumeration off the main actor |
| `AjarQuickLook/FolderPreviewView.swift` | SwiftUI rendering of the scan result |
| `AjarQuickLook/AjarQuickLook.entitlements` | Extension sandbox entitlements |
