//
//  CPUMeterApp.swift
//  CPUMeter
//
//  The app's single window. Increment 0.1 — a correctly titled, top-left,
//  fixed-size window with a placeholder where the meter will go.
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

    var body: some Scene {
        // A single, unique floating window (FR-1). `Window`, not `WindowGroup`,
        // because this is a one-window app, and because closing a lone `Window`
        // scene quits the app (FR-23).
        Window(Self.windowTitle, id: "main") {
            // Placeholder at Medium's size, the first-launch size (FR-21), until
            // Increment 2.2 draws the meter.
            Color.clear
                .frame(width: 360, height: 225)
        }
        // First launch only: top-left of the screen (FR-21). Later launches
        // reopen where the window was left.
        .defaultPosition(.topLeading)
        // The window takes its size from its content and can't be dragged (FR-3).
        .windowResizability(.contentSize)
    }
}
