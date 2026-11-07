//
//  MeterView.swift
//  CPUMeter
//
//  The meter: the top row, the group labels, a bar for each core and the
//  figure under it, drawn as Core Animation layers and never with Charts
//  (FR-6, FR-7, FR-27, requirements §6). Increment 2.2, revised in
//  Increment 2.3 for system time at the base of each bar, the key's order,
//  and the labels' averages, in Increment 3.3 for colors chosen in
//  View → Colors, and in Increment 5.3 for layers in place of `Canvas`,
//  which leaked a timer on every redraw at Medium and Large.
//  `MeterLayout` says where everything goes; this file adds the colors and
//  text, snaps the bars to whole pixels, and puts the text where `Canvas`
//  put it. The bar geometry, the text and its place are pure functions, so
//  they can be checked without drawing.
//

import SwiftUI
import AppKit
import QuartzCore

/// The meter at one size, showing one sample. It takes plain values rather
/// than the sampler, so every bar and figure in a frame comes from the same
/// sample (FR-12), and a test can draw it with made-up readings.
struct MeterView: View {
    /// Where everything goes at the current size.
    let layout: MeterLayout

    /// The latest update, or nil before the first reading: the dash state
    /// (FR-14, design §6).
    let sample: CPUSample?

    /// The bar colors chosen in View → Colors, if any (FR-28).
    let colorChoice: BarColorChoice

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        MeterLayers(content: MeterLayerView.Content(layout: layout, sample: sample,
                                                    colorChoice: colorChoice, scale: displayScale))
            .frame(width: layout.contentSize.width, height: layout.contentSize.height)
    }
}

/// Puts the view that holds the meter's layers into SwiftUI's window
/// (requirements §6, the fifth use of AppKit).
private struct MeterLayers: NSViewRepresentable {
    let content: MeterLayerView.Content

    func makeNSView(context: Context) -> MeterLayerView { MeterLayerView() }

    func updateNSView(_ view: MeterLayerView, context: Context) {
        view.show(content)
    }
}

/// The meter as a tree of Core Animation layers (requirements §6). The tree
/// is built for one layout at one display scale. After that, an update
/// changes only what changed, such as a bar's parts or a figure, and
/// nothing animates. The colors follow the window's appearance.
final class MeterLayerView: NSView {
    /// Everything the meter shows.
    struct Content: Equatable {
        var layout: MeterLayout
        var sample: CPUSample?
        var colorChoice: BarColorChoice
        var scale: CGFloat
    }

    /// What's showing, or nil before the first update.
    private(set) var content: Content?

    /// Holds every layer below, so a new layout can replace them all at once.
    private let root = MeterLayerView.stillLayer()
    private var tree: Tree?

    /// The layers for one layout at one scale.
    private struct Tree {
        var layout: MeterLayout
        var scale: CGFloat
        var bars: [Bar] = []
        var labels: [Label] = []
        var overall = TextLayer()
        var key: [KeyItem] = []
    }

    private struct Bar {
        var core: Int
        /// The track, which clips the parts to its rounded corners.
        var track: CALayer
        var system: CALayer
        var user: CALayer
        var figure: TextLayer
        var figureCenter: CGPoint
    }

    private struct Label {
        /// The group's place in the layout, which is also its average's
        /// place in the sample.
        var group: Int
        var name: String
        var layer: TextLayer
        var start: CGPoint
    }

