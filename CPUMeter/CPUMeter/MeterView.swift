//
//  MeterView.swift
//  CPUMeter
//
//  The meter: the top row, the group labels, a bar for each core and the
//  figure under it, all drawn in a single `Canvas` and never with Charts
//  (FR-6, FR-7, FR-27). Increment 2.2. `MeterLayout` says where everything
//  goes; this file adds the colors and text, and snaps the bars to whole
//  pixels. The bar geometry and the figures' text are pure functions, so they
//  can be checked without drawing.
//

import SwiftUI
import AppKit

/// The meter at one size, showing one sample. It takes plain values rather
/// than the sampler, so every bar and figure in a frame comes from the same
/// sample (FR-12), and a test can draw it with made-up readings.
struct MeterView: View {
    /// Where everything goes at the current size.
    let layout: MeterLayout

    /// The latest update, or nil before the first reading: the dash state
    /// (FR-14, design §6).
    let sample: CPUSample?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        let layout = layout
        let sample = sample
        let colors = MeterColors.standard(for: colorScheme)
        let scale = displayScale
        Canvas { context, _ in
            Self.draw(layout: layout, sample: sample, colors: colors, scale: scale, in: &context)
        }
        .frame(width: layout.contentSize.width, height: layout.contentSize.height)
    }

    // MARK: - Drawing

    private nonisolated static func draw(layout: MeterLayout, sample: CPUSample?, colors: MeterColors,
                                         scale: CGFloat, in context: inout GraphicsContext) {
        let metrics = layout.metrics
        drawTopRow(layout: layout, overall: sample?.overall, colors: colors, scale: scale, in: &context)

        let labelFont = Font.system(size: metrics.labelFontSize, weight: .medium)
        let figureFont = Font.system(size: metrics.figureFontSize).monospacedDigit()

        for group in layout.groups {
            // Left-aligned to the group (design §1). FR-3b made the group
            // wide enough for it.
            let label = context.resolve(Text(verbatim: group.label)
                .font(labelFont).foregroundStyle(colors.secondaryText))
            context.draw(label, at: CGPoint(x: group.labelFrame.minX, y: group.labelFrame.midY),
                         anchor: .leading)

            for bar in group.bars {
                let usage = sample.flatMap { bar.core < $0.cores.count ? $0.cores[bar.core] : nil }
                drawBar(bar, usage: usage, metrics: metrics, colors: colors, scale: scale, in: &context)

                // Centered under the bar, in monospaced digits, so a changing
                // figure doesn't move (FR-11, NFR-3).
                let figure = context.resolve(Text(verbatim: MeterDrawing.figureText(usage))
                    .font(figureFont).foregroundStyle(colors.secondaryText))
                context.draw(figure, at: CGPoint(x: bar.figure.midX, y: bar.figure.midY), anchor: .center)
            }
        }
    }

    /// The overall figure on the left and the color key on the right (FR-27).
    private nonisolated static func drawTopRow(layout: MeterLayout, overall: CPUUsage?, colors: MeterColors,
                                               scale: CGFloat, in context: inout GraphicsContext) {
        let metrics = layout.metrics
        let row = layout.topRow

        let overallText = context.resolve(Text(verbatim: MeterDrawing.overallText(overall))
            .font(.system(size: metrics.overallFontSize, weight: .semibold).monospacedDigit())
            .foregroundStyle(colors.primaryText))
        context.draw(overallText, at: CGPoint(x: row.minX, y: row.midY), anchor: .leading)

        // The key, laid out from the right edge in: "● User   ● System".
        let keyFont = Font.system(size: metrics.keyFontSize)
        let unbounded = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        var x = row.maxX
        for (word, color) in [("System", colors.system), ("User", colors.user)] {
            let text = context.resolve(Text(verbatim: word).font(keyFont).foregroundStyle(colors.secondaryText))
            context.draw(text, at: CGPoint(x: x, y: row.midY), anchor: .trailing)
            x -= text.measure(in: unbounded).width + metrics.keyDotGap

            let diameter = metrics.keyDotDiameter
            let dot = CGRect(x: MeterDrawing.snap(x - diameter, scale: scale),
                             y: MeterDrawing.snap(row.midY - diameter / 2, scale: scale),
                             width: diameter, height: diameter)
            context.fill(Path(ellipseIn: dot), with: .color(color))
            x -= diameter + metrics.keyItemGap
        }
    }

    /// A core's track, with its user and system time inside it (FR-9,
    /// design §3).
    private nonisolated static func drawBar(_ bar: MeterLayout.Bar, usage: CPUUsage?, metrics: MeterMetrics,
                                            colors: MeterColors, scale: CGFloat,
                                            in context: inout GraphicsContext) {
        let track = MeterDrawing.track(bar.track, scale: scale)
        let shape = Path(roundedRect: track, cornerRadius: metrics.cornerRadius, style: .circular)
        context.fill(shape, with: .color(colors.track))

        guard let usage else { return }
        let fills = MeterDrawing.fills(in: track, usage: usage, scale: scale)
        // Clipped to the track's rounded corners, as in the design canvas.
        var inside = context
        inside.clip(to: shape)
        if let user = fills.user { inside.fill(Path(user), with: .color(colors.user)) }
        if let system = fills.system { inside.fill(Path(system), with: .color(colors.system)) }
    }
}

