#!/usr/bin/env bash
# Regenerate the Xcode project from project.yml.
#
# Why this exists: Ajar.xcodeproj is not committed — it's an artifact of
# project.yml + xcodegen. Run this any time you change project.yml (new
# target, new file group, new build setting), or after a fresh clone before
# opening the project in Xcode.

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: xcodegen not found in PATH" >&2
  echo "install it with:  brew install xcodegen" >&2
  exit 1
fi

xcodegen generate
echo "Generated Ajar.xcodeproj — open with:  open Ajar.xcodeproj"
