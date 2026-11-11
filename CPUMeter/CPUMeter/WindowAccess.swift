//
//  WindowAccess.swift
//  CPUMeter
//
//  The one place CPUMeter reaches the window SwiftUI creates: requirements §6,
//  the fourth use of AppKit, added in v1.7. The window level for Keep on Top
//  and staying on screen (Increment 0.2), passing on macOS's notice of
//  whether the window can be seen (Increment 4.1), taking new widths if the
//  core count changes (Increment 4.2), and, since Increment 5.4, keeping the
//  window in Small's shape at any size, from Small up to the largest size
//  its screen holds (requirements v1.17 and v1.18). Increment 0.3's snapping
//  to three sizes is gone. Since Increment 5.7, the green button takes the
//  window to its largest size and back, and from the largest to Large
//  (requirements v1.20).
//

import SwiftUI
import AppKit

/// An invisible view placed behind the window's content. It finds the window
/// it sits in and does what SwiftUI can't:
/// - sets the window level for Keep on Top (FR-2);
/// - keeps the window in Small's shape at every step of a drag from any edge
///   or corner, with the edges design §2 names held in place (FR-3d,
///   requirements §8 items 20 and 22);
/// - takes the window where a press of the green button goes: to the
///   largest size and back, or from the largest to Large (requirements §8
///   item 21, design §8 item 5);
/// - works out the largest size the window's screen holds and passes it up,
///   for the content's own size limits (FR-22, design §8 item 13);
/// - sets the window to the saved scale at launch, and to a preset chosen in
///   View → Size, with its top-left corner in place (FR-20, FR-22);
/// - keeps the window on screen after any of these, and passes the window's
///   scale up to be saved when a resize ends (FR-20, FR-22);
/// - says when the window can or can't be seen, so sampling pauses while it
///   can't (FR-17).
///
/// SwiftUI's `.windowLevel(.floating)` gave level 19 rather than AppKit's
/// floating level 3, and kept setting it again on scene updates, so the scene
/// has no `.windowLevel` and only this view sets the level. SwiftUI can
/// position a window only when it opens, and has no way to keep a window's
/// shape. It also sets the window's size limits again on every update, so
/// the limits come from the content's frame instead (requirements §6).
struct WindowAccess: NSViewRepresentable {
    /// View → Keep on Top.
    let keepOnTop: Bool

    /// The saved scale (FR-20). The window takes it at launch, and again
    /// whenever it changes from outside, as when View → Size chooses a
    /// preset.
    let scale: CGFloat

    /// Small's layout on this Mac, and with it the sizing rules (FR-3b).
    let layouts: MeterLayouts

    /// Called with true when any part of the window can be seen again, and
    /// false when none of it can: minimized, fully covered, the app hidden,
    /// or the display asleep (FR-17).
    let onVisibilityChange: (Bool) -> Void

    /// Called with the largest content size the window's screen holds, at
    /// launch and whenever it changes.
    let onLargest: (CGSize) -> Void

    /// Called with the window's scale when a resize ends at a new one, to be
    /// saved (FR-20).
    let onScale: (CGFloat) -> Void

    func makeNSView(context: Context) -> WindowAccessView {
        let view = WindowAccessView(layouts: layouts)
        updateNSView(view, context: context)
        return view
    }

    func updateNSView(_ view: WindowAccessView, context: Context) {
        view.onVisibilityChange = onVisibilityChange
        view.onLargest = onLargest
        view.onScale = onScale
        view.layouts = layouts
        view.keepOnTop = keepOnTop
        view.request(scale)
        view.keepDelegate()
    }
}

/// Sits in front of SwiftUI's window delegate. It answers the window's
/// sizing questions itself, what size to take at each step of a resize, what
/// frame the green button zooms to and whether macOS should zoom it, and
/// hands every other delegate message to SwiftUI's, which it holds on to
/// (requirements §6).
private final class ShapeDelegate: NSObject, NSWindowDelegate {
    /// SwiftUI's own delegate. Held strongly: a window holds its delegate
    /// weakly, and this one now stands in its place.
    nonisolated(unsafe) var original: (any NSWindowDelegate)?