/// The meter's colors (design §4).
nonisolated struct MeterColors: Sendable {
    var user: Color
    var system: Color
    var track: Color
    /// The overall figure.
    var primaryText: Color
    /// The key, the group labels and the per-core figures.
    var secondaryText: Color

    /// The default colors: the system's blue and orange for the bars, which
    /// adapt to the appearance, and a faint track (NFR-5). View → Colors
    /// (Increment 3.2) replaces the two bar colors.
    static func standard(for scheme: ColorScheme) -> MeterColors {
        MeterColors(
            user: Color(nsColor: .systemBlue),
            system: Color(nsColor: .systemOrange),
            track: scheme == .dark ? .white.opacity(0.10) : .black.opacity(0.08),
            primaryText: Color(nsColor: .labelColor),
            secondaryText: Color(nsColor: .secondaryLabelColor))
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

    /// A bar's track on whole pixels. Every bar keeps the same width, rounded
    /// to whole pixels, and its left edge moves to the nearest pixel, so a gap
    /// between bars can be a pixel narrower or wider than the design's.
    static func track(_ track: CGRect, scale: CGFloat) -> CGRect {
        let minY = snap(track.minY, scale: scale)
        return CGRect(x: snap(track.minX, scale: scale), y: minY,
                      width: max(snap(track.width, scale: scale), 1 / scale),
                      height: snap(track.maxY, scale: scale) - minY)
    }

    /// The user part at the bottom of a snapped track and the system part
    /// above it, on whole pixels, or nil for a part too small to show.
    ///
    /// The top of the bar is always the core's total, to the nearest pixel.
    /// When both parts show, the 1 pt gap between them comes out of the bottom
    /// of the system part. A system part too thin to keep a pixel after the
    /// gap is drawn without one, touching the user part, so it doesn't vanish.
    static func fills(in track: CGRect, usage: CPUUsage, scale: CGFloat) -> (user: CGRect?, system: CGRect?) {
        func clamped(_ share: Double) -> CGFloat { CGFloat(min(max(share, 0), 1)) }
        let busyHeight = snap(track.height * clamped(usage.busy), scale: scale)
        let userHeight = min(snap(track.height * clamped(usage.user), scale: scale), busyHeight)
        let systemHeight = busyHeight - userHeight
        let pixel = 1 / scale

        // Heights are whole pixels, so "at least half a pixel" means "at least
        // one", without trusting floating point to land exactly.
        func part(from bottom: CGFloat, height: CGFloat) -> CGRect? {
            height >= pixel / 2
                ? CGRect(x: track.minX, y: track.maxY - bottom - height, width: track.width, height: height)
                : nil
        }
        let user = part(from: 0, height: userHeight)
        let gap = user != nil && systemHeight - partGap >= pixel / 2 ? partGap : 0
        let system = part(from: userHeight + gap, height: systemHeight - gap)
        return (user, system)
    }

    /// A per-core figure: a whole number with no percent sign (FR-11), or the
    /// dash for a core with no reading (design §6).
    static func figureText(_ usage: CPUUsage?) -> String {
        usage.map { String(wholePercent($0.busy)) } ?? "–"
    }

    /// The overall figure, such as "CPU 42%" (FR-10), or "CPU –" before the
    /// first reading (design §6).
    static func overallText(_ usage: CPUUsage?) -> String {
        usage.map { "CPU \(wholePercent($0.busy))%" } ?? "CPU –"
    }

    /// A share from 0 to 1 as a whole percentage, rounded to the nearest, as
    /// the design canvas does: 99.6% reads 100.
    static func wholePercent(_ share: Double) -> Int {
        Int((min(max(share, 0), 1) * 100).rounded())
    }
}
