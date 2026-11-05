# CPUMeter — Incremental Build Plan

**Version:** 1.3
**Changelog:** v1.3 (Nov 5, 2026) — Increment 2.3 also builds requirements v1.10's wording: the overall figure reads "All cores: 42%", and the group labels take a colon. v1.2 (Nov 5, 2026) — after Increment 2.2, Chris's design changes (requirements v1.9) get their own increment, the new **2.3, design changes**. The old 2.3, other core counts, is now **2.4** and still completes Phase 2; earlier Results that point to it say 2.4. 3.2's menu lists System Color… first, and 4.2 compares the group averages too. v1.1 (Nov 4, 2026) — Increment 0.2's first test found two places where SwiftUI falls short, so requirements v1.7 adds direct window access and 0.2 now uses it, through the new `WindowAccess.swift`. Added Increment 0.3, snap resizing, at Chris's request. It now completes Phase 0 and takes Phase 0's M1 pass. After 0.2's second test, the scene drops `.windowLevel`, and File's Close replaces macOS's own Close group. v1.0 (Nov 2, 2026) — approved by Chris.
**Date:** November 5, 2026
**Companion to:** `cpu-meter-requirements.md` (v1.10) and `cpu-meter-ui-design.md`
**Status:** Approved by Chris on Nov 2, 2026, with the test machine, push and app icon instructions below.
**Progress:** Increment 0.1 (the Xcode project and an empty window) was confirmed by Chris on Nov 4, 2026, and Increment 5.1 (the app icon) the same day. Increment 0.2 (sizes, Keep on Top and remembered position) was confirmed on the M4 the same day, after three tests, as its Results record. Increment 0.3 (snap resizing) was confirmed on the M4 and the M1 the same day, completing Phase 0. Increment 1.1 (reading the counters) was confirmed the same day. Increment 1.2 (core types) was confirmed on the M4 and the M1 the same day. Increment 1.3 (sample on a timer) was confirmed on the M4 and the M1 the same day, completing Phase 1. Increment 2.1 (layout math) was confirmed on the M4 on Nov 5, 2026, and Increment 2.2 (bars on screen) the same day. Chris then asked for some design changes and new wording, recorded in requirements v1.9 and v1.10, and Increment 2.3, design changes, is next. Before writing any code, Claude says which files will change and waits for Chris's go-ahead *(Chris's instruction, Nov 4, 2026)*.
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

**The M1 pass.** The M1 mini is tested when a check needs it: at the end of each phase, and in 1.2 and 1.3, where its equal core counts are the point of the test. When a build is needed there, Claude copies it automatically to the M1's Drop Box, through the Public folder Chris keeps mounted on the M4, and tells Chris its name. Chris then runs it on the M1. If the folder isn't mounted, Claude says so and doesn't copy it anywhere else. The build is a zip named with its increment and commit, such as `CPUMeter-1.2-5d90544.zip`, so builds never overwrite each other. It isn't notarized, so macOS may ask for Open Anyway in System Settings → Privacy & Security the first time. This route was first used at the end of Phase 0, for 0.3 on Nov 4, 2026, and worked.

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

The "Efficiency cores only" load is what proves the group labels are right. A background-priority process stays on the Efficiency cores, so only the bars in the Efficiency group should rise, and from Increment 2.3, that group's average with them. If the other group rises, the labels are swapped.

---

## Already proven

- **Counter read:** `host_processor_info` works from a signed, sandboxed `.app` with no entitlement exceptions, at 3.4–3.7 µs per call, on the M4 (Nov 1).
- **Core-type lookup:** IORegistry and `sysctl` both work in the sandbox on the M4, where the logical IDs and performance levels run in opposite directions (Nov 1). The M1 numbers them the same way, and the rule groups both Macs correctly (Increment 1.2, Nov 4). Under the Efficiency-only load, only the group labeled "Efficiency %" rises on either Mac, and four busy loops raise only "Performance %" on the M1 (Increment 1.3, Nov 4).
- **Sampling:** a 1-second timer in the common run-loop modes keeps updating while a menu is open, and the figures follow every test load on both Mac minis (Increment 1.3, Nov 4).
- **Headless rendering:** SwiftUI's `Canvas` draws to a PNG through `ImageRenderer` from a plain command-line driver, at scale 1.0 and with real text (Nov 2). So Claude can inspect real layouts before Chris sees them.
- **Figure spacing in `Canvas`:** "100" at 21, 23 and 25 pt per core reads as separate numbers there too (Nov 2).
- **Rounding in `Canvas`:** at scale 1.0 it reports text widths rounded up to whole points: "Performance %" measures 77, 83 and 90 against AppKit's 76.1, 82.9 and 89.5. The width rule uses AppKit's figures, because it has to run before anything is drawn. 2.1 confirms the difference doesn't show.

---

## Files

| File | Purpose | First appears |
|---|---|---|
| `CPUMeter/CPUMeter.xcodeproj` | Project, made from DriveSpeed's | 0.1 |
| `CPUMeterApp.swift` | `Window` scene, title, menus, the size and Keep on Top settings | 0.1 |
| `WindowAccess.swift` | The one place CPUMeter reaches its window: level, staying on screen, snapping | 0.2 |
| `MeterSize.swift` | The three sizes and the snap rule, testable on their own | 0.3 |
| `CoreCounters.swift` | Counter read and wrapping tick change | 1.1 |
| `CoreTopology.swift` | Core groups, names and order; the fallback | 1.2 |
| `CPUSampler.swift` | Timer, baseline, percentages, pause and resume | 1.3 |
| `MeterLayout.swift` | The width rule and the design document's numbers | 2.1 |
| `MeterView.swift` | The `Canvas` drawing | 2.2 |
| `SimulatedCores.swift` | Other core counts, Debug builds only | 2.4 |
| `BarColors.swift` | Chosen colors and the system color chooser | 3.2 |
| `Assets.xcassets/AppIcon` | App icon, from Chris's artwork | 5.1 |
| `design/AllIcons.jpeg` | Chris's original icon sheet, which the AppIcon images are cut from | 5.1 |
| `README.md` | Rewritten once the app exists | 5.5 |
| `NEXT-SESSION-HANDOFF.md` | Working note, local and gitignored | As needed |

