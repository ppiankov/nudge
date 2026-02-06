import Foundation

// MARK: - Configuration

/// User-configurable settings for Nudge behavior.
/// Loaded from ~/.config/nudge/config.json with safe defaults.
struct NudgeConfig: Codable {
    var enabled: Bool
    var pollInterval: Double
    var allowlist: [String]
    var showPopup: Bool
    var popupDuration: Double
    var maxAlertsPerApp: Int
    var alertCooldown: Double

    static let defaultConfig = NudgeConfig(
        enabled: true,
        pollInterval: 0.5,
        allowlist: [
            "com.apple.Terminal",
            "com.googlecode.iterm2",
            "com.microsoft.VSCode",
            "com.apple.Safari",
            "com.google.Chrome",
            "org.mozilla.firefox",
            "com.apple.finder",
            "com.apple.dt.Xcode",
            "com.jetbrains.intellij",
            "com.sublimetext.4",
            "com.hegenberg.BetterTouchTool",
            "com.raycast.macos",
            "com.alfredapp.Alfred",
        ],
        showPopup: true,
        popupDuration: 3.0,
        maxAlertsPerApp: 3,
        alertCooldown: 10.0
    )

    /// Path to config file: ~/.config/nudge/config.json
    static var configURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent(".config")
            .appendingPathComponent("nudge")
            .appendingPathComponent("config.json")
    }

    /// Load config from disk, falling back to defaults.
    static func load() -> NudgeConfig {
        let url = configURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(NudgeConfig.self, from: data)
        else {
            return .defaultConfig
        }
        return config
    }

    /// Save config to disk. Creates directory if needed.
    func save() {
        let url = NudgeConfig.configURL
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return }
        try? data.write(to: url)
    }
}

// MARK: - App State

/// Current operating state of the monitor.
enum AppState {
    case idle
    case monitoring
    case paused
}

// MARK: - Clipboard Event

/// A single detected clipboard access event.
/// Contains metadata only -- never clipboard contents.
struct ClipboardEvent: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let appBundleID: String
    let appName: String
    let changeCount: Int

    /// Human-readable time string for display.
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Rate Limiter

/// Per-app rate limiting to prevent alert fatigue.
/// Tracks alert counts within a sliding cooldown window.
final class AlertRateLimiter {
    private var alertHistory: [String: [Date]] = [:]
    private let maxAlerts: Int
    private let cooldown: TimeInterval

    init(maxAlerts: Int, cooldown: TimeInterval) {
        self.maxAlerts = maxAlerts
        self.cooldown = cooldown
    }

    /// Returns true if an alert should be shown for this bundle ID.
    /// Prunes expired entries and enforces the per-app limit.
    func shouldAlert(bundleID: String) -> Bool {
        let now = Date()
        let cutoff = now.addingTimeInterval(-cooldown)

        // Prune expired entries
        alertHistory[bundleID] = (alertHistory[bundleID] ?? []).filter { $0 > cutoff }

        let count = alertHistory[bundleID]?.count ?? 0
        if count >= maxAlerts {
            return false
        }

        alertHistory[bundleID, default: []].append(now)
        return true
    }

    /// Update limits from config.
    func update(maxAlerts: Int, cooldown: TimeInterval) {
        // Limits are read directly from stored properties, but we allow
        // the caller to reconstruct if config changes. For simplicity,
        // this is a no-op since we read from init. Future: make mutable.
    }

    /// Reset all tracking state.
    func reset() {
        alertHistory.removeAll()
    }
}
