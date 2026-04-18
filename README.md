# vertical-visuals-studio-updates

Sparkle appcast + signed update archives for the private
[Vertical Visuals Studio](https://github.com/produkce-oss/vertical-visuals-studio) macOS app.

- `appcast.xml` — the feed Sparkle polls (also served at
  `https://produkce-oss.github.io/vertical-visuals-studio-updates/appcast.xml`
  via GitHub Pages).
- `releases/` — zipped `.app` payloads referenced by the appcast.
  Large files; consider using GitHub Releases for actual distribution.

Release workflow is in the main app repo at `docs/RELEASING.md`.
