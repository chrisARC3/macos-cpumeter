//
//  CPUMeterApp.swift
//  CPUMeter
//
//  The app's single window and its menus: three sizes chosen from the menu,
//  with ⌘1–⌘3 or by dragging, five refresh rates, the two bar colors, and
//  Keep on Top, each remembered across launches, as is the window's position.
//  `MeterSize.swift` holds the sizes and the snap rule, `MeterLayout.swift`
//  works out each size's width on this Mac, `MeterView.swift` draws the meter,
//  `BarColors.swift` holds the colors and opens the color chooser, and
//  `WindowAccess.swift` does the parts SwiftUI can't.
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

    /// View → Refresh Rate, remembered across launches (FR-18c). 1 second at
    /// first launch (FR-18a).
    @AppStorage("refreshRate") private var refreshRate: RefreshRate = .oneSecond

    /// View → Keep on Top, on at first launch and remembered across launches (FR-2).
    @AppStorage("keepOnTop") private var keepOnTop = true

    /// Closes the window for File → Close.
    @Environment(\.dismissWindow) private var dismissWindow

    /// Samples every core on a timer (Increment 1.3). Made with the app, so
    /// the core groups are known before the window opens.
    @State private var sampler: CPUSampler

    /// View → Colors: the chosen bar colors, remembered across launches, and
    /// the system color chooser (FR-28).
    @State private var barColors = BarColors()

    /// The window's size, and the place of everything in it, at each of the
    /// three sizes (Increment 2.1). Worked out once at launch from this Mac's
    /// core groups, with the group labels measured by AppKit, and never stored
    /// (FR-3b, FR-3c). Increment 4.2 works it out again if the core count
    /// changes.
    private let layouts: MeterLayouts

    init() {
        let sampler = CPUSampler()
        _sampler = State(initialValue: sampler)
        // The fallback row has no label (FR-8c, Increment 2.3).
        layouts = MeterLayouts(groups: sampler.topology.groups,
                               labeled: sampler.topology.fallbackReason == nil)
    }

    var body: some Scene {
        // A single, unique floating window (FR-1). `Window`, not `WindowGroup`,
        // because this is a one-window app, and because closing a lone `Window`
        // scene quits the app (FR-23).
        Window(Self.windowTitle, id: "main") {
            // The meter at the chosen size (Increment 2.2), in the chosen
            // colors (Increment 3.3).
            LiveMeter(sampler: sampler, barColors: barColors, layout: layouts[size])
                // The window can be dragged anywhere from Small to Large (FR-3d).
                // While it's between sizes, the meter keeps its size, pinned to
                // the top-left, and the rest shows the window background (design §2).
                .frame(
                    minWidth: layouts.contentSize(of: .small).width,
                    maxWidth: layouts.contentSize(of: .large).width,
                    minHeight: layouts.contentSize(of: .small).height,
                    maxHeight: layouts.contentSize(of: .large).height,
                    alignment: .topLeading
                )
                // Reaches the window for what SwiftUI can't do: Keep on Top's
                // level (FR-2), settling at a size after a drag (FR-3d), and
                // staying on screen (FR-22).
                .background(WindowAccess(keepOnTop: keepOnTop, size: $size, layouts: layouts))
                // Sampling runs while the window is open, at the chosen rate,
                // and a new rate takes effect at once (FR-18d). Increment 4.1
                // also pauses it while the window can't be seen (FR-17).
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
                // With the color chooser in front, ⌘W closes the chooser, as
                // in other Mac apps, rather than the meter, which would quit.
                Button("Close") {
                    if barColors.chooserIsKey {
                        barColors.closeChooser()
                    } else {
                        dismissWindow(id: "main")
                    }
                }
                .keyboardShortcut("w")
            }

            // The View menu (FR-24, design §5). Replacing the toolbar group also
            // removes Show Toolbar and Customize Toolbar, which don't apply
            // (FR-25).
            CommandGroup(replacing: .toolbar) {
                // ⌘1, ⌘2 and ⌘3 choose a size just as the menu does, so the
                // window keeps its top-left corner and stays on screen
                // (FR-22, FR-24a, Increment 3.1). The menu shows them.
                Picker("Size", selection: $size) {
                    ForEach(MeterSize.allCases) { option in
                        Text(option.title).tag(option)
                            .keyboardShortcut(option.shortcutKey)
                    }
                }
                // 1 to 5 seconds, with no shortcuts (FR-18, requirements §8
                // item 10).
                Picker("Refresh Rate", selection: $refreshRate) {
                    ForEach(RefreshRate.allCases) { option in
                        Text(option.title).tag(option)
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

private extension MeterSize {
    /// The size's keyboard shortcut in View → Size, used with ⌘ (FR-24a):
    /// ⌘1, ⌘2 and ⌘3 from smallest to largest, as Finder's View menu numbers
    /// its views.
    var shortcutKey: KeyEquivalent {
        switch self {
        case .small: "1"
        case .medium: "2"
        case .large: "3"
        }
    }
}
