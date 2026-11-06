//
//  CPUSampler.swift
//  CPUMeter
//
//  Samples every core on a timer and works out the percentages the meter
//  shows (FR-8d, FR-9, FR-10, FR-12, FR-14, FR-15). Increment 1.3; each
//  group's average since Increment 2.3, the five refresh rates since
//  Increment 3.2, pausing while the window can't be seen since
//  Increment 4.1, and failed reads, short readings, a changed core count and
//  skipping unchanged updates since Increment 4.2. The arithmetic and the
//  decisions are kept in pure functions, so they can be checked without a
//  timer. In Debug builds, `SimulatedCores.swift` can stand in for the
//  Mac's cores (Increment 2.4).
//

import Foundation
import Observation

/// How often the meter updates, chosen from View → Refresh Rate (FR-18).
/// Saved as its number of seconds. A saved number that isn't one of these
/// gives the default, 1 second (FR-18a).
nonisolated enum RefreshRate: Int, CaseIterable, Identifiable, Sendable {
    case oneSecond = 1, twoSeconds, threeSeconds, fourSeconds, fiveSeconds

    var id: Self { self }

    /// Seconds between updates.
    var interval: TimeInterval { TimeInterval(rawValue) }

    /// The name shown in View → Refresh Rate, such as "1 second" or
    /// "5 seconds" (design §5).
    var title: String { rawValue == 1 ? "1 second" : "\(rawValue) seconds" }
}

/// A share of CPU time over one interval, for one core, a group or all cores.
/// Each part runs from 0 to 1, and the rest of the time was idle.
nonisolated struct CPUUsage: Equatable, Sendable {
    /// User time, with nice time counted as user (FR-9).
    var user: Double
    var system: Double

    /// The time that wasn't idle.
    var busy: Double { user + system }
}

/// Everything one update shows, all from one read (FR-12).
nonisolated struct CPUSample: Equatable, Sendable {
    /// Each core's usage, in logical core order, or nil for a core that
    /// reported no ticks. That core shows the dash, as before the first
    /// reading, so it can't be mistaken for 0% (NFR-4, design §8.3).
    var cores: [CPUUsage?]

    /// Each core group's average, in the topology's group order, from the raw
    /// ticks summed over that group's cores, as the overall figure is
    /// (FR-8d). Nil for a group whose cores reported no ticks; its label
    /// shows the dash.
    var groups: [CPUUsage?]

    /// Across all cores, from the raw ticks summed over every core rather than
    /// by averaging rounded figures (FR-10). Nil if no core reported ticks.
    var overall: CPUUsage?

    /// What the meter shows of this update, at the whole percentages it
    /// draws (NFR-1).
    var shown: ShownFigures {
        func percent(_ share: Double) -> Int { MeterDrawing.wholePercent(share) }
        return ShownFigures(
            cores: cores.map { core in
                core.map { ShownFigures.Core(figure: percent($0.busy), user: percent($0.user),
                                             system: percent($0.system)) }
            },
            groups: groups.map { $0.map { percent($0.busy) } },
            overall: overall.map { percent($0.busy) })
    }
}

/// What the meter shows of an update, as whole percentages (NFR-1): each
/// core's figure and the user and system parts of its bar, each group's
/// average, and the overall figure, with nil for a dash. Two updates with the
/// same figures draw the same meter, but for a bar that can differ by under
/// 1% of its height, so the second isn't drawn.
nonisolated struct ShownFigures: Equatable, Sendable {
    nonisolated struct Core: Equatable, Sendable {
        /// The figure under the bar: user and system together (FR-11).
        var figure: Int
        var user: Int
        var system: Int
    }

    var cores: [Core?]
    var groups: [Int?]
    var overall: Int?
}

/// What one read of the counters leads to (FR-14, FR-15, NFR-4). Worked out
/// by `CPUSampler.outcome(baseline:read:elapsed:groupedCores:)`, so every case
/// can be checked without a timer.
nonisolated enum ReadOutcome: Equatable, Sendable {
    /// The read failed. The meter shows the zero state, and the baseline is
    /// kept, so the next read measures the whole gap (FR-15).
    case failed
    /// The read came too soon after the last one, as when a late timer
    /// catches up. The meter keeps its last update and the baseline is kept,
    /// so this short span is folded into the next reading.
    case tooShort
    /// The number of cores changed, to this many. The core groups are read
    /// again, this read becomes the baseline, and the meter shows the zero
    /// state until the next update (NFR-4).
    case coreCountChanged(to: Int)
    /// An update from these changes, with this read as the new baseline. Nil
    /// when there's no baseline to measure from, which gives the zero state.
    case update([TickChange]?)
}

/// Reads every core's counters on a timer and publishes the latest sample for
/// the meter to draw. Like DriveSpeed's `SpeedSampler`, but its timer also
/// runs while a menu is open, because every control is in the menu bar.
@Observable
@MainActor
final class CPUSampler {

    // MARK: Published (read by the meter)

    /// The core groups, read when the sampler is made, so they're known
    /// before the window opens (FR-8), and read again if the number of cores
    /// a read returns changes (NFR-4). The window's layouts follow them.
    private(set) var topology: CoreTopology

