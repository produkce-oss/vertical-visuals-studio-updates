# 2.1.1

## Fixes

- Fixed `PF-RESERVATION-RECONCILE` blocking every new pipeline after upgrading from an older VVS version.
- VVS now safely clears a legacy run only when both its recorded process and detached process group are confirmed gone.
- Live or ambiguous earlier pipelines remain protected and continue to block conflicting launches.

## Install notes

Existing installs auto-update via Sparkle. To update immediately, open Settings → About → Check for updates.
