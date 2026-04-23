# 1.0.11 — Teammate onboarding: bundled OAuth credentials

**Shipping this release:** a fresh install of VVS now signs in to
YouTube without any pre-setup. Before today, teammates installing for
the first time hit a silent-failure dead end — OAuth helper crashed on
missing `client_secret.json`, Settings row spun for two minutes, no
signal. From 1.0.11, the credential ships with the app and auto-seeds
on first launch.

Also closes two loose ends from v1.0.10: stdout is now captured
alongside stderr (Python prints user-facing errors to stdout, which
v1.0.10 missed), and post-launch subprocess failures surface in the
Settings banner instead of timing out silently.

## What's fixed

- **Bundled `client_secret.json` auto-seeding.** The credential for
  each client (`kings-resort`, `vaclav-nedvidek`) now ships inside
  the `.app` bundle at `Resources/config/<client>/client_secret.json`.
  On first launch, `OAuthConfigMigrator.seedClientSecretsFromBundle`
  copies it into the user's `~/Library/Application Support/...`
  config dir if absent. Idempotent — never overwrites an existing
  secret, so a teammate who replaces the bundled credential with a
  project-specific one keeps their override.
- **stdout capture.** v1.0.10 only drained `stderr`. Python's OAuth
  helper uses `print()` for user-facing errors (most notably
  "Client secret not found at..." when the config dir is empty) —
  those writes go to stdout and were invisible to the app. We now
  drain both streams into a single combined buffer and NSLog the
  full combined output on non-zero exit.
- **Subprocess exit → UI banner.** Post-launch Python failures
  (missing config, import errors, browser-launch failures) now
  throw a new `EnvironmentError.oauthSubprocessFailed` carrying the
  captured stdout/stderr. The Settings warning banner renders it
  (truncated to 600 chars; full text still lands in Console.app)
  within seconds instead of letting the user wait out the 120 s
  polling timeout. Covers the gap in v1.0.10, which only surfaced
  *pre-launch* failures (port conflicts) via the banner.

## Why this matters

Onboarding a new teammate used to be a multi-step hand-off:

1. Filip runs the one-shot installer URL.
2. Filip realizes the app needs `client_secret.json` on that Mac.
3. Filip AirDrops the file from his own Application Support dir.
4. Teammate creates the config directory manually.
5. Teammate drags the file into place.
6. Then sign-in works.

With v1.0.11 installed, a fresh teammate runs the installer, launches
the app, walks the Setup Wizard (Gemini API key + per-channel OAuth
sign-ins), and is done. No shared credentials, no Finder gymnastics,
no invisible spinner failures.

## Under the hood

- New `OAuthLaunchHandle` struct exposed by `launchYouTubeAuth` —
  holds the spawned `Process` + captured-output buffer so the poll
  loop can detect early subprocess exit.
- `waitForOAuthToken` accepts the handle (optional for backward
  compat) and checks `process.isRunning` each iteration. On early
  exit with non-zero status, throws `.oauthSubprocessFailed` with
  the captured text.
- `OAuthStderrBuffer` renamed to `OAuthOutputBuffer`; drain closure
  marked `@Sendable` so it can cross the GCD queue boundary where
  `readabilityHandler` fires.
- Gitignore carved out for `Resources/config/*/client_secret.json`
  — documented in-place with the security rationale (Desktop-app
  OAuth secrets are treated as public by Google, so bundling is
  safe and necessary for zero-friction onboarding).

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs auto-update via Sparkle within ~24h, or
force-update via Settings → About → *Check for updates*.

For a brand-new teammate, the full install experience is now:

```
curl -fsSL https://raw.githubusercontent.com/produkce-oss/vertical-visuals-studio-updates/main/install-vvs.command | bash
```

…then launch, walk the Setup Wizard, done.
