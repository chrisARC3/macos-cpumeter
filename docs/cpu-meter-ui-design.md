# CPUMeter — UI Design

**Date:** November 2, 2026
**Owner:** Chris
**Status:** Approved by Chris on Nov 2, 2026, with the percent labels in §1 added at approval. Revised Nov 4, 2026, for requirements v1.7: dragging the window snaps to the three sizes (§2), File keeps Close (§5), and the green window button zooms (§8.5). Revised again the same day for requirements v1.8: §7 gives the label widths to three decimals, which the width rule uses. The window behavior is built: by Nov 4, 2026, Phase 0 had been confirmed by Chris, including the three sizes, Keep on Top, snap resizing and the menus in §5. Phase 1, the measurement behind the bars, was confirmed the same day, including the group labels in §1 on both Mac minis. Increment 2.1, confirmed on the M4 on Nov 5, 2026, works out this page's layout numbers. Increment 2.2, confirmed the same day, draws the meter from this page, and Chris found it matches the design canvas very well.
**Requirements:** [cpu-meter-requirements.md](cpu-meter-requirements.md), v1.8. If the two disagree, the requirements win.
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

### Resizing by dragging

Requirements FR-3d. The window can be dragged to any size between Small and Large, and no smaller or larger. When the drag ends:

1. **The dimension the drag changed more decides.** For width and for height, the change is measured as a share of that dimension's range from Small to Large. So dragging only the right edge, or only the bottom edge, can reach every size.
2. **The window settles at the size nearest the dragged value** in that dimension. An exact tie goes to the larger size.
3. **The edge or corner opposite the one dragged stays in place.** Then the on-screen rule in FR-22 applies.

For example, on the M4, Small is 246 × 150 and Large is 480 × 300. Dragging the right edge of a Small window out to 380 changes the width by 57% of its range and the height by none, so width decides. 380 is nearest Medium's 360, so the window settles at Medium.

During the drag, the meter stays at its current size, pinned to the window's top-left, and the rest of the window shows the plain window background.

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

**File** contains only **Close** (⌘W). Closing the window quits the app (FR-23).

**Edit, Window and Help** stay as macOS provides them. Edit stays for the color chooser's hex field, which needs Copy and Paste.

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
- **Group labels at 10, 11 and 12 pt:** "Efficiency %" is 61.5, 66.9 and 72.1 pt wide; "Performance %" is 76.1, 82.9 and 89.5; "Super %" is 41.8, 45.5 and 49.1; "Cores %" is 41.6, 45.3 and 48.9. To three decimals, as the width rule uses them (measured in Increment 2.1, Nov 4, 2026): 61.511, 66.889 and 72.126; 76.130, 82.905 and 89.528; 41.777, 45.503 and 49.148; 41.553, 45.257 and 48.879. The extra precision matters once: the M1 Pro with two Efficiency cores needs 282.05 at Small, so its window is 283 wide.
- **Label fit:** only groups of two cores need extra width, on the MacBook Neo at Small and on the M1 Pro and M1 Max at Small and Medium. With that width, every label fits within its own group on every Mac in the requirements' §6. On the M4 at Small, "Performance %" has 7.9 pt spare.

## 8. Decisions Made Without a Direct Question (please veto if any are wrong)

1. **The faint bar track** (§3) stays. It was on the canvas throughout and drew no objection.
2. **Per-core figures have no percent sign** (§1). There isn't room for one per bar, so the group labels carry it.
3. **The zero state uses a dash** (§6), so "not measured yet" can't be mistaken for 0%.
4. **The key always shows,** at every size and with default colors.
5. **The green window button zooms to Large and back,** and full screen is off. *(Revised Nov 4, 2026. It was gray while the sizes were fixed. Dragging now snaps to the sizes, so the window counts as resizable.)*
6. **The fallback row is labeled "Cores %"** (§6), so the percent marking appears on every Mac.
7. **"Nearest" is judged by whichever dimension the drag changed more** (§2, Resizing by dragging), as a share of its range from Small to Large, so a drag along one edge always works.
8. **During a drag, the meter keeps its current size** rather than stretching, because each size has its own fixed text and spacing.

## 9. To Confirm in the Real App

The canvas is a browser mockup, so these need checking in the real app, at the increments the build plan sets out:

- Text and bar edges on a scale 1.0 display, which is the M4 mini's and the harder case for small text.
- That `Canvas` text matches the widths measured in §7. If it doesn't, the figures need another look at full load.
- Switching size at runtime, including the top-left corner staying in place (FR-22). The M4 confirmed this in Increment 0.2; staying on screen needed direct window access.
- Snapping after a drag from each edge and corner, near screen edges, and with the green button. Confirmed by Chris on the M4 and the M1 in Increment 0.3.
- The top row and title bar on the M3 MacBook Air's built-in display, during its one check near the end.

Core counts other than 8 and 10 can only be checked with simulated data.

---

*Next step: a discussion of some minor design changes with Chris, then Increment 2.3, other core counts, of `cpu-meter-build-plan.md`.*
