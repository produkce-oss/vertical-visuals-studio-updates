# 1.0.3

Hotfix for a launch crash introduced during v1.0.2 testing and new
Library + diagnostics features. Anyone running v1.0.2 should update.

## Fixes

- **Launch crash on Macs with a configured Thumbnail Python path.**
  `AppSettings.load()` was spawning a blocking subprocess
  (`python -c "import flask"`) during SwiftUI's initial graph
  construction — the subprocess's `waitUntilExit()` drained the main
  run loop, which triggered a SwiftUI graph update mid-initialization,
  which aborted the app before any window rendered. The Flask check
  is now deferred to `ThumbnailServerService` where it belongs.
  Fresh-install teammates with an empty Python path weren't affected;
  anyone who set the path in v1.0.2 was.
- **Shorts Generator: single ShortsViewModel.** Lifted the
  ShortsViewModel from a dual-ownership pattern (DashboardViewModel's
  lazy var + ShortsView's own `@StateObject`) to a single
  app-root-owned instance injected via `.environmentObject`. The
  Notion-upload surface in the sidebar and the Shorts Generator tool
  now share one instance of state — previously they could silently
  diverge, and tearing down either while the other still observed
  was the exact pattern in our local EXC_BAD_ACCESS crash log.

## New

- **Library → Thumbnails is grouped by episode.** Instead of a flat
  wall of every generated variant, the Thumbnails tab shows one card
  per episode (mode + guest + day tuple) with an "N versions" badge
  when multiple generations exist. Click a card → expands to a sheet
  with every variant for that episode. Clicking a variant opens it
  in Preview (same as before).
- **Crash reports auto-surfaced on next launch.** macOS writes `.ips`
  crash reports to `~/Library/Logs/DiagnosticReports/` automatically
  but most users don't know where to find them. The app now scans
  that directory on launch, copies any new reports into
  `~/Library/Application Support/VerticalVisualsStudio/crashes/`,
  and shows an NSAlert with *Reveal in Finder* so "send me the crash
  log" becomes a two-click action.

## Install

Still ad-hoc signed — existing installs auto-update via Sparkle
(EdDSA-verified, independent of Apple code signing). Fresh downloads:
right-click → Open on first launch to bypass Gatekeeper. Developer ID
notarization arrives in a separate release when the cert lands.
