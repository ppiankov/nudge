# Design Baseline

## Core idea

The clipboard is a shared, unaudited channel. Any process can read or write it. macOS provides no notification when clipboard access occurs. Users routinely place sensitive material (tokens, passwords, connection strings) on the clipboard with no awareness of what else might be watching.

Nudge exists at this boundary: the moment between clipboard change and user awareness.

## Design principles

1. **Awareness over prevention** -- Nudge tells you something happened. It does not stop it from happening. Prevention requires kernel-level control that macOS does not offer to userspace apps.

2. **Heuristic honesty** -- Nudge uses the best signals available (change count, frontmost app) and is explicit about what those signals cannot tell you. No certainty is ever claimed.

3. **Calm over loud** -- The default state is silence. Alerts are brief, soft, and rate-limited. If the user notices the alert more than the event, the alert is too loud.

4. **Local and stateless** -- No clipboard content is ever stored. No network access. No telemetry. State is ephemeral and memory-only. When Nudge quits, everything is forgotten.

## Success criteria

- User forgets Nudge is running
- Alert fires only when something genuinely unexpected happens
- User says "huh, interesting" not "oh no"
- No clipboard content is ever persisted anywhere

## Related boundaries

This project applies the same philosophy as other tools in the family:

- [PasteWatch](https://github.com/ppiankov/pastewatch) -- intervenes before sensitive data reaches AI interfaces
- [Chainwatch](https://github.com/ppiankov/chainwatch) -- intervenes before AI agents cross irreversible boundaries
- [RootOps](https://github.com/ppiankov/rootops) -- philosophy of preventing irreversible actions upstream

*Principiis obsta.*
