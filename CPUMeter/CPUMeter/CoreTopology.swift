//
//  CoreTopology.swift
//  CPUMeter
//
//  Works out which cores are which type, what macOS calls each type, and the
//  order the groups run in (FR-8). Increment 1.2. The rule is kept apart from
//  the reads that feed it, so it can be checked with fixtures. Nothing here is
//  tied to the main thread.
//

import Foundation
import IOKit

/// One group of bars: the cores of one type, under one label (FR-8).
nonisolated struct CoreGroup: Equatable, Sendable {
    /// macOS's name for this type of core, exactly as macOS gives it, such as
    /// "Efficiency" (FR-8a), or "Cores" for the fallback row (FR-8c). The
    /// meter's layout forms the label from it (FR-8d, FR-8e).
    var name: String

    /// Logical core IDs in ascending order. Each one indexes the array that
    /// `CoreCounters.read()` returns.
    var cores: [Int]
}

nonisolated struct CoreTopology: Equatable, Sendable {
    /// The groups, from lowest to highest performance, left to right (FR-8b).
    var groups: [CoreGroup]

    /// Why the single unlabeled row is shown instead (FR-8c), or nil when the
    /// core types were determined.
    var fallbackReason: String?

    /// How many cores the groups cover: the number each read of the counters
    /// should return. When a read returns a different number, the groups are
    /// read again (NFR-4, Increment 4.2).
    var coreCount: Int { groups.reduce(0) { $0 + $1.cores.count } }

    /// The fallback row's name (FR-8c). The row has no label, so it is never
    /// shown, and no core type can be named wrongly.
    static let fallbackName = "Cores"

    /// What the rule works from, as read from IORegistry and `sysctl`.
    nonisolated struct Inputs: Equatable, Sendable {
        nonisolated struct Core: Equatable, Sendable {
            /// `logical-cpu-id`: the core's place in the counter read.
            var id: Int
            /// `cluster-type`, such as "E" or "P". Only compared with other
            /// cores', never interpreted, so an unfamiliar letter still works.
            var clusterType: String
        }

        nonisolated struct Level: Equatable, Sendable {
            /// `hw.perflevelN.name`, such as "Performance".
            var name: String
            /// `hw.perflevelN.logicalcpu`.
            var coreCount: Int
        }

        /// Each core entry in `IODeviceTree:/cpus`, in the order IORegistry
        /// lists them, or nil if it couldn't be read.
        var cores: [Core]?

        /// Each performance level, `hw.perflevel0` first. Level 0 is the
        /// highest performance. Nil if `sysctl` couldn't be read.
        var levels: [Level]?
    }

    /// Reads the inputs from macOS and applies the rule. `coreCount` is the
    /// number of cores `CoreCounters.read()` returned, so the groups always
    /// cover exactly the cores that are measured.
    static func current(coreCount: Int) -> CoreTopology {
        resolve(readInputs(), coreCount: coreCount)
    }

    // MARK: - The rule (requirements §6)

    /// Groups the cores by type, names each group from macOS, and orders the
    /// groups from lowest to highest performance. Anything that doesn't fit
    /// gives the single unlabeled row (FR-8c) rather than a label that could
    /// be wrong.
    ///
    /// macOS numbers its performance levels and its cores in opposite
    /// directions on the M4: `hw.perflevel0` is Performance, while logical
    /// IDs 0–5 are Efficiency. So the levels are matched to the cores from
    /// the highest level number down.
    static func resolve(_ inputs: Inputs, coreCount: Int) -> CoreTopology {
        func fallback(_ reason: String) -> CoreTopology {
            CoreTopology(groups: [CoreGroup(name: fallbackName, cores: Array(0..<max(coreCount, 0)))],
                         fallbackReason: reason)
        }

        guard coreCount > 0 else { return fallback("no cores were counted") }
        guard let cores = inputs.cores, !cores.isEmpty else { return fallback("IORegistry gave no cores") }
        guard let levels = inputs.levels, !levels.isEmpty else {
            return fallback("sysctl gave no performance levels")
        }

        // Every measured core must appear once, numbered 0 to n − 1, or the
        // groups can't be matched to the counters.
        let ascending = cores.sorted { $0.id < $1.id }
        guard ascending.map(\.id) == Array(0..<coreCount) else {
            return fallback("the logical IDs aren't exactly 0–\(coreCount - 1)")
        }
        guard ascending.allSatisfy({ !$0.clusterType.isEmpty }) else {
            return fallback("a core has no cluster type")
        }
        guard levels.allSatisfy({ !$0.name.isEmpty }) else {
            return fallback("a performance level has no name")
        }

        // 1. In ascending ID order, each run of one cluster type is a group.
        var runs: [(type: String, cores: [Int])] = []
        for core in ascending {
            if core.clusterType == runs.last?.type {
                runs[runs.count - 1].cores.append(core.id)
            } else {
                runs.append((type: core.clusterType, cores: [core.id]))
            }
        }
        guard runs.count == levels.count else {
            return fallback("runs of one cluster type: \(runs.count); performance levels: \(levels.count)")
        }
        guard Set(runs.map(\.type)).count == runs.count else {
            return fallback("a cluster type appears in more than one run")
        }

        // 2. The lowest IDs get the highest level number, the lowest
        //    performance.
        let lowestFirst = Array(levels.reversed())

        // 3. Each group's core count must match its level's.
        for (run, level) in zip(runs, lowestFirst) where run.cores.count != level.coreCount {
            return fallback("cluster type \(run.type): \(run.cores.count) cores; "
                            + "\(level.name): \(level.coreCount)")
        }

        // 4. From lowest to highest performance (FR-8b).
        return CoreTopology(groups: zip(runs, lowestFirst).map { CoreGroup(name: $1.name, cores: $0.cores) },
                            fallbackReason: nil)
    }

    // MARK: - Reading the inputs

    /// Reads the rule's inputs. Both sources work inside the App Sandbox with
    /// no entitlement exceptions (NFR-2).
    static func readInputs() -> Inputs {
        Inputs(cores: readCores(), levels: readLevels())
    }

    /// Each entry under `IODeviceTree:/cpus` that has a logical ID. A core
    /// with no cluster type is kept, with an empty one, so the rule can refuse
    /// it.
    private static func readCores() -> [Inputs.Core]? {
        let cpus = IORegistryEntryFromPath(kIOMainPortDefault, "IODeviceTree:/cpus")
        guard cpus != 0 else { return nil }
        defer { IOObjectRelease(cpus) }

        var iterator: io_iterator_t = 0
        guard IORegistryEntryGetChildIterator(cpus, kIODeviceTreePlane, &iterator) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var cores: [Inputs.Core] = []
        var entry = IOIteratorNext(iterator)
        while entry != 0 {
            if let id = integer(property(entry, "logical-cpu-id")) {
                cores.append(Inputs.Core(id: id, clusterType: text(property(entry, "cluster-type")) ?? ""))
            }
            IOObjectRelease(entry)
            entry = IOIteratorNext(iterator)
        }
        return cores
    }

    /// Each performance level's name and core count, `hw.perflevel0` first.
    private static func readLevels() -> [Inputs.Level]? {
        guard let count = sysctlInteger("hw.nperflevels"), count > 0 else { return nil }
        var levels: [Inputs.Level] = []
        for level in 0..<count {
            guard let name = sysctlText("hw.perflevel\(level).name"),
                  let cores = sysctlInteger("hw.perflevel\(level).logicalcpu") else { return nil }
            levels.append(Inputs.Level(name: name, coreCount: cores))
        }
        return levels
    }

    private static func property(_ entry: io_registry_entry_t, _ key: String) -> CFTypeRef? {
        IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
    }

    /// A number, or a 4-byte little-endian device-tree cell. macOS 27 gives
    /// `logical-cpu-id` as a number. A cell, the form most device-tree values
    /// take, is accepted too.
    private static func integer(_ value: CFTypeRef?) -> Int? {
        if let number = value as? NSNumber { return number.intValue }
        if let data = value as? Data, data.count == 4 {
            return Int(data.withUnsafeBytes { UInt32(littleEndian: $0.loadUnaligned(as: UInt32.self)) })
        }
        return nil
    }

    /// A string, or device-tree bytes such as `<"E">` without the trailing NUL.
    private static func text(_ value: CFTypeRef?) -> String? {
        if let string = value as? String { return string }
        if let data = value as? Data { return String(decoding: data.prefix { $0 != 0 }, as: UTF8.self) }
        return nil
    }

    /// A `sysctl` integer. macOS gives most as 32 bits and some as 64.
    private static func sysctlInteger(_ name: String) -> Int? {
        var value: Int64 = 0
        var size = MemoryLayout<Int64>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return nil }
        switch size {
        // A 32-bit value lands in the low half, because Apple Silicon is
        // little-endian.
        case 4: return Int(Int32(truncatingIfNeeded: value))
        case 8: return Int(value)
        default: return nil
        }
    }

    /// A `sysctl` string, without the trailing NUL.
    private static func sysctlText(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var bytes = [UInt8](repeating: 0, count: size)
        guard sysctlbyname(name, &bytes, &size, nil, 0) == 0 else { return nil }
        return String(decoding: bytes.prefix(size).prefix { $0 != 0 }, as: UTF8.self)
    }
}
