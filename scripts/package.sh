#!/usr/bin/env bash
# Build a Release configuration of Ajar with ad-hoc signing and zip it
# for distribution. Output: build/Ajar-<version>.zip plus its sha256.
#
# Ad-hoc signing means no Apple Developer Program subscription is needed.
# Homebrew Cask strips the quarantine attribute on install, so brew users
# get a working install with no Gatekeeper prompt. Direct-download users
# may need to run `xattr -cr /Applications/Ajar.app` once after unzipping.
#
# Pass VERSION=x.y.z to override the version stamped into the bundle
# (CI does this from the git tag); otherwise the value in project.yml's
# MARKETING_VERSION is used.

set -euo pipefail

cd "$(dirname "$0")/.."

./scripts/bootstrap.sh

BUILD_DIR="$PWD/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild_args=(
  -project Ajar.xcodeproj
  -scheme Ajar
  -configuration Release
  -destination 'platform=macOS'
  -derivedDataPath "$BUILD_DIR/DerivedData"
  CODE_SIGN_STYLE=Manual
  CODE_SIGN_IDENTITY=-
  DEVELOPMENT_TEAM=""
)
if [ -n "${VERSION:-}" ]; then
  xcodebuild_args+=("MARKETING_VERSION=$VERSION")
fi

xcodebuild "${xcodebuild_args[@]}" build

APP="$BUILD_DIR/DerivedData/Build/Products/Release/Ajar.app"
if [ ! -d "$APP" ]; then
  echo "error: expected $APP after build, not found" >&2
  exit 1
fi

# Codesign verification is the failure mode that silently makes the Quick
# Look extension invisible to pluginkit. Assert it here so a bad build can
# never produce a release zip.
codesign --verify --verbose=2 "$APP"
codesign --verify --verbose=2 "$APP/Contents/PlugIns/AjarQuickLook.appex"

VERSION_ACTUAL=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")
ZIP="$BUILD_DIR/Ajar-${VERSION_ACTUAL}.zip"

# `ditto -c -k --keepParent` preserves bundle structure, extended attributes,
# and codesign integrity. Plain `zip` corrupts macOS app bundles.
ditto -c -k --keepParent "$APP" "$ZIP"

SHA=$(shasum -a 256 "$ZIP" | awk '{print $1}')

cat <<EOF

  Ajar.app          $APP
  Zipped artifact   $ZIP
  Version           $VERSION_ACTUAL
  SHA-256           $SHA

EOF