    /// The size to take, given the window frame size macOS proposes.
    var shape: ((NSWindow, NSSize) -> NSSize)?

    /// The frame the green button zooms to.
    var standardFrame: ((NSWindow, NSRect) -> NSRect)?

    /// Whether macOS should zoom the window itself, asked at each press of
    /// the green button.
    var shouldZoom: ((NSWindow) -> Bool)?

    nonisolated override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) { return true }
        return original?.responds(to: aSelector) ?? false
    }

    nonisolated override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let original, original.responds(to: aSelector) { return original }
        return super.forwardingTarget(for: aSelector)
    }

    /// SwiftUI answers first, with its own limits, and the shape is put on
    /// its answer.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        let proposed = original?.windowWillResize?(sender, to: frameSize) ?? frameSize
        return shape?(sender, proposed) ?? proposed
    }

    /// SwiftUI doesn't answer this one.
    func windowWillUseStandardFrame(_ window: NSWindow, defaultFrame newFrame: NSRect) -> NSRect {
        standardFrame?(window, newFrame) ?? newFrame
    }

    /// SwiftUI's answer counts first, if it gives one.
    func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool {
        if original?.windowShouldZoom?(window, toFrame: newFrame) == false { return false }
        return shouldZoom?(window) ?? true
    }
}

/// The AppKit side of `WindowAccess`. It draws nothing and takes no clicks.
final class WindowAccessView: NSView {
    var keepOnTop = true {
        didSet { applyLevel() }
    }

    /// Small's layout on this Mac. Worked out at launch, and again if the
    /// core count changes, when the window keeps its scale at the new
    /// widths (NFR-4, Increment 4.2).
    var layouts: MeterLayouts {
        didSet { layoutsChanged(from: oldValue) }
    }

    var onVisibilityChange: ((Bool) -> Void)?
    var onLargest: ((CGSize) -> Void)?
    var onScale: ((CGFloat) -> Void)?

    private let shapeDelegate = ShapeDelegate()

    /// The saved scale as last passed in. Only a change to it resizes the
    /// window, so a value passed in before a resize's new scale has been
    /// saved can't undo the resize.
    private var requestedScale: CGFloat?

    /// The scale the window is at, from the last resize that ended.
    private var scale = MeterSize.medium.scale

    /// The largest size last passed up.
    private var reportedLargest: CGSize?

    /// The window's frame when a resize began, and what kind it is, or nil
    /// and `.none` when none is under way.
    private var resizeStartFrame: NSRect?
    private var drag = MeterSizing.Drag.none

    /// True while a drag of the top edge or a top corner is under way, when
    /// the window's top edge moves.
    private var movesTop = false

    /// True while this view sets the window's frame or origin, so that its
    /// own changes aren't handled a second time.
    private var isSettingFrame = false

    /// True from a change of layouts until the window has taken its new
    /// width, so that a resize SwiftUI makes meanwhile, to fit the new size
    /// limits, is left alone.
    private var isChangingLayouts = false

    /// False until the window has been set to the saved scale at launch.
    private var isReady = false

    /// The green button's last press, which the next press goes back from
    /// while the window is still where it left it (design §8 item 5).
    private var lastPress: MeterSizing.ZoomPress?

    init(layouts: MeterLayouts) {
        self.layouts = layouts
        super.init(frame: .zero)
        shapeDelegate.shape = { [weak self] window, proposed in
            self?.shaped(proposed, for: window) ?? proposed
        }
        shapeDelegate.standardFrame = { [weak self] window, frame in
            self?.zoomFrame(for: window) ?? frame
        }
        shapeDelegate.shouldZoom = { [weak self] window in
            self?.zoom(window) ?? true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("WindowAccessView is made in code only")
    }

    private var sizing: MeterSizing { layouts.sizing }

    // MARK: - From SwiftUI

    /// The saved scale, passed in on every scene update. A change to it,
    /// such as a preset chosen in View → Size, sets the window to that scale
    /// with its top-left corner in place (FR-22), even when the window was
    /// dragged away from that preset. Not during a resize.
    func request(_ newScale: CGFloat) {
        guard newScale != requestedScale else { return }
        requestedScale = newScale
        guard isReady, let window, !window.inLiveResize else { return }
        take(scale: newScale)
    }

    /// Puts the delegate back in front if SwiftUI replaced it. Checked on
    /// every scene update and at the start of every resize.
    func keepDelegate() {
        guard isReady, let window, window.delegate !== shapeDelegate else { return }
        installDelegate(on: window)
    }

    /// The sizes' widths changed with the core count (NFR-4): the window
    /// keeps its scale at the new widths, with the top-left corner it has
    /// now, and stays on screen (FR-3b, FR-3c, FR-22). This waits one turn
    /// of the run loop, so SwiftUI has applied the content's new size limits
    /// first.
    private func layoutsChanged(from old: MeterLayouts) {
        guard layouts != old, let window, isReady else { return }
        isChangingLayouts = true
        let start = window.frame
        let keptScale = scale
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.reportLargest(fittingWindow: false)
            self.take(scale: keptScale, from: start)
            self.isChangingLayouts = false
        }
    }

