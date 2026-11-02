# CPUMeter

A lightweight macOS app that shows **the current usage of every CPU core** as live
bars in a small floating window, in the spirit of Activity Monitor's floating CPU
window.

It measures usage **passively**: it reads the operating system's per-core counters
and computes the change each interval. It keeps no history and needs no elevated
privileges.

> **Status: in development. Not usable yet.** The
> [requirements](docs/cpu-widget-requirements.md),
> [UI design](docs/cpu-widget-ui-design.md) and
> [build plan](docs/cpu-widget-build-plan.md) are approved.

## Planned features

- **One bar per core**, grouped by core type, with group names read from macOS.
- **User and system time** stacked in each bar, blue and orange by default, and
  changeable with the macOS color chooser.
- **An overall figure and a percentage for each core.**
- **Three sizes**, Small, Medium and Large, with the width fitted to the Mac's core
  count, up to the current maximum of 36 cores.
- **Adjustable refresh rate**, 1–5 seconds, remembered across launches.
- **Keep on Top**, on by default, also remembered.

## Requirements

- **macOS 27** or later
- **Apple Silicon** Mac only
- **Xcode 27** or later to build

## License

[MIT](LICENSE) © 2026 ARC3 Solutions

## /\* Begin Note From The Human

## End Note From The Human \*/
