//
//  MeterLayout.swift
//  CPUMeter
//
//  The width rule (FR-3b) and the numbers from §2 of the design document,
//  turned into the window's size and the place of every label, bar and figure.
//  Increment 2.1. Since Increment 2.3 it also forms the labels' text (FR-8d),
//  shortens "Performance" where FR-8e says, and lays out the unlabeled
//  fallback row (FR-8c). Since Increment 5.4 it holds Small's numbers only:
//  the width rule and "Perf" are worked out at Small, and every other size is
//  Small's layout times its scale (FR-3). Everything here except
//  `measuredLabelWidth` is a pure function of the core groups and the label
//  widths, so the rule can be checked without AppKit or a window.
//

import CoreGraphics
import AppKit

/// The numbers from §2 of the design document, in points: Small's, or
/// Small's times a scale (FR-3).
nonisolated struct MeterMetrics: Equatable, Sendable {
    // MARK: Size (FR-3a, FR-3b)

    /// The content's height, below the title bar.
    var contentHeight: CGFloat
    /// The least content width. The bars can need more (FR-3b).
    var baseWidth: CGFloat

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
    /// Gap between a bar's system and user parts (design §3, §8 item 10).
    var partGap: CGFloat

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

    /// Small's numbers (design §2). Every other size is these times its
    /// scale.
    static let small = MeterMetrics(
        contentHeight: 150, baseWidth: 240,
        margin: 12, groupGap: 12, minimumCoreWidth: 21, barGap: 3, cornerRadius: 2, partGap: 1,
        topRowHeight: 16, gapBelowTopRow: 6, labelHeight: 12, gapBelowLabels: 3,
        barHeight: 74, gapBelowBars: 3, figureHeight: 12,
        overallFontSize: 13, keyFontSize: 10, labelFontSize: 10, figureFontSize: 10,
        keyDotDiameter: 7, keyDotGap: 4, keyItemGap: 8)

    /// Every number times a scale: 1.5 gives Medium's column in design §2,
    /// and 2 Large's.
    func scaled(by scale: CGFloat) -> MeterMetrics {
        MeterMetrics(
            contentHeight: contentHeight * scale, baseWidth: baseWidth * scale,
            margin: margin * scale, groupGap: groupGap * scale, minimumCoreWidth: minimumCoreWidth * scale,
            barGap: barGap * scale, cornerRadius: cornerRadius * scale, partGap: partGap * scale,
            topRowHeight: topRowHeight * scale, gapBelowTopRow: gapBelowTopRow * scale,
            labelHeight: labelHeight * scale, gapBelowLabels: gapBelowLabels * scale,
            barHeight: barHeight * scale, gapBelowBars: gapBelowBars * scale, figureHeight: figureHeight * scale,
            overallFontSize: overallFontSize * scale, keyFontSize: keyFontSize * scale,
            labelFontSize: labelFontSize * scale, figureFontSize: figureFontSize * scale,
            keyDotDiameter: keyDotDiameter * scale, keyDotGap: keyDotGap * scale, keyItemGap: keyItemGap * scale)
    }
}

