# 1.0.14

## Fixes

- **Sparkle updates are small again.** Restored 5-version delta coverage so
  updates download in MB range instead of falling back to the full 1.2 GB
  zip. v1.0.11's cached delta source was corrupt and silently dropped from
  v1.0.12 + v1.0.13 — the release script now validates cache integrity
  before reuse and hard-fails if any expected delta is missing.
- **OAuth sign-in no longer port-conflicts.** Switched the local callback
  to ephemeral port allocation (`port=0`). The port-in-use class that
  triggered the v1.0.10 emergency patch is now structurally impossible.
- **Pipeline phases time out instead of hanging.** New per-phase subprocess
  timeouts with conservative defaults (DOWNLOAD 30m, COMPRESS 90m,
  UPLOAD 60m, ANALYZE 30m, TRANSLATE 10m, METADATA 10m, PUSH/THUMBNAIL 5m).
  Override per-phase via `VVS_PHASE_TIMEOUT_<PHASE>` env; disable entirely
  with `VVS_PHASE_TIMEOUTS_DISABLED=1`. SIGTERM goes to the whole process
  group via `os.setsid`.
- **Recovery panel hint is correct now.** No longer hard-codes
  `produkce@verticalvisuals.cz` — speaks generically about "the Google
  account that owns this channel" so the hint matches whichever identity
  actually owns the affected channel.
- **Setup wizard no longer blocks on missing pipeline venvs.** Clean-
  install teammates can complete setup with just the Gemini key; venv
  presence is advisory.

## Refactors

- **Stories: SwiftUI ImageRenderer is the only renderer.** Story preview
  and export now share the same view tree (`StoryCompositionView`),
  eliminating any drift between what you see in the editor and what gets
  exported. The Python story script (`promo_story.py`, 997 lines) is
  deleted. Background gradient matches the old Python look — per-row
  exponential alpha with side glow.
- **Fonts bundled.** Montserrat (regular + italic) and Dela Gothic One
  ship inside the `.app` and register at launch via `FontRegistrar`.
  Teammate clean installs no longer fall back to the system font.
- **Diagnostics tab tokenized.** Settings → Diagnostics now follows the
  v1.0.9 doctrine — `PrimaryButton`, `Typography` tokens, `Spacing`
  tokens.
- **Pipeline call sites unified on `PipelineRun`.** 13 legacy
  `PipelineService(runId:isVN:)` call sites migrated to `(run:)`;
  6 legacy overloads deleted.

## Tests

- `TelemetryRedactor` test target wired into the Xcode project — 20/20
  pass under `xcodebuild test`.

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs on v1.0.9+ auto-update via Sparkle in
single-MB delta mode. Anything older falls back to a one-time full zip
and rejoins the delta train from v1.0.14 onward.
