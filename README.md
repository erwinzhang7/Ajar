# Ajar

A free, open-source **Quick Look extension for macOS** that previews folders and archives. Select a folder or `.zip` in Finder, press Space, and see what's inside — without opening it.

Because Ajar plugs into the system Quick Look API, it works **everywhere Quick Look does** — Finder, ForkLift, Path Finder, Commander One, and any other macOS file manager. No per-app integration.

> Status: early. The first milestone (folder contents preview) is in place. Archive previews, thumbnails, and customizable columns are on the roadmap below.

## Requirements

- macOS 12 Monterey or later
- Xcode 14 or later to build from source

## Install

> Pre-built downloads and a Homebrew Cask are on the roadmap once Ajar has a signed and notarized release. Until then, building from source is the supported path — Xcode handles ad-hoc signing automatically, so no Apple Developer account is required.

### From source

```sh
brew install xcodegen     # one-time, if you don't have it
git clone https://github.com/erwinzhang7/Ajar.git
cd Ajar
./scripts/bootstrap.sh    # generates Ajar.xcodeproj
open Ajar.xcodeproj
```

Build and run the **Ajar** scheme. The first run is just a small window with instructions — the actual feature lives in the Quick Look extension that ships inside the app bundle.

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