    private struct KeyItem {
        var part: BarPart
        var dot: CALayer
        var word: TextLayer
        var end: CGPoint
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.addSublayer(root)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) isn't used")
    }

    /// Top-left coordinates, as `MeterLayout` gives them.
    override var isFlipped: Bool { true }

    override func layout() {
        super.layout()
        Self.quietly { root.frame = bounds }
    }

    /// A change between light and dark, while the meter is showing, changes
    /// its colors at once (NFR-5).
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        if let content { show(content) }
    }

    /// Shows the content: builds the layers if the layout or the scale is
    /// new, then sets each layer's place, color and text. Each of those is
    /// set only if it changed.
    func show(_ content: Content) {
        self.content = content
        let colors = MeterColors.standard(in: effectiveAppearance, chosen: content.colorChoice)
        Self.quietly {
            if tree?.layout != content.layout || tree?.scale != content.scale {
                tree = build(content.layout, scale: content.scale)
            }
            if let tree { fill(tree, sample: content.sample, colors: colors, scale: content.scale) }
        }
    }

    // MARK: - Building

    private func build(_ layout: MeterLayout, scale: CGFloat) -> Tree {
        root.sublayers?.forEach { $0.removeFromSuperlayer() }
        let metrics = layout.metrics
        var tree = Tree(layout: layout, scale: scale)

        // Bars first, so the text is drawn over them.
        for (index, group) in layout.groups.enumerated() {
            for bar in group.bars {
                let track = Self.stillLayer()
                track.frame = MeterDrawing.track(bar.track, scale: scale)
                track.cornerRadius = metrics.cornerRadius
                track.cornerCurve = .circular
                // Clipped to the track's rounded corners, as in the design
                // canvas.
                track.masksToBounds = true
                let system = Self.stillLayer(), user = Self.stillLayer()
                track.addSublayer(system)
                track.addSublayer(user)
                root.addSublayer(track)
                let figure = TextLayer()
                root.addSublayer(figure)
                tree.bars.append(Bar(core: bar.core, track: track, system: system, user: user, figure: figure,
                                     figureCenter: CGPoint(x: bar.figure.midX, y: bar.figure.midY)))
            }
            // "Name: 24%", left-aligned to the group, so the name never moves
            // (design §1). The fallback row has no label (FR-8c).
            if let label = group.label {
                let text = TextLayer()
                root.addSublayer(text)
                tree.labels.append(Label(group: index, name: label.name, layer: text,
                                         start: CGPoint(x: label.frame.minX, y: label.frame.midY)))
            }
        }

        let row = layout.topRow
        root.addSublayer(tree.overall)

        // The key reads "● System   ● User", in the bars' order from the
        // bottom up (FR-27). It's laid out from the right edge in, so User
        // comes first here, with the words' widths as `Canvas` measured them.
        var x = row.maxX
        for part in [BarPart.user, .system] {
            let word = TextLayer()
            let end = CGPoint(x: x, y: row.midY)
            x -= MeterDrawing.textWidth(Self.keyText(part, metrics: metrics, color: .black).size().width, scale: scale)
                + metrics.keyDotGap
            let diameter = metrics.keyDotDiameter
            let dot = Self.stillLayer()
            dot.frame = CGRect(x: MeterDrawing.snap(x - diameter, scale: scale),
                               y: MeterDrawing.snap(row.midY - diameter / 2, scale: scale),
                               width: diameter, height: diameter)
            dot.cornerRadius = diameter / 2
            root.addSublayer(dot)
            root.addSublayer(word)
            tree.key.append(KeyItem(part: part, dot: dot, word: word, end: end))
            x -= diameter + metrics.keyItemGap
        }
        return tree
    }

    // MARK: - Filling in

    private func fill(_ tree: Tree, sample: CPUSample?, colors: MeterColors, scale: CGFloat) {
        let metrics = tree.layout.metrics

        // Monospaced digits in the figures and labels, so a changing number
        // doesn't move or change the label's width (FR-11, NFR-3,
        // design §8.9).
        let figureFont = NSFont.monospacedDigitSystemFont(ofSize: metrics.figureFontSize, weight: .regular)
        for bar in tree.bars {
            let usage = sample.flatMap { bar.core < $0.cores.count ? $0.cores[bar.core] : nil }
            Self.set(bar.track, color: colors.track)
            // The parts in the track's own coordinates: system time at the
            // bottom and user time above it (FR-9, design §3).
            let fills = usage.map { MeterDrawing.fills(in: CGRect(origin: .zero, size: bar.track.bounds.size),
                                                       usage: $0, scale: scale) }
            Self.set(bar.system, frame: fills?.system, color: colors.system)
            Self.set(bar.user, frame: fills?.user, color: colors.user)
            // Centered under the bar (FR-11).
            bar.figure.show(Self.text(MeterDrawing.figureText(usage), font: figureFont, color: colors.secondaryText),
                            at: bar.figureCenter, .center, scale: scale)
        }

        let labelFont = NSFont.monospacedDigitSystemFont(ofSize: metrics.labelFontSize, weight: .medium)
        for label in tree.labels {
            let average = sample.flatMap { label.group < $0.groups.count ? $0.groups[label.group] : nil }
            label.layer.show(Self.text(MeterDrawing.labelText(label.name, usage: average),
                                       font: labelFont, color: colors.secondaryText),
                             at: label.start, .leading, scale: scale)
        }

        // The overall figure on the left of the top row (FR-10).
        let overallFont = NSFont.monospacedDigitSystemFont(ofSize: metrics.overallFontSize, weight: .semibold)
        let row = tree.layout.topRow
        tree.overall.show(Self.text(MeterDrawing.overallText(sample?.overall), font: overallFont,
                                    color: colors.primaryText),
                          at: CGPoint(x: row.minX, y: row.midY), .leading, scale: scale)

        // The key, in the bars' colors (FR-27, FR-28).
        for item in tree.key {
            Self.set(item.dot, color: item.part == .system ? colors.system : colors.user)
            item.word.show(Self.keyText(item.part, metrics: metrics, color: colors.secondaryText),
                           at: item.end, .trailing, scale: scale)
        }
    }

    private static func keyText(_ part: BarPart, metrics: MeterMetrics, color: CGColor) -> NSAttributedString {
        text(part == .system ? "System" : "User", font: .systemFont(ofSize: metrics.keyFontSize), color: color)
    }

    /// Text in a font and a color already worked out for the appearance.
    private static func text(_ string: String, font: NSFont, color: CGColor) -> NSAttributedString {
        NSAttributedString(string: string, attributes: [
            .font: font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        ])
    }

    // MARK: - Layers that never animate

    /// Every property the meter changes, with no animation. Turning
    /// animation off for each change isn't enough: a layer drawn later, such
    /// as a text layer, would still fade its new contents in.
    nonisolated static var stillActions: [String: any CAAction] {
        Dictionary(uniqueKeysWithValues: [
            "bounds", "position", "frame", "contents", "contentsScale", "backgroundColor",
            "cornerRadius", "hidden", "opacity", "sublayers", "onOrderIn", "onOrderOut",
        ].map { ($0, NSNull()) })
    }

    private static func stillLayer() -> CALayer {
        let layer = CALayer()
        layer.actions = stillActions
        return layer
    }

    private static func quietly(_ body: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        body()
        CATransaction.commit()
    }

    private static func set(_ layer: CALayer, color: CGColor) {
        if layer.backgroundColor != color { layer.backgroundColor = color }
    }

    /// A bar part: hidden when it's too small to show.
    private static func set(_ layer: CALayer, frame: CGRect?, color: CGColor) {
        guard let frame else {
            if !layer.isHidden { layer.isHidden = true }
            return
        }
        if layer.frame != frame { layer.frame = frame }
        set(layer, color: color)
        if layer.isHidden { layer.isHidden = false }
    }
}

