# CPUMeter

A lightweight macOS app that shows **the current usage of every CPU core** as live
bars in a small floating window, in the spirit of Activity Monitor's floating CPU
window.

It measures usage **passively**: it reads the operating system's per-core counters
and computes the change each interval. It keeps no history and needs no elevated
privileges.

> **Status: in development. Not usable yet.** The
> [requirements](docs/cpu-meter-requirements.md),
> [UI design](docs/cpu-meter-ui-design.md) and
> [build plan](docs/cpu-meter-build-plan.md) are approved.

## Planned features

- **One bar per core**, grouped by core type, with group names read from macOS.
- **User and system time** stacked in each bar, blue and orange by default, and
  changeable with the macOS color chooser.
- **An overall figure and a percentage for each core.**
- **Any size from Small up**, dragged from any edge or corner, with the whole meter
  scaling together. Small, Medium and Large are presets, and the width fits the
  Mac's core count, up to the current maximum of 36 cores.
- **Adjustable refresh rate**, 1–5 seconds, remembered across launches.
- **Keep on Top**, on by default, also remembered.

## Measured cost

Measured over an hour after a 5-minute warm-up, at a 1-second refresh, on macOS 27.2
(November 2026):

| Mac | CPU | Memory footprint |
|---|---|---|
| M4 Mac mini | 0.37% of one core | about 26 MB |
| 2020 M1 Mac mini | 0.57% of one core | about 25 MB |

These figures are for the Medium size. CPU and memory stay level across the hour. On
the M4, CPU is about the same at every size, from Small up to the largest the screen
allows, which uses about 15 MB more memory.

## Requirements

- **macOS 27** or later
- **Apple Silicon** Mac only
- **Xcode 27** or later to build

## License

[MIT](LICENSE) © 2026 ARC3 Solutions

## /\* Begin Note From The Human

## End Note From The Human \*/
