# 1.0.2

First release that works end-to-end on a fresh teammate install. v1.0.1
shipped the self-contained .app bundle but left every Setup Wizard check
pointed at dev-machine paths that don't exist after the refactor, so
clean installs got locked out at setup with false "missing dependency"
alarms.

## Fixes

- **Setup wizard works on clean installs.** `needsSetup()` only gates on
  things the user actually has to supply (Gemini key + YouTube OAuth),
  instead of checking for `~/kings-automation/pipeline.py` and friends
  that no longer exist.
- **OAuth detection reads the right location.** Post-refactor tokens live
  at `~/Library/Application Support/VerticalVisualsStudio/config/<client>/`;
  Settings and the browser-auth poller now look there first and fall
  back to the legacy dev-dir second.
- **"Missing ML Models" alarm in Settings is gone.** The check now reads
  from the bundled models dir and also refuses to accept Git LFS pointer
  stubs as real weights.
- **Tournament Highlights Background Generator works.** Previously failed
  with "highlight_thumbnail.py not found. Restart the app to install.";
  the script + its asset bundle are now actually inside the .app.
- **Dock click restores a closed main window.** Previously the app kept
  running in the background with no recovery path after ⌘W.

## Install notes

Still ad-hoc signed — Developer ID + notarization ships separately when
the cert lands. First launch: right-click → Open to bypass Gatekeeper.
Subsequent updates via Sparkle install automatically (EdDSA-verified,
independent of Apple signing).
