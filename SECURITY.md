# Security Policy

## Scope

Nudge is a local macOS menu bar utility. It has no network access, no remote API, and no server component.

## What Nudge accesses

- `NSPasteboard.general` -- read-only polling for change count
- `NSWorkspace.shared` -- frontmost application detection
- `~/.config/nudge/config.json` -- user configuration (read/write)
- Screen overlay -- for popup display

## What Nudge does not access

- Clipboard contents (never read, never stored)
- Keychain or credentials
- File system beyond its config file
- Network (no outbound connections, no telemetry)
- Other processes (no process inspection, no IPC)

## Threat model

Nudge is an awareness tool. It does not provide security guarantees.

- It cannot detect all clipboard access (macOS API limitation)
- It cannot prevent clipboard access
- It relies on frontmost-app heuristics, which can be spoofed
- A determined attacker can bypass Nudge trivially

Nudge reduces the risk of *accidental* or *unnoticed* clipboard access by non-malicious software. It is not designed to resist adversarial attack.

## Reporting vulnerabilities

If you discover a vulnerability, please report it via [GitHub Security Advisories](https://github.com/ppiankov/nudge/security/advisories).

Do not post sensitive exploit details in public issues.
