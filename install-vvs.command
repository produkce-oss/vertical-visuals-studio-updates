#!/usr/bin/env bash
#
# Vertical Visuals Studio — one-shot installer for teammates.
#
# What this does:
#   1. Fetches the latest release from
#      https://github.com/produkce-oss/vertical-visuals-studio-updates
#   2. Downloads the full .zip (skips Sparkle deltas, which are for
#      already-installed copies).
#   3. Unzips into /Applications/Vertical Visuals Studio.app, replacing
#      any older copy.
#   4. Strips the quarantine flag so Gatekeeper lets it launch on the
#      first open (the build is not yet Developer-ID signed).
#   5. Launches the app.
#
# How teammates run it:
#   a. Download this file (single click in browser or ⌘-click → Save Link As).
#   b. In Finder, right-click the file → Open → Open (Gatekeeper prompt
#      appears because the script itself is unsigned). Only needed once.
#   c. Terminal pops up, installer runs, the app launches when done.
#
# Or from a terminal one-liner:
#   curl -fsSL https://raw.githubusercontent.com/produkce-oss/vertical-visuals-studio-updates/main/install-vvs.command \
#     | bash
#
# No admin password is required — /Applications is user-writable on
# modern macOS (14+) for installs via cp -R.

set -euo pipefail

APP_NAME="Vertical Visuals Studio"
REPO="produkce-oss/vertical-visuals-studio-updates"
APP_BUNDLE_ID="cz.verticalvisuals.studio"
TARGET="/Applications/${APP_NAME}.app"
WORKDIR="$(mktemp -d /tmp/vvs-install-XXXXXX)"

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

say()  { printf "\033[1;36m→\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
fail() { printf "\033[1;31m✗\033[0m %s\n" "$1" >&2; exit 1; }

# ── Sanity ────────────────────────────────────────────────────────────
command -v curl  >/dev/null || fail "curl not found — stock macOS should have it."
command -v ditto >/dev/null || fail "ditto not found — stock macOS should have it."

# Apple Silicon only — VVS v1.0.x ships arm64-only binaries.
if [[ "$(uname -m)" != "arm64" ]]; then
  fail "This build is Apple Silicon only. Intel Macs aren't supported for now."
fi

say "Finding the latest ${APP_NAME} release…"
# GitHub API for the latest release metadata. No token needed for public
# repos. If we ever rate-limit, fall back to parsing the /releases page.
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")" \
  || fail "Couldn't reach GitHub. Check your connection and try again."

# Pick the first enclosure whose name ends in .zip (the full-zip upload;
# sparkle_deltas are *.delta in the same release).
ZIP_URL="$(printf '%s' "$RELEASE_JSON" \
  | grep -E '"browser_download_url"' \
  | grep -E '\.zip"' \
  | head -1 \
  | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')"

[[ -n "${ZIP_URL:-}" ]] || fail "Couldn't find a .zip in the latest release."

VERSION_TAG="$(printf '%s' "$RELEASE_JSON" \
  | grep -E '"tag_name"' | head -1 \
  | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')"

ok "Latest release is ${VERSION_TAG}"
say "Downloading $(basename "$ZIP_URL")…"
curl -fSL --progress-bar -o "$WORKDIR/app.zip" "$ZIP_URL" \
  || fail "Download failed."

say "Extracting…"
ditto -x -k "$WORKDIR/app.zip" "$WORKDIR/extracted" \
  || fail "Could not unzip the download."

APP_PATH="$(find "$WORKDIR/extracted" -maxdepth 3 -name '*.app' -type d | head -1)"
[[ -n "${APP_PATH:-}" ]] || fail "No .app bundle inside the zip."

# If an older copy is running, ask it to quit so the replace isn't blocked.
if pgrep -f "/Applications/${APP_NAME}.app/Contents/MacOS" >/dev/null 2>&1; then
  say "Quitting the running copy so we can replace it…"
  osascript -e "tell application \"${APP_NAME}\" to quit" 2>/dev/null || true
  sleep 2
fi

if [[ -d "$TARGET" ]]; then
  say "Removing existing ${TARGET}…"
  rm -rf "$TARGET"
fi

say "Installing to /Applications/…"
cp -R "$APP_PATH" "/Applications/" \
  || fail "Couldn't copy into /Applications/. Is the volume read-only?"

# Strip quarantine. The Sparkle updater does this for in-app updates, but
# a fresh install from a browser download lands with com.apple.quarantine
# set, and the unsigned build would otherwise trip Gatekeeper on first
# launch with a generic "cannot be opened" message.
say "Clearing Gatekeeper quarantine flag…"
xattr -dr com.apple.quarantine "$TARGET" 2>/dev/null || true

# Nudge LaunchServices so Finder picks up the new bundle immediately.
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister \
  -f "$TARGET" 2>/dev/null || true

ok "Installed ${APP_NAME} ${VERSION_TAG}"
say "Launching…"
open "$TARGET"

cat <<EOF

${APP_NAME} is now in /Applications.

Next steps:
  • Open Settings (⌘,) → Accounts to sign in to YouTube channels.
  • ⌘N or click "Start New Run" to kick off a pipeline.

If the app didn't launch, open it manually from /Applications.
EOF
