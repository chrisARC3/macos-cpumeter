//
//  CoreCounters.swift
//  CPUMeter
//
//  Reads each core's cumulative tick counters and works out the change between
//  two reads (FR-13, FR-16). Increment 1.1. Nothing here is tied to the main
//  thread, so the sampler's timer (1.3) can call it from anywhere.
//

import Darwin

/// One core's cumulative tick counters as macOS reports them: 32-bit values
/// that wrap (FR-16), advancing about 100 ticks a second per core.
nonisolated struct CoreTicks: Equatable, Sendable {
    var user: UInt32
    var system: UInt32
    var idle: UInt32
    var nice: UInt32
}

/// One core's tick change between two reads.
nonisolated struct TickChange: Equatable, Sendable {
    /// User time, with nice time counted as user (FR-9).
    var user: UInt64
    var system: UInt64
    var idle: UInt64

    /// All of the core's time over the interval. Each percentage is a share of
    /// this, not of clock time (FR-15).
    var total: UInt64 { user + system + idle }
}

nonisolated enum CoreCounters {
    /// The Mac's host port, fetched once. Every `mach_host_self()` call adds a
    /// reference to the port that is never released.
    private static let host = mach_host_self()

    /// Reads every core's counters at once (FR-13), in logical core order.
    /// Returns nil if macOS refuses the read, so that a failure can't be
    /// mistaken for an idle Mac.
    static func read() -> [CoreTicks]? {
        var coreCount: natural_t = 0
        var info: processor_info_array_t?
        var infoCount: mach_msg_type_number_t = 0
        let result = host_processor_info(host, PROCESSOR_CPU_LOAD_INFO, &coreCount, &info, &infoCount)
        guard result == KERN_SUCCESS, let info else { return nil }

        // macOS hands over memory that must be freed after every read, or each
        // tick would leak (NFR-1).
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info),
                          vm_size_t(infoCount) * vm_size_t(MemoryLayout<integer_t>.stride))
        }

        let states = Int(CPU_STATE_MAX)
        guard Int(infoCount) >= Int(coreCount) * states else { return nil }
        return (0..<Int(coreCount)).map { core in
            func ticks(_ state: Int32) -> UInt32 {
                UInt32(bitPattern: info[core * states + Int(state)])
            }
            return CoreTicks(user: ticks(CPU_STATE_USER), system: ticks(CPU_STATE_SYSTEM),
                             idle: ticks(CPU_STATE_IDLE), nice: ticks(CPU_STATE_NICE))
        }
    }

    /// One core's change between two reads. The subtraction wraps, so a
    /// counter that passes 0xFFFFFFFF between reads still gives the right
    /// change (FR-16).
    static func change(from old: CoreTicks, to new: CoreTicks) -> TickChange {
        TickChange(user: UInt64(new.user &- old.user) + UInt64(new.nice &- old.nice),
                   system: UInt64(new.system &- old.system),
                   idle: UInt64(new.idle &- old.idle))
    }

    /// Every core's change between two reads, in core order. Returns nil if
    /// the reads have different numbers of cores, rather than pairing the
    /// wrong cores.
    static func changes(from old: [CoreTicks], to new: [CoreTicks]) -> [TickChange]? {
        guard old.count == new.count else { return nil }
        return zip(old, new).map { change(from: $0, to: $1) }
    }
}
