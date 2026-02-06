import AppKit

/// Manages clipboard alert display using a floating HUD window.
///
/// Uses CGShieldingWindowLevel to ensure visibility above all other windows.
/// Design: calm, brief, informational. No clipboard contents shown.
final class PopupWindowController {
    private var window: NSWindow?

    /// Show the popup for a clipboard event.
    func show(event: ClipboardEvent, onDismiss: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.showOnMain(event: event)
        }
    }

    private func showOnMain(event: ClipboardEvent) {
        // Dismiss any existing popup
        if let existing = window {
            existing.orderOut(nil)
            window = nil
        }

        // Build label
        let text = "  \u{1F4CB}  Clipboard activity — \(event.appName) \u{2022} \(event.timeString)  "
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        label.alignment = .center
        label.sizeToFit()

        let panelWidth = max(label.frame.width + 32, 300)
        let panelHeight: CGFloat = 44
        let panelRect = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)

        // Create borderless window at shielding level (above everything)
        let win = NSWindow(
            contentRect: panelRect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        win.isOpaque = false
        win.backgroundColor = NSColor.black.withAlphaComponent(0.85)
        win.level = NSWindow.Level(Int(CGShieldingWindowLevel()))
        win.collectionBehavior = [.canJoinAllSpaces, .stationary]
        win.hasShadow = true
        win.hidesOnDeactivate = false
        win.ignoresMouseEvents = true
        win.isReleasedWhenClosed = false

        // Round corners
        win.contentView?.wantsLayer = true
        win.contentView?.layer?.cornerRadius = 10
        win.contentView?.layer?.masksToBounds = true

        // Center label
        label.frame = NSRect(
            x: (panelWidth - label.frame.width) / 2,
            y: (panelHeight - label.frame.height) / 2,
            width: label.frame.width,
            height: label.frame.height
        )
        win.contentView?.addSubview(label)

        // Position at top-center of screen
        if let screen = NSScreen.main {
            let sf = screen.frame
            let x = sf.midX - (panelWidth / 2)
            let y = sf.maxY - panelHeight - 40
            win.setFrameOrigin(NSPoint(x: x, y: y))
        }

        win.alphaValue = 0
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()

        // Fade in
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            win.animator().alphaValue = 1
        }

        self.window = win
    }

    /// Dismiss the popup.
    func close() {
        guard let win = window else { return }
        self.window = nil
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            win.animator().alphaValue = 0
        }, completionHandler: {
            win.orderOut(nil)
        })
    }
}
