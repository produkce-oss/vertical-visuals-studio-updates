# Vertical Visuals Studio 2.0.0

The team release. VVS grew from Filip's pipeline driver into the team's production backbone: safe parallel use, self-service problem fixing, shared visibility, and runs that survive restarts, reboots, and multi-day reviews.

## New

- **Run queue.** Launches go through a queue with a concurrency cap (default 2, set 1-4 in Settings → Pipelines). Extra runs show as "Queued" with their position; "Start Now" bypasses the cap when you really mean it. No more three simultaneous 17GB downloads melting one Mac.
- **Who ran what.** Runs are stamped with the teammate who launched them (from your tracker sign-in) and show an owner chip everywhere; filter runs by Mine / Everyone. Telemetry carries the name too, so a failing pipeline is attributable at a glance.
- **Doctor.** Settings → Doctor replaces the read-only Environment tab. Every failed check has a Fix button (re-auth, paste a key), "Run Full Checkup" gives one health verdict, and "Copy Diagnostic Bundle" puts a redacted report on your clipboard for chat. Failed runs with environment causes deep-link straight to the right Doctor row.
- **Team notifications.** Run completed / failed / stalled / awaiting-review can post to a Discord channel (Settings → Pipelines → Team Webhook: paste a channel webhook URL, pick events, Send Test). Generic JSON mode exists for other receivers. Works independently of local notification settings.
- **Add a client without a release.** Settings → Advanced → Add Client: duplicate an existing client as template; VVS seeds its pipeline folder and validates everything per-client in Doctor. (Pipelines for new clients live in Application Support and follow the documented contract in the seeded README.)

## Changed

- **Reviews now park instead of waiting.** When a run reaches metadata review, the pipeline saves its state and exits cleanly - no more background process burning a slot for hours and no 24h deadline. Approving relaunches it exactly at the push step. Reviews survive app quits, reboots, and weekends.
- **Run state survives reboots.** Live run status moved from /tmp to the same per-run folder as its artifacts. Relaunching the app mid-run re-adopts live pipelines instead of falsely marking them crashed; finished-while-closed runs get their real result (and still notify the team, marked "finished while app was closed").
- **Re-running an episode can no longer show the previous run's result** - stale state is scrubbed at launch.

## Fixed (highlights of 40+ fixes from the June audit)

- Tracker edits made offline are re-sent automatically instead of silently reverting.
- The post-publish metadata editor and "Update on YouTube" work again for runs made after v1.0.12.
- VN runs: reliable Stop (process tree actually terminates), live download progress, upload retries on network blips, resume actually works, crash visibility.
- Successful runs no longer randomly display as failed due to unknown pipeline phases (and a contract test now makes that class of bug impossible to reintroduce).
- Language-clone runs (DE/CZ Tournament Highlights) track correctly and no longer collide with their parent run.
- OAuth/credential hygiene: tighter scopes, atomic 0600 token writes, API keys out of URLs.

## Under the hood

- Both client pipelines now run on a single shared `pipeline_core` package - reliability fixes land once, for everyone, forever.
- Everything client-specific (prefixes, validation, pipeline trees) derives from client config; the hardcoded two-client era is over.
- Test suite grew from 40 to 306 cases, covering the orchestration core for the first time.

## Updating

- Update arrives via the normal in-app Sparkle flow. Until the Developer ID certificate lands, first launch after install is still right-click → Open.
- After updating mid-run: the app will re-adopt your live runs on first launch - this is the new normal, not a crash.
- To get Discord notifications, any team member can set the webhook once in Settings; it ships off by default.
