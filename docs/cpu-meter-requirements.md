# CPUMeter — Requirements

**Version:** 1.8
**Changelog:** v1.8 (Nov 4, 2026) — §6's window widths: the M1 Pro with 6 Performance and 2 Efficiency cores is 283 points wide at Small, not 282. Increment 2.1 measured "Efficiency %" at 61.511 points at 10 pt, not 61.5, so the width its bars need is 282.05, which FR-3b rounds up. The table had been worked out from the rounded figure. No requirement changed. Chris's decision, Nov 4, 2026. v1.7 (Nov 4, 2026) — §6 adds a fourth use of AppKit: direct access to CPUMeter's own window, to set its level for Keep on Top (FR-2), keep it on screen after a size change (FR-22) and snap drag resizing to the three sizes. Increment 0.2 found that SwiftUI's `.windowLevel` didn't keep the window on top at launch, and that SwiftUI can't move a window once it's open. Added **FR-3d**: the window can be resized by dragging, and settles at the nearest of the three sizes when the drag ends. FR-25 keeps File → Close. §§2, 3 and 8 and FR-3 and FR-22 are updated to match. All are Chris's decisions, Nov 4, 2026. v1.6 (Nov 2, 2026) — the project folder and these documents now say "meter" rather than "widget", at Chris's request, because the product is a meter. They were `CPU-widget` and `cpu-widget-*.md`. No requirement changed. v1.5 (Nov 2, 2026) — the M4 is now the primary test machine, and the M1 is tested when a check needs it. The app icon is Chris's to create. Both are Chris's instructions when approving the build plan. v1.4 (Nov 2, 2026) — §6 now lists a third small use of AppKit: measuring group labels for FR-3b. Found while writing the build plan. v1.3 (Nov 2, 2026) — added **FR-8d**: each group label ends in " %", so it is clear the per-core figures are percentages. Chris's request when approving the UI design. FR-8c's single row now has a label too, FR-3b makes room for the longer labels, and FR-11 and §§6 and 8 are updated to match. v1.2 (Nov 2, 2026) — revised **FR-3** and **FR-11** to support up to 36 cores, the current Mac maximum. Height stays fixed at each size and width fits the Mac's core count, so per-core figures now appear at every size on every Mac. Chris's request and choice during the UI design stage. Also updated NFR-4 and §§6, 8 and 9 to match, and FR-27 records Chris's top-row choice. v1.1 (Nov 2, 2026) — added **FR-28**: the bar colors default to blue and orange and can be changed with the macOS system color chooser, opened from View → Colors. Chris's request during the UI design stage. Also updated FR-9, FR-24, NFR-5 and §§6–8 to match. v1.0 (Nov 2, 2026) — approved by Chris with no changes to the v0.1 draft, including the §8 decisions. v0.1 (Nov 2, 2026) — initial draft, from Chris's project brief and the question-by-question review of Nov 1–2, 2026.
**Date:** November 4, 2026
**Owner:** Chris
**Status:** **v1.0 approved by Chris, Nov 2, 2026; v1.1 adds Chris's color request; v1.2 adds Chris's 36-core sizing; v1.3 adds Chris's percent labels; v1.7 adds Chris's window access and snap resizing decisions, Nov 4, 2026; v1.8 corrects one width in §6, Chris's decision the same day.** Increment 0.1 (the Xcode project and an empty window) was confirmed by Chris on Nov 4, 2026. Phase 0, the window shell, was completed the same day: Increment 0.2 (sizes and Keep on Top) and 0.3 (snap resizing) were confirmed under v1.7, 0.3 on both the M4 and the M1. Increment 1.1 (reading the counters) was confirmed too, and Increment 1.2 (core types) on both Mac minis. Phase 1, measurement, was completed the same day, when Increment 1.3 (sampling on a timer) was confirmed on both Mac minis. Increment 2.1 (layout math) was confirmed on the M4 on Nov 5, 2026, with every width in §6 matching. The UI design in `cpu-meter-ui-design.md` was approved by Chris on Nov 2, 2026.
**Lineage:** Sibling to NetSpeed and DriveSpeed. It carries over their window behavior, persistence, project layout and refresh choices. The differences are live bars instead of a rolling graph, three set window sizes, menus in the Mac menu bar, a Keep on Top option, and bar colors the user can change.

---

## 1. Overview

A lightweight macOS app that shows the current usage of every CPU core as live bars in a small floating window, in the spirit of Activity Monitor's floating CPU window. It reads the operating system's per-core counters passively and keeps no history.

