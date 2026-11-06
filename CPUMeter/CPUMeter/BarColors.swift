//
//  BarColors.swift
//  CPUMeter
//
//  The bar colors chosen in View → Colors, and the system color chooser that
//  picks them (FR-28, Increment 3.3). The chooser is `NSColorPanel`, one of
//  requirements §6's uses of AppKit: SwiftUI's `ColorPicker` is a control
//  inside a window, and FR-26 keeps the window free of controls.
//

import SwiftUI
import AppKit

/// A bar part whose color can be changed: system time at the base of each
/// bar, and user time above it (FR-9).
nonisolated enum BarPart: CaseIterable, Sendable {
    // System first, as in the key and the menu (FR-28b, requirements §8
    // item 26).
    case system, user

    /// The item in View → Colors (FR-28b).
    var menuTitle: String {
        switch self {
        case .system: "System Color…"
        case .user: "User Color…"
        }
    }

    /// The chooser's title while this color is being changed (FR-28b).
    var chooserTitle: String {
        switch self {
        case .system: "System Color"
        case .user: "User Color"
        }
    }

    /// Where a chosen color is remembered (FR-28d).
    var defaultsKey: String {
        switch self {
        case .system: "systemColor"
        case .user: "userColor"
        }
    }

    /// The default: the system's orange or blue, which adapt to light and
    /// dark appearance (FR-28a).
    var defaultColor: NSColor {
        switch self {
        case .system: .systemOrange
        case .user: .systemBlue
        }
    }
}

/// The colors chosen for the two parts. Nil means the part has no chosen
/// color and uses its default (FR-28a).
nonisolated struct BarColorChoice: Equatable {
    var system: NSColor?
    var user: NSColor?

    subscript(part: BarPart) -> NSColor? {
        get {
            switch part {
            case .system: system
            case .user: user
            }
        }
        set {
            switch part {
            case .system: system = newValue
            case .user: user = newValue
            }
        }
    }

    /// The color a part is drawn in: the chosen one, which stays as picked in
    /// both appearances, or the adaptive default (NFR-5, requirements §8
    /// item 12).
    func color(for part: BarPart) -> NSColor {
        self[part] ?? part.defaultColor
    }
}

