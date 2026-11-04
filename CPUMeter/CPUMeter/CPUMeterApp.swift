//
//  CPUMeterApp.swift
//  CPUMeter
//
//  The app's single window and its menus. Increment 0.2 — three fixed sizes,
//  Keep on Top, and a remembered size, position and window level.
//  `WindowAccess.swift` does the parts SwiftUI can't.
//

import SwiftUI
import Foundation

/// The three window sizes (FR-3). Saved by name, never by width, so the width
/// is always worked out on the Mac the app is running on (FR-3c).
nonisolated enum MeterSize: String, CaseIterable, Identifiable {
    case small, medium, large

    var id: Self { self }

    /// The name shown in View → Size.
    var title: String {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }

    /// Base content width in points (FR-3b). Increment 2.1 widens it to fit
    /// the Mac's core count.
    var baseWidth: CGFloat {
        switch self {
        case .small: 240
        case .medium: 360
        case .large: 480
        }
    }

    /// Fixed content height in points, below the title bar (FR-3a).
    var height: CGFloat {
        switch self {
        case .small: 150
        case .medium: 225
        case .large: 300
        }
    }
}

@main
struct CPUMeterApp: App {
    /// Window title: the app name plus its major.minor version (e.g. "CPUMeter 1.0"),
    /// read from the bundle's marketing version (`CFBundleShortVersionString`) so it
    /// tracks the project version automatically instead of being hard-coded (FR-4).
    private static let windowTitle: String = {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let majorMinor = version.split(separator: ".").prefix(2).joined(separator: ".")
        return majorMinor.isEmpty ? "CPUMeter" : "CPUMeter \(majorMinor)"
    }()

    /// View → Size, remembered across launches (FR-20). Medium at first launch (FR-21).
    @AppStorage("meterSize") private var size: MeterSize = .medium

    /// View → Keep on Top, on at first launch and remembered across launches (FR-2).
    @AppStorage("keepOnTop") private var keepOnTop = true

    /// Closes the window for File → Close.
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        // A single, unique floating window (FR-1). `Window`, not `WindowGroup`,
        // because this is a one-window app, and because closing a lone `Window`
        // scene quits the app (FR-23).
        Window(Self.windowTitle, id: "main") {
            // Temporary placeholder until Increment 2.2 draws the meter. It names
            // the size so each switch is easy to check.
            Text(verbatim: "\(size.title) · \(Int(size.baseWidth)) × \(Int(size.height))")
                .foregroundStyle(.secondary)
                .frame(width: size.baseWidth, height: size.height)
                // Reaches the window for what SwiftUI can't do: Keep on Top's
                // level (FR-2) and staying on screen (FR-22).
                .background(WindowAccess(keepOnTop: keepOnTop))
        }
        // First launch only: top-left of the screen (FR-21). Later launches
        // reopen where the window was left, through SwiftUI's saved window
        // frame, as in DriveSpeed (FR-19).
        .defaultPosition(.topLeading)
        // The window takes its size from its content and can't be dragged
        // (FR-3), so a size change resizes the window.
        .windowResizability(.contentSize)
        // No `.windowLevel` here: `WindowAccess` alone sets Keep on Top's level
        // (FR-2). SwiftUI's `.floating` gave level 19 rather than AppKit's
        // floating level 3, and SwiftUI set it again on every scene update,
        // overriding the level `WindowAccess` set.
        .commands {
            // File holds only Close (FR-25), and closing the window quits the
            // app (FR-23). macOS's own Close and Close All live in this group,
            // so replacing it leaves just our Close. Every other File group is
            // left alone: replacing one, even with nothing, adds a stray
            // separator line to File.
            CommandGroup(replacing: .saveItem) {
                Button("Close") { dismissWindow(id: "main") }
                    .keyboardShortcut("w")
            }

            // The View menu (FR-24, design §5). Replacing the toolbar group also
            // removes Show Toolbar and Customize Toolbar, which don't apply
            // (FR-25). Refresh Rate (3.1) and Colors (3.2) go above the divider.
            CommandGroup(replacing: .toolbar) {
                Picker("Size", selection: $size) {
                    ForEach(MeterSize.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Divider()
                Toggle("Keep on Top", isOn: $keepOnTop)
            }
        }
    }
}