This is a personal-use utility, built in Swift with Xcode, for Apple Silicon Macs running macOS 27 or later.

## 2. Goals

- See at a glance how busy each core is, and which type of core, without opening Activity Monitor.
- Use as few system resources as reasonably possible.
- Stay out of the way: small, one of three set sizes, and it remembers where I put it.

## 3. Non-Goals (v1)

- No WidgetKit widget or widget gallery entry. *(See §6, Form-factor decision.)*
- No line graph and no history, in memory or on disk.
- No GPU, memory, temperature, frequency or per-process data.
- No logging.
- No menu bar item.
- No free drag resizing: dragging snaps to one of the three sizes (FR-3d). No multi-window support or adjustable transparency.
- No built-in launch-at-login; add CPUMeter via System Settings → General → Login Items. *(Same as DriveSpeed.)*
- No Intel Macs and no macOS earlier than 27.

## 4. Functional Requirements

### 4.1 Form factor
- FR-1: The app presents a single **floating window** the user can position anywhere on screen. It is not a WidgetKit widget.
- FR-2: **View → Keep on Top** floats the window above other windows. It is **on at first launch**, and the choice is remembered across launches. When off, the window behaves as a normal window that others can cover.
- FR-3: The window has **three sizes: Small, Medium and Large**, chosen from **View → Size** or by dragging (FR-3d). It never rests at any other size. Each size's dimensions depend only on the Mac's core count, and support runs to **36 cores**, the current Mac maximum. *(Chris's request and choice, Nov 2, 2026.)*
  - FR-3a: **Height is fixed** at each size: 150, 225 and 300 points of content, below the 32-point title bar.
  - FR-3b: **Width fits the core count.** It is the larger of the base width and the width the bars need: 2 × margin, plus gap between groups × (groups − 1), plus cores × width per core. Width per core is the minimum in the table below, or more if a group's label wouldn't otherwise fit within that group. Labels are measured at launch, because their names come from macOS, and the width is rounded up to a whole point. §6 lists the result for each Mac.
  - FR-3c: **The core count is read at every launch and never stored**, so the width stays correct if settings move to a different Mac. The saved setting is the size's name (FR-20), not its width.
  - FR-3d: **Dragging snaps to the three sizes.** The window's edges and corners can be dragged anywhere between Small and Large, and when the drag ends the window settles at the nearest of the three sizes, which becomes the chosen size. The edge or corner opposite the one dragged stays in place, subject to FR-22's on-screen rule. `cpu-meter-ui-design.md` sets how "nearest" is judged. *(Chris's request, Nov 4, 2026.)*

| Points | Small | Medium | Large |
|---|---|---|---|
| Base width | 240 | 360 | 480 |
| Margin | 12 | 14 | 16 |
| Gap between groups | 12 | 14 | 16 |
| Minimum width per core | 21 | 23 | 25 |

- FR-4: The window uses the **standard native title bar**, titled with the app name and its major.minor version, e.g. **"CPUMeter 1.0"**, read from the bundle's marketing version. *(Same mechanism as DriveSpeed FR-18.)*
- FR-5: CPUMeter is a **normal app with a Dock icon**, because the Mac menu bar holds its controls (FR-26).

### 4.2 What it shows
- FR-6: **One bar per CPU core**, as reported by macOS. There are no separate logical and physical sets: Apple Silicon has no simultaneous multithreading, so the two are the same. Verified on the M4 Mac mini, where `hw.physicalcpu` and `hw.logicalcpu` both report 10.
- FR-7: The display is **bars, not a line graph**. Only the latest sample is shown.
- FR-8: Bars are **grouped by core type**, with a label for each group.
  - FR-8a: Group names come **from macOS** (`hw.perflevelN.name`) and are never hard-coded. M5 Pro and M5 Max have Super and Performance cores rather than Performance and Efficiency, so a fixed pair of labels would be wrong there.
  - FR-8b: Groups run from **lowest to highest performance, left to right**. On the M4 that is Efficiency, then Performance.
  - FR-8c: If the core types can't be determined reliably, the app shows **one row of bars labeled "Cores %"**. A label that names no core type can't be wrong.
  - FR-8d: Each label ends in **" %"**, such as "Efficiency %", "Performance %" or "Super %", because the per-core figures have no percent sign of their own. *(Chris's request, Nov 2, 2026.)*
- FR-9: Each bar **stacks user and system time**, as two colors (FR-28). Its full height is 100% of that core's time, and the remainder is idle. Nice time counts as user.
- FR-10: An **overall CPU percentage** appears above the bars: the average across all cores, from 0 to 100%, as a whole number. It is calculated from raw tick counts, not by averaging rounded per-core figures.
- FR-11: A **per-core percentage**, as a whole number, appears under each bar **at every size on every Mac**, at 10, 11 and 12 points for Small, Medium and Large. The figures have no percent sign; the group label carries it (FR-8d). FR-3b guarantees the room. Its minimum widths per core keep the figures readable as separate numbers when every core reads 100; at 20, 22 and 24 points per core they run together. Measured Nov 2, 2026 by rendering real system text at scale 1.0, the scale of the M4 mini's display.
- FR-12: Bars and figures in one update all come from **the same sample**, so they can't disagree.

### 4.3 How it measures
- FR-13: Usage is measured **passively**, by reading each core's cumulative tick counters and calculating the change between consecutive reads.
- FR-14: **The baseline is primed at start**, before the first timer fires, so the first update is a real measurement rather than a spike measured from zero. *(Same as DriveSpeed FR-10f.)* Until then the window shows its zero state.
- FR-15: **Each percentage comes from that core's own tick change**, not from elapsed clock time, so a late timer can't distort a reading.
- FR-16: The counters are 32-bit, so the change is calculated with **wrapping subtraction**. At about 100 ticks per second, a counter wraps after about 497 days of accumulated time, which is reachable on a Mac with long uptime.
- FR-17: **Sampling and drawing pause** while the window is minimized, fully covered, or otherwise not visible, including when the display sleeps. On resuming, the baseline is primed again so the first update covers only the visible period.

### 4.4 Refresh rate
- FR-18: **View → Refresh Rate** offers **1, 2, 3, 4 and 5 seconds**.
  - FR-18a: The default on first launch is **1 second**.
  - FR-18b: The rate stays fixed until the user changes it, with no automatic variation.
  - FR-18c: The choice is remembered across launches.
  - FR-18d: A change takes effect immediately and primes the baseline again, so it causes no false reading.

### 4.5 Window behavior
- FR-19: **Remember window position** across launches and restarts.
- FR-20: **Remember the chosen size** across launches and restarts.
- FR-21: On the **very first launch**, the window opens at **Medium** in the **top-left** of the screen.
- FR-22: **Switching size from View → Size keeps the window's top-left corner in place**, unless that would push the window off screen. In that case the window moves just far enough to stay within the screen's visible area, clear of the menu bar and Dock. The same rule keeps the window on screen after a drag snaps it (FR-3d).
- FR-23: **Closing the window quits the app.** Relaunch to bring it back. *(Same as DriveSpeed FR-16.)*

### 4.6 Menus and layout
- FR-24: **View** holds Size, Refresh Rate, Colors and Keep on Top, with the current size, rate and Keep on Top state checked.
- FR-25: Menu items that don't apply to a one-window app, such as New Window, are removed. **File keeps Close** (⌘W), which quits like the close button (FR-23).
- FR-26: **All controls are in the Mac menu bar.** The window contains only the display, so all of its space is available for bars and figures.
- FR-27: Layout is a **top row with the overall figure on the left and the color key on the right**, then group labels, bars and per-core figures. *(Chris's choice, Nov 2, 2026.)* `cpu-meter-ui-design.md` sets the details.

### 4.7 Colors
- FR-28: **The user and system bar colors can each be changed** with the **macOS system color chooser**. *(Chris's request, Nov 2, 2026.)*
  - FR-28a: The defaults are **blue for user time and orange for system time**, using system colors that adapt to light and dark appearance.
  - FR-28b: **View → Colors** holds **User Color…**, **System Color…** and **Reset to Defaults**. User Color… and System Color… each open the system color chooser, set to that color and titled with which one is being changed. The chooser is a macOS panel, not a CPUMeter window, so FR-1 and FR-26 still hold.
  - FR-28c: The bars and the color key update **immediately** as a color is picked, without waiting for the next refresh.
  - FR-28d: Chosen colors are **remembered** across launches.
  - FR-28e: **Reset to Defaults** restores both colors to FR-28a.

## 5. Non-Functional Requirements

- NFR-1: **Low footprint: best effort, measured and reported, with no pass or fail ceiling** (Chris's decision, Nov 2, 2026).
  - **How it's measured:** CPU time over at least one hour, on a Release build at a 1-second refresh, on both Mac minis. Results go in the build plan and README.
  - **Reference points:** DriveSpeed's short Release test measured 0.4% of one core. A running copy later averaged **0.75% of one core** over 21 hours, with its saved refresh rate at 1 second and about 42 MB resident memory.
  - **How it's kept low:** no history, no animation, no SwiftUI Charts, a timer tolerance of 10% of the interval (as in DriveSpeed) so macOS can combine wakeups, and no redraw when the displayed values haven't changed.
  - **Memory** must stay flat after warm-up. This is a leak check and has no size limit.
- NFR-2: **No elevated privileges.** Verified Nov 1, 2026: the counter read and core-type lookup both worked from a signed `.app` with the App Sandbox on and no entitlement exceptions.
- NFR-3: **Readable at a glance** at all three sizes. Figures use monospaced digits in fixed-width fields, so the layout doesn't shift as values change.
- NFR-4: **Resilient.** If a counter read fails or a core reports no tick change, the app shows a sensible zero state rather than crashing. It handles sleep and wake without a false spike. If the reported core count ever changes, it primes the baseline again and recalculates the window width (FR-3b).
- NFR-5: **Respects system appearance.** The UI follows the system light or dark setting. The default bar colors adapt too; a chosen color stays as picked (§8).
- NFR-6: **Accurate.** Under a known load, N single-thread busy loops on a T-core Mac should raise the overall figure by about N/T of the total. Readings should also track Activity Monitor at the same refresh rate. The two apps never sample at the same instant, so this comparison is by trend, not by exact match. Checked on both Mac minis.

## 6. Technical Notes

- **Form-factor decision.** This is the project's one architectural decision, so it is recorded here rather than in a separate decision record. **Chris chose a floating window on Nov 2, 2026**, because a 1–5 second refresh rate rules out WidgetKit.
  - Apple's documentation says a frequently viewed widget typically gets 40–70 refreshes a day, and that timeline entries should be at least about 5 minutes apart.
  - Chris's installed ClaudeUsageWidget does better than that on this Mac. It requests a refresh every 5 minutes and measured a median gap of 5 minutes 20 seconds, or 251–271 reloads a day, from macOS's widget scheduler logs of Oct 25 – Nov 1, 2026.
  - That is still far slower than 1–5 seconds. Whether a widget can refresh faster than every 5 minutes was not tested, because the refresh-rate requirement made the test unnecessary.
- **Language / UI:** Swift and SwiftUI, using a single `Window` scene. The window's size limits come from its content, with `.windowResizability(.contentSize)`. Keep on Top sets the window's level directly (below), not through SwiftUI's `.windowLevel`.
  - **Where SwiftUI falls short,** found in Increment 0.2 on Nov 4, 2026, with the macOS 27.2 SDK: `.windowLevel(.floating)` gives level 19 rather than AppKit's floating level, 3, and sets it again on every scene update, overriding a level set directly. With it, Keep on Top failed at launch. SwiftUI can position a window only when it opens, so it can't keep a resized window on screen. SwiftUI also has no way to limit drag resizing to set sizes.
  - **AppKit is used for only four things,** with no `NSWindow` hosting:
    - observing `NSWindow.didChangeOcclusionStateNotification` for FR-17;
    - `NSColorPanel` for FR-28, because SwiftUI's `ColorPicker` is a control inside a window and FR-26 keeps the window free of controls;
    - measuring group labels at launch for FR-3b, because the window's size has to be known before anything is drawn;
    - reaching the one window SwiftUI creates, from inside its own view, to set its level (FR-2), keep it on screen after a size change (FR-22) and snap drag resizing to the three sizes (FR-3d). *(Added in v1.7, Chris's decision, Nov 4, 2026.)*
- **Drawing:** SwiftUI `Canvas` first, as in DriveSpeed, and never Charts. If Canvas proves costly, Core Animation is the fallback.
- **Project identity:** product name `CPUMeter`; bundle identifier `com.arc3solutions.CPUMeter`; Xcode project at `CPUMeter/CPUMeter.xcodeproj`; team `5JC55GTLZA`, automatic signing, App Sandbox and hardened runtime on.
- **Minimum OS:** macOS 27.0. **Architecture:** Apple Silicon (`arm64`) only. **Toolchain:** Xcode 27.2, at `/Applications/Development/Xcode.app`.
- **Counter source:** `host_processor_info` with `PROCESSOR_CPU_LOAD_INFO`, which returns user, system, idle and nice ticks per core. Measured Nov 1, 2026 on the M4 inside the sandbox: **3.4–3.7 microseconds per call**, about 0.0004% of one core at a 1-second refresh, and 99–102 ticks per second per core. A 1-second sample therefore resolves about 1%, and sampling faster would get coarser.
- **Core-type lookup:** IORegistry `IODeviceTree:/cpus`, reading `logical-cpu-id` and `cluster-type` from each core entry, with group names and counts from `hw.nperflevels` and `hw.perflevelN.name` / `.logicalcpu`.
  - **Measured on the M4:** logical IDs 0–5 are Efficiency and 6–9 are Performance, while `hw.perflevel0` is Performance. The two numberings run in opposite directions, so assuming they match would mislabel every bar.
  - **Matching groups by core count alone won't work:** the M1 and M3 have 4 of each type, so their counts tie.
  - **The rule, verified on the M4 and the M1 in Increment 1.2 (Nov 4, 2026):** walk the logical IDs in ascending order, treat each run of one `cluster-type` as a group, assign performance levels from the highest level number down, and confirm the counts agree. If they don't, FR-8c applies. On the M1, too, logical IDs 0–3 are Efficiency while `hw.perflevel0` is Performance. Increment 1.3 proved the labels under load on both Macs: a background-priority process raises only the group labeled "Efficiency %".
- **Window widths from FR-3b, in points.** The rule doesn't depend on this list. It was checked in Increment 2.1 with AppKit's label widths to three decimals, from the UI design's §7. The M5 family's core counts were checked against published specs on Nov 2, 2026; older chips have not been checked.

| Cores | Macs | Small | Medium | Large |
|---|---|---|---|---|
| 6 | MacBook Neo | 265 | 360 | 480 |
| 8 | M1, M2, M3 | 240 | 360 | 480 |
| 8 | M1 Pro | 283 | 360 | 480 |
| 10 | M4, M5, M2 Pro | 246 | 360 | 480 |
| 10 | M1 Pro, M1 Max | 344 | 377 | 480 |
| 11 | M3 Pro | 267 | 360 | 480 |
| 12 | M2 Pro, M2 Max, M3 Pro, M4 Pro | 288 | 360 | 480 |
| 14 | M3 Max, M4 Pro, M4 Max | 330 | 364 | 480 |
| 15 | M5 Pro | 351 | 387 | 480 |
| 16 | M3 Max, M4 Max | 372 | 410 | 480 |
| 18 | M5 Pro, M5 Max | 414 | 456 | 498 |
| 20 | M1 Ultra | 456 | 502 | 548 |
| 24 | M2 Ultra | 540 | 594 | 648 |
| 28 | M3 Ultra | 624 | 686 | 748 |
| 30 | M5 Ultra | 666 | 732 | 798 |
| 32 | M3 Ultra | 708 | 778 | 848 |
| 36 | M5 Ultra | 792 | 870 | 948 |

- **Test hardware:**

| Mac | CPU cores | Role | Core counts |
|---|---|---|---|
| M4 Mac mini, macOS 27.0.1 | 10 (4 Performance, 6 Efficiency) | Primary, every test | Measured |
| 2020 M1 Mac mini, macOS 27 | 8 (4 Performance, 4 Efficiency) | Secondary: tested when a check needs it, as the build plan sets out | Measured in Increment 1.2 |
| 15-inch M3 MacBook Air | 8 (4 Performance, 4 Efficiency) | One check near the end: energy use on battery, and the window on a built-in display with a notch | Apple's specs; confirm on the machine |

  **Simulated only:** core counts other than 8 and 10, meaning 6 cores and everything from 11 to 36, and core-type names other than Performance and Efficiency. The README and release notes must state what was and wasn't tested.
- **Repository:** follows NetSpeed and DriveSpeed. Public repo `chrisARC3/macos-cpumeter` on `main`, MIT license © 2026 ARC3 Solutions, `docs/cpu-meter-requirements.md`, `docs/cpu-meter-ui-design.md` and `docs/cpu-meter-build-plan.md`, and a gitignored `NEXT-SESSION-HANDOFF.md`. The app icon is Chris's to create, separately. The README's "Note From The Human" section is Chris's to write. The repo was created on Nov 2, 2026.

## 7. Deferred / Future Considerations

- A companion WidgetKit widget alongside the window. A reading about every 5 minutes could still be useful, at very low CPU cost, but it adds a second target.
- Per-core history.
- Adjustable window transparency.
- A menu bar item.
- Additional window sizes.
- Accessibility labels for VoiceOver. `Canvas` content has none by default.
- Separate chosen colors for light and dark appearance.

## 8. Decisions Made Without a Direct Question (please veto if any are wrong)

1. **Refresh choices copy DriveSpeed:** all five values from 1 to 5 seconds, with a default of 1 second. The menu is named "Refresh Rate", your wording, rather than DriveSpeed's "Sample".
2. **Overall CPU % is an unweighted average of all cores** (FR-10). A busy Efficiency core counts the same as a busy Performance core, even though it does less work.
3. **Percentages are whole numbers**, without decimals (FR-10, FR-11).
4. **Lowest-performance group on the left** (FR-8b), matching the mockup you chose.
5. **Nice time counts as user time** (FR-9), which keeps each bar to two colors.
6. **Sampling pauses while the window isn't visible** (FR-17). With Keep on Top on, this mostly applies when the window is minimized or the display is asleep. It has no visible effect, because there is no history to leave gaps in.
7. **Bars change without animation** (NFR-1). Animating them would cost extra frames on every update.
8. **Switching size keeps the top-left corner in place** (FR-22).
9. **Spaces use standard macOS behavior**, with no custom code. The window stays on its own Space and doesn't appear over full-screen apps. To see it on every Space, use the Dock icon's Options → Assign To → All Desktops.
10. **No keyboard shortcuts** for size or refresh rate in v1.
11. **Carried over from DriveSpeed:** closing the window quits (FR-23), it first opens at the top-left (FR-21), it remembers its position and settings (FR-19, FR-20), it follows light or dark appearance (NFR-5), and launch at login stays in System Settings (§3).
12. **A chosen color applies in both light and dark appearance.** Only the defaults adapt, so a color picked in dark appearance may be harder to see in light.
13. **The color chooser's opacity control is hidden, and bars are always opaque.** A translucent bar would blend into its track and make its height harder to read.
14. **Any two colors are allowed, including two that match**, with no warning. The thin gap between the two parts of a bar still separates them.
15. **The core count is read at every launch**, rather than once at first launch (FR-3c). You asked for sizes determined at initial launch. The result is the same, with no stored value to go stale.
16. **Small is 246 points wide on a 10-core Mac, including your M4,** rather than 240 (FR-3b), so its figures stay separate at full load.
17. **Height doesn't grow with core count** (FR-3a). A 36-core Mac gets a long, low window.
18. **The fallback row is labeled "Cores %"** rather than having no label (FR-8c), so the percent marking appears on every Mac.
19. **Three Macs get a wider window so the longer labels fit** (FR-3b), because each has a group of only two cores: the MacBook Neo at Small, and the M1 Pro and M1 Max at Small and Medium. No Mac you own changes.
20. **A drag snaps when it ends, not during it** (FR-3d). Jumping between sizes mid-drag would mean taking over part of the window that SwiftUI uses itself. While dragging, the window passes through in-between sizes.
21. **Full screen is off, and the green window button zooms** to Large and back. Because the window can now be dragged, the button is no longer gray. *(Replaces the UI design's §8.5.)*
22. **macOS window tiling isn't supported.** Window → Fill, the tiling layouts, or dragging the window to a screen edge may resize it, and it then settles at the nearest of the three sizes.
23. **"On screen" means the screen's visible area,** clear of the menu bar and Dock (FR-22).
24. **The Edit menu stays,** although the window has no text to edit, because the color chooser's hex field needs Copy and Paste (FR-28).

## 9. Assumptions

- Personal use, published in a public repo as with NetSpeed and DriveSpeed. Builds aren't notarized, because Chris is no longer a paid Apple Developer.
- 100% on an Efficiency core is not the same amount of work as 100% on a Performance core, and core frequency isn't reflected in the bars. The README should say so.
- The window is transient: quitting discards everything except the saved settings and window position.
- The widest window today is 948 × 300 points of content, on a 36-core Mac at Large. There is no special handling for a display narrower than the window.

---

*Next step: a discussion of some minor design changes with Chris, then Increment 2.3, other core counts, of `cpu-meter-build-plan.md`. Increment 2.1 was confirmed on Nov 5, 2026, with all 57 widths in §6 matching the width rule (FR-3b), and Increment 2.2, bars on screen, the same day.*
