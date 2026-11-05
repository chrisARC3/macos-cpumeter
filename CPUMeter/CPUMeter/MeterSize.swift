//
//  MeterSize.swift
//  CPUMeter
//
//  The three window sizes and the rule that picks one when a resize ends.
//  Increment 0.3. Kept free of windows and views so the rule can be tested
//  on its own.
//

import CoreGraphics

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

    /// Base content width in points (FR-3b). The window is at least this wide,
    /// and wider when the Mac's cores need it: `MeterLayout` works out the
    /// real width.
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

    /// The size a window settles at when a resize ends (FR-3d, design §2).
    ///
    /// Whichever dimension changed more, as a share of its range from Small to
    /// Large, decides. The window settles at the size nearest the new value in
    /// that dimension, and an exact tie goes to the larger size. If both
    /// dimensions changed by the same share, width decides.
    ///
    /// - Parameters:
    ///   - start: The content size when the resize began.
    ///   - end: The content size when it ended.
    ///   - sizeOf: Each size's content size on this Mac, from `MeterLayouts`.
    static func settled(
        from start: CGSize,
        to end: CGSize,
        sizeOf: (MeterSize) -> CGSize
    ) -> MeterSize {
        let small = sizeOf(.small)
        let large = sizeOf(.large)
        let widthShare = share(of: end.width - start.width, over: large.width - small.width)
        let heightShare = share(of: end.height - start.height, over: large.height - small.height)

        let widthDecides = widthShare >= heightShare
        let value = widthDecides ? end.width : end.height
        func dimension(_ size: MeterSize) -> CGFloat {
            widthDecides ? sizeOf(size).width : sizeOf(size).height
        }

        // Small to Large, so `<=` hands an exact tie to the larger size.
        var nearest = MeterSize.small
        for size in allCases where abs(value - dimension(size)) <= abs(value - dimension(nearest)) {
            nearest = size
        }
        return nearest
    }

    /// A change as a share of a range, or 0 when the range is empty.
    private static func share(of change: CGFloat, over range: CGFloat) -> CGFloat {
        range > 0 ? abs(change) / range : 0
    }
}
