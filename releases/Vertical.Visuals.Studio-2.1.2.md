# 2.1.2

## Fixes

- Fixed the remaining `PF-RESERVATION-RECONCILE` upgrade block when an old pipeline status file is missing, malformed, or incomplete.
- VVS now recognizes reboot-stale pre-2.1 history only after independently checking boot time, artifact activity, persisted process identity, and the live process table.
- Current or ambiguous pipelines remain protected, so recovery cannot clear storage held by active work.

## Install notes

Existing installs auto-update via Sparkle. To update immediately, open Settings → About → Check for updates.
