import AppKit
import SwiftUI

/// Shared monitor instance. Created once, retained for app lifetime.
let sharedMonitor = ClipboardMonitor()

/// Nudge -- clipboard awareness for macOS.
///
/// Menu bar app that quietly alerts you when an unexpected app
/// accesses your clipboard. Awareness, not prevention.
///
/// Principiis obsta.
@main
struct NudgeApp: App {

    init() {
        NSLog("[Nudge] App init — starting monitor")
        sharedMonitor.autoStartIfNeeded()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: sharedMonitor)
        } label: {
            Image(systemName: menuBarIcon)
        }
        .menuBarExtraStyle(.window)
    }

    /// Menu bar icon changes based on state.
    private var menuBarIcon: String {
        switch sharedMonitor.state {
        case .monitoring: return "hand.raised"
        case .paused: return "hand.raised.slash"
        case .idle: return "hand.raised"
        }
    }
}