---

## Phase 0 — Project and window shell

The window comes first because it holds the biggest unknowns. The requirements assume SwiftUI alone can switch sizes and window levels while running. If it can't, §6 of the requirements has to change, and it's better to learn that before anything is drawn in the window. Increment 0.2 showed it can't in two places, so requirements v1.7 adds direct window access to §6.

### Increment 0.1 — Project and empty window
- **Goal:** A buildable, correctly identified app with a title bar, a Dock icon, and closing that quits. (FR-1, FR-4, FR-5, FR-21, FR-23)
- **Build:** Claude makes the project headlessly from DriveSpeed's project file, so there's no Xcode wizard to click through: file-system-synchronized groups, `com.arc3solutions.CPUMeter`, team `5JC55GTLZA`, arm64 only, App Sandbox and hardened runtime on, marketing version 1.0, and macOS 27.0 at both project and target level. DriveSpeed's read-only file-access setting is dropped, because CPUMeter opens no files. `CPUMeterApp.swift` has a `Window` scene with a plain placeholder at Medium's base size, positioned top-left.
- **Verify:** `xcodebuild` is clean and warning-free. The built bundle reports the right identifier, version 1.0, minimum system 27.0, and the sandbox entitlement. Chris runs it from Xcode and checks the title reads "CPUMeter 1.0", the Dock icon appears (generic for now), the window opens top-left, and closing it quits.
- **Done when:** All of the above pass.
- **Result (Nov 2, 2026):** Headless half: Project made from DriveSpeed's project file, with the file-access setting dropped and macOS 27.0 at both levels. Debug `clean build` → **`** BUILD SUCCEEDED **`** with no compiler warnings. The only tool notes are `appintentsmetadataprocessor`'s, which the siblings also emit, and a CoreSimulator version note unrelated to a macOS-only project. Built bundle: `com.arc3solutions.CPUMeter`, version 1.0, minimum system 27.0, arm64 only, hardened runtime on, team `5JC55GTLZA`, and the sandbox as its only entitlement apart from Debug's `get-task-allow`. **Confirmed in Xcode by Chris** (Nov 4, 2026): the title reads "CPUMeter 1.0", a generic Dock icon appears, the empty window opens top-left, and closing the window quits the app.

### Increment 0.2 — Sizes, Keep on Top and remembered position
- **Goal:** Prove SwiftUI alone can do the window behavior the requirements assume. (FR-2, FR-3, FR-3a, FR-19, FR-20, FR-21, FR-22, FR-24, FR-25, FR-26)
- **Build:** A placeholder sized to the base widths and fixed heights, with `.windowResizability(.contentSize)`. **View → Size** and **View → Keep on Top**, added to the existing View menu and stored with `@AppStorage`. `.windowLevel` follows the Keep on Top setting. Remove the menu items that don't apply to a one-window app.
  - *Added after the first test (Nov 4, 2026):* `WindowAccess.swift` reaches the window SwiftUI creates, under requirements v1.7. It sets the window's level directly and moves the window back on screen after a size change. File → Close is restored.
  - *Changed after the second test (Nov 4, 2026):* the scene no longer uses `.windowLevel`, so `WindowAccess` alone sets the level. File's Close replaces macOS's own Close group, and no other File group is touched.
- **Risk:** If keeping the top-left corner in place or changing the window level needs direct `NSWindow` access, that contradicts §6 of the requirements. Claude stops and reports it, and Chris decides before anything is amended. *Outcome:* the level and staying on screen both needed it, and Chris amended §6 (requirements v1.7).
- **Verify:** Chris's checklist:
  - Each size switch changes the window and keeps its top-left corner in place.
  - Near the bottom-right of the screen, switching to Large keeps the window on screen.
  - With Keep on Top on, other apps' windows can't cover it. With it off, they can.
  - The zoom button is gray, and the window edges can't be dragged.
  - After quitting and relaunching, the size, position and Keep on Top state all return.
  - The menu bar has no New Window, and nothing else that doesn't apply. File keeps Close.
- **Done when:** The checklist passes on the M4. The M1 pass moves to 0.3, which now ends Phase 0.
- **Result, first test (Nov 4, 2026):** Headless: Debug `clean build` → **`** BUILD SUCCEEDED **`** with no compiler warnings. Chris on the M4:
  - Size switches keep the top-left corner in place. **Pass.**
  - Near the bottom-right, switching to Large grows the window off screen. **Fail:** SwiftUI can position a window only when it opens.
  - Keep on Top takes effect only after the window changes size. **Fail:** SwiftUI's `.windowLevel` doesn't hold the level. The cause was found after the second test, below.
  - Enter Full Screen is disabled. **Pass.**
  - Size, position and Keep on Top all return after a relaunch. **Pass.**
  - New Window is gone, but the whole File menu went with it, Close included. **Fix:** restore Close.

  Chris chose to amend §6 rather than work around either failure, and to add snap resizing as 0.3.