    /// The latest update, or nil before the first reading and after a failed
    /// read: the dash state (FR-14, design §6). Replaced only when the new
    /// update changes something the meter shows (NFR-1).
    private(set) var sample: CPUSample?

    // MARK: Bookkeeping (not observed)

    @ObservationIgnored private var timer: Timer?

    /// The previous read, which the next one is measured from.
    @ObservationIgnored private var baseline: [CoreTicks]?

    /// When the baseline was read, in seconds of the Mac's uptime, a clock
    /// that doesn't jump when the time of day is set. A rate change times its
    /// update from it (FR-18d).
    @ObservationIgnored private var baselineTime: TimeInterval = 0

    /// How often it updates. It stays fixed until the user changes it
    /// (FR-18b).
    @ObservationIgnored private(set) var rate: RefreshRate = .oneSecond

    /// True between `start()` and `stop()`: the window is open and wants
    /// updates.
    @ObservationIgnored private var isStarted = false

    /// Whether any part of the window can be seen, as macOS last reported
    /// (FR-17). Assumed true until macOS says otherwise, so a missed report
    /// can't leave the meter stopped.
    @ObservationIgnored private(set) var isVisible = true

    #if DEBUG
    /// Other cores in place of the Mac's own, when the launch arguments ask
    /// for them (Increment 2.4). Debug builds only.
    @ObservationIgnored private var simulation: SimulatedCores?
    #endif

    init() {
        #if DEBUG
        if let simulation = SimulatedCores.fromLaunchArguments() {
            self.simulation = simulation
            topology = simulation.topology
            return
        }
        #endif
        topology = CoreTopology.current(coreCount: CoreCounters.read()?.count ?? 0)
    }

    // MARK: Lifecycle

    /// Starts sampling at the current rate, if the window can be seen. The
    /// baseline is read first, so the first update is a real measurement
    /// rather than a spike measured from zero (FR-14). Safe to call again: it
    /// restarts the timer and reads a new baseline.
    func start() {
        isStarted = true
        guard isVisible else { return }
        begin(firstUpdateAfter: rate.interval, exact: false)
    }

    /// Stops sampling: the window closed.
    func stop() {
        isStarted = false
        stopTimer()
    }

    /// The window can now be seen, or can't (FR-17). Hidden, the timer stops,
    /// so nothing is read or drawn. Seen again, a new baseline is read at
    /// once, so the next update covers only the time it can be seen. That
    /// update comes after `shortestReading`, exactly, and later ones at the
    /// rate. A rate chosen while hidden takes effect then.
    func setVisible(_ visible: Bool) {
        guard visible != isVisible else { return }
        isVisible = visible
        guard isStarted else { return }
        if visible {
            begin(firstUpdateAfter: Self.shortestReading, exact: true)
        } else {
            stopTimer()
        }
    }

