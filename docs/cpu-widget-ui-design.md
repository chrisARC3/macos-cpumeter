# CPUMeter — UI Design

**Date:** November 2, 2026
**Owner:** Chris
**Status:** Approved by Chris on Nov 2, 2026, with the percent labels in §1 added at approval. Nothing is built yet.
**Requirements:** [cpu-widget-requirements.md](cpu-widget-requirements.md), v1.3. If the two disagree, the requirements win.
**Design canvas:** https://claude.ai/artifact/UHY36UTxX5jYKkNp33nCYa (private to Chris). It holds the true-size mockups; this document holds the numbers the build uses.

All dimensions are in points.

---

## 1. Layout

From top to bottom, inside a standard title bar titled "CPUMeter 1.0":

1. **Top row:** the overall figure ("CPU 42%") on the left and the color key (User, System) on the right. *(Chris's choice.)*
2. **Group labels:** one above each group of bars, left-aligned to the group. Each is the name from macOS followed by " %", such as "Efficiency %". *(Chris's addition.)*
3. **Bars:** one per core, grouped by core type, lowest to highest performance from left to right.
4. **Per-core figures:** one centered under each bar, as a whole number with no percent sign. The group label carries it.

The window contains no controls. Everything else is in the Mac menu bar (§5).

## 2. Sizes

Height is fixed at each size. Width is the larger of the base width and the width the bars need: 2 × margin + group gap × (groups − 1) + cores × width per core. Width per core is the minimum below, or more if a group's label wouldn't otherwise fit within that group. The requirements' §6 lists the result for each Mac.

| | Small | Medium | Large |
|---|---|---|---|
| **Content height** (below the 32 pt title bar) | 150 | 225 | 300 |
| **Base width** | 240 | 360 | 480 |
| **Minimum width per core** | 21 | 23 | 25 |
| **Margin, all sides** | 12 | 14 | 16 |
| **Gap between groups** | 12 | 14 | 16 |
| **Gap between bars** | 3 | 4 | 5 |
| **Bar corner radius** | 2 | 3 | 3 |
| **Bar height** | 74 | 134 | 195 |

Bars share whatever width the window has, so they are wider than the minimum on Macs at a base width.

### Text

All text uses the system font. Figures use monospaced digits.

| | Small | Medium | Large |
|---|---|---|---|
| **Overall figure,** semibold | 13 | 16 | 20 |
| **Color key,** regular | 10 | 11 | 12 |
| **Group labels,** medium | 10 | 11 | 12 |
| **Per-core figures,** regular | 10 | 11 | 12 |

### Vertical spacing

| | Small | Medium | Large |
|---|---|---|---|
| **Top row height** | 16 | 20 | 24 |
| **Gap below the top row** | 6 | 8 | 10 |
| **Group label height** | 12 | 14 | 15 |
| **Gap below group labels** | 3 | 4 | 5 |
| **Gap below bars** | 3 | 4 | 5 |
| **Per-core figure height** | 12 | 13 | 14 |

### Color key

| | Small | Medium | Large |
|---|---|---|---|
| **Dot diameter** | 7 | 8 | 9 |
| **Gap between dot and word** | 4 | 4 | 4 |
| **Gap between User and System** | 8 | 10 | 12 |

## 3. Bars

- **Solid**, not segmented. *(Chris's choice.)*
- **User time at the bottom, system time above it,** with a 1 pt gap between the two when both are present.
- **A faint track** fills the full bar height, so an idle core still shows where its bar is.
- **No animation.** A bar changes height at the next refresh.

## 4. Colors

| Element | Dark appearance | Light appearance | In the app |
|---|---|---|---|
| **User time, default** | `#0A84FF` | `#007AFF` | System blue |
| **System time, default** | `#FF9F0A` | `#FF9500` | System orange |
| **Bar track** | White at 10% | Black at 8% | As listed |
| **Overall figure** | `#F5F5F7` | `#1D1D1F` | Primary label color |
| **Key, group labels and per-core figures** | `#AEAEB2` | `#636366` | Secondary label color |
| **Window background** | `#2C2C2E` | `#F5F5F7` | Standard window background |

The hex values for text and the window background are what the mockups use. The app uses the macOS colors in the last column, so its exact shades may differ slightly.

Chosen bar colors replace the two defaults in both the bars and the key (FR-28).

## 5. Menus

**View** contains, in order:

- **Size** ▸ Small, Medium, Large, with the current size checked
- **Refresh Rate** ▸ 1 second, 2 seconds, 3 seconds, 4 seconds, 5 seconds, with the current rate checked
- **Colors** ▸ User Color…, System Color…, then a separator and Reset to Defaults
- A separator
- **Keep on Top,** checked when on

## 6. States

- **Before the first reading:** the tracks are empty, each per-core figure shows "–", and the overall figure shows "CPU –".
- **Core types can't be determined** (FR-8c): one row of bars labeled "Cores %". Sizes and bar height don't change.
- **Full load:** every figure can read 100. The minimum width per core exists for this case.

## 7. Measured fit

Measured on the M4 Mac mini with macOS 27, from real system text. Its display is 2560 × 1440 at scale 1.0, not Retina.

- **Per-core figures:** rendered "100" side by side at full load. At 20, 22 and 24 pt per core they run together; at 21, 23 and 25 pt they read separately. These results set the minimum widths in §2.
- **Top row at base width:** the overall figure at "CPU 100%" plus the key leaves 58.6 pt spare at Small, 151.2 at Medium and 239.7 at Large.
- **Title bar at 240 wide:** "CPUMeter 1.0" is 88.2 pt wide and centered, so it starts 6.9 pt clear of the window buttons, which end at 69.
- **Group labels at 10, 11 and 12 pt:** "Efficiency %" is 61.5, 66.9 and 72.1 pt wide; "Performance %" is 76.1, 82.9 and 89.5; "Super %" is 41.8, 45.5 and 49.1; "Cores %" is 41.6, 45.3 and 48.9.
- **Label fit:** only groups of two cores need extra width, on the MacBook Neo at Small and on the M1 Pro and M1 Max at Small and Medium. With that width, every label fits within its own group on every Mac in the requirements' §6. On the M4 at Small, "Performance %" has 7.9 pt spare.

## 8. Decisions Made Without a Direct Question (please veto if any are wrong)

1. **The faint bar track** (§3) stays. It was on the canvas throughout and drew no objection.
2. **Per-core figures have no percent sign** (§1). There isn't room for one per bar, so the group labels carry it.
3. **The zero state uses a dash** (§6), so "not measured yet" can't be mistaken for 0%.
4. **The key always shows,** at every size and with default colors.
5. **The zoom button is grayed out** because each size is fixed. This should follow from the fixed window size, and the first increment confirms it.
6. **The fallback row is labeled "Cores %"** (§6), so the percent marking appears on every Mac.

## 9. To Confirm in the Real App

The canvas is a browser mockup, so these need checking in the first increments on both Mac minis:

- Text and bar edges on a scale 1.0 display, which is the M4 mini's and the harder case for small text.
- That `Canvas` text matches the widths measured in §7. If it doesn't, the figures need another look at full load.
- Switching size at runtime, including the top-left corner staying in place (FR-22).
- The top row and title bar on the M3 MacBook Air's built-in display, during its one check near the end.

Core counts other than 8 and 10 can only be checked with simulated data.

---

*Next step: `cpu-widget-build-plan.md` breaks the work into small, verifiable increments.*
