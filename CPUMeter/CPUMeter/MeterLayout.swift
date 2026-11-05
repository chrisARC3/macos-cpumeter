//
//  MeterLayout.swift
//  CPUMeter
//
//  The width rule (FR-3b) and the numbers from §2 of the design document,
//  turned into the window's size and the place of every label, bar and figure.
//  Increment 2.1. Everything here except `measuredLabelWidth` is a pure
//  function of the core groups and the label widths, so the rule can be
//  checked without AppKit or a window.
//

import CoreGraphics
import AppKit

/// The numbers from §2 of the design document for one size, in points.
nonisolated struct MeterMetrics: Equatable, Sendable {
    // MARK: Across (FR-3b)

    /// Margin on all sides of the content.
    var margin: CGFloat
    /// Gap between one group of bars and the next.
    var groupGap: CGFloat
    /// The least width a core gets, so that figures reading 100 stay separate
    /// numbers (FR-11, design §7).
    var minimumCoreWidth: CGFloat
    /// Gap between neighboring bars. Each bar is inset half of it on each side.
    var barGap: CGFloat
    var cornerRadius: CGFloat

    // MARK: Down, top to bottom (design §2, Vertical spacing)

    var topRowHeight: CGFloat
    var gapBelowTopRow: CGFloat
    var labelHeight: CGFloat
    var gapBelowLabels: CGFloat
    var barHeight: CGFloat
    var gapBelowBars: CGFloat
    var figureHeight: CGFloat

    // MARK: Text sizes, all in the system font (design §2, Text)

    /// The overall figure, semibold.
    var overallFontSize: CGFloat
    /// The color key, regular.
    var keyFontSize: CGFloat
    /// The group labels, medium.
    var labelFontSize: CGFloat
    /// The per-core figures, regular, with monospaced digits.
    var figureFontSize: CGFloat

    // MARK: Color key (design §2)

    var keyDotDiameter: CGFloat
    /// Between a dot and its word.
    var keyDotGap: CGFloat
    /// Between User and System.
    var keyItemGap: CGFloat

    static let small = MeterMetrics(
        margin: 12, groupGap: 12, minimumCoreWidth: 21, barGap: 3, cornerRadius: 2,
        topRowHeight: 16, gapBelowTopRow: 6, labelHeight: 12, gapBelowLabels: 3,
        barHeight: 74, gapBelowBars: 3, figureHeight: 12,
        overallFontSize: 13, keyFontSize: 10, labelFontSize: 10, figureFontSize: 10,
        keyDotDiameter: 7, keyDotGap: 4, keyItemGap: 8)

    static let medium = MeterMetrics(
        margin: 14, groupGap: 14, minimumCoreWidth: 23, barGap: 4, cornerRadius: 3,
        topRowHeight: 20, gapBelowTopRow: 8, labelHeight: 14, gapBelowLabels: 4,
        barHeight: 134, gapBelowBars: 4, figureHeight: 13,
        overallFontSize: 16, keyFontSize: 11, labelFontSize: 11, figureFontSize: 11,
        keyDotDiameter: 8, keyDotGap: 4, keyItemGap: 10)

    static let large = MeterMetrics(
        margin: 16, groupGap: 16, minimumCoreWidth: 25, barGap: 5, cornerRadius: 3,
        topRowHeight: 24, gapBelowTopRow: 10, labelHeight: 15, gapBelowLabels: 5,
        barHeight: 195, gapBelowBars: 5, figureHeight: 14,
        overallFontSize: 20, keyFontSize: 12, labelFontSize: 12, figureFontSize: 12,
        keyDotDiameter: 9, keyDotGap: 4, keyItemGap: 12)
}

nonisolated extension MeterSize {
    /// The design document's numbers at this size.
    var metrics: MeterMetrics {
        switch self {
        case .small: .small
        case .medium: .medium
        case .large: .large
        }
    }
}

