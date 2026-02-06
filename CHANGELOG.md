# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-02-06

### Added

- Initial MVP release
- Clipboard polling via NSPasteboard with configurable interval
- Frontmost app detection via NSWorkspace
- Allowlist-based filtering with default set (Terminal, iTerm, VS Code, Safari, Chrome, Firefox)
- Soft popup overlay alert with app name and timestamp
- Rate limiting per app with configurable cooldown
- Menu bar app with enable/disable toggle, pause, and recent events
- JSON configuration at ~/.config/nudge/config.json
- No clipboard content storage, no network access, no telemetry