/// One line of text in a layer of its own, drawn by Core Text at the place
/// `Canvas` drew it, to a fraction of a pixel (see `MeterDrawing.textOrigin`).
/// The layer is a little bigger than the text, on whole pixels, so nothing is
/// cut off and the text stays sharp.
private nonisolated final class TextLayer: CALayer {
    private var text: NSAttributedString?
    private var anchor = CGPoint.zero
    private var alignment = MeterDrawing.TextAlignment.leading
    private var line: CTLine?
    /// The left end of the baseline, from the layer's top-left corner.
    private var origin = CGPoint.zero

    override init() {
        super.init()
        actions = MeterLayerView.stillActions
    }

    /// Core Animation's copy of a layer.
    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? TextLayer {
            text = other.text
            anchor = other.anchor
            alignment = other.alignment
            line = other.line
            origin = other.origin
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) isn't used")
    }

    /// Shows the text lined up with the anchor point. Does nothing if
    /// nothing changed, so an unchanged figure isn't drawn again.
    func show(_ text: NSAttributedString, at anchor: CGPoint, _ alignment: MeterDrawing.TextAlignment,
              scale: CGFloat) {
        guard text != self.text || anchor != self.anchor || alignment != self.alignment
                || scale != contentsScale else { return }
        self.text = text
        self.anchor = anchor
        self.alignment = alignment

        let line = CTLineCreateWithAttributedString(text)
        var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
        let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        let baseline = MeterDrawing.textOrigin(anchor: anchor, alignment: alignment, width: width,
                                               height: text.size().height, ascent: ascent, scale: scale)
        // Room around the line for accents and anything else that reaches
        // past it.
        let pad = ((ascent + descent) / 2).rounded(.up)
        let frame = MeterDrawing.outward(CGRect(x: baseline.x - pad, y: baseline.y - ascent - pad,
                                                width: width + 2 * pad, height: ascent + descent + 2 * pad),
                                         scale: scale)
        self.line = line
        origin = CGPoint(x: baseline.x - frame.minX, y: baseline.y - frame.minY)
        if self.frame != frame { self.frame = frame }
        if contentsScale != scale { contentsScale = scale }
        setNeedsDisplay()
    }

    override func draw(in ctx: CGContext) {
        guard let line else { return }
        ctx.saveGState()
        if contentsAreFlipped() {
            // Top-left coordinates, so each glyph is turned back upright.
            ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
            ctx.textPosition = origin
        } else {
            ctx.textMatrix = .identity
            ctx.textPosition = CGPoint(x: origin.x, y: bounds.height - origin.y)
        }
        CTLineDraw(line, ctx)
        ctx.restoreGState()
    }
}

