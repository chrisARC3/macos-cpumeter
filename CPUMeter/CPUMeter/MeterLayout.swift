//
//  MeterLayout.swift
//  CPUMeter
//
//  The width rule (FR-3b) and the numbers from §2 of the design document,
//  turned into the window's size and the place of every label, bar and figure.
//  Increment 2.1. Since Increment 2.3 it also forms the labels' text (FR-8d),
//  shortens "Performance" where FR-8e says, and lays out the unlabeled
//  fallback row (FR-8c). Everything here except `measuredLabelWidth` is a pure
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
    /// The group labels, medium, with monospaced digits for the average.
    var labelFontSize: CGFloat
    /// The per-core figures, regular, with monospaced digits.
    var figureFontSize: CGFloat

    // MARK: Color key (design §2)

    var keyDotDiameter: CGFloat
    /// Between a dot and its word.
    var keyDotGap: CGFloat
    /// Between System and User.
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

    /// A group's label: its name, a colon and its average, such as
    /// "Efficiency: 24%" (FR-8d). The meter adds the average as it draws.
    nonisolated struct Label: Equatable, Sendable {
        /// The name as the label shows it: exactly as macOS gives it (FR-8a),
        /// or "Perf" where FR-8e shortens "Performance".
        var name: String
        /// Where the label goes: left-aligned to the group and as wide as it.
        /// The label at its widest, "Name: 100%", fits within this width
        /// (FR-3b).
        var frame: CGRect
    }

    /// One group of bars and its label.
    nonisolated struct Group: Equatable, Sendable {
        /// The group's label, or nil on the fallback row, which has none
        /// (FR-8c).
        var label: Label?
        /// The group's bars, in logical-ID order.
        var bars: [Bar]
    }

    /// What the width rule needs to know about one group.
    nonisolated struct GroupNeed: Equatable, Sendable {
        var cores: Int
        /// The label's width at its widest, as `measuredLabelWidth` gives it,
        /// or 0 for a group with no label.
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

    // MARK: - Label text (FR-8d, FR-8e, FR-10)

    /// The meter's one form of label: a name, a colon and a whole percentage,
    /// such as "Efficiency: 24%" or "All cores: 42%", or a dash in place of
    /// the percentage before the first reading, such as "Efficiency: –"
    /// (FR-8d, FR-10, design §6). The width rule and the drawing both use it,
    /// so they can't disagree.
    static func labelText(_ name: String, percent: Int?) -> String {
        "\(name): " + (percent.map { "\($0)%" } ?? "–")
    }

    /// A group's label at its widest, with its average at 100%. The width
    /// rule keeps room for it, so the name never moves (FR-3b, NFR-3).
    static func widestLabel(_ name: String) -> String {
        labelText(name, percent: 100)
    }

    /// The names FR-8e may shorten, and what to.
    static let shortNames = ["Performance": "Perf"]

    /// The names the labels show at one size: exactly as macOS gives them
    /// (FR-8a), except that the names in `shortNames` are shortened if, and
    /// only if, that gives a narrower window at this size (FR-8e). Decided
    /// from the labels at their widest, so a label never switches between
    /// the two as its average changes.
    static func shownNames(for groups: [CoreGroup], size: MeterSize,
                           labelWidth: (String) -> CGFloat) -> [String] {
        let full = groups.map(\.name)
        let short = full.map { shortNames[$0] ?? $0 }
        guard short != full else { return full }
        func width(_ names: [String]) -> CGFloat {
            contentWidth(for: zip(groups, names).map {
                GroupNeed(cores: $0.cores.count, labelWidth: labelWidth(widestLabel($1)))
            }, size: size)
        }
        return width(short) < width(full) ? short : full
    }

    // MARK: - Positions

    /// The layout of the given groups at one size.
    ///
    /// - Parameters:
    ///   - groups: The core groups, lowest to highest performance.
    ///   - labeled: False for the fallback row (FR-8c), which has no label.
    ///     Its bars take the label's height and the gap below it, and the
    ///     label needs no width.
    ///   - labelWidth: A label's width at this size's label font size, given
    ///     its full text. `measuredLabelWidth` in the app; fixed figures in
    ///     tests.
    init(groups coreGroups: [CoreGroup], size: MeterSize, labeled: Bool, labelWidth: (String) -> CGFloat) {
        let metrics = size.metrics
        let names: [String?] = labeled
            ? Self.shownNames(for: coreGroups, size: size, labelWidth: labelWidth)
            : coreGroups.map { _ in nil }
        let needs = zip(coreGroups, names).map { group, name in
            GroupNeed(cores: group.cores.count, labelWidth: name.map { labelWidth(Self.widestLabel($0)) } ?? 0)
        }
        let width = Self.contentWidth(for: needs, size: size)
        let cores = needs.reduce(0) { $0 + $1.cores }
        let gaps = metrics.groupGap * CGFloat(max(needs.count - 1, 0))
        // Bars share whatever width the window has (design §2).
        let coreWidth = cores > 0 ? (width - 2 * metrics.margin - gaps) / CGFloat(cores) : 0

        // Down the window, top to bottom (design §2, Vertical spacing). With
        // no label, the bars start where the label would and grow by the
        // label's height and the gap below it, so they end where labeled bars
        // do: 89, 152 and 215 tall (design §2, §6).
        let labelY = metrics.margin + metrics.topRowHeight + metrics.gapBelowTopRow
        let barY = labeled ? labelY + metrics.labelHeight + metrics.gapBelowLabels : labelY
        let barHeight = labeled ? metrics.barHeight
                                : metrics.labelHeight + metrics.gapBelowLabels + metrics.barHeight
        let figureY = barY + barHeight + metrics.gapBelowBars

        var groups: [Group] = []
        var groupX = metrics.margin
        for (group, name) in zip(coreGroups, names) {
            let bars = group.cores.enumerated().map { index, core in
                let cellX = groupX + CGFloat(index) * coreWidth
                return Bar(
                    core: core,
                    track: CGRect(x: cellX + metrics.barGap / 2, y: barY,
                                  width: coreWidth - metrics.barGap, height: barHeight),
                    figure: CGRect(x: cellX, y: figureY,
                                   width: coreWidth, height: metrics.figureHeight))
            }
            let groupWidth = CGFloat(group.cores.count) * coreWidth
            groups.append(Group(
                label: name.map {
                    Label(name: $0,
                          frame: CGRect(x: groupX, y: labelY, width: groupWidth, height: metrics.labelHeight))
                },
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

    /// A group label's width in the system font at medium weight, with
    /// monospaced digits, as the meter draws it. The window's size has to be
    /// known before anything is drawn, so this can't wait for `Canvas` to
    /// measure the text. AppKit gives the exact width, where `Canvas` rounds
    /// up to whole points.
    static func measuredLabelWidth(_ label: String, fontSize: CGFloat) -> CGFloat {
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .medium)
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
    ///   - labeled: False for the fallback row (FR-8c), which has no label.
    ///   - labelWidth: A label's width at a font size. AppKit's measurement in
    ///     the app; fixed figures in tests.
    init(groups: [CoreGroup], labeled: Bool,
         labelWidth: (_ label: String, _ fontSize: CGFloat) -> CGFloat = MeterLayout.measuredLabelWidth) {
        func layout(_ size: MeterSize) -> MeterLayout {
            MeterLayout(groups: groups, size: size, labeled: labeled) { labelWidth($0, size.metrics.labelFontSize) }
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
