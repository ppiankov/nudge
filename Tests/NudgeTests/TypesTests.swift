import XCTest
@testable import Nudge

final class TypesTests: XCTestCase {

    // MARK: - Config Tests

    func testDefaultConfigHasExpectedValues() {
        let config = NudgeConfig.defaultConfig
        XCTAssertTrue(config.enabled)
        XCTAssertEqual(config.pollInterval, 0.5)
        XCTAssertTrue(config.showPopup)
        XCTAssertEqual(config.popupDuration, 3.0)
        XCTAssertEqual(config.maxAlertsPerApp, 3)
        XCTAssertEqual(config.alertCooldown, 10.0)
    }

    func testDefaultAllowlistContainsExpectedApps() {
        let config = NudgeConfig.defaultConfig
        XCTAssertTrue(config.allowlist.contains("com.apple.Terminal"))
        XCTAssertTrue(config.allowlist.contains("com.microsoft.VSCode"))
        XCTAssertTrue(config.allowlist.contains("com.apple.Safari"))
        XCTAssertTrue(config.allowlist.contains("com.google.Chrome"))
    }

    func testConfigEncodesAndDecodes() throws {
        let original = NudgeConfig.defaultConfig
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(NudgeConfig.self, from: data)
        XCTAssertEqual(decoded.enabled, original.enabled)
        XCTAssertEqual(decoded.pollInterval, original.pollInterval)
        XCTAssertEqual(decoded.allowlist, original.allowlist)
        XCTAssertEqual(decoded.popupDuration, original.popupDuration)
    }

    // MARK: - Rate Limiter Tests

    func testRateLimiterAllowsFirstAlert() {
        let limiter = AlertRateLimiter(maxAlerts: 3, cooldown: 10.0)
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app"))
    }

    func testRateLimiterBlocksAfterMax() {
        let limiter = AlertRateLimiter(maxAlerts: 2, cooldown: 60.0)
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app"))
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app"))
        XCTAssertFalse(limiter.shouldAlert(bundleID: "com.test.app"))
    }

    func testRateLimiterTracksAppsIndependently() {
        let limiter = AlertRateLimiter(maxAlerts: 1, cooldown: 60.0)
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app1"))
        XCTAssertFalse(limiter.shouldAlert(bundleID: "com.test.app1"))
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app2"))
    }

    func testRateLimiterResetClearsState() {
        let limiter = AlertRateLimiter(maxAlerts: 1, cooldown: 60.0)
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app"))
        XCTAssertFalse(limiter.shouldAlert(bundleID: "com.test.app"))
        limiter.reset()
        XCTAssertTrue(limiter.shouldAlert(bundleID: "com.test.app"))
    }

    // MARK: - Clipboard Event Tests

    func testClipboardEventTimeString() {
        let event = ClipboardEvent(
            timestamp: Date(),
            appBundleID: "com.test.app",
            appName: "Test App",
            changeCount: 42
        )
        // Should return a time string in HH:mm:ss format
        XCTAssertEqual(event.timeString.count, 8)
        XCTAssertTrue(event.timeString.contains(":"))
    }

    func testClipboardEventHasUniqueID() {
        let event1 = ClipboardEvent(
            timestamp: Date(),
            appBundleID: "com.test.app",
            appName: "Test",
            changeCount: 1
        )
        let event2 = ClipboardEvent(
            timestamp: Date(),
            appBundleID: "com.test.app",
            appName: "Test",
            changeCount: 2
        )
        XCTAssertNotEqual(event1.id, event2.id)
    }
}
