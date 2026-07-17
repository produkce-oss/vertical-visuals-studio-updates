# 2.2.0

## Improvements

- Notion video uploads now resume from the last confirmed part after a connection drop, with live progress and clear recovery actions.
- Google sign-in automatically reserves a free callback port, removing the recurring "Address already in use" failure.
- Tracker project refreshes are coalesced to prevent duplicate request bursts and rate limits.
- Gemini safety timeouts now show the correct analysis checkpoint and recovery action.

## Reliability

- Notion API upgraded to 2026-03-11; task content is created atomically to avoid blank duplicates.
- Upload checkpoints are stored privately, and configuration failures no longer waste time on automatic retries.
- Teammates see plain-language errors while redacted technical evidence remains available in telemetry.

## Install notes

Existing installs update automatically through Sparkle. New installs may need right-click -> Open on first launch.
