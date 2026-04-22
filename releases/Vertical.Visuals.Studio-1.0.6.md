# 1.0.6

First release with Sparkle binary-delta updates — from 1.0.5 onward,
teammates only download what actually changed (a few hundred KB per
patch), not the full 1.27 GB bundle.

## New

- **Tournament Highlights — Overlays card.** Add arbitrary foreground
  images (player cutouts, trophies, sponsor badges) on top of the AI
  background. Drop an image in the preview editor's Overlays card,
  each overlay gets its own drag position + scale. Combines cleanly
  with the existing KR + festival-logo slots.

## Fixes

- **Thumbnail Save button.** "Save" on a generated thumbnail variant
  used to silently fail for Tournament Highlights (the SwiftUI-rendered
  export lives in a different directory than the legacy Python output
  path the Save handler looked at). Now the Save button always opens a
  location picker, copies the file, and reveals it in Finder so you
  always know where it went.

- **Tournament Highlights — sharp AI backgrounds.** The Gemini-generated
  background used to ship permanently soft (8px Python Gaussian blur
  baked in), which meant the preview's blur slider at 0 was adding
  nothing on top of an already-blurred source. The source now comes
  back sharp and the preview slider is the sole blur authority — dial
  in exactly the softness you want, or leave it at 0 for a crisp
  background.

## Under the hood

- **Sparkle binary deltas.** Every release script run now generates a
  `.delta` patch against the prior 5 versions and lists them in the
  appcast. Sparkle clients pick the matching delta or fall back to
  the full zip. For v1.0.5 → v1.0.6 the delta is 340 KB vs. the 1.27 GB
  full zip — 3,700× smaller download.

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs auto-update via Sparkle (340 KB download
if you're on v1.0.5).
