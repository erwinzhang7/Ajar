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

That installs the latest ad-hoc-signed build from the [`erwinzhang7/homebrew-ajar`](https://github.com/erwinzhang7/homebrew-ajar) tap. `brew upgrade --cask ajar` picks up new releases when they ship.

### Direct download

Grab `Ajar-<version>.zip` from the [Releases page](https://github.com/erwinzhang7/Ajar/releases), unzip, drag `Ajar.app` into `/Applications`. If macOS blocks first launch with "cannot be verified", clear the quarantine flag once:

```sh
xattr -cr /Applications/Ajar.app
```

(Homebrew Cask handles this step automatically, which is why it's the recommended path.)

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
