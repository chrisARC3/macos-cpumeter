//
//  CPUSampler.swift
//  CPUMeter
//
//  Samples every core on a timer and works out the percentages the meter
//  shows (FR-8d, FR-9, FR-10, FR-12, FR-14, FR-15). Increment 1.3; each
//  group's average since Increment 2.3, and the five refresh rates since
//  Increment 3.2. The arithmetic is kept in pure functions, so it can be
//  checked without a timer. In Debug builds, `SimulatedCores.swift` can
//  stand in for the Mac's cores (Increment 2.4).
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
}

/// Reads every core's counters on a timer and publishes the latest sample for
/// the meter to draw. Like DriveSpeed's `SpeedSampler`, but its timer also
/// runs while a menu is open, because every control is in the menu bar.
@Observable
@MainActor
final class CPUSampler {

    // MARK: Published (read by the meter)

    /// The core groups, read once when the sampler is made, so they're known
    /// before the window opens (FR-8). Increment 4.2 reads them again if the
    /// core count changes.
    private(set) var topology: CoreTopology

    /// The latest update, or nil before the first reading and after a failed
    /// read: the dash state (FR-14, design §6).
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

    /// Starts sampling at the current rate. The baseline is read first, so the
    /// first update is a real measurement rather than a spike measured from
    /// zero (FR-14). Safe to call again: it restarts the timer and reads a new
    /// baseline.
    func start() {
        stop()
        setBaseline(readCounters())
        runTimer(firstUpdateAfter: rate.interval, exact: false)
    }

    /// Stops sampling.
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Changes the refresh rate (FR-18d). While sampling, the meter updates
    /// at once, measured from its last update, or when a full second has
    /// passed since it, and then at the new rate. Until then it keeps its last
    /// update. The baseline isn't read again, and another change doesn't delay
    /// the update, because the wait is always timed from the last update.
    /// When not sampling, the next `start()` uses the new rate.
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
        // A failed read keeps the baseline, so the next read measures the
        // whole gap. Each percentage is a share of ticks, not of clock time,
        // so a longer interval still gives the right figures (FR-15).
        guard let current = readCounters() else {
            sample = nil
            return
        }
        // Reads with different core counts give no changes. The newer read
        // becomes the baseline, so the next tick measures again.
        let changes = baseline.flatMap { CoreCounters.changes(from: $0, to: current) }
        setBaseline(current)
        let groups = topology.groups
        sample = changes.map { Self.sample(from: $0, groups: groups) }
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
