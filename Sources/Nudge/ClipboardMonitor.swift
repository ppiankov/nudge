import AppKit
import Combine

/// Core clipboard monitoring engine.
/// Polls NSPasteboard at regular intervals, detects changes,
/// and determines whether the frontmost app is allowlisted.
///
/// Design: observes metadata only (change count, timestamps).
/// Never reads clipboard contents. Never stores clipboard data.
final class ClipboardMonitor: ObservableObject {

    // MARK: - Published State

    @Published var state: AppState = .idle
    @Published var config: NudgeConfig
    @Published var recentEvents: [ClipboardEvent] = []
    @Published var currentAlert: ClipboardEvent?
    @Published var sessionAlertCount: Int = 0

    // MARK: - Private State

    private var timer: Timer?
    private var lastChangeCount: Int
    private var rateLimiter: AlertRateLimiter
    private var dismissTimer: Timer?
    private let popupController = PopupWindowController()

    /// Maximum number of recent events kept in memory.
    private let maxRecentEvents = 20

    // MARK: - Init

    init() {
        let config = NudgeConfig.load()
        self.config = config
        self.lastChangeCount = NSPasteboard.general.changeCount
        self.rateLimiter = AlertRateLimiter(
            maxAlerts: config.maxAlertsPerApp,
            cooldown: config.alertCooldown
        )
    }

    // MARK: - Control

    /// Called once from the view layer after the object is fully retained.
    func autoStartIfNeeded() {
        guard config.enabled, state == .idle else { return }
        start()
    }

    /// Start monitoring the clipboard.
    func start() {
        guard state != .monitoring else { return }
        lastChangeCount = NSPasteboard.general.changeCount
        state = .monitoring
        scheduleTimer()
    }

    /// Stop monitoring and clean up.
    func stop() {
        timer?.invalidate()
        timer = nil
        dismissTimer?.invalidate()
        dismissTimer = nil
        state = .idle
    }

    /// Pause monitoring temporarily.
    func pause() {
        timer?.invalidate()
        timer = nil
        state = .paused
    }

    /// Resume from paused state.
    func resume() {
        guard state == .paused else { return }
        state = .monitoring
        lastChangeCount = NSPasteboard.general.changeCount
        scheduleTimer()
    }

    /// Pause for a fixed duration, then resume automatically.
    func pauseFor(seconds: TimeInterval) {
        pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self, self.state == .paused else { return }
            self.resume()
        }
    }

    /// Clear recent events and reset counters.
    func clearHistory() {
        recentEvents.removeAll()
        sessionAlertCount = 0
        rateLimiter.reset()
    }

    /// Reload config from disk and apply changes.
    func reloadConfig() {
        let wasMonitoring = state == .monitoring
        if wasMonitoring { stop() }

        config = NudgeConfig.load()
        rateLimiter = AlertRateLimiter(
            maxAlerts: config.maxAlertsPerApp,
            cooldown: config.alertCooldown
        )

        if wasMonitoring && config.enabled {
            start()
        }
    }

    /// Save current config to disk.
    func saveConfig() {
        config.save()
    }

    // MARK: - Polling

    private func scheduleTimer() {
        timer?.invalidate()
        let newTimer = Timer(timeInterval: config.pollInterval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    /// Core polling logic. Called on each timer tick.
    /// Compares current change count against last known value.
    /// If changed, checks frontmost app against allowlist.
    private func checkClipboard() {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }

        lastChangeCount = currentCount

        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = frontApp.bundleIdentifier
        else { return }

        let appName = frontApp.localizedName ?? bundleID

        // Check if the frontmost app is on the allowlist
        if config.allowlist.contains(bundleID) {
            return
        }

        // Non-allowlisted app changed the clipboard
        let event = ClipboardEvent(
            timestamp: Date(),
            appBundleID: bundleID,
            appName: appName,
            changeCount: currentCount
        )

        recordEvent(event)

        // Rate-limit before showing alert
        if config.showPopup && rateLimiter.shouldAlert(bundleID: bundleID) {
            showAlert(event)
        }
    }

    // MARK: - Event Recording

    private func recordEvent(_ event: ClipboardEvent) {
        recentEvents.insert(event, at: 0)
        if recentEvents.count > maxRecentEvents {
            recentEvents.removeLast()
        }
        sessionAlertCount += 1
    }

    // MARK: - Alert Display

    private func showAlert(_ event: ClipboardEvent) {
        dismissTimer?.invalidate()
        currentAlert = event

        popupController.show(event: event) { [weak self] in
            self?.currentAlert = nil
        }

        let dismissDelay = Timer(timeInterval: config.popupDuration, repeats: false) { [weak self] _ in
            self?.dismissAlert()
        }
        RunLoop.main.add(dismissDelay, forMode: .common)
        dismissTimer = dismissDelay
    }

    /// Dismiss the current popup alert.
    func dismissAlert() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        currentAlert = nil
        popupController.close()
    }
}