/// The meter's colors (design §4), worked out for one appearance, since a
/// layer can't follow the appearance by itself.
nonisolated struct MeterColors: Equatable {
    var user: CGColor
    var system: CGColor
    var track: CGColor
    /// The overall figure.
    var primaryText: CGColor
    /// The key, the group labels and the per-core figures.
    var secondaryText: CGColor

    /// The meter's colors in an appearance: the bar colors chosen in
    /// View → Colors, in both the bars and the key, and a faint track
    /// (design §4). A part with no chosen color uses the system's blue or
    /// orange, which adapt to the appearance; a chosen one stays as picked
    /// (NFR-5, FR-28a).
    static func standard(in appearance: NSAppearance, chosen: BarColorChoice = BarColorChoice()) -> MeterColors {
        var colors: MeterColors?
        appearance.performAsCurrentDrawingAppearance {
            let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            colors = MeterColors(
                user: chosen.color(for: .user).cgColor,
                system: chosen.color(for: .system).cgColor,
                track: dark ? CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.10)
                            : CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.08),
                primaryText: NSColor.labelColor.cgColor,
                secondaryText: NSColor.secondaryLabelColor.cgColor)
        }
        // performAsCurrentDrawingAppearance runs its block before returning.
        return colors!
    }
}

/// The parts of drawing that are plain arithmetic.
nonisolated enum MeterDrawing {
    /// The gap between a bar's user and system parts, in points (design §3).
    static let partGap: CGFloat = 1

    /// A position rounded to the nearest whole pixel.
    static func snap(_ value: CGFloat, scale: CGFloat) -> CGFloat {
        (value * scale).rounded() / scale
    }

    /// A position moved down or right onto a whole pixel. A position already
    /// on one, give or take rounding error, stays.
    static func snapUp(_ value: CGFloat, scale: CGFloat) -> CGFloat {
        (value * scale - 1e-6).rounded(.up) / scale
    }

    /// The smallest rectangle on whole pixels that holds this one.
    static func outward(_ rect: CGRect, scale: CGFloat) -> CGRect {
        let minX = (rect.minX * scale + 1e-6).rounded(.down) / scale
        let minY = (rect.minY * scale + 1e-6).rounded(.down) / scale
        return CGRect(x: minX, y: minY, width: snapUp(rect.maxX, scale: scale) - minX,
                      height: snapUp(rect.maxY, scale: scale) - minY)
    }

    /// A bar's track on whole pixels. Every bar keeps the same width, rounded
    /// to whole pixels, and its left edge moves to the nearest pixel, so a gap
    /// between bars can be a pixel narrower or wider than the design's.
    static func track(_ track: CGRect, scale: CGFloat) -> CGRect {
        let minY = snap(track.minY, scale: scale)
        return CGRect(x: snap(track.minX, scale: scale), y: minY,
                      width: max(snap(track.width, scale: scale), 1 / scale),
                      height: snap(track.maxY, scale: scale) - minY)
    }

    /// The system part at the bottom of a snapped track and the user part
    /// above it (FR-9, design §3), on whole pixels, or nil for a part too
    /// small to show.
    ///
    /// The top of the bar is always the core's total, to the nearest pixel.
    /// When both parts show, the 1 pt gap between them comes out of the bottom
    /// of the user part. A user part too thin to keep a pixel after the gap is
    /// drawn without one, touching the system part, so it doesn't vanish.
    static func fills(in track: CGRect, usage: CPUUsage, scale: CGFloat) -> (system: CGRect?, user: CGRect?) {
        func clamped(_ share: Double) -> CGFloat { CGFloat(min(max(share, 0), 1)) }
        let busyHeight = snap(track.height * clamped(usage.busy), scale: scale)
        let systemHeight = min(snap(track.height * clamped(usage.system), scale: scale), busyHeight)
        let userHeight = busyHeight - systemHeight
        let pixel = 1 / scale

        // Heights are whole pixels, so "at least half a pixel" means "at least
        // one", without trusting floating point to land exactly.
        func part(from bottom: CGFloat, height: CGFloat) -> CGRect? {
            height >= pixel / 2
                ? CGRect(x: track.minX, y: track.maxY - bottom - height, width: track.width, height: height)
                : nil
        }
        let system = part(from: 0, height: systemHeight)
        let gap = system != nil && userHeight - partGap >= pixel / 2 ? partGap : 0
        let user = part(from: systemHeight + gap, height: userHeight - gap)
        return (system, user)
    }

    /// How a line of text lines up with its anchor point.
    enum TextAlignment {
        /// Starts at the anchor.
        case leading
        /// Centered on the anchor.
        case center
        /// Ends at the anchor.
        case trailing
    }

    /// A text's width as `Canvas` measured it: rounded up to whole pixels.
    static func textWidth(_ width: CGFloat, scale: CGFloat) -> CGFloat {
        snapUp(width, scale: scale)
    }

    /// Where `Canvas` drew a line of text: the left end of its baseline,
    /// from the meter's top-left corner, as measured at scales 1, 2 and 8 in
    /// Increment 5.3. `Canvas` lines up a box with the anchor point: the
    /// text's width rounded up to whole pixels, and its line height
    /// (`height`), centered on the anchor's y. The text starts at the box's
    /// left edge, and its baseline is the ascent, to the nearest point, below
    /// the box's top, moved down onto a whole pixel.
    static func textOrigin(anchor: CGPoint, alignment: TextAlignment, width: CGFloat, height: CGFloat,
                           ascent: CGFloat, scale: CGFloat) -> CGPoint {
        let box = textWidth(width, scale: scale)
        let x = switch alignment {
        case .leading: anchor.x
        case .center: anchor.x - box / 2
        case .trailing: anchor.x - box
        }
        return CGPoint(x: x, y: snapUp(anchor.y - height / 2 + ascent.rounded(), scale: scale))
    }

    /// A per-core figure: a whole number with no percent sign (FR-11), or the
    /// dash for a core with no reading (design §6).
    static func figureText(_ usage: CPUUsage?) -> String {
        usage.map { String(wholePercent($0.busy)) } ?? "–"
    }

    /// A group label with its average, such as "Efficiency: 24%" (FR-8d), or
    /// "Efficiency: –" before the first reading (design §6).
    static func labelText(_ name: String, usage: CPUUsage?) -> String {
        MeterLayout.labelText(name, percent: usage.map { wholePercent($0.busy) })
    }

    /// The overall figure's name. "CPU" alone could be read on Activity
    /// Monitor's per-process scale, where one core is 100% (FR-10).
    static let overallName = "All cores"

    /// The overall figure, such as "All cores: 42%" (FR-10), or
    /// "All cores: –" before the first reading (design §6). The same form as
    /// the group labels (design §1).
    static func overallText(_ usage: CPUUsage?) -> String {
        labelText(overallName, usage: usage)
    }

    /// A share from 0 to 1 as a whole percentage, rounded to the nearest, as
    /// the design canvas does: 99.6% reads 100.
    static func wholePercent(_ share: Double) -> Int {
        Int((min(max(share, 0), 1) * 100).rounded())
    }
}
