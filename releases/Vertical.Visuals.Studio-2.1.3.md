# 2.1.3

## Fixes

- Fixed `PF-RESERVATION-RECONCILE` remaining after an ordinary VVS update when the stale pipeline was created during the current Mac boot.
- Recovery now uses a five-minute idle window plus run-specific process evidence, so teammates no longer need to restart macOS.
- Unrelated VVS Python helpers no longer look like an active pipeline, while live upload, Notion, thumbnail, and download workers still keep the safety gate closed.

## Install notes

Existing installs auto-update via Sparkle. After updating, reopen the blocked run and click **Check & Retry**.
