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

## Icon

The app icon currently lives in `Ajar/Assets.xcassets/AppIcon.appiconset/` as a 10-size `.appiconset` rendered from `assets/icon-source-light-1024.png`. This works on all macOS versions but doesn't respond to **macOS 26's per-icon Light/Dark setting** in System Settings → Appearance.

To get appearance-adaptive icons, ship an `AppIcon.icon` package built with Xcode's Icon Composer:

1. In Xcode: **File → New → File from Template → Icon Composer Document**. Save as `Ajar/Assets.xcassets/AppIcon.icon`.
2. In Icon Composer, set the **default (light)** group's foreground to `assets/icon-source-light-1024.png`.
3. Add a **dark** appearance group; set its foreground to `assets/icon-source-dark-1024.png`. (Optionally add tinted/clear if you want full Liquid Glass coverage.)
4. Save. `project.yml` already has `fileTypes.icon.file: true`, so xcodegen will treat the package as a single file and Xcode will recognize it.
5. Set `ASSETCATALOG_COMPILER_APPICON_NAME` in `project.yml` to `AppIcon` (already set). When both `AppIcon.icon` and `AppIcon.appiconset` are present, Tahoe prefers the `.icon`; older macOS versions fall back to the `.appiconset`.

The `.icon` package format has no CLI tool and an undocumented schema; Icon Composer is the only supported way to produce it. The whole job is ~5 minutes once you have the source PNGs.

## Releases (maintainer notes)

Ajar ships as an ad-hoc-signed `.app` distributed via GitHub Releases and a Homebrew Cask tap. No Apple Developer Program subscription is involved.

To cut a release:

1. Bump `MARKETING_VERSION` in `project.yml` (e.g. `"0.1.0"` → `"0.2.0"`), regenerate (`./scripts/bootstrap.sh`), commit.
2. Tag and push:
   ```sh
   git tag v0.2.0
   git push origin v0.2.0
   ```
3. The `release` workflow:
   - Runs `scripts/package.sh` (Release build, ad-hoc signed, zipped with `ditto`).
   - Creates a GitHub Release with the zip attached and a paste-ready Cask formula in the notes (in case auto-bump is disabled).
   - **Auto-bumps the Homebrew tap** (if `HOMEBREW_TAP_TOKEN` is configured) by cloning `erwinzhang7/homebrew-ajar`, replacing `version` + `sha256` in `Casks/ajar.rb`, and pushing the commit.
4. Users then get the new build with `brew upgrade --cask ajar`. No manual tap edit needed.

### One-time setup: `HOMEBREW_TAP_TOKEN`

The auto-bump step needs to push to a separate repo (`homebrew-ajar`), which the default `GITHUB_TOKEN` can't do. Create a fine-grained PAT:

1. https://github.com/settings/personal-access-tokens/new
2. **Resource owner:** your user (`erwinzhang7`)
3. **Repository access:** Only select repositories → pick **`homebrew-ajar`**
4. **Repository permissions:**
   - `Contents`: **Read and write**
   - (Leave everything else as default / no access)
5. **Expiration:** whatever you're comfortable with. Re-rotate when it expires.
6. Generate, copy the token.
7. In the Ajar repo → Settings → Secrets and variables → Actions → **New repository secret**:
   - Name: `HOMEBREW_TAP_TOKEN`
   - Value: paste the token.

After that, every tag push handles itself end-to-end. Without the secret, the workflow logs a notice and you bump the tap by hand as before — nothing breaks.

You can also build a release zip locally to test:

```sh
./scripts/package.sh
# build/Ajar-<version>.zip plus its sha256 are printed at the end
```

## License

By contributing, you agree your contributions are licensed under the [MIT License](./LICENSE).
