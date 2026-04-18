First versioned build after the self-contained .app refactor. Everything
the pipelines need (ffmpeg, Python 3.12.13, KR + VN pipelines, ML models,
thumbnail Flask server) ships inside the bundle.

This build is ad-hoc signed; on first launch right-click -> Open to
bypass Gatekeeper. Developer ID + notarization arrives in the next
release, at which point updates will install silently.
