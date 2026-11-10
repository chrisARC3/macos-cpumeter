//
//  MeterSize.swift
//  CPUMeter
//
//  The window's sizes: the three presets, and the rules that give a size at
//  any scale, the largest size a screen holds, and the size to take at each
//  step of a resize. Increment 0.3, rewritten in Increment 5.4 for free
//  sizing (requirements v1.17 and v1.18): every size is Small enlarged.
//  Kept free of windows and views, so every rule can be tested on its own.
//

import CoreGraphics

/// The three presets in View → Size (FR-3, FR-24). Each is Small enlarged by
/// its scale.
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

    /// How many times Small this preset is (FR-3).
    var scale: CGFloat {
        switch self {
        case .small: 1
        case .medium: 1.5
        case .large: 2
        }
    }

    /// The preset with exactly this scale, or nil for any other scale. The
    /// saved scale of a window at a preset is always the preset's own (see
    /// `MeterSizing.scale(ofWidth:)`), so this tells View → Size which
    /// preset to check (FR-24, design §8 item 12).
    static func preset(atScale scale: CGFloat) -> MeterSize? {
        allCases.first { $0.scale == scale }
    }

    /// The scale to save in place of a size saved by an earlier build, by
    /// name (FR-20): "small", "medium" or "large" carries over as that
    /// preset's scale. Nil for anything else.
    static func carriedOverScale(fromSavedSize name: String?) -> CGFloat? {
        name.flatMap(MeterSize.init(rawValue:))?.scale
    }
}