    // MARK: - Joining the window

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        // SwiftUI's delegate goes back in place on the window being left.
        if let window, window.delegate === shapeDelegate {
            window.delegate = shapeDelegate.original
        }
        super.viewWillMove(toWindow: newWindow)
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
        // The window's state isn't read here: until it's first ordered on
        // screen, macOS reports it as not visible. The sampler assumes it can
        // be seen until the first notice says otherwise.
        center.addObserver(self, selector: #selector(windowDidChangeOcclusionState(_:)),
                           name: NSWindow.didChangeOcclusionStateNotification, object: window)
        // The largest size follows the window's screen (design §8 item 13).
        center.addObserver(self, selector: #selector(screenChanged(_:)),
                           name: NSWindow.didChangeScreenNotification, object: window)
        center.addObserver(self, selector: #selector(screenChanged(_:)),
                           name: NSApplication.didChangeScreenParametersNotification, object: nil)

        // At launch the saved scale wins over the size of the restored frame,
        // which supplies only the position (FR-19, FR-20). This waits one
        // turn of the run loop, so that SwiftUI has restored the frame and
        // set its own delegate first.
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window else { return }
            self.installDelegate(on: window)
            self.reportLargest(fittingWindow: false)
            self.take(scale: self.requestedScale ?? MeterSize.medium.scale)
            self.isReady = true
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    private func installDelegate(on window: NSWindow) {
        let current = window.delegate
        guard current !== shapeDelegate else { return }
        shapeDelegate.original = current
        window.delegate = shapeDelegate
    }

    /// Floating above other windows when Keep on Top is on; a normal window
    /// that others can cover when it's off (FR-2).
    private func applyLevel() {
        window?.level = keepOnTop ? .floating : .normal
    }

    // MARK: - The delegate's answers

    /// The frame size to take at one step of a resize, given the one macOS
    /// proposes: Small's shape, by the kind of resize read when it started,
    /// from Small up to the largest size (FR-3d, design §2). While the top
    /// edge is dragged, the size also stops where the top edge reaches the
    /// top of the visible area, so the opposite edge or corner stays in
    /// place (FR-22). Without that, a top corner's size could outgrow the
    /// room above the window, and macOS would push the window down below
    /// the menu bar.
    private func shaped(_ proposed: NSSize, for window: NSWindow) -> NSSize {
        let bar = titleBarHeight(of: window)
        let asked = CGSize(width: proposed.width, height: proposed.height - bar)
        var largest = largestSize(for: window)
        if movesTop, let start = resizeStartFrame, let visible = (window.screen ?? NSScreen.main)?.visibleFrame {
            let room = visible.maxY - start.minY - bar
            largest = sizing.largest(in: CGSize(width: largest.width, height: min(largest.height, room)))
        }
        let content = sizing.answer(asked: asked, drag: drag, largest: largest)
        return NSSize(width: content.width, height: content.height + bar)
    }

    /// Where the next press of the green button takes the window: to the
    /// largest size, back to where the last press started, or from the
    /// largest to Large (requirements §8 item 21, design §8 item 5).
    private func zoomFrame(for window: NSWindow) -> NSRect {
        guard let visible = (window.screen ?? NSScreen.main)?.visibleFrame else { return window.frame }
        return sizing.zoomTarget(from: window.frame, lastPress: lastPress,
                                 titleBar: titleBarHeight(of: window),
                                 largest: largestSize(for: window), visible: visible)
    }