- **Result, second test (Nov 4, 2026),** with `WindowAccess.swift` and File → Close. Headless: clean build, no compiler warnings. Chris on the M4:
  - Near the bottom-right, switching to Large keeps the window on screen. **Pass.**
  - Size switches keep the top-left corner, and a relaunch restores size, position and Keep on Top. **Pass.**
  - Toggling Keep on Top now works both ways at once, but at launch the window isn't on top until it's toggled. **Fail:** something resets the level after `WindowAccess` sets it.
  - File shows the restored Close (⌘W), then macOS's own Close and Close All, so Close appears twice. **Fix:** remove macOS's pair.
- **Fixes after the second test (Nov 4, 2026), checked by Claude.** Clean build, no compiler warnings.
  - *Keep on Top at launch.* The debugger showed SwiftUI's `.windowLevel(.floating)` sets level 19, macOS's utility level, rather than AppKit's floating level, 3. It does so when it creates the window and again on every scene update, overriding the 3 that `WindowAccess` sets at launch. A toggle comes after SwiftUI's update, which is why toggling worked. Level 19 still sat above other windows in Claude's runs, so the failure itself wasn't reproduced. The fix gives the launch the same level a toggle gives. **Fix:** the scene no longer uses `.windowLevel`. Checked: with a breakpoint on the level setter, `WindowAccess` is now the only thing that sets it. The window server reports level 3 from launch, through app switches and size changes, and 0 and then 3 when Keep on Top is turned off and on.
  - *Close twice.* Close now replaces macOS's Close group (`.saveItem`), and the New group is left alone. Replacing any File group, even with nothing, adds a separator line, so the first try left a stray line under Close. Checked with the debugger: File holds only Close (⌘W), with no separator, and choosing it quits the app.
- **Result, third test (Nov 4, 2026).** Chris on the M4:
  - Keep on Top holds from launch, and toggling works both ways. **Pass.**
  - File holds only Close (⌘W), and closing quits the app. **Pass.**
  - Size switches keep the top-left corner, Large near the bottom-right stays on screen, and a relaunch restores size, position and Keep on Top. **Pass.**

  **Confirmed by Chris** (Nov 4, 2026).

### Increment 0.3 — Snap resizing
- **Goal:** Dragging the window's edges settles it at one of the three sizes. (FR-3, FR-3d, FR-22) *(Added Nov 4, 2026, at Chris's request.)*
- **Build:** The content's size limits become Small and Large, so the window can be dragged between them. `WindowAccess.swift` watches for the end of a drag, picks the nearest size by the rule in §2 of the design document, sets the window to it with the opposite edge or corner in place, and saves it as the chosen size. View → Size sets the window's frame the same way, keeping the top-left corner. `.windowFullScreenBehavior(.disabled)` turns off full screen, so the green button zooms.
- **Risk:** SwiftUI and the snapping code could both try to set the window's size and fight. If they do, Claude stops and reports.
- **Verify:** Chris's checklist:
  - Dragging the bottom-right corner more than halfway toward the next size and letting go snaps to that size. Less than halfway, it returns.
  - Dragging only the right edge, or only the bottom edge, reaches all three sizes.
  - Dragging the left or top edge snaps with the opposite edge in place.
  - The window can't be dragged smaller than Small or larger than Large.
  - After a snap, View → Size has the new size checked, and the size returns after a relaunch.
  - The green button zooms to Large and back, and full screen stays off.
  - A snap near a screen edge leaves the window fully on screen.
  - 0.2's checklist still passes.
- **Done when:** The checklist passes on the M4 and in the M1 pass. **Completes Phase 0.**
- **Result, Claude's checks (Nov 4, 2026):** `MeterSize` and the snap rule moved to the new `MeterSize.swift`. `.windowFullScreenBehavior` turned out to be a view modifier, so it sits on the window's content. Debug and Release clean builds, no compiler warnings.
  - The snap rule, compiled alone with a test driver, passes 19 cases. They include design §2's M4 example, an exact tie going to the larger size, edge-only drags reaching all three sizes, corner drags, and equal shares.
  - In the running app, through the debugger, with a drag's end simulated by the live-resize notifications:
    - right-edge, left-edge, bottom-left-corner and top-edge drags each settle at the expected size, with the opposite edge or corner in place, and the saved size follows;
    - a resize that isn't a drag settles with the top-left in place;
    - the green button zooms to Large and back, and full screen is off;
    - View → Size keeps the top-left corner, and near the bottom-right both a switch to Large and a snap stay on screen;
    - relaunching with a saved size that doesn't match the saved frame opens at the saved size with the top-left in place. The open animation shows the old size for about 4 ms first.
    - The level is still 3 from launch, and File still holds only Close.
  - Not covered by Claude's checks: a real mouse drag.
  - Copied to the M1's Drop Box as `CPUMeter-0.3-95283b6-dirty.zip`.
- **Result, Chris's test (Nov 4, 2026):** all eight checks pass on the M4 (run from Xcode) and on the M1 (the Drop Box build), including 0.2's checklist. **Confirmed by Chris** (Nov 4, 2026). **Phase 0 is complete.**

---

## Phase 1 — Measurement (console only)

