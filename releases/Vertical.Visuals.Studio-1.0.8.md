# 1.0.8 — Error visibility + migration repair

**Shipping this release:** two small but load-bearing fixes. Pipeline
failures that happen before the first status-file write now surface in
the Failed sidebar tab instead of getting stranded at phase=INIT. And
the commentators field that should have been backfilled on the v1.0.7
upgrade now migrates correctly, so Settings → Accounts renders a real
list instead of an empty nil state.

## What's fixed

- **Pipeline errors before init are now visible.** When `pipeline.py`
  exited on an argparse problem (missing `--language`, bad `--format`,
  invalid episode number, any early exception), Swift never saw a
  `phase: "ERROR"` and the run stayed stuck at `INIT` — invisible in
  the Failed tab, no way to retry or clean up. A `StatusAwareParser`
  now emits a real ERROR status file before the process exits, keyed
  to the correct run_id so the Mac app picks it up.
- **Commentators migration.** Upgraded installs from v1.0.6 / early
  v1.0.7 had `commentators` missing from `clients.json`, which left
  Settings → Accounts with a nil collection instead of an empty list.
  `migrateUpgradedClients()` now backfills `commentators: []` on
  launch, alongside the existing `youtube_channels` backfill.

## Under the hood

- `build_run_id()` extracted to a shared helper so the pre-parser and
  the main pipeline derive run IDs identically.
- Pre-parser uses `parse_known_args()` to extract run-id ingredients
  without failing on missing or unknown flags; falls back to
  `unknown_<pid>` when nothing can be derived.
- Outer try/except in `main()` catches pre-init exceptions in the
  narrow window between argparse success and the `PipelineStatus`
  constructor inside `run_pipeline()`.
- Migration gate uses `== nil` (not `?.isEmpty ?? true`) so an
  intentionally-empty commentator list set from Settings is preserved
  across launches.
