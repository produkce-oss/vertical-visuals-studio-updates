# 1.0.10 — OAuth sign-in diagnostics

**Shipping this release:** a small patch that turns the "Sign In spinner
runs 120 seconds and silently gives up" failure mode into an actionable
error message. No behavior change on the happy path — only better
diagnostics when something goes wrong.

## What's fixed

- **Pre-flight port probe.** Before spawning the Python OAuth helper,
  VVS now probes `127.0.0.1:8090` with a non-blocking `bind()`. If the
  port is already held (stale OAuth flow from a previous session, any
  other local dev server), sign-in fails up-front with a clear error
  pointing you at `lsof -iTCP:8090` instead of silently timing out
  after two minutes.
- **Stderr capture on `youtube_auth.py`.** Python's stderr is now drained
  asynchronously and, on non-zero exit, dumped to Console.app via
  `NSLog` with the token filename and exit code. Whatever Python dies
  of — missing dependency, import error, failed browser launch, API
  scope refusal — now leaves a breadcrumb you can grep for.
- **Error banner in Settings → Accounts.** A tokenized warning banner
  appears above the YouTube sections whenever a Sign In attempt fails,
  carrying the thrown error's `localizedDescription`. No more watching
  the spinner stop with no explanation — the row now tells you what
  happened and suggests a next step. Dismissable; cleared on next
  retry.

## Why this matters

Teammate onboarding on v1.0.7–1.0.9 had a rough edge: if the Google
OAuth flow failed for any reason (port conflict, stale consent cache,
"Service unavailable" from a legacy brand account, or anything
Python-side), the Sign In button just spun until its 120s polling
timeout, then returned to idle. A fresh teammate with no context had
no way to tell what was wrong.

From 1.0.10 forward, the user sees the actual problem and can act on
it (or copy-paste it into a support thread) instead of staring at a
dead spinner.

## Under the hood

- New `EnvironmentError.oauthPortInUse(port:)` case with a
  `localizedDescription` that names the port and a specific
  troubleshooting command.
- Centralized `EnvironmentValidator.oauthCallbackPort: UInt16 = 8090`
  constant so the pre-flight check and any future port-conflict
  messaging stay in sync.
- Lock-protected `OAuthStderrBuffer` mirrors the `DataBuffer` pattern
  from `SubprocessRunner` — kept local so that file's buffer stays
  `private`. `readabilityHandler` closures fire on arbitrary GCD
  queues while `terminationHandler` runs on another; the lock
  prevents torn reads of the accumulated stderr.

## Known limitation

The Python helper's `run_local_server(port=8090, ...)` still hard-codes
the port. A one-line switch to `port=0` (ephemeral port) would
eliminate the port-conflict class of failure entirely, but requires
first confirming the OAuth client's registered redirect URIs allow
`http://localhost` at any port (Google's Desktop-client defaults
usually do). Deferred to a follow-up once verified.

## Install notes

Still ad-hoc signed — right-click → Open on first launch to bypass
Gatekeeper. Existing installs auto-update via Sparkle within ~24h, or
force-update via Settings → About → *Check for updates*.