### Increment 1.1 — Read the counters
- **Goal:** Correct per-core tick changes, including across a counter wrap. (FR-13, FR-15, FR-16, NFR-2)
- **Build:** `CoreCounters.swift`: a `nonisolated` read of user, system, idle and nice ticks for each core, and a pure function for the wrapping change between two reads. Every read frees the array macOS returns with `vm_deallocate`, because missing that would leak memory on every tick and break NFR-1.
- **Verify:** A headless driver compiles the real file and checks the arithmetic, including `0xFFFFFFF0` → `0x00000010`, identical reads, and nice counted as user. It also reads live counters and shows them advancing about 100 ticks per second per core. A run of 100,000 reads shows flat memory.
- **Done when:** All checks pass, and a sandboxed build reads the same values.
- **Result, Claude's checks (Nov 4, 2026):** `CoreCounters.swift` has `CoreTicks`, `TickChange` (nice counted as user, and a total for 1.3 to divide by), `read()` and the wrapping change. It keeps the host port, fetched once, because each `mach_host_self()` call adds a reference.
  - Compiled alone with a test driver under Swift 6 and the project's main-actor default, with no warnings. 12 checks pass:
    - arithmetic: `0xFFFFFFF0` → `0x00000010` gives 32, every counter wrapping at once, identical reads giving zero, nice counted as user, mismatched core counts refused, and cores paired in order;
    - live: 10 cores at 99–100 ticks a second each;
    - 100,000 reads, none failed, at 3.38 µs each, with the memory footprint flat at 1,904 KB and the host port's references flat.
  - A deliberately leaky copy fails both of those last checks. It skips `vm_deallocate` and calls `mach_host_self()` on every read. Memory grows from 18 MB to 1.6 GB, and references climb to the 65,535 limit.
  - Debug and Release clean builds, with no compiler warnings.
  - A temporary launch print in `CPUMeterApp.swift`, Debug only and absent from the Release binary, shows the sandboxed app read 10 cores and about 105 ticks per core over 1.05 s. The unsandboxed driver, reading 3.48 s later, found every core 345–349 ticks further on, matching the time between the two reads, so both read the same counters.
  - **Confirmed by Chris** (Nov 4, 2026).

### Increment 1.2 — Core types
- **Goal:** Correct groups, names and order, on both Macs. **This is the first real test of the core-type rule on the M1.** (FR-6, FR-8, FR-8a, FR-8b, FR-8c)
- **Build:** `CoreTopology.swift`: the rule from §6 of the requirements, separated from its inputs so it can be tested with fixtures. It takes the logical IDs and cluster types from IORegistry and the names and counts from `sysctl`, and returns groups ordered from lowest to highest performance, each with its bars in logical-ID order. A temporary launch print shows the result.
- **Verify:**
  - Headless fixtures: the M4's 6 + 4, the M1's tied 4 + 4, the M5 Max's Performance and Super, and mismatched counts, which must fall back to one "Cores %" group.
  - Live on the M4: Efficiency logical IDs 0–5, then Performance 6–9.
  - Live on the M1: Claude copies the build to the Drop Box, and Chris runs one pasted command and sends back the output.
- **Done when:** Fixtures pass and both Macs report the right groups. If the M1 reports something unexpected, the rule gets fixed here, before anything depends on it.
- **Result, Claude's checks (Nov 4, 2026):** `CoreTopology.swift` has `CoreGroup`, which holds macOS's name, the " %" label and the logical IDs, and `CoreTopology`. Its `resolve` applies the rule to inputs passed in, and `readInputs` reads them from IORegistry and `sysctl`. A fallback carries its reason, which the launch print shows. The temporary launch print in `CPUMeterApp.swift` now also shows the groups and the raw inputs. 1.3 removes it.
  - Compiled alone with a test driver under Swift 6 and the project's main-actor default, with no warnings. 22 checks pass:
    - groups: the M4's 6 + 4 with IORegistry's order shuffled, the M1's tied 4 + 4, an M5 Max with Performance and Super (its layout assumed), made-up names and letters across three levels, and a single level;
    - a fallback to "Cores %" when the counts disagree, when the M4's levels come in the other order, when the IDs have a gap or a duplicate, when IORegistry lists fewer or more cores than were counted, when either source is unreadable or empty, when a name is empty or a cluster type is missing, when there are fewer runs than levels, when a type appears in two runs, when no cores are counted, and for an Ultra numbered E, P, E, P (the known limit below);
    - the label "Efficiency %".
  - Live on the M4, the driver and the sandboxed Debug app both report **Efficiency % 0–5, then Performance % 6–9**, from `perflevel0` Performance ×4 and `perflevel1` Efficiency ×6.
  - 100,000 reads of both sources leave the memory footprint flat at 2,000 KB and the process's Mach ports at 11. A read takes about 70 µs, and the rule runs once at launch.
  - Debug and Release clean builds, with no compiler warnings. The Release binary has no launch print. It doesn't contain the topology code yet either, because nothing in Release calls it until 1.3.
  - Copied to the M1's Drop Box as `CPUMeter-1.2-aa25872-dirty.zip`. It's a Debug build, because the print is Debug-only.
  - **Known limits.** On the M1 the counts tie, so the count check can't catch a reversed order; 1.3's Efficiency-only load proves the M1's labels. An Ultra whose dies number their cores E, P, E, P falls back to "Cores %". FR-8c allows that, and no Mac Chris owns is affected.
- **Result, the M1 (Nov 4, 2026):** Chris ran the Debug build from Terminal. It reports **Efficiency % 0–3, then Performance % 4–7**, with no fallback, from 8 cores counted, `perflevel0` Performance ×4 and `perflevel1` Efficiency ×4, and IORegistry's IDs 0–3 E and 4–7 P. So the two numberings run in opposite directions on the M1 too, as on the M4, and the rule handles both. macOS also printed a `sandbox_extension_issue_file_to_process … Operation not permitted` line for the app's own folder in `/tmp`. Every read after it worked, so it doesn't affect this check. **Confirmed by Chris** (Nov 4, 2026).