    /// A press of the green button, Window → Zoom, or a double-click on the
    /// title bar. CPUMeter moves the window itself, animated as macOS would,
    /// and tells macOS not to, so macOS's own idea of zoomed and unzoomed
    /// doesn't decide where it goes. Until 5.7, at Large with nothing to go
    /// back to, macOS took the window to an in-between size of its own.
    private func zoom(_ window: NSWindow) -> Bool {
        let start = window.frame
        let target = zoomFrame(for: window)
        let goingBack = lastPress.map { MeterSizing.isSameFrame(start, $0.to) } ?? false
        lastPress = goingBack ? nil : MeterSizing.ZoomPress(from: start, to: target)
        guard target != start else { return false }
        // After macOS has finished with the press.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.window === window, window.frame == start else { return }
            self.isSettingFrame = true
            window.setFrame(target, display: true, animate: true)
            self.isSettingFrame = false
            // In shape and on screen, with its scale saved, as after any
            // resize; and where the window really ended, for the next press.
            self.settle(window)
            if !goingBack { self.lastPress?.to = window.frame }
        }
        return false
    }

    // MARK: - Resizing

    /// macOS says whether any part of the window can be seen changed: it was
    /// minimized or restored, fully covered or uncovered, the app was hidden
    /// or shown, or the display slept or woke (FR-17). A window only partly
    /// covered still counts as seen.
    @objc private func windowDidChangeOcclusionState(_ notification: Notification) {
        guard let window else { return }
        onVisibilityChange?(window.occlusionState.contains(.visible))
    }

    /// A resize begins: a drag, or the green button or a tiling layout
    /// animating. Its kind is read once, from the mouse (`MeterSizing.drag`).
    @objc private func windowWillStartLiveResize(_ notification: Notification) {
        guard let window else { return }
        keepDelegate()
        // In case the visible area changed with no notice, such as the Dock
        // showing.
        reportLargest(fittingWindow: false)
        resizeStartFrame = window.frame
        let mouse = NSEvent.mouseLocation
        drag = MeterSizing.drag(mouse: mouse, frame: window.frame,
                                buttonDown: NSEvent.pressedMouseButtons & 1 == 1)
        movesTop = (drag == .topOrBottom || drag == .corner) && mouse.y > window.frame.midY
    }

    /// A resize ended. The window stays at its size, brought on screen if the
    /// drag took it off (FR-3d, FR-22), and its scale is saved (FR-20).
    @objc private func windowDidEndLiveResize(_ notification: Notification) {
        guard let window else { return }
        resizeStartFrame = nil
        drag = .none
        movesTop = false
        settle(window)
    }

    /// During a drag, a side's edge is held in place (design §2 step 1).
    /// Any other resize, such as SwiftUI keeping its limits or another app
    /// sizing the window, is put into Small's shape, on screen (FR-3d,
    /// FR-22), and its scale saved (FR-20).
    @objc private func windowDidResize(_ notification: Notification) {
        guard let window, isReady, !isSettingFrame else { return }
        if window.inLiveResize {
            holdEdge(of: window)
        } else if !isChangingLayouts {
            settle(window)
        }
    }

    /// Put back the edge a side drag keeps, where macOS centered it
    /// (design §2 step 1, §8 item 7).
    private func holdEdge(of window: NSWindow) {
        guard let start = resizeStartFrame,
              let origin = MeterSizing.heldOrigin(of: window.frame, start: start, drag: drag) else { return }
        isSettingFrame = true
        window.setFrameOrigin(origin)
        isSettingFrame = false
    }

    /// The window at the end of a resize: in Small's shape, which every
    /// answer gives, or put into it if something sized it without asking;
    /// on screen; and its scale saved.
    private func settle(_ window: NSWindow) {
        let content = contentSize(ofFrame: window.frame)
        let shaped = sizing.isInShape(content)
            ? content
            : sizing.answer(asked: content, drag: .none, largest: largestSize(for: window))
        setContent(shaped)
        resizeEnded()
    }

    /// The window takes a scale's size with its top-left corner in place, or
    /// the largest size that fits if it doesn't (FR-22). `start` is the frame
    /// to keep the corner of, if not the current one.
    private func take(scale newScale: CGFloat, from start: NSRect? = nil) {
        guard let window else { return }
        let wanted = newScale.isFinite && newScale > 0 ? newScale : MeterSize.medium.scale
        let content = sizing.clamped(width: sizing.size(atScale: wanted).width, largest: largestSize(for: window))
        setContent(content, from: start)
        resizeEnded()
    }

    /// A resize ended: the window's scale is passed up to be saved, if it
    /// isn't the saved one already (FR-20). On the next turn of the run
    /// loop, because a resize can arrive while SwiftUI is in the middle of
    /// updating its views.
    private func resizeEnded() {
        guard let window else { return }
        let newScale = sizing.scale(ofWidth: contentSize(ofFrame: window.frame).width)
        scale = newScale
        guard newScale != requestedScale else { return }
        let onScale = onScale
        DispatchQueue.main.async { onScale?(newScale) }
    }

    /// Sets the window's content to a size with the top-left corner of
    /// `start`, or of the current frame, then moves it just far enough to be
    /// on screen (FR-22).
    private func setContent(_ content: CGSize, from start: NSRect? = nil) {
        guard let window else { return }
        let target = frame(for: content, keepingTopLeftOf: start ?? window.frame, in: window)
        guard target != window.frame else { return }
        isSettingFrame = true
        window.setFrame(target, display: true, animate: false)
        isSettingFrame = false
    }

    // MARK: - Limits (FR-3d, FR-22, design §8 item 13)

    /// The screen changed: the window moved to another, or the screens'
    /// arrangement or visible areas did.
    @objc private func screenChanged(_ notification: Notification) {
        reportLargest(fittingWindow: true)
    }

    /// Passes up the largest size the window's screen holds, if it changed.
    /// With `fittingWindow`, a window now larger than that first takes the
    /// largest size, its top-left corner kept where it can be.
    private func reportLargest(fittingWindow: Bool) {
        guard let window else { return }
        let largest = largestSize(for: window)
        guard largest != reportedLargest else { return }
        reportedLargest = largest
        if fittingWindow, isReady, contentSize(ofFrame: window.frame).width > largest.width + 0.001 {
            setContent(largest)
            resizeEnded()
        }
        let onLargest = onLargest
        DispatchQueue.main.async { onLargest?(largest) }
    }

    /// The largest content size of Small's shape the window's screen holds:
    /// its visible area, clear of the menu bar and Dock, less the title bar
    /// (requirements §8 items 23 and 30). The screen is the one macOS says
    /// the window is on.
    private func largestSize(for window: NSWindow) -> CGSize {
        guard let visible = (window.screen ?? NSScreen.main)?.visibleFrame else {
            return CGSize(width: CGFloat.infinity, height: .infinity)
        }
        return sizing.largest(in: CGSize(width: visible.width, height: visible.height - titleBarHeight(of: window)))
    }

    // MARK: - Geometry

    /// The frame for a content size with the top-left corner of `anchor`,
    /// moved just far enough to be on screen (FR-22).
    private func frame(for content: CGSize, keepingTopLeftOf anchor: NSRect, in window: NSWindow) -> NSRect {
        let height = content.height + titleBarHeight(of: window)
        let frame = NSRect(x: anchor.minX, y: anchor.maxY - height, width: content.width, height: height)
        guard let visible = (window.screen ?? NSScreen.main)?.visibleFrame else { return frame }
        return MeterSizing.onScreen(frame, visible: visible)
    }

    /// The content area a window frame has, below the title bar.
    private func contentSize(ofFrame frame: NSRect) -> CGSize {
        guard let window else { return frame.size }
        return CGSize(width: frame.width, height: frame.height - titleBarHeight(of: window))
    }

    /// SwiftUI's window has a full-size content view, so the title bar is
    /// the difference between the frame and the layout rectangle: 32 points.
    private func titleBarHeight(of window: NSWindow) -> CGFloat {
        window.frame.height - window.contentLayoutRect.height
    }
}
