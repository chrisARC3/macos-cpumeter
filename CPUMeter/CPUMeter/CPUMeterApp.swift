//
//  CPUMeterApp.swift
//  CPUMeter
//
//  The app's single window and its menus: three sizes chosen from the menu or
//  by dragging, Keep on Top, and a remembered size, position and window level.
//  `MeterSize.swift` holds the sizes and the snap rule, and `WindowAccess.swift`
//  does the parts SwiftUI can't.
//

import SwiftUI
import Foundation

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

    /// View → Size, or the size a drag settled at, remembered across launches
    /// (FR-20). Medium at first launch (FR-21).
    @AppStorage("meterSize") private var size: MeterSize = .medium

    /// View → Keep on Top, on at first launch and remembered across launches (FR-2).
    @AppStorage("keepOnTop") private var keepOnTop = true

    /// Closes the window for File → Close.
    @Environment(\.dismissWindow) private var dismissWindow

    /// Samples every core on a timer (Increment 1.3). Made with the app, so
    /// the core groups are known before the window opens.
    @State private var sampler = CPUSampler()

    var body: some Scene {
        // A single, unique floating window (FR-1). `Window`, not `WindowGroup`,
        // because this is a one-window app, and because closing a lone `Window`
        // scene quits the app (FR-23).
        Window(Self.windowTitle, id: "main") {
            // Temporary placeholder until Increment 2.2 draws the meter. It names
            // the size so each switch is easy to check.
            Text(verbatim: "\(size.title) · \(Int(size.contentSize.width)) × \(Int(size.contentSize.height))")
                .foregroundStyle(.secondary)
                .frame(width: size.contentSize.width, height: size.contentSize.height)
                // The window can be dragged anywhere from Small to Large (FR-3d).
                // While it's between sizes, the meter keeps its size, pinned to
                // the top-left, and the rest shows the window background (design §2).
                .frame(
                    minWidth: MeterSize.small.contentSize.width,
                    maxWidth: MeterSize.large.contentSize.width,
                    minHeight: MeterSize.small.contentSize.height,
                    maxHeight: MeterSize.large.contentSize.height,
                    alignment: .topLeading
                )
                // Reaches the window for what SwiftUI can't do: Keep on Top's
                // level (FR-2), settling at a size after a drag (FR-3d), and
                // staying on screen (FR-22).
                .background(WindowAccess(keepOnTop: keepOnTop, size: $size))
                // Sampling runs while the window is open. Increment 4.1 also
                // pauses it while the window can't be seen (FR-17).
                .onAppear { sampler.start() }
                .onDisappear { sampler.stop() }
                // Full screen is off, so the green button zooms to Large and
                // back (requirements §8, item 21).
                .windowFullScreenBehavior(.disabled)
        }
        // First launch only: top-left of the screen (FR-21). Later launches
        // reopen where the window was left, through SwiftUI's saved window
        // frame, as in DriveSpeed (FR-19).
        .defaultPosition(.topLeading)
        // The window's size limits come from its content: Small to Large.
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
