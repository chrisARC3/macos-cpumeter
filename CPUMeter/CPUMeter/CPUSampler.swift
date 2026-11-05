//
//  CPUSampler.swift
//  CPUMeter
//
//  Samples every core on a timer and works out the percentages the meter
//  shows (FR-8d, FR-9, FR-10, FR-12, FR-14, FR-15). Increment 1.3; each
//  group's average since Increment 2.3. The arithmetic is kept in pure
//  functions, so it can be checked without a timer.
//

import Foundation
import Observation

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

    /// Seconds between updates. View → Refresh Rate (3.1) makes it a setting.
    @ObservationIgnored private let interval: TimeInterval = 1

    init() {
        topology = CoreTopology.current(coreCount: CoreCounters.read()?.count ?? 0)
    }

    // MARK: Lifecycle

    /// Starts sampling. The baseline is read first, so the first update is a
    /// real measurement rather than a spike measured from zero (FR-14). Safe
    /// to call again: it restarts the timer and reads a new baseline.
    func start() {
        stop()
        baseline = CoreCounters.read()

        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            // The timer is on the main run loop, so this runs on the main
            // actor already.
            MainActor.assumeIsolated { self?.tick() }
        }
        // Lets macOS combine wakeups (NFR-1).
        timer.tolerance = interval * 0.1
        // The common modes include the one macOS uses while a menu is open,
        // so the meter keeps updating then too.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Stops sampling.
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: Sampling

    /// One update, from one read (FR-12).
    private func tick() {
        // A failed read keeps the baseline, so the next read measures the
        // whole gap. Each percentage is a share of ticks, not of clock time,
        // so a longer interval still gives the right figures (FR-15).
        guard let current = CoreCounters.read() else {
            sample = nil
            return
        }
        // Reads with different core counts give no changes. The newer read
        // becomes the baseline, so the next tick measures again.
        let changes = baseline.flatMap { CoreCounters.changes(from: $0, to: current) }
        baseline = current
        let groups = topology.groups
        sample = changes.map { Self.sample(from: $0, groups: groups) }
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