/// Chosen colors as text, such as "#FF9500": sRGB, eight bits a channel, and
/// always opaque (requirements §8 item 13). Readable in `defaults read`.
nonisolated enum ColorHex {
    /// A color as "#RRGGBB" in sRGB. Channels outside sRGB are clamped and
    /// opacity is dropped. Nil for a color with no RGB value, such as a
    /// pattern.
    static func string(from color: NSColor) -> String? {
        guard let srgb = color.usingColorSpace(.sRGB) else { return nil }
        let channels = [srgb.redComponent, srgb.greenComponent, srgb.blueComponent]
            .map { Int((min(max($0, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", channels[0], channels[1], channels[2])
    }

    /// The opaque sRGB color "#RRGGBB" names, in either case. Nil for
    /// anything else, which leaves that part at its default.
    static func color(from string: String) -> NSColor? {
        let digits = Array(string.utf8.dropFirst())
        guard string.utf8.first == UInt8(ascii: "#"), digits.count == 6,
              digits.allSatisfy(isHexDigit),
              let value = UInt32(String(decoding: digits, as: UTF8.self), radix: 16)
        else { return nil }
        func channel(_ shift: UInt32) -> CGFloat { CGFloat((value >> shift) & 0xFF) / 255 }
        return NSColor(srgbRed: channel(16), green: channel(8), blue: channel(0), alpha: 1)
    }

    private static func isHexDigit(_ byte: UInt8) -> Bool {
        switch byte {
        case UInt8(ascii: "0")...UInt8(ascii: "9"),
             UInt8(ascii: "A")...UInt8(ascii: "F"),
             UInt8(ascii: "a")...UInt8(ascii: "f"): true
        default: false
        }
    }
}

/// The chosen bar colors, remembered across launches (FR-28d), and the system
/// color chooser that changes them (FR-28b).
@Observable
final class BarColors {
    /// What the meter draws with. A change redraws the meter at once, without
    /// waiting for the next update (FR-28c).
    private(set) var choice: BarColorChoice

    /// Where chosen colors are remembered. A test passes its own.
    @ObservationIgnored private let defaults: UserDefaults

    /// The part the chooser is changing, or nil before it opens and after
    /// CPUMeter closes it. The chooser's own close button leaves it set, which
    /// does no harm: picks arrive only while the chooser is open.
    @ObservationIgnored private(set) var editing: BarPart?

    /// Receives the chooser's picks.
    @ObservationIgnored private let relay = ChooserRelay()

    /// The chooser's window level: one above Keep on Top's floating level
    /// (FR-2), so clicking a kept-on-top meter can't put it behind the meter.
    nonisolated static let chooserLevel = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 1)

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var choice = BarColorChoice()
        for part in BarPart.allCases {
            choice[part] = defaults.string(forKey: part.defaultsKey).flatMap(ColorHex.color(from:))
        }
        self.choice = choice
        relay.owner = self
    }

    /// Chooses a color for a part and remembers it. The meter shows the color
    /// as saved, so it looks the same after a relaunch.
    func set(_ color: NSColor, for part: BarPart) {
        guard let hex = ColorHex.string(from: color), let saved = ColorHex.color(from: hex) else { return }
        defaults.set(hex, forKey: part.defaultsKey)
        choice[part] = saved
    }

    /// View → Colors → Reset to Defaults: both colors back to FR-28a
    /// (FR-28e). An open chooser shows the default of the color it's changing.
    func reset() {
        for part in BarPart.allCases {
            defaults.removeObject(forKey: part.defaultsKey)
        }
        choice = BarColorChoice()
        if let editing, chooserIsOpen {
            show(choice.color(for: editing), in: NSColorPanel.shared)
        }
    }

    // MARK: - The chooser

    /// System Color… or User Color…: opens the system color chooser set to
    /// that color and titled with its name (FR-28b), with no opacity control
    /// (requirements §8 item 13). Choosing the other one while it's open
    /// switches the chooser to that color.
    func openChooser(for part: BarPart) {
        let panel = NSColorPanel.shared
        editing = part
        panel.showsAlpha = false
        // Picks arrive while dragging, not only when the mouse is let go.
        panel.isContinuous = true
        panel.title = part.chooserTitle
        show(choice.color(for: part), in: panel)
        panel.level = Self.chooserLevel
        panel.makeKeyAndOrderFront(nil)
    }

    /// Whether the chooser is the window in front, which ⌘W closes.
    var chooserIsKey: Bool {
        NSColorPanel.sharedColorPanelExists && NSApp.keyWindow === NSColorPanel.shared
    }

    /// Closes the chooser, if it's open.
    func closeChooser() {
        editing = nil
        guard NSColorPanel.sharedColorPanelExists else { return }
        NSColorPanel.shared.close()
    }

    private var chooserIsOpen: Bool {
        NSColorPanel.sharedColorPanelExists && NSColorPanel.shared.isVisible
    }

    /// Sets the chooser's color without counting it as a pick, then listens
    /// for picks again.
    private func show(_ color: NSColor, in panel: NSColorPanel) {
        panel.setTarget(nil)
        panel.setAction(nil)
        panel.color = color
        panel.setTarget(relay)
        panel.setAction(#selector(ChooserRelay.colorChanged(_:)))
    }

    /// A color picked in the chooser, for the part it's changing.
    fileprivate func picked(_ color: NSColor) {
        guard let editing else { return }
        set(color, for: editing)
    }
}

/// The chooser's target. `NSColorPanel` sends each pick as an Objective-C
/// action, so this small object takes it and passes the color on.
private final class ChooserRelay: NSObject {
    weak var owner: BarColors?

    @objc func colorChanged(_ sender: NSColorPanel) {
        owner?.picked(sender.color)
    }
}
