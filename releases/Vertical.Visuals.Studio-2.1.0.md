# 2.1.0

VVS 2.1 makes pipeline starts safer and brings OpenAI image generation into the Tournament Highlights thumbnail workflow.

## New

- OpenAI is now the default thumbnail image provider, with the API key stored securely in macOS Keychain.
- Generate two economical background drafts, compare them in VVS, and choose the version used for the final thumbnail.
- Gemini remains available as an explicit fallback in Settings.
- Pipeline preflight now checks the source, the real download/output volumes, and available disk space before work starts.
- Readiness cards explain what VVS is checking, how much space is needed and available, and what a teammate must do when launch is blocked.

## Reliability

- Disk reservations prevent simultaneous runs from silently overcommitting the same drive.
- Failed, cancelled, resumed, and retried runs preserve their ownership and history more safely.
- Thumbnail files and generation history stay in persistent Application Support storage across app updates.
- Drive metadata validation, subprocess cancellation, timeouts, output limits, and launch failure reporting are hardened.
- Tracker updates are serialized per task so a slower stale response cannot overwrite the latest teammate action.
- Release publishing now waits for the exact source commit to pass CI before any update assets become public.

## Install notes

Existing installs update automatically through Sparkle. OpenAI thumbnail generation requires an OpenAI API key in Settings and uses the OpenAI API account associated with that key.

The app remains ad-hoc signed. On a first installation, right-click the app and choose **Open** to pass Gatekeeper.
