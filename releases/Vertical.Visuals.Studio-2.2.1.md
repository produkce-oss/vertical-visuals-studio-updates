# 2.2.1

## Reliability upgrade

- Adds live Gemini, Notion, and YouTube health checks to the in-app Doctor, with clear actions for non-technical teammates.
- Adds fleet heartbeats and service-health telemetry so silent failures and outdated installs are visible sooner.
- Adds a release-blocking end-to-end sandbox canary that verifies compression, Gemini analysis, metadata, Notion delivery, and private YouTube upload before shipping.
- Makes Notion video delivery resumable and preserves the correct video MIME type across large multipart uploads.
- Narrows canary YouTube authentication to YouTube-only permissions and verifies the exact sandbox channel before any upload.

## Install notes

Existing installs receive this update automatically through Sparkle. No setup changes are required for normal production workflows.
