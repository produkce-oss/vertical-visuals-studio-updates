# 1.0.12 — Pipeline output survives app updates

**Shipping this release:** fixes a data-loss bug where pipeline runs
disappeared from the UI after every Sparkle auto-update on clean-install
teammates. Run artifacts (status, compressed video, Gemini analysis,
metadata, logs) now live in a stable location outside the `.app` bundle.

## What's fixed

- **Pipeline output no longer lives inside the `.app` bundle.** Before
  v1.0.12, `pipeline.py` hard-coded its output directory to
  `Path(__file__).parent / "output"`. On a clean teammate install,
  `__file__` resolved to inside `/Applications/Vertical Visuals Studio.app/Contents/Resources/pipeline/<client>/`,
  which Sparkle moves to Trash (along with every run's artifacts) every
  time it installs a new version. From v1.0.12, output lives at
  `~/Library/Application Support/VerticalVisualsStudio/output/<client>/<runId>/`
  — outside the bundle, stable across updates, user-writable.
- **Resume / Retry actually works post-upgrade.** Because the old output
  path got wiped on every update, the Retry-from-X buttons couldn't find
  any artifacts to resume from. Now that output persists, the existing
  resume-from-checkpoint machinery works reliably — stalled runs can pick
  up from Compress / Gemini / Metadata / Review instead of restarting
  from Download.
- **Legacy-location fallback during upgrade.** A run that started on
  v1.0.11 keeps resolving its artifacts from the old bundled location
  even after you update to v1.0.12 — so an upgrade mid-flow doesn't
  strand in-flight runs.

## Why this matters

Teammate Lukas ran a Brunato Talks episode on v1.0.10, reached the
private-draft upload + Gemini analysis, then force-updated to a newer
VVS. The run "disappeared from the UI" — actually, its output tree was
moved to his Trash with the old `.app`. The history.json still had the
run recorded with a `metadataPath` pointing at a no-longer-existing
file inside the old bundle.

With v1.0.12 installed, that can't happen. Every run artifact is stable
across updates. Past runs are kept in the same directory forever unless
you explicitly clear them.

## Recovery for prior runs

If you've lost runs to this on v1.0.6–v1.0.11, check your Trash — the
previous `.app` versions still contain the output tree. Copy the
relevant `<runId>` dir out of the old bundle's `Contents/Resources/pipeline/<client>/output/`
into `~/Library/Application Support/VerticalVisualsStudio/output/<client>/`
and the run should re-appear in the UI.

## Under the hood

- **`ClientConfig.resolvedOutputDirectory`** (new): per-client URL under
  `~/Library/Application Support/VerticalVisualsStudio/output/<clientId>/`.
- **`ClientConfig.outputDirectory(forRunId:)`** (new helper): composes
  the per-run full path. Replaces the 18+ scattered
  `"\(resolvedPipelineDirectory)/output/\(runId)"` call sites so a
  future move is one edit, not fifteen.
- **`ProcessEnvironment.bundled`** now creates the output dir on demand
  and exports `VVS_OUTPUT_DIR` alongside `VVS_CONFIG_DIR` and
  `VVS_MODELS_DIR`.
- **`pipeline.py` (KR + VN)**:
  `OUTPUT_DIR = Path(os.environ.get("VVS_OUTPUT_DIR") or (Path(__file__).parent / "output"))`.
  The env-var wins when VVS sets it; the old path remains the fallback
  for standalone CLI runs from a dev checkout.
- Every Swift site that reads from the output tree (resume-point probe,
  stall detector, shorts flows, metadata loader, captions history,
  parent-analysis lookup for clones) now reads from the new location
  with a legacy fallback for pre-v1.0.12 in-flight runs.

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs auto-update via Sparkle within ~24h, or
force-update via Settings → About → *Check for updates*.
