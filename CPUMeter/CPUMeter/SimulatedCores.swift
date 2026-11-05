//
//  SimulatedCores.swift
//  CPUMeter
//
//  Other core counts, for seeing the meter as it would look on Macs it can't
//  be run on (Increment 2.4; FR-3b, FR-8a, FR-8c, FR-8e, FR-11). Compiled
//  only in Debug builds, so a Release build has none of it and always shows
//  the Mac it runs on.
//
//  Launch arguments:
//
//    -simulateCores Efficiency:4,Performance:2
//        Replaces the detected core groups with these, left to right, lowest
//        performance first (FR-8b). Each name shows exactly as typed (FR-8a),
//        and the cores are numbered in order. A name with spaces needs quotes.
//
//    -simulateCores 10
//        Ten cores whose types are unknown: the unlabeled fallback row (FR-8c).
//
//    -simulateLoad full
//        Every core at 100%, for checking the figures at their widest. Without
//        it, or with `-simulateLoad moving`, a pattern moves across the bars.
//
//  The simulated counters go through the same sampling as the real ones, so
//  the figures, group averages and bars are worked out by the app's own code.
//

#if DEBUG

import Foundation

/// Made-up cores and made-up tick counters, standing in for the Mac's own.
nonisolated struct SimulatedCores: Equatable, Sendable {
    /// How busy the simulated cores are.
    nonisolated enum Load: String, Equatable, Sendable {
        /// A pattern that moves across the bars, with each core, each group
        /// and the overall figure changing over time.
        case moving
        /// Every core at 100%.
        case full
    }

    /// Why a launch argument can't be used.
    nonisolated struct ArgumentError: Error, Equatable, CustomStringConvertible {
        var description: String
    }

    /// The groups the meter shows in place of the Mac's own.
    let topology: CoreTopology

    let load: Load

    /// Reads so far.
    private(set) var step = 0

    /// Each core's cumulative counters, as `CoreCounters.read()` gives them.
    private var counters: [CoreTicks]

    /// Ticks each core gains per read, about what a real core gains in a
    /// second (requirements §6).
    static let ticksPerRead = 100

    /// Where the counters start: just below the 32-bit limit, so they wrap in
    /// the first few seconds and the wrapping subtraction runs in the live
    /// path too (FR-16).
    static let firstCounter = UInt32.max - 199

    /// The most cores a simulation can have. Requirements FR-3 goes to 36;
    /// this leaves room to look beyond it.
    static let maximumCores = 64

    init(topology: CoreTopology, load: Load) {
        self.topology = topology
        self.load = load
        let cores = topology.groups.reduce(0) { $0 + $1.cores.count }
        counters = Array(repeating: CoreTicks(user: Self.firstCounter, system: Self.firstCounter,
                                              idle: Self.firstCounter, nice: 0),
                         count: cores)
    }

    /// The next read: each core's counters after one more interval.
    mutating func read() -> [CoreTicks] {
        step += 1
        for core in counters.indices {
            let ticks = Self.ticks(core: core, coreCount: counters.count, step: step, load: load)
            counters[core].user &+= UInt32(ticks.user)
            counters[core].system &+= UInt32(ticks.system)
            counters[core].idle &+= UInt32(ticks.idle)
        }
        return counters
    }

    // MARK: - The pattern

    /// One core's ticks over one interval, which always add up to
    /// `ticksPerRead`. A pure function of its inputs, so a run can be
    /// repeated exactly.
    ///
    /// The moving pattern is a wave that travels left to right across the
    /// bars every 20 reads, on a level that rises and falls every 30, so the
    /// overall figure moves too. Where the wave is high, cores read 100; where
    /// it's low, 0. System time is 10–40% of each core's busy time, changing
    /// from core to core and over time.
    static func ticks(core: Int, coreCount: Int, step: Int, load: Load)
        -> (user: Int, system: Int, idle: Int) {
        let total = ticksPerRead
        switch load {
        case .full:
            // Some system time, different on neighboring cores, so each bar
            // shows both parts.
            let system = 5 + 5 * (core % 4)
            return (total - system, system, 0)
        case .moving:
            let t = Double(step)
            let x = Double(core) / Double(max(coreCount, 1))
            let level = 0.5 + 0.3 * sin(2 * .pi * t / 30)
            let busy = min(max(level + 0.6 * sin(2 * .pi * (t / 20 - x)), 0), 1)
            let systemShare = 0.1 + 0.3 * (0.5 + 0.5 * sin(2 * .pi * (t / 13 + 3 * x)))
            let busyTicks = Int((busy * Double(total)).rounded())
            let systemTicks = Int((Double(busyTicks) * systemShare).rounded())
            return (busyTicks - systemTicks, systemTicks, total - busyTicks)
        }
    }

    // MARK: - Launch arguments

    /// The simulation the launch arguments ask for, or nil if they don't ask
    /// for one. If an argument can't be used, it prints why, and the app shows
    /// the Mac's own cores.
    static func fromLaunchArguments() -> SimulatedCores? {
        switch parse(arguments: ProcessInfo.processInfo.arguments) {
        case nil:
            return nil
        case .success(let simulation):
            print("CPUMeter: simulating \(simulation.summary).")
            return simulation
        case .failure(let error):
            print("CPUMeter: \(error) Showing this Mac's own cores.")
            return nil
        }
    }

    /// What the launch arguments ask for: nil with neither `-simulateCores`
    /// nor `-simulateLoad`, otherwise the simulation or why it can't be run.
    static func parse(arguments: [String]) -> Result<SimulatedCores, ArgumentError>? {
        /// The value after a flag: nil if the flag isn't there, empty if
        /// nothing follows it.
        func value(of flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag) else { return nil }
            return index + 1 < arguments.count ? arguments[index + 1] : ""
        }
        let coresText = value(of: "-simulateCores")
        let loadText = value(of: "-simulateLoad")
        if coresText == nil && loadText == nil { return nil }

        guard let coresText else {
            return .failure(ArgumentError(description: "-simulateLoad needs -simulateCores."))
        }
        guard !coresText.isEmpty else {
            return .failure(ArgumentError(description:
                "-simulateCores needs a value, such as Efficiency:4,Performance:2."))
        }
        var load = Load.moving
        if let loadText {
            guard let chosen = Load(rawValue: loadText) else {
                return .failure(ArgumentError(description: "-simulateLoad must be full or moving."))
            }
            load = chosen
        }
        return topology(from: coresText).map { SimulatedCores(topology: $0, load: load) }
    }

    /// The groups `-simulateCores` describes: "Name:count,Name:count", left
    /// to right, or a bare count for the unlabeled fallback row.
    static func topology(from text: String) -> Result<CoreTopology, ArgumentError> {
        func refuse(_ why: String) -> Result<CoreTopology, ArgumentError> {
            .failure(ArgumentError(description: "-simulateCores \"\(text)\": \(why)."))
        }
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // A bare count: the core types are unknown (FR-8c).
        if let count = Int(trimmed) {
            guard (1...maximumCores).contains(count) else {
                return refuse("the core count must be 1 to \(maximumCores)")
            }
            return .success(CoreTopology(
                groups: [CoreGroup(name: CoreTopology.fallbackName, cores: Array(0..<count))],
                fallbackReason: "simulated: the core types weren't given"))
        }

        var groups: [CoreGroup] = []
        var next = 0
        for part in trimmed.split(separator: ",", omittingEmptySubsequences: false) {
            guard let colon = part.lastIndex(of: ":") else {
                return refuse("each group is a name, a colon and a core count, such as Efficiency:4")
            }
            let name = part[..<colon].trimmingCharacters(in: .whitespaces)
            let countText = part[part.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return refuse("a group has no name") }
            guard let count = Int(countText), count > 0 else {
                return refuse("\(name) needs a core count of 1 or more")
            }
            guard next + count <= maximumCores else {
                return refuse("more than \(maximumCores) cores in all")
            }
            groups.append(CoreGroup(name: name, cores: Array(next..<next + count)))
            next += count
        }
        return .success(CoreTopology(groups: groups, fallbackReason: nil))
    }

    /// What's being simulated, for the console.
    var summary: String {
        let cores = topology.groups.reduce(0) { $0 + $1.cores.count }
        let groups = topology.fallbackReason == nil
            ? topology.groups.map { "\($0.name) \($0.cores.count)" }.joined(separator: ", ")
            : "types unknown, so one row with no label"
        return "\(cores) cores (\(groups)), \(load == .full ? "every core at 100%" : "a moving pattern")"
    }
}

#endif
