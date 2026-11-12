//
//  CPUMeterApp.swift
//  CPUMeter
//
//  The app's single window and its menus: any size from Small up, dragged
//  from any edge or corner or chosen from three presets in the menu, with
//  ⇧⌘S, ⇧⌘M and ⇧⌘L, five refresh rates chosen from the menu or with ⌘1–⌘5,
//  the two bar colors, and Keep on Top, each remembered across launches, as
//  is the window's position. File → Close closes the About box or the color
//  chooser, and never the meter.
//  `MeterSize.swift` holds the presets and the sizing rules,
//  `MeterLayout.swift` works out Small's width on this Mac and the layout at
//  any size, `MeterView.swift` draws the meter, `BarColors.swift` holds the
//  colors and opens the color chooser, and `WindowAccess.swift` does the
//  parts SwiftUI can't.
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

    /// The window's scale: its content width over Small's (FR-3). Saved
    /// whenever a resize ends, and set by View → Size's presets. Remembered
    /// across launches (FR-20); Medium at first launch (FR-21).
    @AppStorage(CPUMeterApp.scaleKey) private var scale: Double = Double(MeterSize.medium.scale)

    /// The saved scale's key since Increment 5.4. An earlier build saved a
    /// size's name under `oldSizeKey`, carried over once in `init()`.
    private static let scaleKey = "meterScale"
    private static let oldSizeKey = "meterSize"

    /// View → Refresh Rate, remembered across launches (FR-18c). 1 second at
    /// first launch (FR-18a).
    @AppStorage("refreshRate") private var refreshRate: RefreshRate = .oneSecond

    /// View → Keep on Top, on at first launch and remembered across launches (FR-2).
    @AppStorage("keepOnTop") private var keepOnTop = true

    /// Which window is in front, for File → Close (FR-25).
    @State private var frontWindow = FrontWindow()

    /// Samples every core on a timer (Increment 1.3). Made with the app, so
    /// the core groups are known before the window opens.
    @State private var sampler: CPUSampler

    /// View → Colors: the chosen bar colors, remembered across launches, and
    /// the system color chooser (FR-28).
    @State private var barColors = BarColors()

    /// Small's size, and the place of everything in it (Increment 2.1), from
    /// which every other size is worked out (FR-3, Increment 5.4). Worked out
    /// at launch from this Mac's core groups, with the group labels measured
    /// by AppKit, and never stored (FR-3b, FR-3c). Worked out again if the
    /// sampler reads new core groups because the core count changed (NFR-4,
    /// Increment 4.2).
    @State private var layouts: MeterLayouts

    /// The largest content size the window's screen holds, from
    /// `WindowAccess`: the window's upper size limit (FR-22). No limit until
    /// it's known.
    @State private var largest = CGSize(width: CGFloat.infinity, height: .infinity)

    init() {
        // A size saved by an earlier build, by name, carries over once as
        // its preset's scale (FR-20). The old key is left as it was.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.scaleKey) == nil,
           let carried = MeterSize.carriedOverScale(fromSavedSize: defaults.string(forKey: Self.oldSizeKey)) {
            defaults.set(Double(carried), forKey: Self.scaleKey)
        }

        let sampler = CPUSampler()
        _sampler = State(initialValue: sampler)
        // The fallback row has no label (FR-8c, Increment 2.3).
        _layouts = State(initialValue: MeterLayouts(topology: sampler.topology))
    }

    var body: some Scene {
        // A single, unique floating window (FR-1). `Window`, not `WindowGroup`,
        // because this is a one-window app, and because closing a lone `Window`
        // scene quits the app (FR-23).
        Window(Self.windowTitle, id: "main") {
            let small = layouts.small.contentSize
            // The meter at the window's size, Small's layout times the
            // window's width over Small's (FR-3, Increment 5.4), so it's
            // drawn at each size a drag passes through, in the chosen colors
            // (Increment 3.3).
            GeometryReader { geometry in
                LiveMeter(sampler: sampler, barColors: barColors,
                          layout: layouts.layout(atWidth: geometry.size.width))
            }
                // The window's size limits: Small, and the largest size of
                // its shape that its screen holds (FR-3d, FR-22). SwiftUI
                // turns the content's limits into the window's, and keeps
                // them; limits set on the window itself, it sets back on
                // every update (requirements §6).
                .frame(minWidth: small.width, maxWidth: largest.width,
                       minHeight: small.height, maxHeight: largest.height, alignment: .topLeading)
                // Reaches the window for what SwiftUI can't do: Keep on Top's
                // level (FR-2), keeping Small's shape at any size (FR-3d),
                // the largest size and staying on screen (FR-22), the saved
                // scale (FR-20), pausing sampling while the window can't be
                // seen (FR-17), and telling the meter from the app's other
                // windows for File → Close (FR-25).
                .background(WindowAccess(keepOnTop: keepOnTop, scale: CGFloat(scale), layouts: layouts,
                                         onVisibilityChange: { sampler.setVisible($0) },
                                         onLargest: { largest = $0 },
                                         onScale: { scale = Double($0) },
                                         onWindow: { frontWindow.meter = $0 }))
                // Sampling runs while the window is open and can be seen, at
                // the chosen rate, and a new rate takes effect at once
                // (FR-18d).
                .onAppear {
                    sampler.setRate(refreshRate)
                    sampler.start()
                }
                // Closing the meter closes the color chooser too, so the app
                // still quits (FR-23).
                .onDisappear {
                    sampler.stop()
                    barColors.closeChooser()
                }
                .onChange(of: refreshRate) { _, rate in sampler.setRate(rate) }
                // New core groups, after the core count changed, give new
                // widths; the window keeps its scale at them (NFR-4, FR-3b).
                .onChange(of: sampler.topology) { _, topology in
                    layouts = MeterLayouts(topology: topology)
                }
                // Full screen is off, so the green button zooms to the largest
                // size and back (requirements §8, item 21, Increment 5.7).
                .windowFullScreenBehavior(.disabled)
        }
        // First launch only: top-left of the screen (FR-21). Later launches
        // reopen where the window was left, through SwiftUI's saved window
        // frame, as in DriveSpeed (FR-19).
        .defaultPosition(.topLeading)
        // The window's size limits come from its content: Small up to the
        // largest size.
        .windowResizability(.contentSize)
        // No `.windowLevel` here: `WindowAccess` alone sets Keep on Top's level
        // (FR-2). SwiftUI's `.floating` gave level 19 rather than AppKit's
        // floating level 3, and SwiftUI set it again on every scene update,
        // overriding the level `WindowAccess` set.
        .commands {
            // File holds only Close (FR-25), which never closes the meter,
            // since closing the meter quits the app (FR-23). macOS's own Close
            // and Close All live in this group, so replacing it leaves just
            // our Close. Every other File group is left alone: replacing one,
            // even with nothing, adds a stray separator line to File.
            CommandGroup(replacing: .saveItem) {
                // ⌘W closes the About box or the color chooser when either is
                // in front, as in other Mac apps, and with the meter in front
                // Close is grayed out (requirements v1.22). SwiftUI may bring
                // the menu up to date late, so Close also checks for itself,
                // and with the meter in front it does nothing. The chooser
                // closes through `BarColors`, which then stops editing a
                // color; any other window as its close button would close it.
                Button("Close") {
                    if barColors.chooserIsKey {
                        barColors.closeChooser()
                    } else {
                        frontWindow.other?.performClose(nil)
                    }
                }
                .keyboardShortcut("w")
                .disabled(!frontWindow.otherInFront)
            }

            // The View menu (FR-24, design §5). Replacing the toolbar group also
            // removes Show Toolbar and Customize Toolbar, which don't apply
            // (FR-25).
            CommandGroup(replacing: .toolbar) {
                // A preset is checked only when the window is exactly that
                // size, so after a drag to any other size none is (FR-24,
                // design §8 item 12). Choosing one sets the window to it,
                // keeping its top-left corner and staying on screen (FR-22).
                // ⇧⌘S, ⇧⌘M and ⇧⌘L choose a preset just as the menu does
                // (FR-24a, Increment 3.4). The menu shows them.
                Picker("Size", selection: Binding(
                    get: { MeterSize.preset(atScale: CGFloat(scale)) },
                    set: { preset in if let preset { scale = Double(preset.scale) } }
                )) {
                    ForEach(MeterSize.allCases) { option in
                        Text(option.title).tag(Optional(option))
                            .keyboardShortcut(option.shortcutKey, modifiers: [.command, .shift])
                    }
                }
                // 1 to 5 seconds. ⌘1 to ⌘5 choose a rate just as the menu does,
                // so it takes effect as FR-18d says (FR-18e, Increment 3.4).
                // The menu shows them.
                Picker("Refresh Rate", selection: $refreshRate) {
                    ForEach(RefreshRate.allCases) { option in
                        Text(option.title).tag(option)
                            .keyboardShortcut(option.shortcutKey)
                    }
                }
                // System Color… and User Color… in the key's order, each
                // opening the system color chooser, then Reset to Defaults
                // (FR-28b, FR-28e).
                Menu("Colors") {
                    ForEach(BarPart.allCases, id: \.self) { part in
                        Button(part.menuTitle) { barColors.openChooser(for: part) }
                    }
                    Divider()
                    Button("Reset to Defaults") { barColors.reset() }
                }
                Divider()
                Toggle("Keep on Top", isOn: $keepOnTop)
            }
        }
    }
}