### Increment 1.3 — Sample on a timer
- **Goal:** Live percentages that match the test loads, and proof the group labels are right. (FR-8b, FR-9, FR-10, FR-12, FR-14, FR-15, NFR-6)
- **Build:** `CPUSampler.swift`, an `@Observable`, main-actor class like DriveSpeed's `SpeedSampler`: the baseline is primed in `start()`, and the timer tolerance is 10% of the interval. The timer runs in the run loop's common modes, unlike DriveSpeed's, so the bars keep updating while a menu is open. That matters here because every control is in the menu bar. Each tick computes user and system percentages per core and the overall figure from raw ticks, all from one read. A temporary console line prints the overall figure and each group's average. It replaces 1.1's temporary launch print.
- **Verify:** Headless checks for the percentage math, the zero-tick case and the overall figure. Then each test load, compared with the table above and with Activity Monitor by trend. The "Efficiency cores only" load must raise only the Efficiency group, on both the M4 and the M1.
- **Done when:** Figures follow every load, and the labels are proven right on both Macs. **Completes Phase 1.**
- **Result, Claude's checks (Nov 4, 2026):** `CPUSampler.swift` has `CPUUsage` (user and system shares), `CPUSample` (every core plus the overall figure, from one read) and `CPUSampler`.
  - The sampler reads the core groups when it's made, so 2.1 can size the window before it opens. `start()` reads the baseline, then runs a 1-second timer with a 0.1-second tolerance in the run loop's common modes.
  - `usage(of:)` sums raw ticks over one core, a group or every core. A core with no ticks gives no figure, which 2.2 draws as the dash. A failed read keeps the baseline, and a changed core count starts a new one; 4.2 tests both.
  - `CPUMeterApp.swift` owns the sampler and starts it when the window appears. The 1.1 and 1.2 launch prints are gone. The temporary console line prints in every build, so it shows in Xcode's console, which runs Release. 2.2 removes it.
  - Compiled alone with a test driver under Swift 6 and the project's main-actor default, with no warnings. 26 checks pass:
    - math: user and system shares, nice counted as user, a wrapped counter, full load and idle, a zero-tick core giving no figure and left out of the overall, every core at zero and no cores giving no overall, the overall from raw ticks (0.45% where averaging rounded figures gives 1%), each core weighted by its own ticks, group averages, and mismatched core counts;
    - live: the groups at launch, nothing published before the first tick, 5 ticks in 5.5 s, 1.000 s apart after the first, and none after `stop()`;
    - menus: with AppKit loaded and the run loop in event-tracking mode, the mode macOS uses while a menu is open, the sampler ticked 3 times in 3.5 s, while a control timer in the default mode only never fired;
    - 100,000 live reads through the math, with the memory footprint flat at 1,904 KB.
  - Debug and Release clean builds, with no compiler warnings. The Release binary now has the sampler and the topology code, and none of the 1.1 and 1.2 prints.
  - The Release app on the M4, under each test load, as the median of 7 or 8 ticks after the first, with the table above for comparison:

    | Load | Efficiency | Performance | Overall | User / system |
    |---|---|---|---|---|
    | None | 14.2% (11.8) | 0.4% (4.6) | 9.2% (8.9) | — |
    | User time | 5.4% (7.5) | 26.5% (26.8) | 13.9% (15.2) | 12.3% / 1.6% (13.1 / 2.2) |
    | System time | 10.4% (7.3) | 26.8% (26.2) | 19.9% (14.9) | 7.2% / 10.9% (3.7 / 11.2) |
    | Efficiency cores only | 27.9% (31.4) | **0.0%** (2.1) | 16.9% (19.7) | 5.3% / 11.6% (7.1 / 12.6) |
    | Four busy loops | 5.5% (10.9) | 100% (99.8) | 43.3% (46.5) | 41.8% / 1.4% (43.7 / 2.8) |
    | Every core | 100% (99.9) | 100% (100) | 100% (99.9) | 98.6% / 1.4% (97.8 / 2.1) |

    Every load moves the figures as the table does. Under the Efficiency-only load, Performance never rose above 0.5%, so the M4's labels are right. The system-time run's overall figure is higher than the table's because other user work was running in its first two ticks; its system share and Performance figure match. Under the every-core load the app's own timer fired late, with 84 to 156 ticks per core between updates and one 2-second gap, and every figure still read 100.0, because each comes from the ticks rather than clock time (FR-15).
  - Copied to the M1's Drop Box as `CPUMeter-1.3-0684c30-dirty.zip`, a Release build.
  - Not covered by Claude's checks: a menu held open in the running app, and Activity Monitor alongside.
- **Result, Chris's test (Nov 4, 2026):**
  - On the M4, run from Xcode: the figures follow the test loads and Activity Monitor, the console lines keep coming while the View menu is held open, and the Efficiency-only load raises only the Efficiency group. **Pass.**
  - On the M1, the Drop Box build, run from Terminal with one pasted command: about 100 ticks per core between updates throughout, and macOS's harmless `sandbox_extension_issue_file_to_process` line from 1.2. As the median of the ticks after the first:

    | Load | Efficiency | Performance | Overall | User / system |
    |---|---|---|---|---|
    | Efficiency cores only (10 ticks) | 33.4% | **0.3%** | 16.9% | 3.0% / 13.7% |
    | Four busy loops (9 ticks) | 2.8% | **100%** | 51.5% | 50.6% / 1.0% |

    Each load raises only the group it should. Performance reached 10.8% in one tick of the Efficiency-only load and stayed under 2% in the rest. **So the M1's labels are right in both directions**, which the tied counts in 1.2 couldn't show. Four busy loops on 8 cores give 51.5% overall, close to the 4 / 8 that NFR-6 expects. **Pass.**

  **Confirmed by Chris** (Nov 4, 2026). **Phase 1 is complete.**

---

## Phase 2 — Display

