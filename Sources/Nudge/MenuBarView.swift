import SwiftUI

/// Main menu bar dropdown view.
/// Provides controls for enable/disable, pause, allowlist editing,
/// and recent event history.
struct MenuBarView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            statusSection
            Divider()
            controlsSection
            Divider()
            recentEventsSection
            Divider()
            footerSection
        }
        .frame(width: 280)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Nudge")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Text("v0.1.0")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Status

    private var statusSection: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            if monitor.sessionAlertCount > 0 {
                Text("\(monitor.sessionAlertCount) alert\(monitor.sessionAlertCount == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var statusColor: Color {
        switch monitor.state {
        case .monitoring: return .green
        case .paused: return .orange
        case .idle: return .gray
        }
    }

    private var statusText: String {
        switch monitor.state {
        case .monitoring: return "Monitoring"
        case .paused: return "Paused"
        case .idle: return "Idle"
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Toggle(isOn: Binding(
                get: { monitor.config.enabled },
                set: { newValue in
                    monitor.config.enabled = newValue
                    monitor.saveConfig()
                    if newValue {
                        monitor.start()
                    } else {
                        monitor.stop()
                    }
                }
            )) {
                Text("Enabled")
                    .font(.system(size: 13))
            }
            .toggleStyle(.switch)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            if monitor.state == .monitoring {
                Button("Pause for 10 minutes") {
                    monitor.pauseFor(seconds: 600)
                }
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
            }

            if monitor.state == .paused {
                Button("Resume") {
                    monitor.resume()
                }
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
            }

            Button("Settings\u{2026}") {
                showSettings.toggle()
            }
            .font(.system(size: 13))
            .padding(.horizontal, 12)
            .padding(.vertical, 2)
            .popover(isPresented: $showSettings) {
                SettingsView(monitor: monitor)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Recent Events

    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Recent")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 6)

            if monitor.recentEvents.isEmpty {
                Text("No events")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            } else {
                ForEach(monitor.recentEvents.prefix(5)) { event in
                    HStack {
                        Text(event.appName)
                            .font(.system(size: 11))
                            .lineLimit(1)
                        Spacer()
                        Text(event.timeString)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                }

                if monitor.recentEvents.count > 5 {
                    Text("+\(monitor.recentEvents.count - 5) more")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            if !monitor.recentEvents.isEmpty {
                Button("Clear History") {
                    monitor.clearHistory()
                }
                .font(.system(size: 11))
            }
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .font(.system(size: 11))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Settings View

/// Settings popover for editing configuration.
struct SettingsView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var newAllowlistEntry = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))

            // Popup toggle
            Toggle(isOn: Binding(
                get: { monitor.config.showPopup },
                set: { newValue in
                    monitor.config.showPopup = newValue
                    monitor.saveConfig()
                }
            )) {
                Text("Show popup alerts")
                    .font(.system(size: 12))
            }
            .toggleStyle(.switch)

            Divider()

            // Allowlist
            Text("Allowlist")
                .font(.system(size: 12, weight: .medium))

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(monitor.config.allowlist, id: \.self) { bundleID in
                        HStack {
                            Text(bundleID)
                                .font(.system(size: 11, design: .monospaced))
                                .lineLimit(1)
                            Spacer()
                            Button(action: {
                                monitor.config.allowlist.removeAll { $0 == bundleID }
                                monitor.saveConfig()
                            }) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 11))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 1)
                    }
                }
            }
            .frame(maxHeight: 150)

            HStack {
                TextField("com.example.app", text: $newAllowlistEntry)
                    .font(.system(size: 11, design: .monospaced))
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    let entry = newAllowlistEntry.trimmingCharacters(in: .whitespaces)
                    guard !entry.isEmpty,
                          !monitor.config.allowlist.contains(entry) else { return }
                    monitor.config.allowlist.append(entry)
                    monitor.saveConfig()
                    newAllowlistEntry = ""
                }
                .font(.system(size: 11))
                .disabled(newAllowlistEntry.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Divider()

            // Popup duration
            HStack {
                Text("Popup duration:")
                    .font(.system(size: 12))
                Spacer()
                Text("\(monitor.config.popupDuration, specifier: "%.1f")s")
                    .font(.system(size: 12, design: .monospaced))
                Stepper("", value: Binding(
                    get: { monitor.config.popupDuration },
                    set: { newValue in
                        monitor.config.popupDuration = max(1.0, min(10.0, newValue))
                        monitor.saveConfig()
                    }
                ), step: 0.5)
                .labelsHidden()
            }

            // Cooldown
            HStack {
                Text("Alert cooldown:")
                    .font(.system(size: 12))
                Spacer()
                Text("\(monitor.config.alertCooldown, specifier: "%.0f")s")
                    .font(.system(size: 12, design: .monospaced))
                Stepper("", value: Binding(
                    get: { monitor.config.alertCooldown },
                    set: { newValue in
                        monitor.config.alertCooldown = max(5.0, min(120.0, newValue))
                        monitor.saveConfig()
                    }
                ), step: 5.0)
                .labelsHidden()
            }

            Button("Reload Config from Disk") {
                monitor.reloadConfig()
            }
            .font(.system(size: 11))
        }
        .padding(16)
        .frame(width: 320)
    }
}