/// Where everything goes at one size. Points from the content's top-left
/// corner, below the title bar. Positions aren't rounded to whole pixels
/// here; the meter's drawing does that (Increment 2.2).
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

    /// How many times Small this layout is: the content width over Small's
    /// (FR-3). 1 at Small.
    var scale: CGFloat

    /// The design's numbers at this scale.
    var metrics: MeterMetrics

    /// The window's content area at this size, below the title bar (FR-3a,
    /// FR-3b). Its height is rounded to a whole point (design §2), so it can
    /// be up to half a point shorter or taller than the layout, which is
    /// drawn from the top-left: the difference falls in the bottom margin.
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
    /// core, so bars are the same width in every group. Worked out at Small,
    /// from Small's numbers; every other size is Small's times its scale
    /// (FR-3).
    static func neededCoreWidth(for needs: [GroupNeed]) -> CGFloat {
        needs.filter { $0.cores > 0 }
            .map { $0.labelWidth / CGFloat($0.cores) }
            .reduce(MeterMetrics.small.minimumCoreWidth, max)
    }

    /// Small's content width (FR-3b): the larger of the base width and
    /// 2 × margin + group gap × (groups − 1) + cores × width per core,
    /// rounded up to a whole point.
    static func contentWidth(for needs: [GroupNeed]) -> CGFloat {
        let metrics = MeterMetrics.small
        let cores = needs.reduce(0) { $0 + $1.cores }
        let gaps = metrics.groupGap * CGFloat(max(needs.count - 1, 0))
        let needed = 2 * metrics.margin + gaps + CGFloat(cores) * neededCoreWidth(for: needs)
        // The tolerance keeps floating-point noise in a whole number from
        // adding a point. It is far below anything that could show.
        return max(metrics.baseWidth, (needed - 1e-6).rounded(.up))
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

    /// The names the labels show: exactly as macOS gives them (FR-8a),
    /// except that the names in `shortNames` are shortened if, and only if,
    /// that gives a narrower window at Small (FR-8e). Every size is Small
    /// enlarged, so the choice holds at every size. Decided from the labels
    /// at their widest, so a label never switches between the two as its
    /// average changes.
    static func shownNames(for groups: [CoreGroup], labelWidth: (String) -> CGFloat) -> [String] {
        let full = groups.map(\.name)
        let short = full.map { shortNames[$0] ?? $0 }
        guard short != full else { return full }
        func width(_ names: [String]) -> CGFloat {
            contentWidth(for: zip(groups, names).map {
                GroupNeed(cores: $0.cores.count, labelWidth: labelWidth(widestLabel($1)))
            })
        }
        return width(short) < width(full) ? short : full
    }

    // MARK: - Positions

    /// The layout of the given groups at Small.
    ///
    /// - Parameters:
    ///   - groups: The core groups, lowest to highest performance.
    ///   - labeled: False for the fallback row (FR-8c), which has no label.
    ///     Its bars take the label's height and the gap below it, and the
    ///     label needs no width.
    ///   - labelWidth: A label's width at Small's label font size, given its
    ///     full text. `measuredLabelWidth` in the app; fixed figures in tests.
    init(groups coreGroups: [CoreGroup], labeled: Bool, labelWidth: (String) -> CGFloat) {
        let metrics = MeterMetrics.small
        let names: [String?] = labeled
            ? Self.shownNames(for: coreGroups, labelWidth: labelWidth)
            : coreGroups.map { _ in nil }
        let needs = zip(coreGroups, names).map { group, name in
            GroupNeed(cores: group.cores.count, labelWidth: name.map { labelWidth(Self.widestLabel($0)) } ?? 0)
        }
        let width = Self.contentWidth(for: needs)
        let cores = needs.reduce(0) { $0 + $1.cores }
        let gaps = metrics.groupGap * CGFloat(max(needs.count - 1, 0))
        // Bars share whatever width the window has (design §2).
        let coreWidth = cores > 0 ? (width - 2 * metrics.margin - gaps) / CGFloat(cores) : 0

        // Down the window, top to bottom (design §2, Vertical spacing). With
        // no label, the bars start where the label would and grow by the
        // label's height and the gap below it, so they end where labeled bars
        // do: 89 tall at Small (design §2, §6).
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

        self.scale = 1
        self.metrics = metrics
        self.contentSize = CGSize(width: width, height: metrics.contentHeight)
        self.coreWidth = coreWidth
        self.topRow = CGRect(x: metrics.margin, y: metrics.margin,
                             width: width - 2 * metrics.margin, height: metrics.topRowHeight)
        self.groups = groups
    }

    /// This layout with every place and number times a scale, and the given
    /// content size (FR-3, design §2).
    fileprivate func scaled(by scale: CGFloat, contentSize: CGSize) -> MeterLayout {
        func times(_ rect: CGRect) -> CGRect {
            CGRect(x: rect.minX * scale, y: rect.minY * scale, width: rect.width * scale, height: rect.height * scale)
        }
        var layout = self
        layout.scale = self.scale * scale
        layout.metrics = metrics.scaled(by: scale)
        layout.contentSize = contentSize
        layout.coreWidth = coreWidth * scale
        layout.topRow = times(topRow)
        layout.groups = groups.map { group in
            Group(label: group.label.map { Label(name: $0.name, frame: times($0.frame)) },
                  bars: group.bars.map { Bar(core: $0.core, track: times($0.track), figure: times($0.figure)) })
        }
        return layout
    }

    // MARK: - Measuring the labels (requirements §6, the third use of AppKit)

    /// A group label's width in the system font at medium weight, with
    /// monospaced digits, as the meter draws it. The window's size has to be
    /// known before anything is drawn, so this measures the text itself, to
    /// a fraction of a point.
    static func measuredLabelWidth(_ label: String, fontSize: CGFloat) -> CGFloat {
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .medium)
        return NSAttributedString(string: label, attributes: [.font: font]).size().width
    }
}

/// The meter's layout on this Mac at any size: Small's, worked out at launch
/// from this Mac's core groups, and again if they change, and Small's times
/// the scale at every other size (FR-3). Nothing here is stored, so the
/// window is always sized for the Mac the app is running on (FR-3b, FR-3c).
nonisolated struct MeterLayouts: Equatable, Sendable {
    /// Small's layout.
    let small: MeterLayout

    /// - Parameters:
    ///   - groups: The core groups, lowest to highest performance.
    ///   - labeled: False for the fallback row (FR-8c), which has no label.
    ///   - labelWidth: A label's width at a font size. AppKit's measurement in
    ///     the app; fixed figures in tests.
    init(groups: [CoreGroup], labeled: Bool,
         labelWidth: (_ label: String, _ fontSize: CGFloat) -> CGFloat = MeterLayout.measuredLabelWidth) {
        small = MeterLayout(groups: groups, labeled: labeled) {
            labelWidth($0, MeterMetrics.small.labelFontSize)
        }
    }

    /// The layouts for a Mac's core groups, with no label on the fallback row
    /// (FR-8c). Worked out at launch, and again if the core count changes
    /// (NFR-4, Increment 4.2).
    init(topology: CoreTopology,
         labelWidth: (_ label: String, _ fontSize: CGFloat) -> CGFloat = MeterLayout.measuredLabelWidth) {
        self.init(groups: topology.groups, labeled: topology.fallbackReason == nil, labelWidth: labelWidth)
    }

    /// The sizing rules, from Small's content size on this Mac.
    var sizing: MeterSizing {
        MeterSizing(small: small.contentSize)
    }

    /// The layout for a window whose content is this wide: Small's times the
    /// width over Small's, drawn from the top-left (design §2). A width below
    /// Small's, which the window's limits don't allow, gives Small.
    func layout(atWidth width: CGFloat) -> MeterLayout {
        guard width.isFinite, width > small.contentSize.width else { return small }
        return small.scaled(by: width / small.contentSize.width, contentSize: sizing.size(atWidth: width))
    }

    /// A preset's layout (FR-3).
    func layout(of preset: MeterSize) -> MeterLayout {
        layout(atWidth: sizing.size(of: preset).width)
    }
}
