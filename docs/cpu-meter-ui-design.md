# CPUMeter — UI Design

**Date:** November 2, 2026, revised November 11, 2026
**Owner:** Chris
**Status:** Approved by Chris on Nov 2, 2026, with the percent labels in §1 added at approval. Revised Nov 4, 2026, for requirements v1.7: dragging the window snaps to the three sizes (§2), File keeps Close (§5), and the green window button zooms (§8.5). Revised again the same day for requirements v1.8: §7 gives the label widths to three decimals, which the width rule uses. The window behavior is built: by Nov 4, 2026, Phase 0 had been confirmed by Chris, including the three sizes, Keep on Top, snap resizing and the menus in §5. Phase 1, the measurement behind the bars, was confirmed the same day, including the group labels in §1 on both Mac minis. Increment 2.1, confirmed on the M4 on Nov 5, 2026, works out this page's layout numbers. Increment 2.2, confirmed the same day, draws the meter from this page, and Chris found it matches the design canvas very well. **Revised Nov 5, 2026, for requirements v1.9,** with Chris's design changes after 2.2: system time at the bottom of each bar (§3), System first in the key and the Colors menu (§1, §2, §5), each group's average in its label, with "Perf" where "Performance" would widen the window (§1, §7), and no label on the fallback row, whose bars grow to fill the space (§2, §6). Revised again the same day for requirements v1.10, with Chris's wording: the overall figure reads "All cores: 42%", and the group labels take a colon (§1, §6, §7). Increment 2.3 built both revisions, and Chris confirmed it on the M4 the same day: everything looked exactly as predicted and expected. Increment 2.4 drew every Mac in the requirements' §6 from simulated cores, at all three sizes, and Chris confirmed it on the M4 and the M1 the same day. Revised again the same day for requirements v1.11, at Chris's request: View → Size shows the keyboard shortcuts ⌘1, ⌘2 and ⌘3 (§5). Increment 3.1 built them, and Chris confirmed it on the M4 the same day. Increment 3.2 built Refresh Rate (§5), and Chris confirmed it on the M4 the same day. Increment 3.3 built Colors (§4, §5), completing §5's View menu, and Chris confirmed it on the M4 and the M1 on Nov 6, 2026. **Revised Nov 6, 2026, for requirements v1.13,** at Chris's request: ⌘1 to ⌘5 choose the refresh rate, and the sizes take ⇧⌘S, ⇧⌘M and ⇧⌘L (§5). Increment 3.4 built them, and Chris confirmed it on the M4 the same day. **Requirements v1.16, Nov 7, 2026,** moves the drawing from SwiftUI `Canvas` to Core Animation, after Increment 5.2 found that `Canvas` leaks a system timer on every redraw at Medium and Large. Nothing in this page changes: Increment 5.3 draws the same meter, and Chris confirmed it on the M4 and the M1 the same day. **Revised Nov 8, 2026, for requirements v1.17,** Chris's free sizing: every size is Small enlarged, so Medium and Large take Small's numbers times 1.5 and 2 (§2, §6), the window keeps its shape while it's dragged from any edge or corner and stays where the drag ends (§2), View → Size checks a preset only when the window is exactly at it (§5), and "Perf" shows at every size where Small uses it (§1, §7). Chris approved this revision the same day, with four fixes from Claude's reread: §7's top-row spare and label fit brought up to date, one rounding rule for width and height (§2, §8 item 11), and size limits that follow the window's screen (§2, §8 item 13). **Revised Nov 9, 2026, for requirements v1.18,** after Increment 5.4's probe: §2's Resizing by dragging says how the shape and the limits are kept, and records that the edges in step 1 held in Chris's drags; §8 item 5 brings the green button back to exactly the size it had. Chris approved this revision the same day. Increment 5.4 builds both revisions, and Chris confirmed it on the M4 and the M1 on Nov 10, 2026. §7 records its measurements, and §2 the one rule its testing added. **Revised Nov 11, 2026, for requirements v1.20,** at Chris's request: §8 item 5's green button grows the window to its largest size and back, and at the largest size goes to Large. Where the window goes is Claude's proposal. Chris approved this revision the same day.
**Requirements:** [cpu-meter-requirements.md](cpu-meter-requirements.md), v1.20. If the two disagree, the requirements win.
**Design canvas:** https://claude.ai/artifact/UHY36UTxX5jYKkNp33nCYa (private to Chris). It holds the true-size mockups; this document holds the numbers the build uses.

