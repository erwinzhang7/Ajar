# Ajar

A free, open-source **Quick Look extension for macOS** that previews folders and archives. Select a folder or `.zip` in Finder, press Space, and see what's inside — without opening it.

Because Ajar plugs into the system Quick Look API, it works **everywhere Quick Look does** — Finder, ForkLift, Path Finder, Commander One, and any other macOS file manager. No per-app integration.

> Status: early. The first milestone (folder contents preview) is in place. Archive previews, thumbnails, and customizable columns are on the roadmap below.

## Requirements

- macOS 12 Monterey or later
- Xcode 14 or later to build from source

## Install

### Homebrew (recommended)

```sh
brew install --cask erwinzhang7/ajar/ajar
```

Upgrades are `brew upgrade --cask ajar` as usual.

#### First-launch unblock (one time per install)

Ajar is ad-hoc signed — no Apple Developer Program subscription, no notarization. On macOS Sequoia and Tahoe, Gatekeeper blocks first launch with *"Apple could not verify Ajar"*. The unblock:

1. Try to launch Ajar — Spotlight → type **Ajar** → Return, or double-click in Finder. Gatekeeper rejects with a dialog. Click **Done** (NOT *Move to Trash*).
2. Open **System Settings → Privacy & Security**.
3. Scroll down to the **Security** section.
4. Click **Open Anyway** next to the *"Ajar" was blocked* notice.
5. Confirm with your password.

After that Ajar launches normally — the trust is permanent for that bundle. (Re-installing or upgrading via brew re-triggers the unblock.)

> Tahoe removed every CLI shortcut that used to handle this — [`--no-quarantine`](https://github.com/Homebrew/brew/issues/20755), `spctl --add`, right-click → Open, and even `sudo xattr -cr` (App Management TCC now protects `/Applications`). The System Settings flow above is the only path for unsigned apps. Until Ajar is [notarized](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) ($99/yr Apple Developer Program), this single GUI confirmation is unavoidable — same model as installing any other unsigned Mac app from a maintainer you trust.

### Direct download

Grab `Ajar-<version>.zip` from the [Releases page](https://github.com/erwinzhang7/Ajar/releases), unzip, drag `Ajar.app` into `/Applications`. Same first-launch unblock applies (System Settings → Privacy & Security → Open Anyway).

### Build from source

For contributors or anyone who'd rather build locally — see [CONTRIBUTING.md](./CONTRIBUTING.md) for the full walkthrough. Short version:

```sh
brew install xcodegen
git clone https://github.com/erwinzhang7/Ajar.git
cd Ajar
./scripts/bootstrap.sh
open Ajar.xcodeproj
```

### Enable the extension

The extension is registered with the system the first time the host app runs, but macOS requires you to toggle it on:

1. **System Settings → General → Login Items & Extensions**
2. Scroll to **Extensions** → click the **(i)** next to **Quick Look**
3. Toggle **Ajar** on
4. Select a folder in Finder and press **Space**

The host app has an "Open Login Items & Extensions" button that jumps you straight there.

## What works today

- Folder previews: name, kind, size, modified date for each child entry
- Folders sort to the top; results capped per preview for responsiveness
- Hidden files (`.DS_Store`, dotfiles) skipped by default

## Roadmap

- Thumbnails for images, PDFs, and video in the folder list
- Customizable columns (size, modified date, image dimensions, …) persisted in the host app
- Archive previews — `.zip`, `.tar`, `.gz`, `.bz2` first via system / Swift Package decoders
- Optional `.7z` and `.rar` support via a vendored, MIT-compatible decoder (will note the bundled license)
- Subfolder navigation, hidden-file toggle, appearance settings

## Architecture

Two targets — a minimal host app and a Quick Look Preview Extension (`.appex`). The host app exists so macOS has somewhere to install and register the extension; the extension is what actually renders previews. See [ARCHITECTURE.md](./ARCHITECTURE.md) for the lifecycle of a preview, sandbox notes, and where to add new content types or decoders.

## License

[MIT](./LICENSE). Code is original; PeekX (also MIT) was consulted as a reference for the extension's general shape but no source was copied. Ajar has no relationship to any commercial folder-preview application.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for build setup, project layout, and a list of good first issues. The project is early — small focused PRs are the easiest to land.
