# 2.1.5

## Fixes

- Fixes Brunato Titles & Description runs timing out while sending large videos to Gemini.
- Metadata-only runs now create a much smaller analysis copy (up to 600 MB instead of roughly 1.9 GB), making uploads faster and more reliable.
- Retrying an older failed run automatically replaces its oversized cached analysis copy before contacting Gemini again.
- Extends the Gemini upload-and-analysis safety window from 30 minutes to two hours.
- Shows clearer upload status and a direct recovery action when Gemini genuinely takes too long.

## What to do after updating

Open the failed run and choose **Keep compressed, redo Gemini analysis**. VVS will automatically rebuild the old oversized analysis copy when necessary; the original local video is preserved.

## Install notes

Existing installs auto-update via Sparkle. You can force the update from **Settings → About → Check for updates**.