/// The meter, showing the sampler's latest update in the chosen colors. A view
/// of its own, so that each update, and each color picked, redraws only the
/// meter and not the rest of the window's content. A color picked shows at
/// once, between updates (FR-28c).
private struct LiveMeter: View {
    let sampler: CPUSampler
    let barColors: BarColors
    let layout: MeterLayout

    var body: some View {
        MeterView(layout: layout, sample: sampler.sample, colorChoice: barColors.choice)
    }
}

/// Which window is in front, for File → Close (FR-25). Close works only while
/// a window other than the meter is key, the About box or the color chooser,
/// so ⌘W never closes the meter, which would quit the app (FR-23).
@Observable
private final class FrontWindow {
    /// The meter's window, from `WindowAccess` once the meter has joined it.
    /// Until then no window counts as another.
    @ObservationIgnored weak var meter: NSWindow? {
        didSet { update() }
    }

    /// True while a window other than the meter is key, when Close is
    /// enabled.
    private(set) var otherInFront = false

    @ObservationIgnored private var observers: [any NSObjectProtocol] = []

    init() {
        // Any of the app's windows becoming key or giving it up, the app
        // becoming active or not included. Read on the next turn of the run
        // loop, once macOS has settled which window is key.
        let center = NotificationCenter.default
        for name in [NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.updateSoon() }
            })
        }
    }

    /// The key window, read when Close is chosen, if it isn't the meter.
    var other: NSWindow? {
        guard let meter, let key = NSApp.keyWindow, key !== meter else { return nil }
        return key
    }

    private func updateSoon() {
        DispatchQueue.main.async { [weak self] in self?.update() }
    }

    private func update() {
        let now = other != nil
        if now != otherInFront { otherInFront = now }
    }
}

private extension MeterSize {
    /// The preset's keyboard shortcut in View → Size, used with ⇧⌘ (FR-24a):
    /// its first letter. Shift is needed because ⌘M alone is Window →
    /// Minimize, and all three take it so they match.
    var shortcutKey: KeyEquivalent {
        switch self {
        case .small: "s"
        case .medium: "m"
        case .large: "l"
        }
    }
}

private extension RefreshRate {
    /// The rate's keyboard shortcut in View → Refresh Rate, used with ⌘
    /// (FR-18e): its number of seconds, ⌘1 to ⌘5.
    var shortcutKey: KeyEquivalent {
        KeyEquivalent(Character(String(rawValue)))
    }
}