### Increment 2.1 — Layout math
- **Goal:** The width rule produces exactly the table in §6 of the requirements. (FR-3b, FR-3c, FR-8d, FR-11)
- **Build:** `MeterLayout.swift`: pure functions and the numbers from §2 of the design document. It takes the groups and returns the window size and each bar's position. Group labels are measured with AppKit at launch, which is the use added to §6 of the requirements in v1.4. The core count is read at launch and never stored.
- **Verify:** A headless driver runs the 19 core layouts behind that table at all three sizes and compares the results with it, then confirms every label fits its group and every core gets its minimum width. Plug the result into the 0.2 window, and Chris confirms the M4 opens at 246, 360 and 480 wide.
- **Done when:** All 57 widths match. Any mismatch means the code or the table is wrong, and it gets resolved here.
- **Found before the code (Nov 4, 2026):** AppKit measures "Efficiency %" at 61.511 pt at 10 pt, not 61.5. With the 19 layouts rebuilt from Apple's specs, 56 of the 57 widths match, but the M1 Pro with 6 Performance and 2 Efficiency cores needs 282.05 at Small, which rounds up to 283. The table had used the rounded figure. Chris corrected the table to 283 (requirements v1.8), so the code applies the rule unchanged. The design canvas holds only 7 of the layouts; the 19 are the table's 17 rows, with 10 cores split two ways (4 P + 6 E and 6 P + 4 E) and 12 cores two ways (8 P + 4 E and 6 P + 6 E).
- **Result, Claude's checks (Nov 4, 2026):** `MeterLayout.swift` has:
  - `MeterMetrics`, every number in design §2;
  - the width rule, as pure functions that take each group's core count and label width;
  - `MeterLayout`, for one size: the content size, each core's width, the top row, and each group's label frame, bars and figures, from the content's top-left corner. Positions aren't rounded to pixels; 2.2 does that;
  - `MeterLayouts`, all three sizes, built once at launch;
  - `measuredLabelWidth`, the one AppKit call, §6's third use.

  `MeterSize` lost its base-width `contentSize`, so the snap rule always takes the real sizes. `CPUMeterApp`'s `init()` builds `MeterLayouts` from the sampler's topology, and `WindowAccess` and the placeholder use it.
  - Compiled with a test driver under Swift 6 and the project's main-actor default, with no warnings. 18,120 checks pass:
    - **all 57 widths match requirements §6** (v1.8), both with design §7's figures and with live AppKit measurement. One-decimal figures would give the M1 Pro 282 at Small, the old table's figure;
    - at every layout and size: every label fits its group, every core gets at least its minimum width, the bars cover every core in order, bars are a bar gap apart and groups a group gap apart, each figure is centered under its bar, bars are 74, 134 and 195 tall, the figures end at the bottom margin and the last group at the right margin, and each size is larger than the one before;
    - the fallback "Cores %" row at all 15 core counts, which follows FR-3b with one group, so the M4's would be 240 wide at Small; and no cores counted, which gives the base widths and no bars;
    - the snap rule with the M4's widths: design §2's example (Small's right edge out to 380 settles at Medium), an exact tie at 303 going to Medium, and single-edge drags reaching every size;
    - this Mac: Efficiency % 6 and Performance % 4, so 246 × 150, 360 × 225 and 480 × 300. "Performance %" has 7.9 pt spare at Small, as design §7 says;
    - `Canvas`'s rounding: drawn by `Canvas` at scale 1.0, the tightest labels' text ends inside their groups. "Performance %" ends at 76 in the MacBook Neo's 76.33 at Small. "Efficiency %" ends at 61 in the M1 Pro's 61.75 and the M1 Pro and M1 Max's 61.60 at Small, and at 66 in their 67.00 at Medium. `Canvas` measures those labels as 77, 62 and 67, so its rounding doesn't show.
  - Debug and Release clean builds, with no compiler warnings.
  - The running app on the M4, with Chris's settings saved first and restored after:
    - the window server reports 246 × 182, 360 × 257 and 480 × 332, title bar included, at Small, Medium and Large, with the top-left corner in place through every switch. A relaunch opens at the saved size;
    - the window's limits are 246 to 480 wide;
    - through the debugger, with a drag's end simulated: Small's right edge out to 380 settles at Medium, Medium's bottom edge down to 300 settles at Large, and Large's right edge in to 250 settles at Small, each with its top-left corner in place and the size saved.
  - Not covered by Claude's checks: a real mouse drag, and how the placeholder looks.
- **Result, Chris's test (Nov 5, 2026):** run from Xcode on the M4, the placeholder reads "Small · 246 × 150", "Medium · 360 × 225" and "Large · 480 × 300", with the top-left corner in place through each switch. Real mouse drags snap to the nearest size, the window can't be dragged narrower than Small or wider than Large, and Keep on Top and relaunching work as before. **Confirmed by Chris** (Nov 5, 2026). No M1 pass for 2.1; Phase 2's is in 2.4.

### Increment 2.2 — Bars on screen
- **Goal:** The real display, live, matching the approved design. (FR-6, FR-7, FR-8d, FR-9, FR-10, FR-11, FR-14, FR-27, NFR-3, NFR-5)
- **Build:** `MeterView.swift`, a single `Canvas` and never Charts: the top row, group labels, bars with their tracks and 1 pt gap, and per-core figures in monospaced digits. The dash state shows before the first reading. Default colors come from the system's blue and orange. Bar edges are snapped to whole pixels. The temporary console output is removed.
- **Verify:** Claude renders the real view headlessly at scale 1.0, in dark and light, and inspects it. Then Chris runs it on the M4 and compares it with the canvas: the system-time load grows the orange part of a bar, the user-time load grows the blue part, and the every-core load shows every figure at or near 100 and still readable.
- **Done when:** Chris confirms the window matches the design at all three sizes, in both appearances.
- **Plan agreed with Chris (Nov 5, 2026):** the meter takes the layout and the latest sample as plain values, not the sampler. As in the design canvas, each bar's colored parts are clipped to the track's rounded corners, and figures are rounded to the nearest whole number. Two of Claude's calls, which Chris accepted:
  - **pixel snapping:** every bar keeps the same whole-pixel width, and its left edge moves to the nearest pixel, so a gap between bars can be a pixel narrower or wider than the design's;
  - **the 1 pt gap** between user and system comes out of the bottom of the system part, so the top of a bar always shows the true total. The canvas adds the gap instead, so its bars run 1 pt too tall. A system part too thin to keep a pixel after the gap is drawn without one, so it doesn't vanish.
- **Result, Claude's checks (Nov 5, 2026):** `MeterView.swift` draws the meter in one `Canvas`:
  - the top row, with the overall figure and the key;
  - the group labels;
  - each track, and each bar's user and system parts, clipped to the track;
  - the figures, in monospaced digits.

  The bar geometry and the figures' text are pure functions, in `MeterDrawing`. The colors are the system's blue and orange, the label colors and the design's track, in `MeterColors`. `CPUMeterApp` shows the meter in place of the placeholder, through a small view that reads the sampler, so each update redraws only the meter. `CPUSampler`'s temporary console line is gone.
  - A test driver compiles the real files under Swift 6 with no warnings. All 6,867,092 geometry checks pass, at all 19 layouts and the fallback row, at all three sizes, at scales 1 and 2:
    - every bar's edges are on whole pixels, every bar in a layout is the same width, and each bar stays inside its own cell;
    - gaps stay within a pixel of the design's: 2–3 at Small, 3–5 at Medium and 4–6 at Large, at scale 1;
    - every reading in steps of 0.25%: the top of the bar is within half a pixel of the total and the user part within half a pixel of its share, with the gap rule applied;
    - the ends: 0% draws nothing, and 100% fills the track;
    - the figures' text: the dash, rounding (99.49 reads 99, 99.51 reads 100) and "CPU –".
  - The real view rendered at scale 1.0 on the M4's layout, in Dark and Light, at all three sizes: no reading yet, the design canvas's mixed readings, every core at 100, a row of edge cases (thin system parts, one part only, a core with no reading), and the fallback "Cores %" row. Claude inspected each. 510 pixel checks pass:
    - every bar's left, right and top edges are sharp, with no blended column or row, in exactly the system blue or orange;
    - the empty track is white at 10% or black at 8% over the window background.
  - The system colors on macOS 27 differ from the mockup's hex values, as design §4 allows: blue is (0, 145, 255) in Dark and (0, 136, 255) in Light, and orange (255, 146, 48) and (255, 141, 40). The window background is (30, 30, 30) and white.
  - Debug and Release clean builds, with no compiler warnings.
  - The Release app on the M4, with Chris's settings saved first and restored after:
    - 246 × 182, 360 × 257 and 480 × 332 with the title bar, at Small, Medium and Large, with the top-left corner in place;
    - no console output;
    - 0.0–0.1% CPU, over 10 one-second samples at Small.
  - The real window, captured from inside the running Debug app with the debugger at each size, at its backing scale of 1: all 90 edge checks pass, so every bar's left and right edges are sharp in the window too. That capture leaves out text, so it can't show the labels or figures.
  - Not covered by Claude's checks: the text in the real window, a side-by-side comparison with the design canvas, and the test loads.
- **Result, Chris's test (Nov 5, 2026):** run from Xcode on the M4 at all three sizes, in Dark and Light. Every test passes:
  - the window matches the design canvas very well, and still looks very close to Activity Monitor's CPU History;
  - the system-time load grows the orange part of a bar and the user-time load the blue part;
  - under the every-core load, the figures are readable.

  **Confirmed by Chris** (Nov 5, 2026). No M1 pass for 2.2; Phase 2's is in 2.4. Chris then asked for some design changes, which became 2.3.

### Increment 2.3 — Design changes
- **Goal:** The meter matches Chris's changes after 2.2, in requirements v1.9 and v1.10 and the UI design's Nov 5 revisions: system time at the bottom of each bar, System first in the key, the overall figure as "All cores: 42%", each group's average in its label with a colon, "Perf" only where "Performance" would widen the window, and no label on the fallback row. (FR-3b, FR-8a, FR-8c, FR-8d, FR-8e, FR-9, FR-10, FR-11, FR-27, NFR-3)
- **Build:**
  - `CPUSampler.swift`: each sample also holds each group's average, from that group's raw ticks, as the overall figure is calculated.
  - `MeterLayout.swift`: labels measured at their widest ("Efficiency: 100%", in monospaced digits); "Perf" at a size where "Performance" would make the window wider; on the fallback row, no label and taller bars (89, 152 and 215).
  - `MeterView.swift`: the system part at the bottom and the user part above it, with the gap coming out of the user part; the key reading System, then User; the overall figure as "All cores: 42%"; each label drawn with a colon and its average, or a dash before the first reading.
  - `CoreTopology.swift` and `CPUMeterApp.swift`, only as far as the label text and the fallback need.
- **Verify:** Headless, on the real files:
  - all 57 widths match requirements §6 v1.10, with live measurement, and "Perf" appears in exactly the three places FR-8e names;
  - "All cores: 100%" and the key fit the top row at every size, with the room design §7 gives;
  - at every layout and size, every label at its widest fits within its group, and on the fallback row the taller bars end where the other rows' bars do;
  - the group averages from raw ticks, including uneven groups;
  - the bar parts at every reading in steps of 0.25%, with system time at the base;
  - renders at scale 1.0 in Dark and Light at all three sizes: no reading yet, mixed readings, full load and the fallback row.

  Then Chris runs it on the M4 from Xcode, at all three sizes, in Dark and Light:
  - the system-time load grows the orange base of a bar and the user-time load the blue part above it;
  - the top row reads "All cores: nn%", and the labels read "Efficiency: nn%" and "Perf: nn%" at Small, and "Performance: nn%" at Medium and Large;
  - the Efficiency-cores-only load raises the Efficiency average and not the other;
  - under the every-core load, the top row and the labels read 100% and every figure is readable.
- **Done when:** Chris confirms the window matches the revised design on the M4. No M1 pass; Phase 2's is in 2.4.

### Increment 2.4 — Other core counts
- **Goal:** See every Mac in the requirements' table, drawn by the real code. (FR-3b, FR-8a, FR-8c, FR-8e, FR-11)
- **Build:** `SimulatedCores.swift`, compiled only in Debug builds: a launch argument such as `-simulateCores Performance:24,Super:12` replaces the detected groups and feeds them synthetic ticks.
- **Verify:** Claude renders all 19 core layouts at all three sizes as a contact sheet and inspects it for overlaps, clipping and figures running together. Chris spot-checks 36 cores, the fallback row and the MacBook Neo, with its "Perf" at Small and Medium, in the real window. A check of the Release binary confirms the simulation code isn't in it.
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
- **Build:** `BarColors.swift` and **View → Colors**: System Color…, User Color… and Reset to Defaults, in the key's order. `NSColorPanel` opens set to the current color and titled with which one is changing, with its opacity control hidden. Chosen colors are stored as sRGB values. With none stored, the adaptive system colors apply.
- **Risk:** With Keep on Top on, the chooser could open behind CPUMeter, or the app might not quit with the chooser open. Both are checked explicitly. Also, File → Close (from 0.2) closes the meter's window by name, so ⌘W with the chooser in front may quit the app instead of closing the chooser. Check it here, and fix it if so.
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
- **Build:** The sampler publishes only when a displayed value changes, compared at whole percentages for each core's user and system time, each group's average and the overall figure. A failed read keeps the zero state. A changed core count primes the baseline again and recalculates the width.
- **Verify:** Headless: a failed read, zero ticks, a core count that changes between reads, identical samples that publish nothing, and a core-type mismatch reaching the unlabeled fallback row. Chris: put the whole Mac to sleep, wake it, and confirm no false spike.
- **Done when:** All pass with no crash. **Completes Phase 4**, including the M1 pass.

---

## Phase 5 — Finish

### Increment 5.1 — App icon
- **Goal:** Chris's icon in the Dock and in Finder. (FR-5)
- **Build:** Chris creates the icon separately and tells Claude when it's finished. Claude then adds it to `Assets.xcassets/AppIcon`. This increment runs whenever the icon is ready and doesn't hold up any other increment, but the v1.0 release in 5.5 includes it. *(Chris's instruction, Nov 2, 2026.)*
- **Verify:** Chris checks it in the Dock and in Finder.
- **Done when:** Chris approves it.
- **Result (Nov 4, 2026):** Chris's artwork arrived as one sheet of six drawings on a dark background, labelled 512 down to 16. It's kept as `design/AllIcons.jpeg`. Each drawing was cut out of the background, and each icon size uses the drawing labelled for it, with the 1024-pixel size taken from the largest. Every drawing is larger than its label, so nothing was enlarged. As drawn, the icon was put inside a gray rounded square by macOS 27, because the chip's outline isn't Apple's standard shape. Chris chose a version stretched to Apple's 824-of-1024 tile and clipped to its corners. That trims the outer pin tips and leaves the shadow to macOS, which then shows the icon full size. `xcodebuild` is clean. The first run from Xcode still showed the blank icon, because macOS caches an app's icon by the `.app` folder's path and date, and an Xcode rebuild doesn't change the folder's date. Touching the built `.app` fixed it. **Confirmed by Chris** (Nov 4, 2026): the new icon shows in the Dock and the About box.

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
| FR-3, FR-3a | 0.2, 0.3 |
| FR-3b | 2.1, 2.3, 2.4 |
| FR-3c | 2.1 |
| FR-3d | 0.3 |
| FR-4 | 0.1 |
| FR-5 | 0.1, 5.1 |
| FR-6 | 1.2, 2.2 |
| FR-7 | 2.2 |
| FR-8 | 1.2 |
| FR-8a | 1.2, 2.3, 2.4 |
| FR-8b | 1.2, 1.3 |
| FR-8c | 1.2, 2.3, 2.4, 4.2 |
| FR-8d | 2.1, 2.2, 2.3 |
| FR-8e | 2.3, 2.4 |
| FR-9 | 1.3, 2.2, 2.3 |
| FR-10 | 1.3, 2.2, 2.3 |
| FR-11 | 2.1, 2.2, 2.3, 2.4 |
| FR-12 | 1.3 |
| FR-13 | 1.1 |
| FR-14 | 1.3, 2.2 |
| FR-15 | 1.1, 1.3 |
| FR-16 | 1.1 |
| FR-17 | 4.1 |
| FR-18, FR-18a–d | 3.1 |
| FR-19, FR-20 | 0.2 |
| FR-22 | 0.2, 0.3 |
| FR-21 | 0.1, 0.2 |
| FR-23 | 0.1 |
| FR-24 | 0.2, 3.1, 3.2 |
| FR-25, FR-26 | 0.2 |
| FR-27 | 2.2, 2.3 |
| FR-28, FR-28a–e | 3.2 |
| NFR-1 | 1.1, 4.2, 5.2 |
| NFR-2 | 1.1 *(pre-verified Nov 1)* |
| NFR-3 | 2.2, 2.3 |
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