/// Where everything goes at one size. Points from the content's top-left
/// corner, below the title bar, as `Canvas` draws. Positions aren't rounded to
/// whole pixels here; the meter's drawing does that (Increment 2.2).
nonisolated struct MeterLayout: Equatable, Sendable {
    /// One bar and the figure under it.
    nonisolated struct Bar: Equatable, Sendable {
        /// The core's logical ID, which indexes `CPUSample.cores`.
        var core: Int
        /// The bar's track: its full height is 100% of the core's time
        /// (FR-9, design §3).
        var track: CGRect
        /// The per-core figure, centered under the bar (FR-11). As wide as the
        /// core's share of the width, so it reaches half a bar gap past the
        /// bar on each side.
        var figure: CGRect
    }

    /// One group of bars and its label.
    nonisolated struct Group: Equatable, Sendable {
        /// The name followed by " %", such as "Efficiency %" (FR-8d).
        var label: String
        /// Where the label goes: left-aligned to the group and as wide as it.
        /// The label fits within this width (FR-3b).
        var labelFrame: CGRect
        /// The group's bars, in logical-ID order.
        var bars: [Bar]
    }

    /// What the width rule needs to know about one group.
    nonisolated struct GroupNeed: Equatable, Sendable {
        var cores: Int
        /// The label's width, as `measuredLabelWidth` gives it.
        var labelWidth: CGFloat
    }

    var size: MeterSize
    var metrics: MeterMetrics

    /// The window's content area at this size, below the title bar (FR-3a,
    /// FR-3b).
    var contentSize: CGSize

    /// The width each core gets once the bars share the window's width. At
    /// least the minimum, and more on Macs at the base width (design §2).
    var coreWidth: CGFloat

    /// The top row: the overall figure at its left, the color key at its
    /// right (FR-27).
    var topRow: CGRect

    /// The groups, lowest to highest performance, left to right (FR-8b).
    var groups: [Group]

    // MARK: - The width rule (FR-3b)

    /// The width per core the bars need: the minimum, or more if a group's
    /// label wouldn't otherwise fit within that group. One width for every
    /// core, so bars are the same width in every group.
    static func neededCoreWidth(for needs: [GroupNeed], size: MeterSize) -> CGFloat {
        needs.filter { $0.cores > 0 }
            .map { $0.labelWidth / CGFloat($0.cores) }
            .reduce(size.metrics.minimumCoreWidth, max)
    }

    /// The content width (FR-3b): the larger of the base width and
    /// 2 × margin + group gap × (groups − 1) + cores × width per core,
    /// rounded up to a whole point.
    static func contentWidth(for needs: [GroupNeed], size: MeterSize) -> CGFloat {
        let metrics = size.metrics
        let cores = needs.reduce(0) { $0 + $1.cores }
        let gaps = metrics.groupGap * CGFloat(max(needs.count - 1, 0))
        let needed = 2 * metrics.margin + gaps + CGFloat(cores) * neededCoreWidth(for: needs, size: size)
        // The tolerance keeps floating-point noise in a whole number from
        // adding a point. It is far below anything that could show.
        return max(size.baseWidth, (needed - 1e-6).rounded(.up))
    }

    // MARK: - Positions

    /// The layout of the given groups at one size.
    ///
    /// - Parameters:
    ///   - groups: The core groups, lowest to highest performance.
    ///   - labelWidth: Each group label's width at this size's label font
    ///     size. `measuredLabelWidth` in the app; fixed figures in tests.
    init(groups coreGroups: [CoreGroup], size: MeterSize, labelWidth: (String) -> CGFloat) {
        let metrics = size.metrics
        let needs = coreGroups.map { GroupNeed(cores: $0.cores.count, labelWidth: labelWidth($0.label)) }
        let width = Self.contentWidth(for: needs, size: size)
        let cores = needs.reduce(0) { $0 + $1.cores }
        let gaps = metrics.groupGap * CGFloat(max(needs.count - 1, 0))
        // Bars share whatever width the window has (design §2).
        let coreWidth = cores > 0 ? (width - 2 * metrics.margin - gaps) / CGFloat(cores) : 0

        // Down the window, top to bottom (design §2, Vertical spacing).
        let labelY = metrics.margin + metrics.topRowHeight + metrics.gapBelowTopRow
        let barY = labelY + metrics.labelHeight + metrics.gapBelowLabels
        let figureY = barY + metrics.barHeight + metrics.gapBelowBars

        var groups: [Group] = []
        var groupX = metrics.margin
        for group in coreGroups {
            let bars = group.cores.enumerated().map { index, core in
                let cellX = groupX + CGFloat(index) * coreWidth
                return Bar(
                    core: core,
                    track: CGRect(x: cellX + metrics.barGap / 2, y: barY,
                                  width: coreWidth - metrics.barGap, height: metrics.barHeight),
                    figure: CGRect(x: cellX, y: figureY,
                                   width: coreWidth, height: metrics.figureHeight))
            }
            let groupWidth = CGFloat(group.cores.count) * coreWidth
            groups.append(Group(
                label: group.label,
                labelFrame: CGRect(x: groupX, y: labelY, width: groupWidth, height: metrics.labelHeight),
                bars: bars))
            groupX += groupWidth + metrics.groupGap
        }

        self.size = size
        self.metrics = metrics
        self.contentSize = CGSize(width: width, height: size.height)
        self.coreWidth = coreWidth
        self.topRow = CGRect(x: metrics.margin, y: metrics.margin,
                             width: width - 2 * metrics.margin, height: metrics.topRowHeight)
        self.groups = groups
    }

    // MARK: - Measuring the labels (requirements §6, the third use of AppKit)

    /// A group label's width in the system font at medium weight, as the meter
    /// draws it. The window's size has to be known before anything is drawn,
    /// so this can't wait for `Canvas` to measure the text. AppKit gives the
    /// exact width, where `Canvas` rounds up to whole points.
    static func measuredLabelWidth(_ label: String, fontSize: CGFloat) -> CGFloat {
        let font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        return NSAttributedString(string: label, attributes: [.font: font]).size().width
    }
}

/// The layout at each of the three sizes, worked out once at launch from this
/// Mac's core groups. Nothing here is stored, so the window is always sized for
/// the Mac the app is running on (FR-3b, FR-3c).
nonisolated struct MeterLayouts: Equatable, Sendable {
    private var small: MeterLayout
    private var medium: MeterLayout
    private var large: MeterLayout

    /// - Parameters:
    ///   - groups: The core groups, lowest to highest performance.
    ///   - labelWidth: A label's width at a font size. AppKit's measurement in
    ///     the app; fixed figures in tests.
    init(groups: [CoreGroup],
         labelWidth: (_ label: String, _ fontSize: CGFloat) -> CGFloat = MeterLayout.measuredLabelWidth) {
        func layout(_ size: MeterSize) -> MeterLayout {
            MeterLayout(groups: groups, size: size) { labelWidth($0, size.metrics.labelFontSize) }
        }
        small = layout(.small)
        medium = layout(.medium)
        large = layout(.large)
    }

    subscript(size: MeterSize) -> MeterLayout {
        switch size {
        case .small: small
        case .medium: medium
        case .large: large
        }
    }

    /// The window's content area at a size, below the title bar.
    func contentSize(of size: MeterSize) -> CGSize {
        self[size].contentSize
    }
}