All dimensions are in points.

---

## 1. Layout

From top to bottom, inside a standard title bar titled "CPUMeter 1.0":

1. **Top row:** the overall figure ("All cores: 42%") on the left and the color key (System, User) on the right. *(Chris's choice; System first since Nov 5, 2026, to match the bars from the bottom up. The wording is Chris's, Nov 5, 2026; it was "CPU 42%".)*
2. **Group labels:** one above each group of bars, left-aligned to the group. Each is the name from macOS, exactly as given, a colon and the group's average, such as "Efficiency: 24%" or "Performance: 13%", in the same form as the top row. The average has monospaced digits and room for "100%", so the name never moves. "Performance" becomes "Perf" where the full label would widen Small (requirements FR-8e), and then at every size, because every size is Small enlarged: on the Macs in requirements §6, on the 10-core M4 and M5 and on the MacBook Neo. *(Until requirements v1.17, only at Small on the M4 and M5, and at Small and Medium on the Neo.)* The fallback row has no label (§6). *(Chris's addition; the average, "Perf" and the colon, Chris's requests of Nov 5, 2026.)*
3. **Bars:** one per core, grouped by core type, lowest to highest performance from left to right.
4. **Per-core figures:** one centered under each bar, as a whole number with no percent sign. The group label carries it, or on the fallback row, the overall figure.

The window contains no controls. Everything else is in the Mac menu bar (§5).

## 2. Sizes

**Every size is Small enlarged** (requirements FR-3). Small's content is 150 high. Its width is the larger of the base width and the width the bars need: 2 × margin + group gap × (groups − 1) + cores × width per core. Width per core is the minimum below, or more if a group's label, at its widest ("Efficiency: 100%"), wouldn't otherwise fit within that group. Every core gets the same width, so all bars match.

