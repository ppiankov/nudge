# nudge

Quietly alerts you when an unexpected app accesses your clipboard on macOS.

*Principiis obsta* -- resist the beginnings.

## Philosophy

The clipboard is global, implicit, unaudited, and heavily abused. Electron apps, browser extensions, helper utilities -- any process can read your clipboard without your knowledge. Nudge makes that invisible access visible.

Nudge is **awareness, not prevention**. It does not block clipboard access. It does not guarantee detection. It tells you when something unexpected appears to have happened, so you can decide what to do.

If Nudge is silent, things are normal. If Nudge speaks, pay attention.

## What it does

- polls the macOS pasteboard for access changes
- tracks which app is frontmost when clipboard activity occurs
- maintains an allowlist of expected apps (Terminal, VS Code, browsers)
- shows a soft, brief popup when a non-allowlisted app accesses the clipboard
- lives in the menu bar, stays out of the way

## What it does not do

- prevent or block clipboard access
- identify the exact process that read the clipboard (macOS does not expose this)
- store clipboard contents (ever)
- send data anywhere (no network access, no telemetry)
- use machine learning, heuristics, or probabilistic scoring
- provide security guarantees of any kind

## Detection model

Nudge uses a **heuristic, honest** approach:

1. Poll `NSPasteboard.general` at regular intervals
2. Track `changeCount` to detect clipboard mutations
3. Compare the frontmost app at time of change against the allowlist
4. If the frontmost app is not allowlisted, show a popup

This catches the common case: an unexpected app writing to or interacting with the clipboard while you are working in another app. It does not catch background reads by design -- macOS does not provide that visibility.

## Installation

### From source

```
git clone https://github.com/ppiankov/nudge.git
cd nudge
make app
open build/Nudge.app
```

### Requirements

- macOS 14+ (Sonoma or later)
- Apple Silicon (M1+) or Intel

## Configuration

Config file: `~/.config/nudge/config.json`

```json
{
  "enabled": true,
  "pollInterval": 0.5,
  "allowlist": [
    "com.apple.Terminal",
    "com.googlecode.iterm2",
    "com.microsoft.VSCode",
    "com.apple.Safari",
    "com.google.Chrome",
    "org.mozilla.firefox"
  ],
  "showPopup": true,
  "popupDuration": 3.0,
  "maxAlertsPerApp": 3,
  "alertCooldown": 10.0
}
```

All settings have safe defaults. No configuration is required.

## UX principles

- **awareness without panic** -- if the alert causes more anxiety than the event, it failed
- **calm over loud** -- soft popup, no sounds, no red, no sirens
- **rate-limited** -- max alerts per app per cooldown window
- **forgettable** -- if you forget Nudge is running, it is working correctly

## Related projects

- [PasteWatch](https://github.com/ppiankov/pastewatch) -- obfuscates sensitive data in clipboard before AI paste
- [Chainwatch](https://github.com/ppiankov/chainwatch) -- runtime control plane for AI agent safety
- [VaultSpectre](https://github.com/ppiankov/vaultspectre) -- Vault secret path auditor
- [ClickSpectre](https://github.com/ppiankov/clickspectre) -- ClickHouse table usage analyzer

## License

MIT
