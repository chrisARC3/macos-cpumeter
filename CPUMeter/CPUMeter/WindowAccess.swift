//
//  WindowAccess.swift
//  CPUMeter
//
//  The one place CPUMeter reaches the window SwiftUI creates: requirements §6,
//  the fourth use of AppKit, added in v1.7. Increment 0.2 — the window level
//  for Keep on Top, and keeping the window on screen after a size change.
//

import SwiftUI
import AppKit

/// An invisible view placed behind the window's content. It finds the window
/// it sits in and does the two things SwiftUI can't: setting the window level
/// for Keep on Top (FR-2), and moving the window back on screen after a size
/// change (FR-22). SwiftUI's `.windowLevel(.floating)` gave level 19 rather
/// than AppKit's floating level 3, and kept setting it again on scene updates,
/// so the scene has no `.windowLevel` and only this view sets the level.
/// SwiftUI can position a window only when it opens.
struct WindowAccess: NSViewRepresentable {
    /// View → Keep on Top.
    let keepOnTop: Bool

    func makeNSView(context: Context) -> WindowAccessView {
        let view = WindowAccessView()
        view.keepOnTop = keepOnTop
        return view
    }

    func updateNSView(_ view: WindowAccessView, context: Context) {
        view.keepOnTop = keepOnTop
    }
}

/// The AppKit side of `WindowAccess`. It draws nothing and takes no clicks.
final class WindowAccessView: NSView {
    var keepOnTop = true {
        didSet { applyLevel() }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResizeNotification, object: nil)
        guard let window else { return }
        applyLevel()
        NotificationCenter.default.addObserver(
            self, selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification, object: window)
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    /// Floating above other windows when Keep on Top is on; a normal window
    /// that others can cover when it's off (FR-2).
    private func applyLevel() {
        window?.level = keepOnTop ? .floating : .normal
    }

    @objc private func windowDidResize(_ notification: Notification) {
        keepOnScreen()
    }

    /// Moves the window just far enough to fit within the screen's visible
    /// area, clear of the menu bar and Dock (FR-22). If it can't fit, its
    /// top-left corner wins, so the title bar stays reachable.
    private func keepOnScreen() {
        guard let window, let visible = window.screen?.visibleFrame else { return }
        var origin = window.frame.origin
        let size = window.frame.size
        if origin.x + size.width > visible.maxX { origin.x = visible.maxX - size.width }
        if origin.x < visible.minX { origin.x = visible.minX }
        if origin.y < visible.minY { origin.y = visible.minY }
        if origin.y + size.height > visible.maxY { origin.y = visible.maxY - size.height }
        if origin != window.frame.origin {
            window.setFrameOrigin(origin)
        }
    }
}
