# 1.0.9 — Concurrency, durability, and polish

**Shipping this release:** a patch bundling work from three parallel
audit passes on top of v1.0.8. No new features — the whole release is
hardening: pipe-buffer-deadlock fixes across every subprocess helper,
atomic writes for every on-disk JSON, @MainActor on PipelineService,
a Python-side PATH/atomicity sweep, plus a wide UI polish pass that
unifies primary CTAs and migrates sheets onto the Spacing / Typography
token scale. Release itself also ships ~3× faster.

## What's fixed

### Concurrency & subprocess reliability

- **Pipe-buffer deadlocks eliminated.** Six subprocess helpers
  (ClaudeService, HighlightThumbnailService, StoryGenerationService,
  ArtifactCleanupService, YouTubeMetadataPushService,
  EnvironmentValidator) used the wait-then-read pattern, which hung the
  moment a child's combined output crossed the ~64 KB Darwin pipe
  buffer. Extracted a single `SubprocessRunner` that drains pipes
  concurrently via readabilityHandler; every helper now routes through
  it. Most likely to have bitten us on Claude CLI with long reasoning
  output and Gemini traceback errors.
- **PipelineService @MainActor + pgrp-safe terminate.** Every caller
  was already @MainActor in practice; the annotation promotes that to a
  compile-time check so a stray background caller fails to build
  instead of silently racing on the `processes` dict. `terminate()`
  rewritten to never signal VVS's own process group during the brief
  window before the child calls `os.setpgrp()`.
- **Clients snapshot cache locked against torn reads.**
  `ClientConfigStore.clientsSnapshot` was `nonisolated(unsafe)` and
  read from file-watcher timers while MainActor writes mutated it.
  Wrapped in `OSAllocatedUnfairLock` with defensive copies.
- **FileWatcher timer invalidation on deinit.** Long-lived watchers
  never deallocated in practice, but scene restoration could leave
  timers armed against zombie instances, waking the main RunLoop to
  fire closures on a dead object.
- **Thumbnail-server startup race + bounded auto-restart.**
  `startWithApp` didn't flip `isStarting` synchronously, so concurrent
  `ensureRunning()` calls could race into a second Flask start and
  fight over the port. Terminator auto-restart is now capped at 6
  attempts with exponential backoff (1/2/4/8/16/32s) — a permanently
  broken server no longer busy-loops.

### Data durability

- **Atomic JSON writes across every persisted state file.**
  HistoryService, AppSettings, ClientConfigStore, and VideoMetadata all
  wrote with plain `Data.write` and swallowed errors via `try?`. A
  crash mid-write truncated the file and the next launch silently
  reverted to defaults. Now all four use `.atomic` writes (temp file +
  rename) and NSLog failures so a future Settings UI can surface a
  "last save failed" chip.
- **Atomic status-file writes in pipeline.py.** Subprocesses killed
  mid-flush left truncated JSON that Swift's 2s poller decoded as nil.
  Dump to `.tmp` neighbor then `os.replace`.
- **Migrator marker on fresh installs.** Fresh machines with no
  `~/kings-automation` or `~/vn-automation` dirs never stamped a
  marker, so every launch rescanned the legacy paths for nothing.
- **Commentator-decode breadcrumb + ShortItem.id uniqueness.**
  Malformed commentator payloads silently resolved to nil and the next
  run's description went out without credits — now NSLogs on catch.
  `ShortItem.id` was `sourceFile` alone and clashed in SwiftUI
  `ForEach` when two runs had identically-named sources; now composes
  `runId/sourceFile`.

### Pipeline correctness

- **`pipeline.py` hardening (both KR and VN).** Drop
  `/opt/homebrew/bin:` PATH prepend so teammate machines can't pull in
  a diverged Homebrew ffmpeg; `sys.stdout.reconfigure(line_buffering=True)`
  so running pipelines don't look frozen behind block buffering;
  UTF-8 decode with `errors='replace'` so non-UTF-8 ffmpeg/Gemini output
  no longer propagates as a pipeline error with no message; review-gate
  poll 5s → 1s with a 24h safety cap so orphaned pipelines don't sit in
  /tmp forever.
- **`resume()` no longer drops flags.** The resume path reimplemented
  the argument builder inline and silently dropped `--language`,
  `--commentator-names/flags`, `--clone-from`,
  `--use-shared-thumbnail`, `--no-cleanup`, `--download-threads`,
  `--drive-link/--local`, and `--parent-analysis`. Resumed Tournament
  Highlights runs lost their brand-channel binding; resumed DE/CZ
  clones forgot they were clones. Now reuses the single `buildArguments`
  helper.
