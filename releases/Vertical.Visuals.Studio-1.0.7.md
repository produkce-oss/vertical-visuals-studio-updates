# 1.0.7 — Tournament Highlights pipeline

**Shipping this release:** end-to-end Tournament Highlights workflow for
King's Resort that covers an EN highlight from Gemini analysis through
auto-translated DE/CZ uploads to separate brand channels. ~$0.001 per
language clone vs ~$0.58 for a fresh Gemini Pro video analysis.

## What's new

- **Tournament Highlights format** in the New Run form. Picks up the
  king's-events pipeline with a punchy + factual prompt calibrated
  against a real WSOPC Main Event episode.
- **Per-language YouTube brand channels.** Sign in separately to King's
  Resort English, King's Resort German, and (when ready) Czech from
  **Settings → Accounts**. Teammates can join and sign in on their
  own — no more single shared token.
- **Language-clone workflow.** On a completed EN kings-events run,
  click *Clone for Language* to spawn a DE or CZ upload that reuses
  the approved EN metadata via Gemini Flash translation (auto-approved
  when validation passes). Share the same thumbnail across all three
  channels or generate a new one per language.
- **Multi-commentator attribution** — up to N commentators per episode
  with flag emoji, rendered as "Commentary by A 🇬🇧 & B 🇨🇿" in the
  description. CZ booths routinely have two commentators; this handles
  it natively.
- **Settings ⇒ Accounts commentators section** — build up a freeform
  roster of voices per client over time.

## Under the hood

- Existing installs upgrade cleanly: migrator backfills `kings-events`
  format, `youtubeChannels`, and handles legacy single `commentatorId`
  field.
- YouTube token filename is now language-routable via
  `VVS_TOKEN_FILENAME` env var in Python. KS/BT unchanged.
- New scripts: `analyze_highlight.py` (Gemini Pro Files API),
  `translate_metadata.py` (Gemini Flash preserving schema + brand terms
  + prize amounts).
- Thumbnail generator gains a CZ locale entry (falls back to EN
  strings; brand terms untranslated).
