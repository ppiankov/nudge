# Status

## Current version

0.1.0 -- experimental prototype

## What works

- Clipboard change detection via NSPasteboard polling
- Frontmost app identification
- Allowlist-based filtering
- Soft popup overlay alerts
- Rate limiting per app
- Menu bar controls (enable, pause, recent events)
- JSON configuration

## Known limitations

- Cannot detect which specific process read the clipboard (macOS API limitation)
- Cannot detect background reads that do not change the clipboard
- Frontmost app is a heuristic, not a proof of access
- Polling interval creates a detection window (events between polls are missed)
- No code signing or notarization yet (requires Apple Developer account)

## What will not be built

- Clipboard content analysis or classification
- Process-level monitoring or inspection
- Kernel extensions or system extensions
- AI-powered detection
- Cloud dashboard or remote management
- Enterprise features or policy engines