- **Setup detection is OAuth-aware.** `needsSetup()` hardcoded
  `youtube_oauth.json` against a two-client list, so v1.0.7+ Tournament
  Highlights users with `youtube_oauth_en.json` / `youtube_oauth_de.json`
  kept getting kicked back into the wizard on every launch. Now
  iterates `ClientConfigStore.clientsSnapshot` and accepts any
  `youtube_oauth*.json` as "set up."
- **Metadata decoder tolerates partial payloads.** Translator-produced
  `metadata.json` can ship without `title_options`; the synthesized
  decoder required it and failed the whole decode, so the review gate
  showed "no metadata" instead of the partial payload. Custom
  `init(from:)` with `.decodeIfPresent` + defaults.
- **Highlight thumbnail filenames UUID-tokened.** `Int(Date().timeIntervalSince1970)`
  has 1s resolution; rapid double-click Regenerate clobbered the prior
  render.
- **AppSupportMigrator logs via NSLog.** `print()` only shows up when
  running from Xcode — teammates' migration failures now land in
  Console.app, matching OAuthConfigMigrator.

### UI polish

- **Primary CTAs unified on `PrimaryButton`** (lime doctrine).
  `.borderedProminent + .tint(vm.theme.primary)` resolved to CLIENT
  gold/red-orange on Launch Pipeline / Approve & Push / Launch Clone,
  making them quieter than the lime "Start New Run" that spawned them.
  Swapped across NewRunView, CloneRunSheet, ReviewGateView,
  SettingsView (Save), and RecoveryPanel's primary suggested action.
  Return-key shortcut preserved.
- **Completion date on done runs** (no more "368h 37m" /
  "498h 43m"). `durationString` included idle windows; completed runs
  now show a localized "Apr 16" via `completedDateString`. Legacy
  records without `completedAt` fall back to a plain "Done"
  instead of a misleading wall-clock label. Active and error runs
  keep the live duration timer.
- **`SelectableChip` component extracted.**
  `NewRunView.commentatorChip` and `CloneRunSheet.commentatorChip`
  were copy-paste; unified into `Components/Input/SelectableChip` with
  tint supplied per caller so client identity still reads on
  selection.
- **Spacing & Typography token migration across sheets.** NewRunView,
  NewRunStandardForm, CloneRunSheet, ReviewGateView, RecoveryPanel,
  PipelineDetailView. Raw pixel paddings and SwiftUI semantic font
  keywords (`.title3`, `.headline`, `.callout`, etc.) replaced with
  `Spacing.*` / `Radius.*` / `Typography.*` so the same "section
  header" no longer renders at 14pt in one file and 20pt in the next.
- **Form hints split neutral vs warn.** Config-completion hints used
  orange everywhere ("Fill in episode…" read as a warning). Neutral
  hints now show `info.circle` + `theme.text.tertiary`; actual
  warnings (token missing, channel not authenticated) keep
  `exclamationmark.triangle.fill` + `theme.state.review`.
- **`theme.state.ai` token for LLM refinement surfaces.** ReviewGate
  used raw SwiftUI `.purple` for "Claude Suggestions" / "Gemini
  Suggestions" — now a dedicated muted-violet semantic token that sits
  calmly on ink0 without claiming the brand-lime LIVE slot.
- **RecoveryPanel tokenized.** Reds → `theme.state.failed`, tint map
  → `theme.state.*` / `theme.text.*` across the full recovery
  suggestion flow.
- **Sidebar polish.** PROJECTS header lost its stub "+" (fired an
  empty closure; "Phase 3" flow hadn't landed). Env-warning banner's
  "Fix" button replaced with a tokenized capsule pill in warn tint,
  matching the banner's own review-color wash.

## Under the hood

- **Release wall-clock cut ~3×.** `DELTA_COUNT` 5 → 2 (fewer bsdiff
  passes, smaller cache prime), `generate_appcast --delta-compression lzfse`
  (3–4× faster than lzma with a ~10% size penalty; Sparkle 2.6+
  decompresses natively), `ARCHS=arm64` pinned in `project.yml`. All
  shipped clients run Sparkle 2.6+. Users more than 2 versions behind
  fall back to the full zip.
- **Bundle prune ~170 MB pre-codesign.** Conservative list of
  runtime-unneeded artifacts (`__pycache__`, `*.dist-info`,
  `torch/include`, `ensurepip`, `idlelib`) stripped before ad-hoc
  signing. Flow-through: smaller ditto zip, faster codesign,
  proportionally smaller bsdiff scans.

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs auto-update via Sparkle.
