# Hard Constraints

Non-negotiable rules that define Nudge's identity. If a feature violates any of these, it is rejected.

1. **No clipboard content storage** -- Nudge never reads, logs, caches, or persists clipboard contents. It observes metadata (change count, timestamps) only.

2. **No network access** -- Nudge makes zero outbound connections. No telemetry, no update checks, no analytics, no cloud sync.

3. **No process inspection** -- Nudge does not inspect, enumerate, or probe other processes. It uses only the frontmost-app API provided by NSWorkspace.

4. **No blocking** -- Nudge never prevents or delays clipboard operations. The clipboard always works normally.

5. **No certainty claims** -- Nudge never says "X read your clipboard." It says "unexpected clipboard activity while X was frontmost." The distinction is critical and must be preserved in all UI and documentation.

6. **No persistent logging** -- Event history is memory-only and capped. When Nudge quits, history is gone.

7. **No external dependencies** -- Apple frameworks only. No third-party libraries, no SPM dependencies, no pods, no Carthage.

8. **Rate limiting is mandatory** -- Every alert path must be rate-limited. There is no code path where Nudge can produce unbounded alerts.
