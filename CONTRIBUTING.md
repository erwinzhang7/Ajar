# Contributing to Ajar

Thanks for the interest. Ajar is small and early — the surface area for contribution will grow as the roadmap lands. The notes below should be enough to get a working build and find your way around.

## Prerequisites

- macOS 12 or later
- Xcode 16 or later (Xcode 26 if you want to match CI exactly)
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Build from source

```sh
git clone https://github.com/erwinzhang7/Ajar.git
cd Ajar
./scripts/bootstrap.sh    # generates Ajar.xcodeproj from project.yml
open Ajar.xcodeproj
```

Then build and run the **Ajar** scheme in Xcode. Xcode ad-hoc signs the bundle automatically; no Apple Developer account is required for local development.

After the first run, enable the extension in **System Settings → General → Login Items & Extensions → Quick Look → Ajar**. Hit Space on a folder in Finder to confirm it's wired up.

If your previewer doesn't show up, two things usually fix it:

1. Reset the Quick Look daemon — `qlmanage -r && qlmanage -r cache && killall -9 quicklookd`.
2. Re-open the host app once so `pluginkit` re-indexes — the embedded `.appex` registers from the host app's launch.

## Project layout

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full tour. The short version:

- `Ajar/` — minimal SwiftUI host app (first-run instructions, settings)
- `AjarQuickLook/` — the `.appex` that does the actual previewing
- `project.yml` — xcodegen spec; `.xcodeproj` is not committed
- `scripts/bootstrap.sh` — regenerates the Xcode project

## Making changes

- Edit Swift sources directly. Run from Xcode to test.
- Edit `project.yml` for build settings / new targets / new file groups. Re-run `./scripts/bootstrap.sh` after.
- Keep PRs focused. One feature, one fix, one cleanup per PR.
- CI runs a debug build on every push and PR (see `.github/workflows/build.yml`). PRs that don't build won't be merged.

## What's a good first contribution?

Anything from the [roadmap](./README.md#roadmap) is fair game, but the cheapest wins right now:

- Thumbnails for images/PDFs/video in the folder table (`AjarQuickLook/FolderPreviewView.swift` is where they'd render; thumbnails come from `QLThumbnailGenerator`).
- A "Show hidden files" toggle in the host app, persisted via `UserDefaults` shared with the extension through an App Group.
- A first archive scanner — `.zip` via Apple's `AppleArchive` framework — exposing the same shape as `FolderScanner.scan`.

If you're not sure whether something fits, open an issue first and we can sort scope before you write code.

## Code style

- Swift 5 mode, SwiftUI where it fits, AppKit when it doesn't. No third-party dependencies in the extension target unless they're MIT/BSD-compatible and small.
- Don't add files that aren't load-bearing — no boilerplate, no scaffolding for hypothetical future targets.
- Match the existing comment style: only explain *why*, never *what*.

## Releases (maintainer notes)

Ajar ships as an ad-hoc-signed `.app` distributed via GitHub Releases and a Homebrew Cask tap. No Apple Developer Program subscription is involved.

To cut a release:

1. Bump `MARKETING_VERSION` in `project.yml` (e.g. `"0.1.0"` → `"0.2.0"`), regenerate (`./scripts/bootstrap.sh`), commit.
2. Tag and push:
   ```sh
   git tag v0.2.0
   git push origin v0.2.0
   ```
3. The `release` workflow picks up the tag, runs `scripts/package.sh` (Release build, ad-hoc signed, zipped with `ditto`), and creates a GitHub Release with the zip attached and a ready-to-paste Homebrew Cask formula in the notes.
4. Open [`erwinzhang7/homebrew-ajar`](https://github.com/erwinzhang7/homebrew-ajar), update `Casks/ajar.rb` with the new `version` and `sha256` from the release notes, push. Users can now `brew install --cask erwinzhang7/ajar/ajar` to get the new build.

You can also build a release zip locally to test:

```sh
./scripts/package.sh
# build/Ajar-<version>.zip plus its sha256 are printed at the end
```

## License

By contributing, you agree your contributions are licensed under the [MIT License](./LICENSE).