    /// Reads a new baseline and runs the timer from it.
    private func begin(firstUpdateAfter delay: TimeInterval, exact: Bool) {
        setBaseline(readCounters())
        runTimer(firstUpdateAfter: delay, exact: exact)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Changes the refresh rate (FR-18d). While sampling, the meter updates
    /// at once, measured from its last update, or when a full second has
    /// passed since it, and then at the new rate. Until then it keeps its last
    /// update. The baseline isn't read again, and another change doesn't delay
    /// the update, because the wait is always timed from the last update.
    /// When not sampling, because the window is closed or hidden, the next
    /// `start()` or `setVisible(true)` uses the new rate.
    func setRate(_ newRate: RefreshRate) {
        guard newRate != rate else { return }
        rate = newRate
        guard timer != nil else { return }
        let sinceBaseline = ProcessInfo.processInfo.systemUptime - baselineTime
        runTimer(firstUpdateAfter: Self.waitAfterRateChange(sinceLastRead: sinceBaseline), exact: true)
    }

    /// The shortest time a reading can cover: the shortest refresh rate.
    /// That's about 100 ticks per core, so a figure can't come from a handful
    /// of ticks (FR-18d).
    nonisolated static let shortestReading = RefreshRate.oneSecond.interval

    /// The shortest span a timer's reading is shown for: half the shortest
    /// reading, about 50 ticks per core. A repeating timer that fires late,
    /// after the app stalls or the Mac wakes, keeps its schedule, so its next
    /// firing can come a fraction of a second later. Such a reading, from a
    /// few ticks, could show a false spike (NFR-4), so it's folded into the
    /// next. A timer on time, up to a tenth early or late, is never this short.
    nonisolated static let shortestShownSpan = shortestReading / 2

    /// How long after a rate change the meter updates (FR-18d): at once when
    /// the last read was at least `shortestReading` ago, otherwise when that
    /// time is up. Never more than `shortestReading`.
    nonisolated static func waitAfterRateChange(sinceLastRead elapsed: TimeInterval) -> TimeInterval {
        min(max(shortestReading - elapsed, 0), shortestReading)
    }

    /// Replaces the timer: the first update after `delay`, then one every
    /// interval at the current rate.
    ///
    /// - Parameter exact: Whether the first update comes exactly on time. A
    ///   rate change's update does, so it's never later than promised
    ///   (FR-18d). Every other update may come up to a tenth of the interval
    ///   late, which lets macOS combine wakeups (NFR-1).
    private func runTimer(firstUpdateAfter delay: TimeInterval, exact: Bool) {
        timer?.invalidate()
        let interval = rate.interval
        let leeway = interval * 0.1
        let timer = Timer(fire: Date(timeIntervalSinceNow: delay), interval: interval, repeats: true) { [weak self] firing in
            // The timer is on the main run loop, so this runs on the main
            // actor already.
            MainActor.assumeIsolated { self?.tick() }
            // Only the first update is exact.
            firing.tolerance = leeway
        }
        timer.tolerance = exact ? 0 : leeway
        // The common modes include the one macOS uses while a menu is open,
        // so the meter keeps updating then too.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Makes `ticks` the read the next update is measured from, and notes
    /// when it was taken.
    private func setBaseline(_ ticks: [CoreTicks]?) {
        baseline = ticks
        baselineTime = ProcessInfo.processInfo.systemUptime
    }

    // MARK: Sampling

    /// One update, from one read (FR-12).
    private func tick() {
        let current = readCounters()
        let elapsed = ProcessInfo.processInfo.systemUptime - baselineTime
        let outcome = Self.outcome(baseline: baseline, read: current, elapsed: elapsed,
                                   groupedCores: topology.coreCount)
        switch outcome {
        case .failed:
            show(nil)
        case .tooShort:
            // The baseline stays, so the next reading covers this span too.
            break
        case .coreCountChanged(let count):
            topology = readTopology(coreCount: count)
            setBaseline(current)
            show(nil)
        case .update(let changes):
            setBaseline(current)
            let groups = topology.groups
            show(changes.map { Self.sample(from: $0, groups: groups) })
        }
    }

    /// What a read leads to (FR-14, FR-15, NFR-4).
    ///
    /// - Parameters:
    ///   - baseline: The read the next update is measured from, if any.
    ///   - current: This read, or nil if it failed.
    ///   - elapsed: Seconds since the baseline was read.
    ///   - groupedCores: How many cores the core groups cover.
    nonisolated static func outcome(baseline: [CoreTicks]?, read current: [CoreTicks]?,
                                    elapsed: TimeInterval, groupedCores: Int) -> ReadOutcome {
        guard let current else { return .failed }
        guard current.count == groupedCores else { return .coreCountChanged(to: current.count) }
        // No baseline, or one with a different core count: this read starts
        // a new one.
        guard let baseline, baseline.count == current.count else { return .update(nil) }
        guard elapsed >= shortestShownSpan else { return .tooShort }
        // Each percentage is a share of ticks, not of clock time, so a longer
        // span still gives the right figures (FR-15).
        return .update(CoreCounters.changes(from: baseline, to: current))
    }

    /// Shows an update, unless it would draw the same meter (NFR-1).
    private func show(_ newSample: CPUSample?) {
        guard newSample?.shown != sample?.shown else { return }
        sample = newSample
    }

    /// The core groups for this many cores: macOS's own, or in a Debug build
    /// with a simulation, the simulated ones (Increment 2.4).
    private func readTopology(coreCount: Int) -> CoreTopology {
        #if DEBUG
        if let simulation { return simulation.topology }
        #endif
        return CoreTopology.current(coreCount: coreCount)
    }

    /// Every core's counters: the Mac's own, or in a Debug build with a
    /// simulation, the simulated ones (Increment 2.4).
    private func readCounters() -> [CoreTicks]? {
        #if DEBUG
        if let simulated = simulation?.read() { return simulated }
        #endif
        return CoreCounters.read()
    }

    /// The share of time spent on user and system work, from the raw ticks
    /// summed over the given changes: one core's, a group's or every core's.
    /// Nil when they hold no ticks at all, rather than dividing by zero
    /// (NFR-4).
    nonisolated static func usage(of changes: some Sequence<TickChange>) -> CPUUsage? {
        var user: UInt64 = 0
        var system: UInt64 = 0
        var total: UInt64 = 0
        for change in changes {
            user += change.user
            system += change.system
            total += change.total
        }
        guard total > 0 else { return nil }
        return CPUUsage(user: Double(user) / Double(total), system: Double(system) / Double(total))
    }

    /// Every figure one update shows, from one set of tick changes.
    ///
    /// - Parameters:
    ///   - changes: Each core's tick change, in logical core order.
    ///   - groups: The core groups, whose logical IDs index `changes`. An ID
    ///     past the end is skipped, so a group can't read another core's ticks.
    nonisolated static func sample(from changes: [TickChange], groups: [CoreGroup]) -> CPUSample {
        CPUSample(cores: changes.map { usage(of: CollectionOfOne($0)) },
                  groups: groups.map { group in
                      usage(of: group.cores.lazy.filter { changes.indices.contains($0) }.map { changes[$0] })
                  },
                  overall: usage(of: changes))
    }
}
