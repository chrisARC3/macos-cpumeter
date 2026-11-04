# CPUMeter — Incremental Build Plan

**Version:** 1.0
**Date:** November 2, 2026
**Companion to:** `cpu-meter-requirements.md` (v1.6) and `cpu-meter-ui-design.md`
**Status:** Approved by Chris on Nov 2, 2026, with the test machine, push and app icon instructions below.
**Approach:** Small, verifiable increments. Each one has a single goal, a concrete build step, and a way to confirm it works before moving on. We do not start an increment until the previous one is verified.

---

## How to read this

Each increment lists:

- **Goal** — the one thing this step proves.
- **Build** — what gets added.
- **Verify** — the observable check that it works.
- **Done when** — the pass condition.

Requirement IDs (FR-#, NFR-#) reference `cpu-meter-requirements.md`. Results are added to each increment as it completes, as in NetSpeed and DriveSpeed.

**Division of labor.** Claude verifies logic headlessly with `swiftc` and `xcodebuild` and reports. Chris runs the GUI and confirms. Any command handed to Chris uses absolute paths and can be pasted as is.

**Test machines.** The M4 is the primary test machine, and every increment is confirmed there. *(Chris's instruction, Nov 2, 2026.)*

**The M1 pass.** The M1 mini is tested when a check needs it: at the end of each phase, and in 1.2 and 1.3, where its equal core counts are the point of the test. When a build is needed there, Claude copies it automatically to the M1's Drop Box, through the Public folder Chris keeps mounted on the M4, and tells Chris its name. Chris then runs it on the M1. If the folder isn't mounted, Claude says so and doesn't copy it anywhere else. The build is a zip named with its increment and commit, such as `CPUMeter-1.2-5d90544.zip`, so builds never overwrite each other. It isn't notarized, so macOS may ask for Open Anyway in System Settings → Privacy & Security the first time. This route hasn't been tried yet; the end of Phase 0 is its first use.

**Commits.** One commit per confirmed increment, named "Increment N.N — …", and every commit is pushed right away. *(Chris's instruction, Nov 2, 2026.)*

**Headless checks.** Drivers that compile the real source files live outside the repo, as in the sibling projects. Two lessons carry over from DriveSpeed:

- `swiftc` doesn't apply the project's build settings, so it can't see main-actor isolation warnings. Every increment also gets a full `xcodebuild`.
- Launching a second build of the same bundle ID can disturb the saved window frame. Release testing has to allow for that (5.2).

---

## Test loads

Measured on the M4 on Nov 2, 2026, each over 3 seconds. With no load, Efficiency cores averaged 11.8%, Performance cores 4.6%, and overall 8.9%, from the Mac's normal background work.

| Load | Command | Efficiency | Performance | Overall | User / system |
|---|---|---|---|---|---|
| **User time** | `awk 'BEGIN{while(1);}' &` | 7.5% | 26.8% | 15.2% | 13.1% / 2.2% |
| **System time** | `yes > /dev/null &` | 7.3% | 26.2% | 14.9% | 3.7% / 11.2% |
| **Efficiency cores only** | `taskpolicy -b yes > /dev/null &` | 31.4% | 2.1% | 19.7% | 7.1% / 12.6% |
| **Four busy loops** | `for i in {1..4}; do awk 'BEGIN{while(1);}' & done` | 10.9% | 99.8% | 46.5% | 43.7% / 2.8% |
| **Every core** | `for i in {1..10}; do awk 'BEGIN{while(1);}' & done` | 99.9% | 100% | 99.9% | 97.8% / 2.1% |

Use `{1..8}` for every core on the M1 and M3. To stop any of them:

```bash
pkill -x awk; pkill -x yes
```

The "Efficiency cores only" load is what proves the group labels are right. A background-priority process stays on the Efficiency cores, so only the bars labeled "Efficiency %" should rise. If the other group rises, the labels are swapped.

---

## Already proven

- **Counter read:** `host_processor_info` works from a signed, sandboxed `.app` with no entitlement exceptions, at 3.4–3.7 µs per call, on the M4 (Nov 1).
- **Core-type lookup:** IORegistry and `sysctl` both work in the sandbox on the M4, where the logical IDs and performance levels run in opposite directions (Nov 1). **Not yet run on the M1.**
- **Headless rendering:** SwiftUI's `Canvas` draws to a PNG through `ImageRenderer` from a plain command-line driver, at scale 1.0 and with real text (Nov 2). So Claude can inspect real layouts before Chris sees them.
- **Figure spacing in `Canvas`:** "100" at 21, 23 and 25 pt per core reads as separate numbers there too (Nov 2).
- **Rounding in `Canvas`:** at scale 1.0 it reports text widths rounded up to whole points: "Performance %" measures 77, 83 and 90 against AppKit's 76.1, 82.9 and 89.5. The width rule uses AppKit's figures, because it has to run before anything is drawn. 2.1 confirms the difference doesn't show.

---

## Files

| File | Purpose | First appears |
|---|---|---|
| `CPUMeter/CPUMeter.xcodeproj` | Project, made from DriveSpeed's | 0.1 |
| `CPUMeterApp.swift` | `Window` scene, title, View menu, Keep on Top | 0.1 |
| `CoreCounters.swift` | Counter read and wrapping tick change | 1.1 |
| `CoreTopology.swift` | Core groups, names and order; the fallback | 1.2 |
| `CPUSampler.swift` | Timer, baseline, percentages, pause and resume | 1.3 |
| `MeterLayout.swift` | The width rule and the design document's numbers | 2.1 |
| `MeterView.swift` | The `Canvas` drawing | 2.2 |
| `SimulatedCores.swift` | Other core counts, Debug builds only | 2.3 |
| `BarColors.swift` | Chosen colors and the system color chooser | 3.2 |
| `Assets.xcassets/AppIcon` | App icon, from Chris's artwork | 5.1 |
| `README.md` | Rewritten once the app exists | 5.5 |
| `NEXT-SESSION-HANDOFF.md` | Working note, local and gitignored | As needed |

---

## Phase 0 — Project and window shell

The window comes first because it holds the biggest unknowns. The requirements assume SwiftUI alone can switch sizes and window levels while running. If it can't, §6 of the requirements has to change, and it's better to learn that before anything is drawn in the window.

### Increment 0.1 — Project and empty window
- **Goal:** A buildable, correctly identified app with a title bar, a Dock icon, and closing that quits. (FR-1, FR-4, FR-5, FR-21, FR-23)
- **Build:** Claude makes the project headlessly from DriveSpeed's project file, so there's no Xcode wizard to click through: file-system-synchronized groups, `com.arc3solutions.CPUMeter`, team `5JC55GTLZA`, arm64 only, App Sandbox and hardened runtime on, marketing version 1.0, and macOS 27.0 at both project and target level. DriveSpeed's read-only file-access setting is dropped, because CPUMeter opens no files. `CPUMeterApp.swift` has a `Window` scene with a plain placeholder at Medium's base size, positioned top-left.
- **Verify:** `xcodebuild` is clean and warning-free. The built bundle reports the right identifier, version 1.0, minimum system 27.0, and the sandbox entitlement. Chris runs it from Xcode and checks the title reads "CPUMeter 1.0", the Dock icon appears (generic for now), the window opens top-left, and closing it quits.
- **Done when:** All of the above pass.
- **Result (Nov 2, 2026):** Headless half: Project made from DriveSpeed's project file, with the file-access setting dropped and macOS 27.0 at both levels. Debug `clean build` → **`** BUILD SUCCEEDED **`** with no compiler warnings. The only tool notes are `appintentsmetadataprocessor`'s, which the siblings also emit, and a CoreSimulator version note unrelated to a macOS-only project. Built bundle: `com.arc3solutions.CPUMeter`, version 1.0, minimum system 27.0, arm64 only, hardened runtime on, team `5JC55GTLZA`, and the sandbox as its only entitlement apart from Debug's `get-task-allow`. **Confirmed in Xcode by Chris** (Nov 4, 2026): the title reads "CPUMeter 1.0", a generic Dock icon appears, the empty window opens top-left, and closing the window quits the app.

### Increment 0.2 — Sizes, Keep on Top and remembered position
- **Goal:** Prove SwiftUI alone can do the window behavior the requirements assume. (FR-2, FR-3, FR-3a, FR-19, FR-20, FR-21, FR-22, FR-24, FR-25, FR-26)
- **Build:** A placeholder sized to the base widths and fixed heights, with `.windowResizability(.contentSize)`. **View → Size** and **View → Keep on Top**, added to the existing View menu and stored with `@AppStorage`. `.windowLevel` follows the Keep on Top setting. Remove the menu items that don't apply to a one-window app.
- **Risk:** If keeping the top-left corner in place or changing the window level needs direct `NSWindow` access, that contradicts §6 of the requirements. Claude stops and reports it, and Chris decides before anything is amended.
- **Verify:** Chris's checklist:
  - Each size switch changes the window and keeps its top-left corner in place.
  - Near the bottom-right of the screen, switching to Large keeps the window on screen.
  - With Keep on Top on, other apps' windows can't cover it. With it off, they can.
  - The zoom button is gray, and the window edges can't be dragged.
  - After quitting and relaunching, the size, position and Keep on Top state all return.
  - The menu bar has no New Window, and nothing else that doesn't apply.
- **Done when:** The checklist passes on the M4 and in the M1 pass. **Completes Phase 0.**

---

## Phase 1 — Measurement (console only)

### Increment 1.1 — Read the counters
- **Goal:** Correct per-core tick changes, including across a counter wrap. (FR-13, FR-15, FR-16, NFR-2)
- **Build:** `CoreCounters.swift`: a `nonisolated` read of user, system, idle and nice ticks for each core, and a pure function for the wrapping change between two reads. Every read frees the array macOS returns with `vm_deallocate`, because missing that would leak memory on every tick and break NFR-1.
- **Verify:** A headless driver compiles the real file and checks the arithmetic, including `0xFFFFFFF0` → `0x00000010`, identical reads, and nice counted as user. It also reads live counters and shows them advancing about 100 ticks per second per core. A run of 100,000 reads shows flat memory.
- **Done when:** All checks pass, and a sandboxed build reads the same values.

### Increment 1.2 — Core types
- **Goal:** Correct groups, names and order, on both Macs. **This is the first real test of the core-type rule on the M1.** (FR-6, FR-8, FR-8a, FR-8b, FR-8c)
- **Build:** `CoreTopology.swift`: the rule from §6 of the requirements, separated from its inputs so it can be tested with fixtures. It takes the logical IDs and cluster types from IORegistry and the names and counts from `sysctl`, and returns groups ordered from lowest to highest performance, each with its bars in logical-ID order. A temporary launch print shows the result.
- **Verify:**
  - Headless fixtures: the M4's 6 + 4, the M1's tied 4 + 4, the M5 Max's Performance and Super, and mismatched counts, which must fall back to one "Cores" group.
  - Live on the M4: Efficiency logical IDs 0–5, then Performance 6–9.
  - Live on the M1: Claude copies the build to the Drop Box, and Chris runs one pasted command and sends back the output.
- **Done when:** Fixtures pass and both Macs report the right groups. If the M1 reports something unexpected, the rule gets fixed here, before anything depends on it.

### Increment 1.3 — Sample on a timer
- **Goal:** Live percentages that match the test loads, and proof the group labels are right. (FR-8b, FR-9, FR-10, FR-12, FR-14, FR-15, NFR-6)
- **Build:** `CPUSampler.swift`, an `@Observable`, main-actor class like DriveSpeed's `SpeedSampler`: the baseline is primed in `start()`, and the timer tolerance is 10% of the interval. The timer runs in the run loop's common modes, unlike DriveSpeed's, so the bars keep updating while a menu is open. That matters here because every control is in the menu bar. Each tick computes user and system percentages per core and the overall figure from raw ticks, all from one read. A temporary console line prints the overall figure and each group's average.
- **Verify:** Headless checks for the percentage math, the zero-tick case and the overall figure. Then each test load, compared with the table above and with Activity Monitor by trend. The "Efficiency cores only" load must raise only the Efficiency group, on both the M4 and the M1.
- **Done when:** Figures follow every load, and the labels are proven right on both Macs. **Completes Phase 1.**

---

## Phase 2 — Display

### Increment 2.1 — Layout math
- **Goal:** The width rule produces exactly the table in §6 of the requirements. (FR-3b, FR-3c, FR-8d, FR-11)
- **Build:** `MeterLayout.swift`: pure functions and the numbers from §2 of the design document. It takes the groups and returns the window size and each bar's position. Group labels are measured with AppKit at launch, which is the use added to §6 of the requirements in v1.4. The core count is read at launch and never stored.
- **Verify:** A headless driver runs the 19 core layouts behind that table at all three sizes and compares the results with it, then confirms every label fits its group and every core gets its minimum width. Plug the result into the 0.2 window, and Chris confirms the M4 opens at 246, 360 and 480 wide.
- **Done when:** All 57 widths match. Any mismatch means the code or the table is wrong, and it gets resolved here.

### Increment 2.2 — Bars on screen
- **Goal:** The real display, live, matching the approved design. (FR-6, FR-7, FR-8d, FR-9, FR-10, FR-11, FR-14, FR-27, NFR-3, NFR-5)
- **Build:** `MeterView.swift`, a single `Canvas` and never Charts: the top row, group labels, bars with their tracks and 1 pt gap, and per-core figures in monospaced digits. The dash state shows before the first reading. Default colors come from the system's blue and orange. Bar edges are snapped to whole pixels. The temporary console output is removed.
- **Verify:** Claude renders the real view headlessly at scale 1.0, in dark and light, and inspects it. Then Chris runs it on the M4 and compares it with the canvas: the system-time load grows the orange part of a bar, the user-time load grows the blue part, and the every-core load shows every figure at or near 100 and still readable.
- **Done when:** Chris confirms the window matches the design at all three sizes, in both appearances.

### Increment 2.3 — Other core counts
- **Goal:** See every Mac in the requirements' table, drawn by the real code. (FR-3b, FR-8a, FR-8c, FR-11)
- **Build:** `SimulatedCores.swift`, compiled only in Debug builds: a launch argument such as `-simulateCores Performance:24,Super:12` replaces the detected groups and feeds them synthetic ticks.
- **Verify:** Claude renders all 19 core layouts at all three sizes as a contact sheet and inspects it for overlaps, clipping and figures running together. Chris spot-checks 36 cores, the fallback row and the MacBook Neo in the real window. A check of the Release binary confirms the simulation code isn't in it.
- **Done when:** Every configuration is clean, and Release has no simulation code. **Completes Phase 2**, including the M1 pass. This is the limit of what can be tested above 10 cores, and the README will say so.

---

## Phase 3 — Controls

### Increment 3.1 — Refresh Rate
- **Goal:** All five rates work and take effect immediately. (FR-18, FR-18a, FR-18b, FR-18c, FR-18d, FR-24)
- **Build:** **View → Refresh Rate** with 1–5 seconds, stored with `@AppStorage`. Changing it re-arms the timer and primes the baseline again.
- **Verify:** Headless: the timer interval and tolerance at each rate. Chris: the bars visibly slow at 5 seconds, no false spike appears on a change, the choice survives a relaunch, and the bars keep updating while the menu is open.
- **Done when:** All of FR-18 is observed.

### Increment 3.2 — Colors
- **Goal:** Both colors can be changed with the system chooser. (FR-24, FR-28, FR-28a, FR-28b, FR-28c, FR-28d, FR-28e, NFR-5)
- **Build:** `BarColors.swift` and **View → Colors**: User Color…, System Color… and Reset to Defaults. `NSColorPanel` opens set to the current color and titled with which one is changing, with its opacity control hidden. Chosen colors are stored as sRGB values. With none stored, the adaptive system colors apply.
- **Risk:** With Keep on Top on, the chooser could open behind CPUMeter, or the app might not quit with the chooser open. Both are checked explicitly.
- **Verify:** Chris's checklist:
  - The bars and key change as a color is picked, between refreshes.
  - The chooser is reachable with Keep on Top on.
  - Colors survive a relaunch and stay as picked when the appearance changes.
  - Reset restores both colors, and the defaults adapt to appearance again.
  - Closing the window quits even with the chooser open.
- **Done when:** The checklist passes. **Completes Phase 3**, including the M1 pass.

---

## Phase 4 — Robustness

### Increment 4.1 — Pause when not visible
- **Goal:** No sampling or drawing while the window can't be seen, and no false reading after. (FR-17, NFR-4)
- **Build:** Observe `NSWindow.didChangeOcclusionStateNotification`. Stop the timer when the window isn't visible, and prime the baseline again on resuming. A temporary per-tick line shows whether sampling is running.
- **Verify:** Chris minimizes the window, fully covers it with Keep on Top off, and sleeps the display, then returns each time. The output must show no ticks during the pause and no spike in the first one after. To sleep the display:

  ```bash
  pmset displaysleepnow
  ```

- **Done when:** Ticks stop in all three cases and resume cleanly. Any case macOS doesn't report gets recorded here, not worked around quietly. The temporary line is removed.

### Increment 4.2 — Failures, sleep and needless redraws
- **Goal:** It stays sensible when things go wrong, and doesn't redraw when nothing changed. (FR-8c, NFR-1, NFR-4)
- **Build:** The sampler publishes only when a displayed value changes, compared at whole percentages for each core's user and system time and for the overall figure. A failed read keeps the zero state. A changed core count primes the baseline again and recalculates the width.
- **Verify:** Headless: a failed read, zero ticks, a core count that changes between reads, identical samples that publish nothing, and a core-type mismatch reaching the "Cores %" row. Chris: put the whole Mac to sleep, wake it, and confirm no false spike.
- **Done when:** All pass with no crash. **Completes Phase 4**, including the M1 pass.

---

## Phase 5 — Finish

### Increment 5.1 — App icon
- **Goal:** Chris's icon in the Dock and in Finder. (FR-5)
- **Build:** Chris creates the icon separately and tells Claude when it's finished. Claude then adds it to `Assets.xcassets/AppIcon`. This increment runs whenever the icon is ready and doesn't hold up any other increment, but the v1.0 release in 5.5 includes it. *(Chris's instruction, Nov 2, 2026.)*
- **Verify:** Chris checks it in the Dock and in Finder.
- **Done when:** Chris approves it.

### Increment 5.2 — Footprint
- **Goal:** Measure and report the real cost. There's no pass or fail ceiling. (NFR-1)
- **Build:** A Release build, at Medium and a 1-second refresh. The saved window frame gets noted first, because of DriveSpeed's lesson, and restored if the build disturbs it.
- **Verify:** On each Mac mini, run this at the start and again after at least an hour, then divide the CPU time gained by the time elapsed:

  ```bash
  ps -o %cpu=,cputime=,etime=,rss= -p "$(pgrep -x CPUMeter)"
  ```

  Then, for the share of time the main thread sits idle, run:

  ```bash
  sample CPUMeter 5
  ```

- **Done when:** CPU and memory are recorded for both Macs, next to DriveSpeed's 0.75% of one core, and memory is flat after warm-up. Results go here and in the README.

### Increment 5.3 — Accuracy
- **Goal:** Confirm the readings on both Macs. (NFR-6)
- **Build:** None expected.
- **Verify:** On each Mac mini, run 1, 2, 4 and all-core busy loops from a quiet start. Each should raise the overall figure by about N/T of the total, and the readings should follow Activity Monitor at the same refresh rate. The two never sample at the same instant, so this compares trends, not exact numbers.
- **Done when:** Both Macs follow the expected rise, and the results are recorded.

### Increment 5.4 — M3 MacBook Air check
- **Goal:** The two things only the Air can show. (Requirements §6, Test hardware)
- **Build:** None expected.
- **Verify:** Chris runs the Release build on battery for about an hour and reads CPUMeter's line in Activity Monitor's Energy tab. Chris also checks the window on the built-in display: the notch, and text on a Retina screen.
- **Done when:** The results are recorded, and nothing looks wrong near the notch.

### Increment 5.5 — Traceability, README and release
- **Goal:** Every requirement is met, deferred, or explicitly removed. → **v1.0**
- **Build:** Walk the requirements top to bottom against the running app and record the evidence, as DriveSpeed's 5.4 did. Fix any drift between the requirements, the design document and the code. Rewrite the README, including exactly what was and wasn't tested. The "Note From The Human" section stays Chris's.
- **Verify:** Each requirement is checked off with evidence.
- **Done when:** Full coverage is confirmed, Chris has written the note, and on Chris's go-ahead a zipped build is published as a GitHub release.

---

## Coverage map (requirement → increment)

| Requirement | Increment |
|---|---|
| FR-1 | 0.1 |
| FR-2 | 0.2 |
| FR-3, FR-3a | 0.2 |
| FR-3b | 2.1, 2.3 |
| FR-3c | 2.1 |
| FR-4 | 0.1 |
| FR-5 | 0.1, 5.1 |
| FR-6 | 1.2, 2.2 |
| FR-7 | 2.2 |
| FR-8 | 1.2 |
| FR-8a | 1.2, 2.3 |
| FR-8b | 1.2, 1.3 |
| FR-8c | 1.2, 2.3, 4.2 |
| FR-8d | 2.1, 2.2 |
| FR-9, FR-10 | 1.3, 2.2 |
| FR-11 | 2.1, 2.2, 2.3 |
| FR-12 | 1.3 |
| FR-13 | 1.1 |
| FR-14 | 1.3, 2.2 |
| FR-15 | 1.1, 1.3 |
| FR-16 | 1.1 |
| FR-17 | 4.1 |
| FR-18, FR-18a–d | 3.1 |
| FR-19, FR-20, FR-22 | 0.2 |
| FR-21 | 0.1, 0.2 |
| FR-23 | 0.1 |
| FR-24 | 0.2, 3.1, 3.2 |
| FR-25, FR-26 | 0.2 |
| FR-27 | 2.2 |
| FR-28, FR-28a–e | 3.2 |
| NFR-1 | 1.1, 4.2, 5.2 |
| NFR-2 | 1.1 *(pre-verified Nov 1)* |
| NFR-3 | 2.2 |
| NFR-4 | 4.1, 4.2 |
| NFR-5 | 2.2, 3.2 |
| NFR-6 | 1.3, 5.3 |

---

## Prerequisites before Increment 0.1

- [x] Requirements approved (`cpu-meter-requirements.md`).
- [x] UI design approved (`cpu-meter-ui-design.md`).
- [x] Counter source and core-type lookup proven on the M4 under the App Sandbox.
- [x] Test loads and headless rendering proven on the M4.
- [x] Public repo created.
- [x] Chris approved this plan (Nov 2, 2026).
