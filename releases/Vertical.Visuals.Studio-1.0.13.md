# 1.0.13 — Opt-in error reporting

**Shipping this release:** when a pipeline fails, the app crashes, or a
teammate hits an OAuth or setup error, the event is now redacted and
forwarded to a dedicated Convex backend so Filip can see and fix it in
the next release instead of waiting for a Slack mention.

## What's new

- **Settings → Diagnostics tab.** New section with an opt-in toggle
  ("Send error reports to Filip") — default ON per agreement (internal
  tool, 3–5 teammates). Helper text explains what's collected, an
  anonymous install-ID row is copy-able for Slack diagnostics, and a
  "Send a test report" button exercises the pipeline end-to-end (Sent ✓
  / Queued (offline) badge inline).
- **Five capture points wired.** Pipeline phase = ERROR transitions
  (with redacted log-tail read from `/tmp/<prefix>_<run_id>.log`), macOS
  `.ips` crash reports (exception type + signal + top 20 stack frames),
  OAuth sign-in failures (main + per-language channels), setup-wizard
  fatals, and a generic classified-error catchall.
- **Secrets never leave the Mac.** 13 ordered regex passes strip Google
  OAuth tokens (`ya29.*`), API keys (`AIza*` / `sk-*` / `AKIA*`), Bearer
  headers, JWTs, Google client secrets (`GOCSPX-*`) and refresh tokens,
  email addresses, Drive file IDs (both `/d/<id>` and `?id=<id>`),
  YouTube video IDs, and `/Users/<name>/` home paths. Redaction happens
  at enqueue — the on-disk NDJSON queue is safe to inspect.
- **Offline-tolerant.** Events queue to
  `~/Library/Application Support/VerticalVisualsStudio/telemetry/queue.ndjson`,
  flush on launch + every 5 min while foregrounded + after each new
  record. Queue caps at 500 lines (drops oldest); hard rejects go to
  `queue.rejected.ndjson` so the main queue never stalls.

## Why this matters

Bugs on teammate Macs used to stay silent for days until someone
mentioned them in Slack. With 1.0.13, Filip sees each failure within
minutes in the Convex dashboard — signature-grouped ("this error hit 5
installs over 3 versions") so fix-once-apply-everywhere is the default
workflow. The loop closes: error lands → fix in next release → ship via
Sparkle → teammates update silently → resolved badge flips green.

## Backend (for the curious)

- Dedicated Convex deployment `outstanding-malamute-460` in the
  `produkce-9dbc9` team, project `vvs-telemetry`. Isolated from other
  infra for clean billing + retention.
- POST `/vvs-telemetry` with `X-VVS-Telemetry-Key` header, 100
  events/install/day rate limit, SHA-256 signature hashing for group-by
  queries.
- Admin via the built-in Convex dashboard — no bespoke Next.js UI; the
  Functions tab runs `list`, `groupBySignature`, `markResolved`, `reopen`
  directly.

## Upgrade

Sparkle auto-prompts. Diagnostics tab lives under Settings → ladybug
icon. If you'd rather not share, flip the toggle off — events still
accumulate locally so a later re-enable ships the backlog, but nothing
goes out until you opt back in.