/// The sizing rules for one Mac, worked out from Small's content size there
/// (FR-3, FR-3a, FR-3b). Content sizes are in points, below the title bar.
nonisolated struct MeterSizing: Equatable, Sendable {
    /// Small's content size on this Mac, from `MeterLayout`.
    var small: CGSize

    /// A length to the nearest whole point, with a half rounding up
    /// (design §2, §8 item 11).
    static func toPoint(_ value: CGFloat) -> CGFloat {
        (value + 0.5).rounded(.down)
    }

    // MARK: - Sizes

    /// The content size in Small's shape at a width: the height is the width
    /// times Small's height over Small's width, to the nearest point
    /// (FR-3a). This is the window's shape at every size.
    func size(atWidth width: CGFloat) -> CGSize {
        // Multiplied before dividing, so whole numbers give an exact half
        // where there is one.
        CGSize(width: width, height: Self.toPoint(width * small.height / small.width))
    }

    /// The content size at a scale: Small's width times the scale, to the
    /// nearest point, and the height from that width (FR-3b, design §2). A
    /// scale saved from a width gives that width back exactly.
    func size(atScale scale: CGFloat) -> CGSize {
        size(atWidth: Self.toPoint(small.width * scale))
    }

    /// A preset's content size: for Medium, Small's width times 1.5 with a
    /// half rounding up, and 225 high; for Large, twice Small (requirements
    /// §6).
    func size(of preset: MeterSize) -> CGSize {
        size(atScale: preset.scale)
    }

    /// The scale to save for a window this wide (FR-20): a preset's own
    /// scale when the width is exactly that preset's, so a preset carries
    /// over as itself to a Mac with another Small, and otherwise the width
    /// over Small's (FR-3).
    func scale(ofWidth width: CGFloat) -> CGFloat {
        if let preset = MeterSize.allCases.first(where: { abs(size(of: $0).width - width) < 0.001 }) {
            return preset.scale
        }
        return width / small.width
    }

    // MARK: - Limits

    /// The largest content size of Small's shape that fits an area: the
    /// widest whole-point width whose exact height, before rounding, fits
    /// (requirements §8 item 30). Never smaller than Small (requirements
    /// §9). For the screen, the area is its visible area with the title bar
    /// taken off its height: 2259 × 1377 on the M4.
    func largest(in area: CGSize) -> CGSize {
        let widthFromHeight = area.height * small.width / small.height
        var width = (min(area.width, widthFromHeight) + 1e-9).rounded(.down)
        // The height rounds to the nearest point, so on an area of
        // fractional height it could round up past it.
        while width > small.width, size(atWidth: width).height > area.height + 1e-9 {
            width -= 1
        }
        return size(atWidth: max(width, small.width))
    }

    /// The size in Small's shape at a width, kept from Small up to the
    /// largest size (FR-3d, FR-22). Every size has the same shape, so the
    /// width alone decides.
    func clamped(width: CGFloat, largest: CGSize) -> CGSize {
        size(atWidth: min(max(width, small.width), max(largest.width, small.width)))
    }

    // MARK: - Resizing (FR-3d, design §2, requirements §8 items 20–22)

    /// What kind of resize is under way, read once when it starts.
    enum Drag: Equatable, Sendable {
        /// Not a drag: the green button, a tiling layout, or Fill.
        case none
        /// The left or right edge: the width leads.
        case side
        /// The top or bottom edge: the height leads.
        case topOrBottom
        /// A corner: the width and the height both lead.
        case corner
    }

    /// How close to an edge, in points, the mouse can be for a drag to count
    /// as being at that edge, so that within this distance of a side and of
    /// the top or bottom it's a corner. macOS's own corner grab area is
    /// smaller.
    static let cornerReach: CGFloat = 24

    /// The kind of resize from where the mouse is when it starts, in screen
    /// coordinates. With no mouse button down it isn't a drag. Otherwise it
    /// is at a corner when within `cornerReach` of a side and of the top or
    /// bottom, and else at whichever edge is nearer.
    static func drag(mouse: CGPoint, frame: CGRect, buttonDown: Bool) -> Drag {
        guard buttonDown else { return .none }
        let fromSide = min(abs(mouse.x - frame.minX), abs(mouse.x - frame.maxX))
        let fromTopOrBottom = min(abs(mouse.y - frame.minY), abs(mouse.y - frame.maxY))
        if fromSide <= cornerReach, fromTopOrBottom <= cornerReach { return .corner }
        return fromSide < fromTopOrBottom ? .side : .topOrBottom
    }

    /// The content size to take at one step of a resize, given the content
    /// size macOS asks for.
    ///
    /// - A side sets the width, and the height follows.
    /// - The top or bottom sets the height, and the width follows.
    /// - A corner follows the average of the widths the two ask for, so the
    ///   size moves smoothly rather than switching between them.
    /// - Not a drag: a size already in Small's shape is kept as it is, so
    ///   the green button comes back to exactly the size it had (design §8
    ///   item 5). Any other size, such as a tile, gets the largest size of
    ///   the shape that fits within it (requirements §8 item 22).
    ///
    /// Always a whole-point width in Small's shape, from Small up to the
    /// largest size.
    func answer(asked: CGSize, drag: Drag, largest: CGSize) -> CGSize {
        let widthFromHeight = asked.height * small.width / small.height
        let width: CGFloat
        switch drag {
        case .side:
            width = asked.width
        case .topOrBottom:
            width = widthFromHeight
        case .corner:
            width = (asked.width + widthFromHeight) / 2
        case .none:
            width = isInShape(asked) ? asked.width : self.largest(in: asked).width
        }
        return clamped(width: Self.toPoint(width), largest: largest)
    }

    /// True for a whole-point width with its height in Small's shape.
    func isInShape(_ content: CGSize) -> Bool {
        let width = Self.toPoint(content.width)
        return abs(content.width - width) < 0.001 && abs(content.height - size(atWidth: width).height) < 0.001
    }

    // MARK: - Frames on screen (Cocoa coordinates, y up)

    /// Where a side drag puts the window back after a step, or nil to leave
    /// it. macOS centers the dimension a side doesn't set, so a left or right
    /// side gets its top edge back where it was when the drag started, and
    /// the top or bottom its left edge (design §2 step 1, §8 item 7).
    static func heldOrigin(of frame: CGRect, start: CGRect, drag: Drag) -> CGPoint? {
        switch drag {
        case .side:
            guard abs(frame.maxY - start.maxY) > 0.25 else { return nil }
            return CGPoint(x: frame.minX, y: start.maxY - frame.height)
        case .topOrBottom:
            guard abs(frame.minX - start.minX) > 0.25 else { return nil }
            return CGPoint(x: start.minX, y: frame.minY)
        case .corner, .none:
            return nil
        }
    }

    /// A frame moved just far enough to be within the screen's visible area,
    /// clear of the menu bar and Dock (FR-22). If it can't fit, its top-left
    /// corner wins, so the title bar stays reachable.
    static func onScreen(_ frame: CGRect, visible: CGRect) -> CGRect {
        var frame = frame
        if frame.maxX > visible.maxX { frame.origin.x = visible.maxX - frame.width }
        if frame.minX < visible.minX { frame.origin.x = visible.minX }
        if frame.minY < visible.minY { frame.origin.y = visible.minY }
        if frame.maxY > visible.maxY { frame.origin.y = visible.maxY - frame.height }
        return frame
    }
}
