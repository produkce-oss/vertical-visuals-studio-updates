# 1.0.15

## Fixes

- **King's Resort sign-in is back.** A teammate hit `ImportError: google_auth_oauthlib` 10 times trying to OAuth into KR (legacy + EN + DE channels). Root cause: a stale `pythonPath` in `clients.json`, either migrated from a pre-bundle dev venv or pinned to an old `.app` location Sparkle had moved to Trash. `resolvedPythonPath` now always prefers the bundled `.app`'s Python 3.12 (which ships every dependency pre-installed) and treats the stored field as a dev-mode fallback only. Self-heals on next launch, no Settings action needed.

## New

- **Notion API token in Settings.** Notion-driven steps no longer require `~/.notion_key` on disk. Settings, Accounts, Notion API Token: paste once, get the same env-var injection treatment as the Gemini key.
- **MVO A/B/C title testing.** Long-form runs for Václav now generate 6 title candidates with distinct rhetorical roles. The Review Gate lets you pick up to 3 in click-order; A becomes the upload title, B + C are saved as alternates and surfaced in Pipeline Detail with one-click Copy buttons for YouTube's Test & Compare manual rotation.

## Diagnostics

- OAuth-failure logs in Console.app now name the resolved Python interpreter so future telemetry distinguishes a missing-dep error from a stale-path error at a glance.

## Install notes

Still ad-hoc signed, right-click then Open on first launch to bypass Gatekeeper. Existing installs auto-update via Sparkle.