At any other size, **every number on this page is Small's times the scale,** the window's content width divided by Small's. Medium is 1.5 and Large is 2, and their columns below are shown for reference. Any size's width is Small's times its scale, and its height 150 times its scale, each to the nearest whole point, with a half rounding up. For Medium and Large that gives the widths in the requirements' §6, which round up, because Small's width times 1.5 or 2 always ends in .0 or .5. The meter is drawn from the top-left at the scale of its width, so any fraction of a point the height gains or loses falls in the bottom margin. The requirements' §6 lists Small, Medium and Large for each Mac. *(Until requirements v1.17, Medium and Large had numbers of their own, larger in places, such as bars 134 and 195 tall and text of 11 and 12 points. This page's git history keeps them.)*

| | Small | Medium (1.5×) | Large (2×) |
|---|---|---|---|
| **Content height** (below the 32 pt title bar) | 150 | 225 | 300 |
| **Base width** | 240 | 360 | 480 |
| **Minimum width per core** | 21 | 31.5 | 42 |
| **Margin, all sides** | 12 | 18 | 24 |
| **Gap between groups** | 12 | 18 | 24 |
| **Gap between bars** | 3 | 4.5 | 6 |
| **Bar corner radius** | 2 | 3 | 4 |
| **Bar height** | 74 | 111 | 148 |

Bars share whatever width the window has, so they are wider than the minimum on Macs at a base width.

The fallback row (§6) has no group label, so its bars also take the label's height and the gap below it: they are 89 tall at Small, 133.5 at Medium and 178 at Large.

### Resizing by dragging

Requirements FR-3d. Any edge or corner can be dragged, and the window keeps Small's shape throughout: at each step of the drag, CPUMeter answers the window with the size of Small's shape, by the rounding rule above (requirements §6 and §8 item 20).

1. **Dragging the left or right edge sets the width, and the height follows,** with the top edge in place. **Dragging the top or bottom edge sets the height, and the width follows,** with the left edge in place. **Dragging a corner** keeps the opposite corner in place. So a meter grows down and to the right, away from its title bar, unless its top or left edge is dragged. On its own, macOS centers the dimension a side drag doesn't set, so after each step CPUMeter puts the top edge, or the left edge, back where it was. A corner follows the average of what its width and height ask for, so the size moves smoothly rather than switching between them.
2. **The limits are Small and the largest size of the shape that fits the screen's visible area,** set through the meter's own frame, which SwiftUI turns into the window's limits. The screen is the one macOS says the window is on, the one holding most of it. The limits are set again when the window moves to another screen or that screen's visible area changes, and a window that is then larger than its new limit takes the largest size that fits, keeping its top-left corner in place where it can (FR-22).
3. **The meter is drawn at each size as the drag passes it,** with the text, bars and gaps growing and shrinking together.
4. **When the drag ends, the window stays at that size.** FR-22's on-screen rule then applies, and the new scale is saved (FR-20).

For example, on the M4, Small is 246 × 150. Dragging the right edge of a Small window out to 300 makes it 300 × 183, a scale of 1.22, with per-core figures of 12.2 points.

Increment 5.4's probe (Nov 8–9, 2026) settled how. AppKit's `contentAspectRatio` shaped the whole window, title bar included, so the meter came out 32 points short, and SwiftUI reset limits put directly on the window about once a second. Answering each step of the drag works: in Chris's drags of every edge and corner on the M4, every drag ended exactly in shape, the edges named in step 1 stayed in place at every step with no flicker, and the window stopped at Small and at the largest size, 2,259 × 1,377 there. Drags that ran off the screen came back on when they ended (step 4).

Increment 5.4's code (Nov 9, 2026) added one rule, found in its real drags. While a drag moves the top edge, the size stops where the top reaches the top of the screen's visible area, so the opposite edge or corner stays in place (FR-22). Without it, macOS pushed a window grown into the menu bar back down, which moved the corner that should have stayed put. Chris checked it on the M4 in 5.4's tests.

### Text

All text uses the system font. Figures use monospaced digits, including each group's average.

| | Small | Medium (1.5×) | Large (2×) |
|---|---|---|---|
| **Overall figure,** semibold | 13 | 19.5 | 26 |
| **Color key,** regular | 10 | 15 | 20 |
| **Group labels,** medium | 10 | 15 | 20 |
| **Per-core figures,** regular | 10 | 15 | 20 |

### Vertical spacing

| | Small | Medium (1.5×) | Large (2×) |
|---|---|---|---|
| **Top row height** | 16 | 24 | 32 |
| **Gap below the top row** | 6 | 9 | 12 |
| **Group label height** | 12 | 18 | 24 |
| **Gap below group labels** | 3 | 4.5 | 6 |
| **Gap below bars** | 3 | 4.5 | 6 |
| **Per-core figure height** | 12 | 18 | 24 |

### Color key

| | Small | Medium (1.5×) | Large (2×) |
|---|---|---|---|
| **Dot diameter** | 7 | 10.5 | 14 |
| **Gap between dot and word** | 4 | 6 | 8 |
| **Gap between System and User** | 8 | 12 | 16 |

## 3. Bars

- **Solid**, not segmented. *(Chris's choice.)*
- **System time at the bottom, user time above it,** as in Activity Monitor, with a 1 pt gap between the two when both are present. The gap comes out of the user part, so the top of the bar always shows the true total. A user part too thin to keep a pixel after the gap touches the system part instead. *(The order is Chris's request, Nov 5, 2026. Until then, user time was at the bottom.)*
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

- **Size** ▸ Small ⇧⌘S, Medium ⇧⌘M, Large ⇧⌘L. A size is checked only when the window is exactly that size, meaning its content width is that preset's width, so after a drag to any other size none is checked (requirements FR-24). Choosing one sets the window to it with the top-left corner in place (FR-22). Each shortcut shows at the right of its item, where macOS draws menu shortcuts (requirements FR-24a). *(Chris's request, Nov 5, 2026, with ⌘1, ⌘2 and ⌘3; first letters since Nov 6, 2026.)*
- **Refresh Rate** ▸ 1 second ⌘1, 2 seconds ⌘2, 3 seconds ⌘3, 4 seconds ⌘4, 5 seconds ⌘5, with the current rate checked (requirements FR-18e). *(Shortcuts at Chris's request, Nov 6, 2026.)*
- **Colors** ▸ System Color…, User Color…, then a separator and Reset to Defaults
- A separator
- **Keep on Top,** checked when on

## 6. States

- **Before the first reading:** the tracks are empty, each per-core figure shows "–", each group label shows its name and a dash, such as "Efficiency: –", and the overall figure shows "All cores: –".
- **Core types can't be determined** (FR-8c): one row of bars with no label. The bars take the label's place, so at Small they are 89 tall rather than 74, and at other sizes those times the scale. The window's sizes don't change. *(Chris's decision, Nov 5, 2026. Until then the row was labeled "Cores %".)*
- **Full load:** every figure can read 100, and the overall figure and every group label "100%". The minimum width per core exists for this case.

## 7. Measured fit

Measured on the M4 Mac mini with macOS 27, from real system text. Its display is 2560 × 1440 at scale 1.0, not Retina.

- **Per-core figures:** rendered "100" side by side at full load. At 20, 22 and 24 pt per core they run together; at 21, 23 and 25 pt they read separately. These results set Small's minimum width in §2. Medium and Large used 23 and 25 until requirements v1.17.
- **Top row at base width:** the overall figure at "All cores: 100%" plus the key leaves 27.3 pt spare at Small (measured Nov 5, 2026). Since requirements v1.17 the spare grows with the scale, and by a little more, because the text gets narrower for its size as it grows (below), so it is at least 41.0 at Medium and 54.6 at Large. Measured in Increment 5.4 (Nov 9, 2026), it is 52.8 at Medium, 79.1 at Large and 407.1 at the M4's largest size, 2,259 wide. In Small's points, that is 27.3, 35.2, 39.6 and 44.3. No layout leaves less than the base width does. With their own layouts, before v1.17, Medium and Large left 114.2 and 196.0, and "CPU 100%", before requirements v1.10, left 58.6, 151.2 and 239.7.
- **Title bar at 240 wide:** "CPUMeter 1.0" is 88.2 pt wide and centered, so it starts 6.9 pt clear of the window buttons, which end at 69.
- **Group labels before requirements v1.9,** at 10, 11 and 12 pt: "Efficiency %" is 61.5, 66.9 and 72.1 pt wide; "Performance %" is 76.1, 82.9 and 89.5; "Super %" is 41.8, 45.5 and 49.1; "Cores %" is 41.6, 45.3 and 48.9. To three decimals, as the width rule uses them (measured in Increment 2.1, Nov 4, 2026): 61.511, 66.889 and 72.126; 76.130, 82.905 and 89.528; 41.777, 45.503 and 49.148; 41.553, 45.257 and 48.879. The extra precision matters once: the M1 Pro with two Efficiency cores needs 282.05 at Small, so its window is 283 wide.
- **Group labels at their widest,** with monospaced digits, at 10, 11 and 12 pt (measured Nov 5, 2026): "Efficiency: 100%" is 84.488, 91.906 and 99.136; "Performance: 100%" is 99.107, 107.922 and 116.537; "Perf: 100%" is 56.293, 61.277 and 66.145; "Super: 100%" is 64.754, 70.520 and 76.158. From requirements v1.10 the width rule used these at each size. Since v1.17 it uses only the 10-pt figures, because it sets Small's width alone and every other size scales from it.
- **Label fit** (requirements v1.10): the M1 Pro and M1 Max need the most extra width, because their Efficiency group has two cores: Small is 374 wide rather than 240 on the 8-core M1 Pro, and 459 on the 10-core M1 Pro and M1 Max. Since requirements v1.17 that extra width carries to every size. *(Until then, the 8-core M1 Pro needed it only at Small and Medium.)* Macs with four Efficiency cores and 10 or more cores in all need 2–3 pt more at Small, because "Efficiency: 100%" is 0.5 pt wider than four 21 pt cores. "Perf" appears on the 10-core M4 and M5 and on the MacBook Neo at Small, and so at every size since requirements v1.17, and nowhere else. With that, every label fits within its own group on every Mac in the requirements' §6. On the M4, "Perf: 100%" has 27.7 pt spare at Small.
- **Text at larger sizes** (requirements v1.17): from 10 to 12 pt, the system font gets slightly narrower for its size as the size grows. "Efficiency: 100%" is 8.45 pt wide per point of size at 10 pt, 8.36 at 11 and 8.26 at 12, and "Performance: 100%" 9.91, 9.81 and 9.71. It holds at larger sizes too (measured in Increment 5.4, Nov 9, 2026):
  - "Efficiency: 100%" is 8.01 pt per point of size at Medium's 15 pt, 7.69 at Large's 20 pt and 7.38 at the M4's largest, 91.8 pt. "Performance: 100%" is 9.45, 9.08 and 8.64.
  - A "100" figure is 1.92 per point at Small, 1.84 at Medium, 1.80 at Large and 1.81 at the largest.

  So text that fits at Small, with the gaps and widths scaled with it, fits at every larger size, with a little more room. The tightest places are at Small: 0.012 pt to spare for the 8-core M1 Pro's "Efficiency: 100%", and 1.752 pt beside a "100" figure on the 10-core M4 and M5.

## 8. Decisions Made Without a Direct Question (please veto if any are wrong)

1. **The faint bar track** (§3) stays. It was on the canvas throughout and drew no objection.
2. **Per-core figures have no percent sign** (§1). There isn't room for one per bar, so the group labels carry it.
3. **The zero state uses a dash** (§6), so "not measured yet" can't be mistaken for 0%.
4. **The key always shows,** at every size and with default colors.
5. **The green window button grows the window to its largest size and back** (requirements §8 item 21), and full screen is off. The first press takes the window to the largest size its screen holds. That size fills the visible area from top to bottom, so the window's top goes to the top of the area. Its left edge stays where it was, unless the window would then run off the right of the screen; then it moves left just far enough (FR-22). The next press takes the window back to exactly the size and place it had. At the largest size, with nothing to go back to, the first press takes the window to Large with its top-left corner in place, and the next back to the largest. A press after the window has been moved or resized counts as a first press. *(Revised Nov 11, 2026, for requirements v1.20, at Chris's request; where the window goes is Claude's proposal. Until then the button zoomed to Large and back. Revised Nov 4, 2026: it was gray while the sizes were fixed, and since then the window can be dragged, so it counts as resizable. "Exactly" added for v1.18: in the probe, macOS asked for the way back by the old size, and working it out again from the height came back a point wider.)*
6. **The fallback row has no label** (§6), so the overall figure carries the percent sign there. *(Revised Nov 5, 2026, at Chris's request. It was labeled "Cores %".)*
7. **A drag keeps the top edge in place when a side is dragged, and the left edge when the top or bottom is dragged** (§2, Resizing by dragging), so the meter grows away from its title bar and its top-left corner, which is where FR-22 pins it too. *(Revised for requirements v1.17. Until then this item set how the nearest size was judged when a drag snapped.)*
8. **During a drag, the meter is drawn at each size it passes through** (§2), so the size you see is the size you'll get. That costs some CPU, but only while dragging. *(Revised for requirements v1.17. Until then the meter kept its size during a drag, because each size had its own text and spacing.)*
9. **A group label keeps the label's style for its average,** medium weight in the secondary label color, with monospaced digits. *(Added Nov 5, 2026.)*
10. **The 1 pt gap comes out of the upper part of a bar,** now user time, so the bar's top always shows the true total (§3). *(Added Nov 5, 2026.)* With v1.17 it scales with the rest: 1.5 pt at Medium and 2 at Large.
11. **Every size's width and height round to the nearest whole point, with a half rounding up** (§2), and the meter is drawn from the top-left at the scale of its width, so any fraction of a point falls in the bottom margin. For Medium and Large this gives the requirements' §6 widths, which round up. A dragged size also comes back exactly from its saved scale at the next launch, where always rounding up could add a point from a tiny error in the arithmetic. *(Added for requirements v1.17, and widened from the height to both when Chris approved this revision.)*
12. **The checkmark goes by the content width** (§5), so it shows after choosing a preset, or after a drag that ends exactly at one. *(Added for requirements v1.17.)*
13. **The size limits follow the window's screen** (§2, Resizing by dragging): the one macOS says it's on, and again whenever it moves to another screen or that screen's visible area changes, such as when the Dock changes size. A window that is then too large for its screen takes the largest size that fits, with its top-left corner kept in place where it can be, as at launch (FR-22). *(Added for requirements v1.17, when Chris approved this revision.)*

## 9. To Confirm in the Real App

The canvas is a browser mockup, so these need checking in the real app, at the increments the build plan sets out:

- Text and bar edges on a scale 1.0 display, which is the M4 mini's and the harder case for small text.
- That the meter's text matches the widths measured in §7, as drawn by `Canvas` through Increment 5.2 and by Core Animation from 5.3. If it doesn't, the figures need another look at full load.
- Switching size at runtime, including the top-left corner staying in place (FR-22). The M4 confirmed this in Increment 0.2; staying on screen needed direct window access.
- Resizing by dragging each edge and corner, with the shape kept during the drag, near screen edges, at the smallest and largest sizes, and with the green button. Snapping, which this replaced in requirements v1.17, was confirmed by Chris on the M4 and the M1 in Increment 0.3. Chris confirmed free sizing in Increment 5.4 (Nov 10, 2026): every one of these on the M4, and a drag, the presets and a relaunch on the M1.
- Text and bars at sizes between and beyond the presets, on a scale 1.0 display, up to the largest size. Chris checked them on the M4 in Increment 5.4, under the test loads and against the design canvas.
- The top row and title bar on the M3 MacBook Air's built-in display, during its one check near the end. Chris checked them in Increment 5.6 (Nov 11, 2026): the title bar stops just below the menu bar, clear of the notch, at every size and position tried, and the text is sharp at scale 2 at the presets, a dragged size and the largest size.

Core counts other than 8 and 10 can only be checked with simulated data. Increment 2.4 did that for every Mac in the requirements' §6, including the MacBook Neo's "Perf" and the fallback row, and found every one clean at all three sizes. Increment 5.4 checked them again, headlessly, at the new Medium and Large and at sizes between and beyond them, and found every one clean.

---

*Next step: Increment 5.7, the green button, in build plan v1.12, which builds §8 item 5's revision for requirements v1.20, then 5.8, traceability, README and release. Increment 5.6, the M3 MacBook Air check, was confirmed on the Air on Nov 11, 2026, with no change to this page: the top row and title bar stay below the menu bar and the notch, and text is sharp on a Retina screen (§9). Increment 5.5, Accuracy, was confirmed on the M4 and the M1 on Nov 10, 2026, with no change to this page. Increment 5.4, free sizing, was confirmed by Chris on the M4 and the M1 on Nov 10, 2026. It builds this page's revisions for requirements v1.17 and v1.18, approved by Chris on Nov 8 and 9, 2026. §7 records its measurements, and §2 the one rule its testing added. The design canvas shows Medium and Large as v1.17 draws them, from version 25 (Nov 8, 2026), and its live window can be set to any scale from 1 to 3 times Small. Increment 5.2, Footprint, was confirmed on the M4 and the M1 on Nov 8, 2026, with no change to this page.*
