//
//  WindowAccess.swift
//  CPUMeter
//
//  The one place CPUMeter reaches the window SwiftUI creates: requirements §6,
//  the fourth use of AppKit, added in v1.7. The window level for Keep on Top
//  and staying on screen (Increment 0.2), and settling at one of the three
//  sizes after a drag or any other resize (Increment 0.3).
//

import SwiftUI
import AppKit

/// An invisible view placed behind the window's content. It finds the window
/// it sits in and does what SwiftUI can't:
/// - sets the window level for Keep on Top (FR-2);
/// - settles the window at one of the three sizes when a drag or other resize
///   ends, and saves that size (FR-3d);
/// - sets the window's size when View → Size changes, with its top-left corner
///   in place;
/// - keeps the window on screen after any of these (FR-22).
///
/// SwiftUI's `.windowLevel(.floating)` gave level 19 rather than AppKit's
/// floating level 3, and kept setting it again on scene updates, so the scene
/// has no `.windowLevel` and only this view sets the level. SwiftUI can
/// position a window only when it opens, and can't limit resizing to set sizes.
struct WindowAccess: NSViewRepresentable {
    /// View → Keep on Top.
    let keepOnTop: Bool

    /// View → Size. Written back when the window settles at a new size.
    @Binding var size: MeterSize

    func makeNSView(context: Context) -> WindowAccessView {
        let view = WindowAccessView()
        updateNSView(view, context: context)
        return view
    }

    func updateNSView(_ view: WindowAccessView, context: Context) {
        view.keepOnTop = keepOnTop
        view.choose(size)
        let binding = $size
        view.onSettle = { binding.wrappedValue = $0 }
    }
}

/// Which edges stay in place when the window changes size.
private struct Pin {
    /// True: the right edge stays. False: the left edge stays.
    var right = false
    /// True: the bottom edge stays. False: the top edge stays.
    var bottom = false

    static let topLeft = Pin()
}

/// The AppKit side of `WindowAccess`. It draws nothing and takes no clicks.
final class WindowAccessView: NSView {
    var keepOnTop = true {
        didSet { applyLevel() }
    }

    /// The size the window is at, or is settling at.
    private(set) var size = MeterSize.medium

    /// Saves a size the window settled at as the chosen size.
    var onSettle: ((MeterSize) -> Void)?

    /// The window's frame when a drag began, or nil when no drag is under way.
    private var dragStartFrame: NSRect?

    /// True while this view sets the window's frame, so that its own resizes
    /// aren't settled a second time.
    private var isSettingFrame = false

    /// False until the window has been set to the saved size at launch.
    private var isReady = false

    /// View → Size changed: the window takes the new size with its top-left
    /// corner in place (FR-22).
    func choose(_ newSize: MeterSize) {
        guard newSize != size else { return }
        size = newSize
        setSize(newSize, pinning: .topLeft, animate: false)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(self)
        isReady = false
        guard let window else { return }
        applyLevel()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(windowDidResize(_:)),
                           name: NSWindow.didResizeNotification, object: window)
        center.addObserver(self, selector: #selector(windowWillStartLiveResize(_:)),
                           name: NSWindow.willStartLiveResizeNotification, object: window)
        center.addObserver(self, selector: #selector(windowDidEndLiveResize(_:)),
                           name: NSWindow.didEndLiveResizeNotification, object: window)

        // At launch the saved size wins over the size of the restored frame,
        // which supplies only the position (FR-19, FR-20). This waits one turn
        // of the run loop, so that SwiftUI has restored the frame first.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.window != nil else { return }
            self.setSize(self.size, pinning: .topLeft, animate: false)
            self.isReady = true
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    /// Floating above other windows when Keep on Top is on; a normal window
    /// that others can cover when it's off (FR-2).
    private func applyLevel() {
        window?.level = keepOnTop ? .floating : .normal
    }

    @objc private func windowWillStartLiveResize(_ notification: Notification) {
        dragStartFrame = window?.frame
    }

    /// A drag ended. The window settles at the nearest size, with the edge or
    /// corner opposite the dragged one in place (FR-3d).
    @objc private func windowDidEndLiveResize(_ notification: Notification) {
        guard let window, let start = dragStartFrame else { return }
        dragStartFrame = nil
        let end = window.frame
        // The left edge moved, so the right edge stays; the top edge moved,
        // so the bottom stays. Otherwise the top-left stays.
        let pin = Pin(right: abs(end.minX - start.minX) > 0.5,
                      bottom: abs(end.maxY - start.maxY) > 0.5)
        let newSize = MeterSize.settled(from: contentSize(ofFrame: start),
                                        to: contentSize(ofFrame: end))
        settle(at: newSize, pinning: pin, animate: true)
    }

    /// Any resize that isn't a drag or this view's own: the green button,
    /// Window → Fill, tiling, or SwiftUI. If it left the window between sizes,
    /// the window settles at the nearest one with its top-left in place
    /// (requirements §8, item 22). Either way it stays on screen (FR-22).
    @objc private func windowDidResize(_ notification: Notification) {
        guard let window, isReady, !isSettingFrame, dragStartFrame == nil,
              !window.inLiveResize else { return }
        let newSize = MeterSize.settled(from: size.contentSize,
                                        to: contentSize(ofFrame: window.frame))
        settle(at: newSize, pinning: .topLeft, animate: false)
    }

    /// Sets the window to `newSize` and saves it as the chosen size.
    private func settle(at newSize: MeterSize, pinning pin: Pin, animate: Bool) {
        size = newSize
        setSize(newSize, pinning: pin, animate: animate)
        // Saved on the next turn of the run loop, because a resize can arrive
        // while SwiftUI is in the middle of updating its views.
        let onSettle = onSettle
        DispatchQueue.main.async { onSettle?(newSize) }
    }

    /// Sets the window to the given size's content size, with the pinned edges
    /// in place, then moves it just far enough to be on screen (FR-22).
    private func setSize(_ size: MeterSize, pinning pin: Pin, animate: Bool) {
        guard let window else { return }
        let current = window.frame
        let content = size.contentSize
        var target = NSRect(x: 0, y: 0, width: content.width,
                            height: content.height + titleBarHeight(of: window))
        target.origin.x = pin.right ? current.maxX - target.width : current.minX
        target.origin.y = pin.bottom ? current.minY : current.maxY - target.height
        target = onScreen(target, for: window)
        guard target != current else { return }
        isSettingFrame = true
        window.setFrame(target, display: true, animate: animate)
        isSettingFrame = false
    }

    /// The content area a window frame has, below the title bar.
    private func contentSize(ofFrame frame: NSRect) -> CGSize {
        guard let window else { return frame.size }
        return CGSize(width: frame.width, height: frame.height - titleBarHeight(of: window))
    }

    private func titleBarHeight(of window: NSWindow) -> CGFloat {
        window.frame.height - window.contentLayoutRect.height
    }

    /// The frame moved just far enough to fit within the screen's visible
    /// area, clear of the menu bar and Dock (FR-22). If it can't fit, its
    /// top-left corner wins, so the title bar stays reachable.
    private func onScreen(_ frame: NSRect, for window: NSWindow) -> NSRect {
        guard let visible = (window.screen ?? NSScreen.main)?.visibleFrame else { return frame }
        var frame = frame
        if frame.maxX > visible.maxX { frame.origin.x = visible.maxX - frame.width }
        if frame.minX < visible.minX { frame.origin.x = visible.minX }
        if frame.minY < visible.minY { frame.origin.y = visible.minY }
        if frame.maxY > visible.maxY { frame.origin.y = visible.maxY - frame.height }
        return frame
    }
}
