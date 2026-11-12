# CPUMeter — Incremental Build Plan

**Version:** 1.14
**Changelog:** v1.14 (Nov 11, 2026) — after Chris checked 5.8's Close change by hand: **⌘W never quits** (requirements v1.22). With the meter in front, File → Close is grayed out and ⌘W does nothing, added to 5.8's Build and Verify. The coverage map adds 5.8 to FR-23. v1.13 (Nov 11, 2026) — from Increment 5.8's walk: **⌘W closes the About box** when it's in front (requirements v1.21), added to 5.8's Build and Verify. The coverage map gains a row for the green button (requirements §8 item 21), adds 5.6 where the MacBook Air checked a requirement, gives FR-25 a row of its own, and puts FR-21 before FR-22. v1.12 (Nov 11, 2026) — Chris's request after Increment 5.6 (requirements v1.20): **the green button grows the window to its largest size and back**, and at the largest size goes to Large. The new **5.7, Green button**, builds it, so Traceability, README and release, which was 5.7, is now **5.8**. The Files table is updated to match. v1.11 (Nov 9, 2026) — **5.4's probe results** (requirements v1.18): the shape comes from CPUMeter answering each step of a resize, in front of SwiftUI's window handling, and the limits from the meter's own frame, because `contentAspectRatio` left the meter 32 points short in SwiftUI's window and SwiftUI reset limits set directly. 5.4's code plan and checks are updated to match: a drag can't be simulated by moving the window from code any more, so the resize answers are checked directly, and tiling is reached from the green button's menu. v1.10 (Nov 8, 2026) — Chris's free sizing (requirements v1.17): the window can be any size from Small up, a plain zoom of Small, dragged from any edge or corner. The new **5.4, Free sizing**, starts with a probe that checks SwiftUI leaves the window's shape and size limits alone, and then builds it. Accuracy, the M3 MacBook Air check and the release, which were 5.4, 5.5 and 5.6, are now **5.5**, **5.6** and **5.7**, and the Air check adds a dragged size. NFR-1 at the new sizes is checked with a 10-minute run at three sizes, and 5.2's hour is repeated only if that run differs from 5.3's (Claude's proposal). The Files table and coverage map are updated to match. v1.9 (Nov 7, 2026) — Increment 5.2's first runs found that SwiftUI's `Canvas` leaves a system timer behind on every redraw at Medium and Large, so CPU use climbs for as long as the app runs, and Chris chose Core Animation (requirements v1.16). The new **5.3, Core Animation drawing**, redraws the meter with nothing on screen changing. Accuracy, the M3 MacBook Air check and the release, which were 5.3, 5.4 and 5.5, are now **5.4**, **5.5** and **5.6**. 5.2 records its first runs and the cause, and is completed by repeating its runs after 5.3, now also with Small, Medium and Large side by side on the M4, and with a definition of level (Claude's proposal). The Files table and coverage map are updated to match. v1.8 (Nov 6, 2026) — adds the **macOS 27.2 recheck** between Phases 4 and 5, after Chris updated both Mac minis from macOS 27.0.1 to 27.2: Claude reruns the automated checks on the M4, and Chris does a short manual pass on each Mac, in place of repeating every test. No increment changed. v1.7 (Nov 6, 2026) — Increment 4.1 also times the first update after a pause: 1 second after the window is visible again, then at the chosen rate (requirements v1.14, FR-17). v1.6 (Nov 6, 2026) — after Increment 3.3, Chris's new keyboard shortcuts (requirements v1.13) get their own increment, the new **3.4, Keyboard shortcuts**, which now ends Phase 3: ⌘1 to ⌘5 for the refresh rates, and ⇧⌘S, ⇧⌘M and ⇧⌘L for the sizes in place of ⌘1, ⌘2 and ⌘3. 3.3 still took Phase 3's M1 pass, and 3.4 needs none. 3.1's Results stay as they were, a record of ⌘1–⌘3. v1.5 (Nov 5, 2026) — after Increment 3.2's first test, Chris's change to FR-18d (requirements v1.12): a new rate updates the meter at once, never from less than 1 second, rather than restarting the interval. 3.2's Build and Verify are updated, and 3.2 stays one increment. v1.4 (Nov 5, 2026) — after Increment 2.4, Chris's size shortcuts (requirements v1.11) get their own increment, the new **3.1, Size shortcuts**. Refresh Rate and Colors, which were 3.1 and 3.2, are now **3.2** and **3.3**, and Colors still completes Phase 3. v1.3 (Nov 5, 2026) — Increment 2.3 also builds requirements v1.10's wording: the overall figure reads "All cores: 42%", and the group labels take a colon. v1.2 (Nov 5, 2026) — after Increment 2.2, Chris's design changes (requirements v1.9) get their own increment, the new **2.3, design changes**. The old 2.3, other core counts, is now **2.4** and still completes Phase 2; earlier Results that point to it say 2.4. 3.2's menu lists System Color… first, and 4.2 compares the group averages too. v1.1 (Nov 4, 2026) — Increment 0.2's first test found two places where SwiftUI falls short, so requirements v1.7 adds direct window access and 0.2 now uses it, through the new `WindowAccess.swift`. Added Increment 0.3, snap resizing, at Chris's request. It now completes Phase 0 and takes Phase 0's M1 pass. After 0.2's second test, the scene drops `.windowLevel`, and File's Close replaces macOS's own Close group. v1.0 (Nov 2, 2026) — approved by Chris.
**Date:** November 12, 2026
**Companion to:** `cpu-meter-requirements.md` (v1.22) and `cpu-meter-ui-design.md`
**Status:** Approved by Chris on Nov 2, 2026, with the test machine, push and app icon instructions below.
**Progress:** Increment 0.1 (the Xcode project and an empty window) was confirmed by Chris on Nov 4, 2026, and Increment 5.1 (the app icon) the same day. Increment 0.2 (sizes, Keep on Top and remembered position) was confirmed on the M4 the same day, after three tests, as its Results record. Increment 0.3 (snap resizing) was confirmed on the M4 and the M1 the same day, completing Phase 0. Increment 1.1 (reading the counters) was confirmed the same day. Increment 1.2 (core types) was confirmed on the M4 and the M1 the same day. Increment 1.3 (sample on a timer) was confirmed on the M4 and the M1 the same day, completing Phase 1. Increment 2.1 (layout math) was confirmed on the M4 on Nov 5, 2026, and Increment 2.2 (bars on screen) the same day. Chris then asked for some design changes and new wording, recorded in requirements v1.9 and v1.10, and Increment 2.3 (design changes), which builds them, was confirmed on the M4 the same day. Increment 2.4 (other core counts) was confirmed on the M4 and the M1 the same day, completing Phase 2. Chris then asked for keyboard shortcuts for the three sizes, recorded in requirements v1.11, and Increment 3.1 (size shortcuts), which builds them, was confirmed on the M4 the same day. Increment 3.2 (Refresh Rate) was confirmed on the M4 the same day, after Chris's change to how a new rate takes effect (requirements v1.12), as its Results record. Increment 3.3 (Colors) was confirmed on the M4 and the M1 on Nov 6, 2026, with Phase 3's M1 pass. Chris then asked for new keyboard shortcuts, recorded in requirements v1.13, and Increment 3.4 (keyboard shortcuts), which builds them, was confirmed on the M4 the same day, completing Phase 3. Increment 4.1 (pause when not visible), with requirements v1.14's timing, was confirmed on the M4 the same day, starting Phase 4. Increment 4.2 (failures, sleep and needless redraws) was confirmed on the M4 and the M1 the same day, completing Phase 4 with its M1 pass. Chris then updated both Mac minis from macOS 27.0.1 to 27.2, and the macOS 27.2 recheck, Claude's automated checks on the M4 and Chris's short pass on each Mac, was confirmed the same day. Increment 5.2 (footprint)'s first runs, on Nov 6–7, 2026, found that SwiftUI's `Canvas` leaks a system timer on every redraw at Medium and Large, so CPU use climbs. Chris chose to move the drawing to Core Animation (requirements v1.16), which the new Increment 5.3 builds, and 5.2's runs are repeated after it. Increment 5.3 (Core Animation drawing) was confirmed on the M4 and the M1 on Nov 7, 2026: the meter looks as it did, and its timer count stays flat at every size. Increment 5.2's runs were repeated on Nov 8, 2026, and Chris confirmed 5.2 (footprint) the same day: CPU and memory stay level on both Macs, at 0.370% of one core on the M4 and 0.570% on the M1 at Medium, and the three sizes cost the same. Chris then chose free sizing, a plain zoom of Small dragged from any edge or corner, and approved requirements v1.17 for it the same day, then the UI design's revision for it, and the design canvas was updated to match. This plan's v1.10 adds **Increment 5.4, free sizing**, with a probe first, so Accuracy, the M3 MacBook Air check and the release are now 5.5, 5.6 and 5.7. Chris approved v1.10 the same day. 5.4's probe ended on Nov 9, 2026, after three rounds and Chris's drags of every edge and corner; this plan's v1.11 records it, with requirements v1.18, and Chris approved both the same day. Increment 5.4 (free sizing) was confirmed on the M4 and the M1 on Nov 10, 2026. The window can be any size from Small up, dragged from any edge or corner, with its shape kept and the edges the UI design names held at every step. CPU and memory stay level at every size, and 5.4 costs the same as the build before it. Increment 5.5 (accuracy) was confirmed on the M4 and the M1 the same day: under 1, 2, 4 and every-core busy loops, each Mac's overall figure rose by about N/T, and the meter followed Activity Monitor to within half a point at every step. Increment 5.6 (the M3 MacBook Air check) was confirmed on the Air on Nov 11, 2026: on battery, CPUMeter used 0.430% of one core, with an Energy Impact of 0.3, and the window stayed below the menu bar and the notch, with sharp text at scale 2. Chris then asked for the green button to grow the window to its largest size and back (requirements v1.20). This plan's v1.12 adds **Increment 5.7, green button**, for it, so traceability, the README and the release are now 5.8. Chris approved v1.12 and requirements v1.20 the same day. Increment 5.7 (the green button) was confirmed on the M4 the same day. The first press grows the window to its largest size, and the next brings it back to exactly the size and place it had. At the largest size, a press goes to Large. Increment 5.8's walk, the same day, checked the Release app against the requirements on the M4, and found that ⌘W with the About box in front quit CPUMeter. Chris chose to have it close the About box (requirements v1.21), and this plan's v1.13 adds that to 5.8. Chris approved v1.13 and requirements v1.21 the same day. Claude's script and Chris's check on the M4 found the change working as designed. Chris then chose that ⌘W should never quit (requirements v1.22), and this plan's v1.14 adds that to 5.8. Chris approved v1.14 and requirements v1.22 on Nov 12, 2026. Before writing any code, Claude says which files will change and waits for Chris's go-ahead *(Chris's instruction, Nov 4, 2026)*.
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
- **Group averages:** under the Efficiency-only load, only the Efficiency group's average rises in the real window on the M4 (Increment 2.3, Nov 5).
- **Other core counts:** every Mac in the requirements' §6, drawn by the real code from simulated cores, is clean at all three sizes, with no overlaps, clipping or figures running together (Increment 2.4, Nov 5). Above 10 cores, that's as far as testing can go.
- **Headless rendering:** SwiftUI's `Canvas` draws to a PNG through `ImageRenderer` from a plain command-line driver, at scale 1.0 and with real text (Nov 2). So Claude can inspect real layouts before Chris sees them. *(The `Canvas` meter, until 5.3, which renders its layers headlessly instead.)*
- **Figure spacing in `Canvas`:** "100" at 21, 23 and 25 pt per core reads as separate numbers there too (Nov 2).
- **Rounding in `Canvas`:** at scale 1.0 it reports text widths rounded up to whole points: "Performance %" measures 77, 83 and 90 against AppKit's 76.1, 82.9 and 89.5. The width rule uses AppKit's figures, because it has to run before anything is drawn. 2.1 confirms the difference doesn't show.

---

## Files

| File | Purpose | First appears |
|---|---|---|
| `CPUMeter/CPUMeter.xcodeproj` | Project, made from DriveSpeed's | 0.1 |
| `CPUMeterApp.swift` | `Window` scene, title, menus, the size and Keep on Top settings | 0.1 |
| `WindowAccess.swift` | The one place CPUMeter reaches its window: level, staying on screen, and snapping until 5.4, then its shape and size limits, and from 5.7 where the green button takes it | 0.2, 5.4, 5.7 |
| `MeterSize.swift` | The three sizes and the snap rule, testable on their own; from 5.4, the presets as scales and the saved scale; from 5.7, where a press of the green button takes the window | 0.3, 5.4, 5.7 |
| `CoreCounters.swift` | Counter read and wrapping tick change | 1.1 |
| `CoreTopology.swift` | Core groups, names and order; the fallback | 1.2 |
| `CPUSampler.swift` | Timer, refresh rates, baseline, percentages, pause and resume | 1.3 |
| `MeterLayout.swift` | The width rule and the design document's numbers, Small's alone from 5.4 | 2.1, 5.4 |
| `MeterView.swift` | The meter's drawing: `Canvas` until 5.3, then Core Animation layers | 2.2, 5.3 |
| `SimulatedCores.swift` | Other core counts, Debug builds only | 2.4 |
| `BarColors.swift` | Chosen colors and the system color chooser | 3.3 |
| `Assets.xcassets/AppIcon` | App icon, from Chris's artwork | 5.1 |
| `design/AllIcons.jpeg` | Chris's original icon sheet, which the AppIcon images are cut from | 5.1 |
| `README.md` | Rewritten once the app exists | 5.8 |
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
- **Plan agreed with Chris (Nov 5, 2026):** no new files. One function forms every label, "Name: 24%" or "Name: –", for both the width rule and the drawing, and the top row uses it too, as "All cores: 42%". At each size the width is worked out with the full names and again with "Perf", and "Perf" is kept only where it gives a narrower window. A group's label is part of the layout only when the row is labeled, so the fallback row has none.
- **Result, Claude's checks (Nov 5, 2026):**
  - `CPUSampler`: each sample also holds each group's average, from that group's summed raw ticks, through the same function as the overall figure. A core ID past the end of the read is skipped.
  - `CoreTopology`: `CoreGroup` no longer forms the " %" label. Each name stays exactly as macOS gives it, and the fallback row's "Cores" is never shown.
  - `MeterLayout`: the label text, labels measured at their widest ("Name: 100%") with monospaced digits, FR-8e's "Perf", and the unlabeled fallback row, whose bars start where the label would be.
  - `MeterView`: system time at the bottom of each bar and user time above it, with the 1 pt gap out of the user part; the key reading System, User; the top row reading "All cores: 42%"; and each label showing its group's average in monospaced digits.
  - `CPUMeterApp`: the fallback row is built without labels.

  Two test drivers compile the real files under Swift 6 with no warnings.
  - The layout, 19,126 checks, all pass:
    - **all 57 widths match requirements §6 v1.10,** both with design §7's figures and with live AppKit measurement. 11 differ from 2.2's, as §6 marks them. Live measurement matches design §7's label widths to three decimals;
    - **"Perf" appears in exactly three places:** the MacBook Neo at Small and Medium, and the 10-core M4 and M5 at Small. At each, "Performance" would have made the window wider. No other name changes;
    - at every layout and size, every label at its widest fits its group. The tightest is "Efficiency: 100%" on the 8-core M1 Pro and the 16-core M3 Max and M4 Max at Small, with 0.012 pt spare;
    - "All cores: 100%" and the key fit the top row everywhere, leaving 27.3, 114.2 and 196.0 pt at the base widths, as design §7 says;
    - names in other words and languages, such as German and Japanese ones, show unchanged, and the window widens to fit them (FR-8a);
    - the fallback row at all 15 core counts: no label, bars 89, 152 and 215 tall, ending where labeled bars end, and widths from the minimum width per core alone;
    - this Mac: 246 × 150, 360 × 225 and 480 × 300. The labels are "Efficiency" and "Perf" at Small, and "Efficiency" and "Performance" at Medium and Large. "Perf: 100%" has 27.7 pt spare at Small, and "Performance: 100%" 19.3 at Medium;
    - `Canvas` at scale 1.0 draws every label at its widest inside its group, at every layout and size. At the tightest, "Efficiency: 100%" ends at 84 in the M1 Pro's 84.50, although `Canvas` measures it as 85.
  - The drawing, 14,554,734 geometry checks, all pass, at all 19 layouts and two fallback rows, at all three sizes, at scales 1 and 2:
    - every reading in steps of 0.25%, on the labeled bars and the fallback row's taller ones: the top of the bar is within half a pixel of the total, the system part sits at the base within half a pixel of its share, the gap comes out of the user part, and a user part too thin for the gap touches the system part;
    - the text: "All cores: –", "All cores: 42%", "Efficiency: –", "Perf: 13%", "Performance: 100%" and the figures;
    - **group averages from raw ticks:** with uneven tick totals, a Performance average of 30.28% from the ticks, where a mean of the per-core shares would give 35.32%; requirements §8 item 25's example, where 24% and 13% give 20% overall; a group with no ticks shows the dash; uneven groups of 1, 5 and 3 cores; and the fallback row's average equal to the overall figure.
  - The real view rendered at scale 1.0 on the M4's layout, in Dark and Light, at all three sizes: no reading yet, mixed readings, full load, a row of edge cases, and the fallback row with and without a reading. Claude inspected each. 664 pixel checks pass:
    - every bar's edges are sharp, in exactly the system blue or orange;
    - each mixed bar is orange at its base and blue at its top;
    - the key's orange dot is left of its blue one;
    - at full load, 33, 113 and 196 clear pixel columns separate "All cores: 100%" from the key;
    - every label's text stays inside its group at full load;
    - the fallback row's taller track starts where the label would be.
  - Debug and Release clean builds, with no compiler warnings.
  - The Release app on the M4, with Chris's settings saved first and restored after:
    - 246 × 182, 360 × 257 and 480 × 332 with the title bar, at Small, Medium and Large, at Keep on Top's level, with the top-left corner in place;
    - no console output;
    - **CPU use:** about 0.65% of one core at Small and at Large, from the process's CPU time over 60 and 120 seconds. A build of 2.2 run the same way, twice each, alternating, used the same, so 2.3 adds nothing. `ps`'s `%cpu` reads 0.0–0.1 for about the first 25 seconds after launch, so 2.2's 10 one-second samples understated it. Increment 5.2 measures it over an hour.
  - Not covered by Claude's checks: the text in the real window, and the test loads.
- **Result, Chris's test (Nov 5, 2026):** run from Xcode on the M4 at all three sizes, in Dark and Light, with every check in the list above. Everything looked exactly as predicted and expected. **Confirmed by Chris** (Nov 5, 2026). No M1 pass for 2.3; Phase 2's is in 2.4.

### Increment 2.4 — Other core counts
- **Goal:** See every Mac in the requirements' table, drawn by the real code. (FR-3b, FR-8a, FR-8c, FR-8e, FR-11)
- **Build:** `SimulatedCores.swift`, compiled only in Debug builds: a launch argument such as `-simulateCores Performance:24,Super:12` replaces the detected groups and feeds them synthetic ticks.
- **Verify:** Claude renders all 19 core layouts at all three sizes as a contact sheet and inspects it for overlaps, clipping and figures running together. Chris spot-checks 36 cores, the fallback row and the MacBook Neo, with its "Perf" at Small and Medium, in the real window. A check of the Release binary confirms the simulation code isn't in it.
- **Done when:** Every configuration is clean, and Release has no simulation code. **Completes Phase 2**, including the M1 pass. This is the limit of what can be tested above 10 cores, and the README will say so.
- **Plan agreed with Chris (Nov 5, 2026):** Xcode's Run uses Release, so Chris runs the spot checks from Terminal, on a Debug build Claude makes, with commands that save Chris's settings first and restore them after. The argument lists the groups left to right, such as `-simulateCores Efficiency:4,Performance:2`, with each name exactly as typed. A bare count, such as `-simulateCores 10`, gives the unlabeled fallback row. `-simulateLoad full` puts every core at 100%; otherwise a pattern moves across the bars. Only the core groups and the counter read are replaced: the made-up counters go through the app's own sampling.
- **Result, Claude's checks (Nov 5, 2026):**
  - `SimulatedCores.swift`, all inside `#if DEBUG`: the launch arguments, the simulated groups, and made-up counters at 100 ticks per core per read. The moving pattern is a wave that crosses the bars every 20 reads, on a level that rises and falls every 30, with system time 10–40% of each core's busy time. The counters start just below the 32-bit limit, so they wrap within seconds, and FR-16's wrapping subtraction runs in the live path too. A malformed argument prints why, and the app shows the Mac's own cores.
  - `CPUSampler`: in a Debug build with a simulation, the simulated groups replace the detected ones, and `start()` and `tick()` read the simulated counters, through one `readCounters()`. In Release, that function is `CoreCounters.read()` alone.
  - A test driver compiles the real files with `DEBUG` under Swift 6 with no warnings. 3,463,960 logic checks pass:
    - the 19 layouts' arguments, the fallback row, and names with spaces or in other languages give exactly the groups they name. 13 malformed values and 5 malformed combinations of arguments are refused, each with its reason;
    - every read gives each core exactly 100 ticks, at every core count from 1 to 64 over 600 reads. The moving pattern reaches 0, 100 and every figure between, and full load reads 100 on every core, every group and overall;
    - through the real counters and sampling, each figure equals its ticks exactly, across the wrap. The overall figure moves between 30% and 70%, and the group averages differ by up to 75 points;
    - **all 57 widths match requirements §6 v1.10** through the simulation, with live measurement, and "Perf" appears in exactly FR-8e's three places. The fallback row is 240, 360 and 480 wide at 10 cores, and 780, 856 and 932 at 36.
  - **The contact sheets:** the 19 layouts, plus the fallback row at 10 and 36 cores and German and Japanese names, drawn by the real `MeterView` at scale 1.0, at all three sizes, in Dark and Light, at full load and with the moving pattern: 48 sheets. Claude inspected every full-load sheet in Dark, and samples of the moving pattern and of Light: no overlaps, no clipping, and no figures running together. 7,752 pixel checks pass:
    - nothing is drawn in the margins, so nothing is cut off at the window's edges;
    - at full load, every bar is blue at its top and orange at its base;
    - at full load, neighboring figures are at least 3 clear pixel columns apart at Small and Medium, and 4 at Large;
    - every label's ink stays within its group. The tightest is "Efficiency: 100%" on the 8-core M1 Pro at Medium, whose ink ends exactly at the group's edge;
    - the top row keeps at least 27, 113 and 196 clear columns between "All cores: 100%" and the key.
  - Debug and Release clean builds, with no compiler warnings. **The Release binary has no simulation code:** none of the simulation's text, such as `simulateCores` or its messages, and no `SimulatedCores` symbols. The Debug build has both, which shows the check would find them.
  - The running apps on the M4, with Chris's settings saved first and restored after:
    - the Debug build at 36 cores is 792 × 182, 870 × 257 and 948 × 332 with the title bar, at both loads. The MacBook Neo and the 10-core fallback row are 240, 360 and 480 wide. Each run prints one line naming the simulation;
    - with a malformed argument, the Debug build prints why and shows the M4: 246, 360 and 480 wide;
    - the Release build ignores the argument: 246, 360 and 480 wide, with no console output.
  - Not covered by Claude's checks: the real window with simulated cores, and the M1.
- **Result, Chris's test (Nov 5, 2026):** on the M4, the Debug build run from Terminal: 36 cores with the moving pattern and at full load, the MacBook Neo, and the 10-core fallback row, at all three sizes. On the M1, the Release build `CPUMeter-2.4-48d9c66-dirty.zip`, with "Efficiency" and "Performance" in full at all three sizes, under the test loads. Chris: "All tests pass perfectly." **Confirmed by Chris** (Nov 5, 2026), completing Phase 2.

---

## Phase 3 — Controls

### Increment 3.1 — Size shortcuts
- **Goal:** ⌘1, ⌘2 and ⌘3 choose Small, Medium and Large, exactly as View → Size does. (FR-3, FR-22, FR-24a)
- **Build:** The three items in View → Size get ⌘1, ⌘2 and ⌘3, which the menu shows. A shortcut sets the same remembered size as the menu, so the window keeps its top-left corner and stays on screen. *(Added at Chris's request on Nov 5, 2026, after 2.4's checks switched sizes many times.)*
- **Verify:** Headless, in the running app: View → Size's items carry ⌘1, ⌘2 and ⌘3, with the current size checked; no other menu item uses those shortcuts; and each shortcut, sent through the app's menus, gives the right window size with the top-left corner in place, and still keeps the window on screen near the screen's right edge. Chris, on the M4 from Xcode: the menu shows the shortcuts, each one switches size, the checkmark follows, and they work with Keep on Top on and off.
- **Done when:** Chris confirms the shortcuts on the M4. No M1 pass; Phase 3's is in 3.3.
- **Result, Claude's checks (Nov 5, 2026):**
  - Before any app code changed, a throwaway probe confirmed that a shortcut on each option of a SwiftUI menu picker reaches AppKit's menu as ⌘1, ⌘2 and ⌘3, with the current option checked.
  - `CPUMeterApp.swift`: each option in View → Size's picker gets its key from a private `MeterSize.shortcutKey`, so a shortcut sets the same remembered size as choosing from the menu. The other changes are comments, renumbered for 3.2 and 3.3.
  - Debug and Release clean builds, with no compiler warnings.
  - The running Debug app on the M4, with Chris's settings saved first and restored after, and each keystroke sent through the app's own menus with the debugger:
    - View → Size's items carry ⌘1, ⌘2 and ⌘3, Command only, with the current size checked. No other menu item uses those shortcuts.
    - From Small with its top-left corner at (66, 180), ⌘2, ⌘3 and ⌘1 gave 360 × 257, 480 × 332 and 246 × 182 with the title bar. The top-left corner stayed in place, and the saved size followed each time.
    - At Small with its top-left corner 250 points from the screen's right edge, ⌘3 moved the window left to x 2080, so all 480 points stayed on screen (FR-22).
    - With Keep on Top off, at the normal window level, ⌘1 and ⌘2 still worked.
    - SwiftUI updates the checkmarks when the menu is about to open. After a shortcut, the menu's stored check still showed the old size, and once the menu was updated as it is on opening, the new size was checked.
  - The Release app: 246, 360 and 480 wide from the saved size, with no console output.
  - Not covered by Claude's checks: keystrokes typed on the keyboard, and the menu as it opens on screen.
- **Result, Chris's test (Nov 5, 2026):** run from Xcode on the M4. View → Size shows the shortcuts. ⌘1, ⌘2 and ⌘3 each switch size with the top-left corner in place, and the checkmark follows. They work with Keep on Top on and off, and a relaunch keeps a size chosen with a shortcut. Chris: "All pass." **Confirmed by Chris** (Nov 5, 2026). No M1 pass for 3.1; Phase 3's is in 3.3.

### Increment 3.2 — Refresh Rate
- **Goal:** All five rates work and take effect immediately. (FR-18, FR-18a, FR-18b, FR-18c, FR-18d, FR-24)
- **Build:** **View → Refresh Rate** with 1–5 seconds, stored with `@AppStorage`. On a change, the next update comes at once, measured from the last update, or 1 second after the last update if that's later. Updates then follow at the new rate. A change doesn't read a new baseline. *(Revised Nov 5, 2026, for requirements v1.12. The first version restarted the interval and read a new baseline.)*
- **Verify:** Headless: the timer interval and tolerance at each rate, and the update after each change: at once when the last update was at least 1 second ago, otherwise when that second is up, and never later than 1 second after the change, even after several changes in a row. Chris: the bars visibly slow at 5 seconds, the meter updates within a second of a change with no false spike, the choice survives a relaunch, and the bars keep updating while the menu is open.
- **Done when:** All of FR-18 is observed.
- **Result, first version, Claude's checks (Nov 5, 2026):**
  - `CPUSampler.swift`: `RefreshRate`, the five rates, saved by their number of seconds, with their menu names. A saved number that isn't one of them gives 1 second. `start()` runs the timer at the current rate with a tenth of the interval as leeway. `setRate(_:)` restarted the timer and read a new baseline.
  - `CPUMeterApp.swift`: View → Refresh Rate, under Size, with 1 second to 5 seconds and no shortcuts, saved with `@AppStorage("refreshRate")`, 1 second at first launch. The window starts sampling at the saved rate, and a change tells the sampler.
  - Debug and Release clean builds, with no compiler warnings.
  - The running Debug app on the M4, with Chris's settings saved first and restored after, and every update and counter read timed with debugger breakpoints:
    - every update came on schedule at all five rates, within the timer's leeway;
    - a change restarted the timer and read a new baseline within about 10 ms, and no update came at the old rate after it;
    - no saved rate, and an unknown value (9), gave 1 second, both while running and at launch. A relaunch with 4 seconds saved ran at 4 seconds;
    - View holds Size, Refresh Rate, a divider and Keep on Top. Refresh Rate lists 1 second to 5 seconds with no shortcuts and the saved rate checked, and the check follows a change.
  - The Release app: 0.62% of one core at 1 second and 0.20% at 5 seconds, from one 60-second sample each. Part of its CPU use doesn't depend on the rate. No console output.
- **Result, first version, Chris's test (Nov 5, 2026):** on the M4 from Xcode, every check passed. Chris then pointed out that a change restarted the wait for the next update, so going from 1 to 5 seconds left the meter still for 5 seconds, and a string of changes could hold it still indefinitely. Chris asked for an update at the change. Claude suggested a 1-second minimum, so no reading comes from a handful of ticks, and Chris agreed: requirements v1.12, FR-18d.
- **Result, revised, Claude's checks (Nov 5, 2026):**
  - `CPUSampler.swift` only: the sampler notes when its baseline was read, on the Mac's uptime clock. A change replaces the timer but keeps the baseline. Its first update comes after `waitAfterRateChange(sinceLastRead:)`, 1 second less the time since the last read, or at once if that's past, with no leeway. Later updates follow at the new rate, with the usual leeway.
  - Debug and Release clean builds, with no compiler warnings.
  - A test driver compiles the real `CPUSampler.swift` under Swift 6 with no warnings. 40,051 checks pass:
    - the five rates, their names, and no rate for 0, 6, 9 and other numbers;
    - the wait for every time since the last read from −2 to 8 seconds, in 0.5 ms steps;
    - a live sampler on the M4's counters, with changes at set moments after an update: 0.002, 0.05, 0.5, 0.99 and 1.5 seconds after, three changes within 0.6 seconds, and a change soon after a change's own update. Each change's update came within 1.008 seconds of the change and covered at least 1.001 seconds, and came at once when a second had already passed. The few milliseconds past 1 second are the run loop's own delay. Updates then followed at the new rate, on schedule. Choosing the same rate changed nothing, and a change while stopped took effect at the next start.
  - The running Debug app, timed with debugger breakpoints, with Chris's settings saved first and restored after: eight changes at set moments after an update, including three within 0.7 seconds. Each change's update came within 0.9 seconds of the change and covered at least 1.018 seconds; the breakpoints add a few milliseconds to each. No change restarted sampling or read a new baseline. No saved rate, and an unknown value, gave 1 second, and a relaunch kept 4 seconds.
  - The Release app: no console output.
- **Result, revised, Chris's test (Nov 5, 2026):** on the M4 from Xcode: the meter updates within about a second of a change and then at the new rate, quick changes don't hold it still, the bars keep updating while the menu is open, and a relaunch keeps the rate. Chris: "All pass." **Confirmed by Chris** (Nov 5, 2026). No M1 pass for 3.2; Phase 3's is in 3.3.

### Increment 3.3 — Colors
- **Goal:** Both colors can be changed with the system chooser. (FR-24, FR-28, FR-28a, FR-28b, FR-28c, FR-28d, FR-28e, NFR-5)
- **Build:** `BarColors.swift` and **View → Colors**: System Color…, User Color… and Reset to Defaults, in the key's order. `NSColorPanel` opens set to the current color and titled with which one is changing, with its opacity control hidden. Chosen colors are stored as sRGB values. With none stored, the adaptive system colors apply.
- **Risk:** With Keep on Top on, the chooser could open behind CPUMeter, or the app might not quit with the chooser open. Both are checked explicitly. Also, File → Close (from 0.2) closes the meter's window by name, so ⌘W with the chooser in front may quit the app instead of closing the chooser. Check it here, and fix it if so.
- **Verify:** Chris's checklist:
  - The bars and key change as a color is picked, between refreshes.
  - The chooser is reachable with Keep on Top on.
  - Colors survive a relaunch and stay as picked when the appearance changes.
  - Reset restores both colors, and the defaults adapt to appearance again.
  - Closing the window quits even with the chooser open.
- **Done when:** The checklist passes. Takes **Phase 3's M1 pass**.
- **Result, Claude's checks (Nov 6, 2026):**
  - `BarColors.swift`, new:
    - `BarPart`: System, then User, with their menu and chooser titles, the saved keys `systemColor` and `userColor`, and their defaults.
    - `ColorHex`: saves a color as "#RRGGBB" in sRGB, clamped, with opacity dropped, and reads back only that form. Anything else gives the default.
    - `BarColors`: loads the saved colors at launch, saves each pick, and shows the color as saved, so a relaunch looks the same. Reset removes both.
    - It opens `NSColorPanel` set to the current color, titled "System Color" or "User Color", with no opacity control. Picks arrive while dragging, and the chooser sits one window level above Keep on Top's.
    - Setting the chooser's color while it has a target counts as a pick, so the chooser's color is set with its target detached.
  - `MeterView.swift`: `MeterView` takes the chosen colors, and `MeterColors.standard(for:chosen:)` uses them in the bars and the key, or the adaptive defaults.
  - `CPUMeterApp.swift`:
    - View → Colors, after Refresh Rate: System Color…, User Color…, a separator and Reset to Defaults.
    - Only the meter view reads the colors, so a pick redraws only the meter.
    - Closing the meter closes the chooser. File → Close (⌘W) closes the chooser when it's in front.
  - Debug and Release clean builds, with no compiler warnings.
  - A test driver compiles the real code under Swift 6 with no warnings. 3,451,500 checks pass:
    - 637,080 round trips through the saved form. Display P3 colors are converted, not relabeled: within half a step inside sRGB, and clamped outside it. Gray, extended-range and translucent colors are handled too, and 23 malformed values give the defaults;
    - loading, saving and Reset against a throwaway settings domain;
    - the chooser in a test process: its title, opacity control, level and starting color, picks, switching colors, Reset while open, and no picks after closing;
    - the meter drawn at all three sizes in Dark and Light. The bars and the key's dots are exactly the chosen colors, the same in both appearances, and nothing else changes. The defaults match the system's colors in each appearance, and chosen colors equal to the defaults draw identically.
  - On macOS 27, the system colors are #0091FF and #FF9230 in Dark and #0088FF and #FF8D28 in Light, not the values in the UI design's §4 table. The app uses the system colors (FR-28a).
  - The running Debug app on the M4, with Chris's settings saved first and restored after:
    - View → Colors lists the four items in order. The chooser opens titled, with no opacity control, at level 4, above the kept-on-top meter's 3, and stays in front when the meter is clicked;
    - picks are saved. Opening the chooser and switching colors aren't picks. Reset clears both, and the open chooser shows the default;
    - ⌘W with the chooser in front closes only the chooser. The app quits when the meter closes with the chooser open, by ⌘W or by the close button. A relaunch keeps the colors and opens the chooser on them;
    - at 5 seconds, timed with debugger breakpoints, three picks and a Reset each redrew the meter within 26 ms, between updates 4.85 seconds apart. The rest of the window wasn't redrawn.
  - The Release app: no console output.
- **Result, Chris's test (Nov 6, 2026):** the checklist, on the M4 from Xcode, and Phase 3's M1 pass from a Release build (`CPUMeter-3.3-db3f893-dirty.zip`): the size shortcuts, refresh rates and colors. Chris: "All tests pass on both Macs." **Confirmed by Chris** (Nov 6, 2026). **Phase 3 is complete.**

### Increment 3.4 — Keyboard shortcuts
- **Goal:** ⌘1 to ⌘5 choose 1 to 5 seconds, and ⇧⌘S, ⇧⌘M and ⇧⌘L choose Small, Medium and Large, exactly as their menus do. (FR-18e, FR-24a, FR-3, FR-22)
- **Build:** View → Refresh Rate's five items get ⌘1 to ⌘5, and View → Size's three items change from ⌘1, ⌘2 and ⌘3 to ⇧⌘S, ⇧⌘M and ⇧⌘L. The menus show them. A shortcut sets the same remembered setting as its menu item, so a new size keeps the window's top-left corner and stays on screen, and a new rate takes effect as FR-18d says. *(Added at Chris's request on Nov 6, 2026, after 3.3.)*
- **Verify:** Headless, in the running app:
  - View → Refresh Rate's items carry ⌘1 to ⌘5, and View → Size's carry ⇧⌘S, ⇧⌘M and ⇧⌘L, with the current choice checked;
  - no other menu item uses any of them, and Window → Minimize keeps ⌘M;
  - each shortcut, sent through the app's menus, sets the right rate or size, and a size keeps the top-left corner in place.

  Chris, on the M4 from Xcode: the menus show the shortcuts, each one works and the checkmark follows, ⌘M still minimizes, and a relaunch keeps a rate and a size chosen with shortcuts.
- **Done when:** Chris confirms the shortcuts on the M4. No M1 pass: shortcuts work the same on every Mac, and Phase 3's M1 pass was in 3.3. **Ends Phase 3.**
- **Result, Claude's checks (Nov 6, 2026):**
  - `CPUMeterApp.swift` only: each option in View → Refresh Rate's picker gets ⌘1 to ⌘5 from a private `RefreshRate.shortcutKey`, its number of seconds. `MeterSize.shortcutKey` is now "s", "m" and "l", used with `modifiers: [.command, .shift]`. A shortcut sets the same remembered setting as its menu item. The other changes are comments.
  - Debug and Release clean builds, with no compiler warnings.
  - The running Debug app on the M4, with Chris's settings saved first and restored after, and each shortcut sent through the app's menus:
    - View → Refresh Rate's items carry ⌘1 to ⌘5, Command only, and View → Size's carry ⇧⌘S, ⇧⌘M and ⇧⌘L, with the current choice checked. No two menu items share a shortcut, and Window → Minimize keeps ⌘M;
    - from Medium with its top-left corner at (72, 56), ⇧⌘L, ⇧⌘S and ⇧⌘M gave 480 × 332, 246 × 182 and 360 × 257 with the title bar. The top-left corner stayed in place, and the saved size followed each time;
    - ⌘5, ⌘3, ⌘2, ⌘4 and ⌘1 each saved their rate, and the checkmarks followed;
    - ⌘S and ⌘L without Shift did nothing. ⌘M minimized the meter and left its size alone;
    - a relaunch kept Large and 5 seconds, checked in the menus.
  - Key events built by hand with `keyEventWithType:` gave false results for letters: ⌘M chose Medium instead of minimizing, and ⇧⌘ letters did nothing. A real ⇧⌘M has the characters "m" with "M" ignoring modifiers, which the hand-built events didn't. Every check above was then rerun with events built as the system builds a key press, from the key code and the keyboard layout, and the results above are from that run.
  - The Release app: no console output.
  - Not covered by Claude's checks: keystrokes typed on the keyboard, and the menus as they open on screen.
- **Result, Chris's test (Nov 6, 2026):** run from Xcode on the M4. The menus show the shortcuts, each one works and the checkmark follows, a size shortcut keeps the top-left corner in place, ⌘M still minimizes, and a relaunch keeps a rate and size chosen with shortcuts. Chris: "All pass." **Confirmed by Chris** (Nov 6, 2026). **Phase 3 is complete.**

---

## Phase 4 — Robustness

### Increment 4.1 — Pause when not visible
- **Goal:** No sampling or drawing while the window can't be seen, and no false reading after. (FR-17, NFR-4)
- **Build:** Observe `NSWindow.didChangeOcclusionStateNotification`. Stop the timer when the window isn't visible, and prime the baseline again on resuming. The first update comes 1 second after resuming, then updates follow at the chosen rate (FR-17, v1.14). A temporary per-tick line shows whether sampling is running.
- **Verify:** Chris minimizes the window, fully covers it with Keep on Top off, and sleeps the display, then returns each time. The output must show no ticks during the pause and no spike in the first one after. To sleep the display:

  ```bash
  pmset displaysleepnow
  ```

- **Done when:** Ticks stop in all three cases and resume cleanly. Any case macOS doesn't report gets recorded here, not worked around quietly. The temporary line is removed.
- **Result, Claude's probe (Nov 6, 2026):** before writing code, a small test app on the M4 logged what macOS 27 reports through `NSWindow.didChangeOcclusionStateNotification`:
  - a window reads as not visible until it's first ordered on screen, and the first "visible" notice comes about 45 ms after it's shown. So the sampler assumes the window can be seen until the first notice says otherwise, rather than reading the state when the window is found;
  - minimizing reports not visible about 0.57 s after the call, once the animation ends, and restoring reports visible about 0.54 s after;
  - covering the window fully reports not visible in about 33 ms, and uncovering reports visible in about 32 ms. A window only half covered sends no notice and stays visible;
  - hiding the app reports not visible in about 31 ms, and showing it reports visible in about 27 ms.
- **Result, Claude's checks (Nov 6, 2026):**
  - `WindowAccess.swift` observes the notice for its window and passes on `occlusionState.contains(.visible)`. `CPUSampler.swift` keeps whether it's started and whether the window can be seen. While the window can't be seen, the timer is stopped. When it can be seen again, the sampler reads a new baseline at once and the first update comes exactly 1 second later, then updates follow at the rate. A rate chosen while hidden takes effect then. `CPUMeterApp.swift` connects the two.
  - Debug and Release clean builds, with no compiler warnings, both with the temporary lines and after they were removed.
  - The running Debug app on the M4 at 1 second, with Chris's settings saved first and restored after, timed with the debugger. The full cover came from a second app, an opaque window one level above floating. Each case was run with the temporary lines and again after they were removed, with the same results:
    - minimizing: the pause began 0.70–0.73 s after the call. Restoring: sampling resumed 0.54–0.55 s after;
    - a full cover: the pause began 14–25 ms after it, and sampling resumed 37–38 ms after uncovering;
    - hiding the app: 45–51 ms. Showing it again: 41–50 ms. A change to 3 seconds while hidden read nothing and drew nothing;
    - while hidden, no reads, updates or redraws in any case;
    - each resume read a new baseline at once, and the first update came 1.01 s later, covering 1.02 s, with figures in line with those before the pause. Later updates came at the rate: every second, or, after the change to 3 seconds, 3.30 s and then 3.00 s apart;
    - choosing 1 second again while the meter could be seen updated it at once, as FR-18d says, 2.66 s after the last read, then every second;
    - the meter redrew once per update and not on resuming.
  - The Release app at 2 seconds, covered fully by the second app for 5 s: paused 24 ms after the cover, resumed 20 ms after uncovering, and the first update came 1.00 s later, then at 2.12 s and 2.08 s. After the temporary lines were removed, the Release app printed nothing.
  - The first two readings after the debugger attached covered 6.76 s and 0.23 s. The debugger stops the app while it attaches, and the repeating timer then keeps its original schedule. That's the debugger, not the app.
  - Not covered by Claude's checks: display sleep, and minimizing, covering and hiding done by hand.
- **Result, Chris's test (Nov 6, 2026):** run from Xcode on the M4, watching the temporary lines in the console. Chris minimized and restored the meter, covered it fully with Keep on Top off and uncovered it, partly covered it, hid and showed the app, and slept and woke the display with `pmset displaysleepnow`. Each time the lines showed the pause, no updates while the meter couldn't be seen, the resume, and a first update about 1 second later with no spike. A partly covered meter kept updating. macOS reported every case, display sleep included, so nothing is recorded as unreported. Chris: "All pass." The temporary lines were then removed. **Confirmed by Chris** (Nov 6, 2026). No M1 pass; Phase 4's is in 4.2.

### Increment 4.2 — Failures, sleep and needless redraws
- **Goal:** It stays sensible when things go wrong, and doesn't redraw when nothing changed. (FR-8c, NFR-1, NFR-4)
- **Build:** The sampler publishes only when a displayed value changes, compared at whole percentages for each core's user and system time, each group's average and the overall figure. A failed read keeps the zero state. A changed core count primes the baseline again and recalculates the width.
- **Verify:** Headless: a failed read, zero ticks, a core count that changes between reads, identical samples that publish nothing, and a core-type mismatch reaching the unlabeled fallback row. Chris: put the whole Mac to sleep, wake it, and confirm no false spike.
- **Done when:** All pass with no crash. **Completes Phase 4**, including the M1 pass.
- **Result, Claude's checks (Nov 6, 2026):**
  - `CPUSampler.swift` works out what the meter would show from each update: the whole percents of each core's figure and its user and system parts, each group's average, and the overall figure. It publishes the update only when those differ, so an unchanged meter isn't redrawn (NFR-1). What each read leads to comes from one function that can be checked on its own:
    - a failed read shows the zero state, with dashes, and keeps the baseline;
    - a reading shorter than 0.5 s is folded into the next. A repeating timer that fires late, after the app stalls or the Mac wakes, keeps its schedule, so its next firing can come a fraction of a second later, and a reading that short could show a false spike;
    - a read with a different number of cores from the groups reads the core groups again, starts a new baseline and shows dashes once;
    - any other read is an update.
  - `CoreTopology.swift` gives the number of cores the groups cover. `MeterLayouts` is worked out from the core groups, and `CPUMeterApp.swift` works it out again when they change. `WindowAccess.swift` then gives the window its size's new width with the top-left corner in place, and keeps it on screen (FR-3b, FR-22).
  - The Debug build's simulation gained `-simulateCoreChange`, which switches to a second set of cores after 5 updates.
  - Debug and Release clean builds, with no compiler warnings, both with the temporary lines and after they were removed.
  - A headless test of the app's own files, 63 checks, passing with the temporary lines and after they were removed:
    - what a read leads to: a failed read, zero ticks, a changed core count, no baseline, and spans just under, at and over 0.5 s;
    - the shown figures and what counts as a change;
    - a core-type mismatch and a core-count mismatch each reaching the unlabeled fallback row (FR-8c);
    - the widths for a changed core count;
    - the simulation's new argument.
  - The real sampler on simulated cores, 3 checks, passing both times: a steady load publishes once; the short reading after a 1.5 s stall is folded into the next; and 6 cores changing to 18 reads the groups again, shows dashes once, then the 18 cores.
  - The running app on the M4, with Chris's settings saved first and restored after:
    - a moving simulated load: 15 updates, 15 redraws. A steady one: 15 updates, no redraws, and no rebuilding of the meter's view;
    - 6 cores changing to 18 at Medium: the window went from 360 to 456 wide, its top-left corner stayed at (72, 56) and View → Size still read Medium. The same change at the screen's right edge moved the window left just enough to stay on screen;
    - 18 cores changing to 10 of unknown type at Large: the unlabeled row, 498 to 480 wide;
    - the Release app stopped four times for 1.2 to 1.95 s: the readings of 0.40 s and 0.41 s that followed were folded into the next. One of 0.51 s was shown, and none under 0.5 s.
  - After the temporary lines were removed, the Release app ran for 70 s at Large and 1 second, with Chris's settings saved first and restored after. It opened at the saved size and position, printed nothing, and used 0.30 s of CPU time between 10 s and 70 s, about 0.5% of one core. Neither the Release app nor the Debug build contains the temporary lines' text.
  - Not covered by Claude's checks: sleeping the whole Mac, and the M1.
- **Result, Chris's tests (Nov 6, 2026):**
  - **M4, sleep,** run from Xcode with temporary console lines: Apple menu → Sleep for about 99 s, then wake.
    - macOS put the app to sleep without first saying the window was hidden, so there was no pause line before sleep. Nothing runs while the Mac sleeps, so nothing was sampled.
    - The reading that spanned sleep covered 3.21 s, because the clock the sampler times readings with and the CPU tick counters both stop while the Mac sleeps. It showed 3%, so there was no false spike.
    - The next reading showed 94% over 0.85 s, then 54, 30, 29 and 24% over the following seconds: macOS's own work on waking, fading as real load does.
    - A pause, then a resume 4 seconds later, most likely the lock screen covering the meter until Chris unlocked. The first update came 1.00 s after the resume (FR-17).
    - No reading under 0.50 s was shown.
    - The console also showed macOS's own messages, none from CPUMeter: a refusal by the App Sandbox to name WindowServer's process, and display messages from Core Animation and AppKit at wake.
  - **M4, a simulated core change,** from Terminal with Chris's settings saved and restored: 6 cores became 18 after 5 updates, with dashes for one update. The window widened at the same size with its top-left corner in place. Chris: "All pass."
  - **M1,** the Release build with temporary console lines, on macOS 27.0.1: minimize and restore, a full cover with Keep on Top off, hide and show, and sleep and wake. The M1 had restarted after an unrelated crash before the check, before the 4.2 build was opened. Chris: "I finished the M1 testing and everything passes."
  - The temporary lines were then removed. **Confirmed by Chris** (Nov 6, 2026). **Phase 4 is complete**, with its M1 pass.

---

## macOS 27.2 recheck

Phases 0–4 were confirmed on macOS 27.0.1. After Increment 4.2, Chris updated both Mac minis to macOS 27.2 and opened Xcode once. Rather than repeat every manual test, Claude reran the automated checks on the M4, and Chris did a short manual pass on each Mac covering what Claude can't drive. The minimum OS stays 27.0. *(Chris's plan, Nov 6, 2026.)*

- **Result, Claude's checks (Nov 6, 2026),** on the M4 with macOS 27.2 (26B123) and Xcode 27.2 (27B52), with Chris's settings saved first and restored after every run of the app. No app code changed.
  - Debug and Release clean builds of `4d1baf8`, with no compiler warnings.
  - The saved test drivers, compiled with the app's current files, give the same results as on 27.0.1. Six needed small changes for later increments, such as `MeterView`'s chosen colors, and the 1.2 driver's check of the " %" label, which 2.3 removed, was dropped.
    - counters (1.1): all pass, at 3.42 µs per read, with memory and the host port's references flat over 100,000 reads;
    - core types (1.2): Efficiency 0–5, then Performance 6–9, the 21 remaining fixture checks, and memory and ports flat over 100,000 reads;
    - sampling (1.3): 26 pass. Updates came 1.000 s apart, and the timer still fires while a menu is open;
    - the snap rule (0.3): 19 pass;
    - layout (2.3): 19,126 pass, including all 57 widths in §6 of the requirements;
    - drawing (2.3): 14,555,398 pass. The system blue and orange are unchanged in both appearances;
    - simulated cores (2.4): 3,471,712 pass;
    - refresh rates (3.2): 40,051 pass;
    - colors (3.3): 3,451,500 pass;
    - 4.2's checks: 63 and 3 pass;
    - all 86 rendered images, rendered on their own, are byte-identical to those made on 27.0.1. When a driver renders after its other checks in the same process, a few text-edge pixels in Dark differ by one step out of 255 from its own render-only run, so that comes from the order of the checks, not from macOS 27.2.
  - The running app:
    - **menus and shortcuts,** as in 3.4: the same, item for item. Every shortcut and checkmark matches. The size shortcuts keep the top-left corner, ⌘S and ⌘L without Shift do nothing, ⌘M minimizes, and a relaunch keeps the size and rate;
    - **sizes:** 246, 360 and 480 wide. Drags simulated as in 2.1 settle at the expected sizes: Small's right edge out to 380 at Medium, the bottom edge down to 300 at Large, and the right edge in to 250 at Small. The green button zooms to Large and back, and full screen stays off. Keep on Top gives level 3, and 0 when it's off. At Small, 250 points from the screen's right edge, ⇧⌘L moved the window to x 2080, so it stayed on screen (FR-22). 36 simulated cores give 792, 870 and 948 wide, and the MacBook Neo and the fallback row give 240, 360 and 480;
    - **colors,** as in 3.3: the chooser opens at level 4, above the meter's 3. Picks and Reset are saved, ⌘W closes only the chooser, the app quits when the meter closes with the chooser open, and a relaunch keeps the colors;
    - **rate changes,** as in 3.2: each change's update came within 0.89 s of it and covered at least 1.016 s;
    - **pausing,** as in 4.1, over three runs: minimize 0.64–0.77 s (0.70–0.73 s on 27.0.1), restore 0.54–0.56 s, a full cover 14–22 ms, uncovering 22–34 ms, hiding 26–50 ms and showing 30–47 ms. The first update came 1.02 s after each resume, and nothing was read or drawn while the meter was hidden. In one run the meter drew once as the app hid, 15 ms before macOS reported it hidden. That was macOS drawing the window as it hides, not a reading;
    - **redraws and core changes,** as in 4.2: a moving load gave 15 updates and 15 draws, and a steady one 15 updates and none. 6 cores changing to 18 at Medium took the window from 360 to 456 wide with its top-left corner at (72, 56), and at the screen's right edge from x 2190 to 2104. 18 cores changing to 10 of unknown type at Large took it from 498 to 480;
    - **the Release app:** no console output and none of the temporary lines' text. It used 0.35 s of CPU time over 60 s, about 0.6% of one core, where 4.2 measured 0.30 s;
    - **the test loads,** on the real sampler: the Efficiency-only load raised only the Efficiency group, from 37.9% to 66.9%, with Performance at 1.2%. Four busy loops put Performance at 99.5%.
  - Found, none of it CPUMeter's:
    - macOS was still busy after the update, analyzing the photo library and re-indexing Spotlight, so the quiet Efficiency average was 38%, where it was 12% on Nov 2;
    - the App Sandbox prints `sandbox_extension_issue_file_to_process … Operation not permitted` when the app is launched through a symbolic link in its path, and nothing when it's launched by its real path. That explains the line the M1 printed from `/tmp` in 1.2 and 1.3, because `/tmp` is a symbolic link.
  - Copied to the M1's Drop Box as `CPUMeter-4.2-4d1baf8.zip`, a Release build.
  - Not covered by Claude's checks: real mouse drags and keystrokes, the color chooser and the icon by hand, minimizing, covering and hiding by hand, and sleep.
- **Result, Chris's checks (Nov 6, 2026):**
  - On the M4, from Xcode: the icon in the Dock and the About box, real keystrokes for the sizes, the rates and Minimize, a drag snap, a color pick and Reset to Defaults, minimizing, covering and hiding with Keep on Top off, and sleep and wake.
  - On the M1, on macOS 27.2, from the Drop Box build: the icon, "Efficiency" and "Performance" in full at all three sizes, a drag snap, a color pick and Reset, minimizing, covering and hiding, and sleep and wake.

  Chris: "Both pass." **Confirmed by Chris** (Nov 6, 2026). Phases 0–4 hold on macOS 27.2.
- **Point releases (Nov 10, 2026):** after Increment 5.5, the M1 took macOS 27.2.1, and Chris is updating the M4 to it the same day. Under Chris's policy, a point release keeps the major and minor version, so it doesn't invalidate any test already done on 27.2, and nothing is rechecked (requirements v1.19, §6).

---

## Phase 5 — Finish

### Increment 5.1 — App icon
- **Goal:** Chris's icon in the Dock and in Finder. (FR-5)
- **Build:** Chris creates the icon separately and tells Claude when it's finished. Claude then adds it to `Assets.xcassets/AppIcon`. This increment runs whenever the icon is ready and doesn't hold up any other increment, but the v1.0 release in 5.8 includes it. *(Chris's instruction, Nov 2, 2026.)*
- **Verify:** Chris checks it in the Dock and in Finder.
- **Done when:** Chris approves it.
- **Result (Nov 4, 2026):** Chris's artwork arrived as one sheet of six drawings on a dark background, labelled 512 down to 16. It's kept as `design/AllIcons.jpeg`. Each drawing was cut out of the background, and each icon size uses the drawing labelled for it, with the 1024-pixel size taken from the largest. Every drawing is larger than its label, so nothing was enlarged. As drawn, the icon was put inside a gray rounded square by macOS 27, because the chip's outline isn't Apple's standard shape. Chris chose a version stretched to Apple's 824-of-1024 tile and clipped to its corners. That trims the outer pin tips and leaves the shadow to macOS, which then shows the icon full size. `xcodebuild` is clean. The first run from Xcode still showed the blank icon, because macOS caches an app's icon by the `.app` folder's path and date, and an Xcode rebuild doesn't change the folder's date. Touching the built `.app` fixed it. **Confirmed by Chris** (Nov 4, 2026): the new icon shows in the Dock and the About box.

### Increment 5.2 — Footprint
- **Goal:** Measure and report the real cost. There's no pass or fail ceiling. (NFR-1)
- **Build:** A Release build, at Medium and a 1-second refresh, with Keep on Top on. Chris's settings are saved first and restored after every run, because of DriveSpeed's lesson. From v1.9, the build is 5.3's Core Animation meter.
- **Verify:**
  - On each Mac mini, `local-tests/inc5.2/measure52.sh` runs the Release build for 65 minutes, the first 5 as warm-up, and logs its CPU time and memory every minute. It ends with a 5-second `sample` for the share of time the main thread sits idle. The M1 gets the same script, pasted as one command.
  - On the M4, `local-tests/inc5.2/cpucheck/cpucheck.sh` also runs copies of the build at Small, Medium and Large side by side for 65 minutes, so all three sizes share the same conditions, and counts each copy's system timers. Each copy has its own test bundle ID, so Chris's settings aren't touched. *(Added in v1.9, for NFR-1's "at every size".)*
- **Done when:** CPU and memory are recorded for both Macs, next to DriveSpeed's 0.75% of one core, and CPU and memory stay level after warm-up at every size (NFR-1): all three on the M4, and Medium on the M1. Results go here and in the README.
  - **Level** means a CPU trend within ±0.03% of one core per hour, a timer count that doesn't grow, and resident memory that grows by less than 0.5 MB across the hour. *(Claude's proposal, v1.9. Under `Canvas`, Small measured +0.01 and −0.01% per hour and +0.1 and +0.2 MB; Medium measured +0.14 and +0.16% per hour and +1.3 and +1.6 MB.)*
- **Result, first runs (Nov 6, 2026),** of the `Canvas` meter: a Release build of `4d1baf8`, 65 minutes on each Mac mini on macOS 27.2, at Medium, a 1-second refresh and Keep on Top, with Chris's settings saved first and restored after.

  | | M4 | M1 |
  |---|---|---|
  | CPU, minutes 5–65 | 0.774% of one core | 1.241% |
  | CPU, first → last 10 minutes | 0.712% → 0.842% | 1.135% → 1.358% |
  | Footprint, minute 5 → 65 | 88.8 → 82.4 MB | 31.5 → 31.4 MB |
  | Resident, minute 5 → 65 | 96.0 → 96.6 MB | 92.7 → 94.2 MB |
  | Main thread idle | 99.4% | 98.3% |

  The M4 matches DriveSpeed's 0.75%, but **neither Mac's CPU stayed level:** each climbed about a fifth across the hour. Memory wasn't flat either. The M4's footprint grew about 1.6 MB an hour and only looked flat because macOS took back about 8 MB at minute 58.
- **Result, the cause (Nov 6–7, 2026):**
  - `heap` found one more system timer (a `dispatch_source_t`) and one block for every update. Each was made inside SwiftUI's renderer, RenderBox, by its surface pool's `collect`, and each is still referenced, so `leaks` reports none.
  - A copy of the app with switches, each turning off one part, ruled out the `Window` scene, `WindowAccess`, the size limits, the full-screen setting, resizability, the menus, the timer's tolerance and the sandbox, and the colors, text, key and clipping one at a time. A meter frozen after its first update didn't leak.
  - **The trigger is the size of what `Canvas` draws.** Above about 336 × 160 points, `Canvas` is drawn through a different kind of layer, an image queue rather than a surface, and that one leaks. Medium and Large are past the line; Small on the M4 isn't. A small standalone test leaks once two 3-point corner marks take its drawing past the line. Neither `rendersAsynchronously` nor `.drawingGroup()` helps. At the same size, SwiftUI shapes and text, a Core Graphics view and Core Animation layers don't leak.
  - **The leak drives the CPU climb** (Nov 7). Two Small and two Medium copies of the same build ran side by side for 65 minutes on the M4:

    | Copy | CPU, first 10 min | CPU, last 10 min | Trend per hour | Timers, minute 4 → 65 |
    |---|---|---|---|---|
    | Small 1 | 0.728% | 0.733% | +0.01 | 54 → 53 |
    | Small 2 | 0.745% | 0.742% | −0.01 | 53 → 54 |
    | Medium 1 | 0.745% | 0.882% | +0.16 | 296 → 3,955 |
    | Medium 2 | 0.695% | 0.815% | +0.14 | 309 → 3,964 |

    Resident memory grew 1.3 and 1.6 MB at Medium, and 0.1 and 0.2 MB at Small. The samples at the end put Medium's extra time in the system's timer bookkeeping and in the renderer's surface pool.
  - Chris chose to move the drawing to Core Animation, §6's fallback (requirements v1.16, Nov 7, 2026). 5.3 builds it, and these runs are then repeated. The scripts, the copy of the app with switches, the small test and every result are kept in `local-tests/inc5.2/`.
- **Result, repeated after 5.3 (Nov 8, 2026),** with the Core Animation meter: a Release build of `b6b579f` on macOS 27.2, at a 1-second refresh with Keep on Top on, with Chris's settings saved first and restored after.
  - **Medium on each Mac mini,** with `measure52.sh`, for 65 minutes:

    | | M4 | M1 |
    |---|---|---|
    | CPU after warm-up | 0.370% of one core, minutes 5–65 | 0.570%, minutes 5–55 |
    | CPU in each 10 minutes | 0.365–0.373% | 0.563–0.580% |
    | Trend per hour | −0.004% | −0.022% |
    | Footprint | 26.3 → 25.6 MB, minute 5 → 65 | 24.5 → 24.6 MB, minute 5 → 55 |
    | Resident | 91.1 → 91.5 MB, minute 5 → 65 | 89.7 → 89.8 MB, minute 5 → 55 |
    | Main thread idle | 99.6% | not measured |

    Both are level, and each uses less than half of what it did with `Canvas` (0.774% and 1.241%). The M4 uses about half of DriveSpeed's 0.75% of one core. **The M1 has 50 clean minutes, not 60.** Chris watched it through Screen Sharing, and when that ended at minute 57, the M1 had no screen. The window was no longer visible, so the meter paused, as FR-17 says. Its resident memory stepped up 1.7 MB at that moment, once. The 5-second sample at the end came during the pause, so it shows nothing about the main thread.
  - **Small, Medium and Large side by side on the M4,** two copies of each, for 65 minutes. The run used `cpucheck/cpucheck3.sh`, which is `cpucheck.sh` set up for three sizes:

    | Copy | CPU, minutes 5–65 | Trend per hour | CPU, minutes 35–65 | Trend per hour | Timers, minute 4 → 65 | Resident, minute 5 → 65 |
    |---|---|---|---|---|---|---|
    | Small 1 | 0.386% | −0.097% | 0.358% | −0.001% | 43 → 52 | 89.1 → 85.8 MB |
    | Small 2 | 0.387% | −0.073% | 0.369% | −0.002% | 43 → 52 | 89.9 → 85.9 MB |
    | Medium 1 | 0.363% | −0.125% | 0.331% | +0.004% | 43 → 52 | 89.5 → 86.1 MB |
    | Medium 2 | 0.390% | −0.077% | 0.369% | +0.002% | 43 → 52 | 89.8 → 86.0 MB |
    | Large 1 | 0.372% | −0.090% | 0.348% | −0.001% | 43 → 52 | 90.2 → 86.0 MB |
    | Large 2 | 0.378% | −0.081% | 0.358% | +0.000% | 53 → 52 | 91.2 → 86.3 MB |

    - **The timer count doesn't grow at any size.** It stayed between 43 and 53, against 3,955 at Medium with `Canvas`. At a 1-second refresh, the count wanders between about 43 and 55 with no trend.
    - **The sizes cost the same.** Once settled, every copy used 0.33–0.37% of one core, with no pattern by size.
    - **The full-hour trends fall outside ±0.03%, but CPU went down, in all six copies together.** Each copy used about 0.44% in minutes 5–15, settled by minute 35 and was flat after that. All six moved alike, so the cause was on the Mac, not in the meter or a size. Memory settled the same way. After minute 25, every copy's resident memory held within 0.1 MB, and after minute 20 its footprint held within 0.03 MB. Resident memory fell 3–5 MB across the hour as macOS took memory back.
    - A first try of this run, earlier the same day, was disturbed. The M4 was showing the M1's screen through Screen Sharing, and every copy's CPU rose by about a fifth together. That run is kept but not used. The run above had Screen Sharing closed and the M4 otherwise idle, and Screen Sharing logged nothing during it. The windows were moved by hand during the run. A copy only uses more CPU while its window is being moved.
  - **Confirmed by Chris (Nov 8, 2026):** "Confirm 5.2." Every result is kept in `local-tests/inc5.2/rerun53/`.

### Increment 5.3 — Core Animation drawing
- **Goal:** The same meter, drawn with Core Animation, so no redraw leaves anything behind at any size. Nothing on screen changes. (Requirements §6 v1.16; FR-6, FR-7, FR-8d, FR-9, FR-10, FR-11, FR-27, FR-28c, NFR-1, NFR-3, NFR-5)
- **Build:**
  - **First, a probe.** 5.2's tests put their layers straight into an AppKit window, not SwiftUI's. So a throwaway copy of the app shows a bare layer view, with a few bars and figures changing every second, inside SwiftUI's window at Large, and its timer count must stay flat for 10 minutes. No app code changes for this.
  - `MeterView.swift`: the `Canvas` gives way to a view holding Core Animation layers, §6's fifth use of AppKit. It has a layer for each track and for each bar's system and user parts, clipped to the track's rounded corners, layers for the key's dots, and text layers for the overall figure, the key, the group labels and the per-core figures, in monospaced digits.
    - `MeterDrawing`'s functions stay as they are and still place everything, so the bar geometry and the text don't change, and their checks from 2.2 and 2.3 still apply.
    - An update changes only the layers whose values changed, with Core Animation's own animation turned off (requirements §8 item 7).
    - The colors are set again when the appearance changes, and at once as a color is picked (FR-28c). Text is drawn at the scale of the window's display.
  - `CPUMeterApp.swift` shouldn't need to change, because the new view takes the same layout, sample and colors. If it does, Claude says so first.
- **Verify:**
  - Headless: the saved geometry checks, and 2.2–2.4's pixel checks and contact sheets, run against the layers rendered to images at scale 1.0. That covers all 19 layouts and the fallback row, at all three sizes, in Dark and Light. Each image is compared with the `Canvas` meter's at the same readings: the bars should match pixel for pixel, and the text to within a pixel. Text at scale 2 is checked headlessly too, and on a Retina display in 5.6.
  - The running Release app on the M4, at each size: no `Canvas` layer in the window, a timer count that stays flat for 10 minutes, and no animation left on any layer after an update.
  - Chris compares the window with the `Canvas` build and with the design canvas, at all three sizes and in both appearances. Chris also runs the test loads, picks colors, and switches the appearance while it runs. Then the same at all three sizes on the M1, since every Mac draws the new meter.
- **Done when:** Chris confirms the meter looks as it did on both Mac minis, and the timer count is flat at every size. 5.2's runs are then repeated, which completes 5.2.
- **Result, the probe (Nov 7, 2026):** a throwaway copy of the app, with `MeterView`'s `Canvas` swapped for a rough layer view driven by the real sampler, ran side by side with the `Canvas` build for 10 minutes on the M4. Each copy had a 1-second refresh, Keep on Top on and its own test bundle ID. The probe's windows held no `Canvas` layer.

  | Copy | Timers, minute 1 → 10 | CPU, minutes 1–10 | Resident |
  |---|---|---|---|
  | Layers, Large | 46 → 46 | 0.42% of one core | 90.2 → 90.2 MB |
  | Layers, Medium | 44 → 44 | 0.43% | 94.4 → 94.5 MB |
  | `Canvas`, Large | 126 → 662 | 0.70% | 100.5 → 101.4 MB |

  A one-minute trial first found that a text layer still faded in its new text, although each update turns animation off, because the layer redraws its text later, outside the update. Turning off each layer's own animations removed every one. The probe has no key and isn't the finished meter, so its CPU figure is only a hint. The probe and its results are kept in `local-tests/inc5.3/probe/`.
- **Result, the code (Nov 7, 2026), after Chris's go-ahead:** only `MeterView.swift` changed. `CPUMeterApp.swift` didn't need to.
  - `MeterView` keeps its three inputs and holds `MeterLayerView`, an AppKit view with top-left coordinates. Its layer tree is built once for each layout and display scale: a track for each core, clipping its system and user parts to its rounded corners, the key's dots, and a text layer for each figure, label, key word and the overall figure. After that, an update sets only the values that changed, and every layer's own animations are off. The colors are worked out for the window's appearance and set again when the appearance changes or a color is picked.
  - **Text sits where `Canvas` put it.** Measured at scales 1, 2 and 8, `Canvas` rounds a text's width up to whole pixels, centers the line's height on its anchor point, and puts the baseline its ascent, to the nearest point, below the top, moved down onto a whole pixel. A standard text layer can't put its baseline there, so each text layer draws its one line with Core Text, using `MeterDrawing.textOrigin`. `MeterDrawing`'s other functions are unchanged.
  - **Checks on the M4:**
    - Debug and Release build with no warnings. The saved checks pass with the counts they had before: 2.3's geometry (14,554,734), 2.4's logic (3,463,960) and 4.2's pure checks (63).
    - **Compared with the `Canvas` build in real windows on the M4's screen (scale 1):** the M4's layout, the 10-core fallback row and 32 cores, at all three sizes, Dark and Light, each showing dashes, mixed readings, full load, thin parts with a core that has no reading, chosen colors, then dashes again. Each kind of meter stayed in one view throughout, so these are updates, not fresh drawings. 108 cases, all pass. Nothing moved. The only differences are anti-aliasing: up to 24 of 255 in any channel, except on the tracks' rounded corners and the key's dots, which each draw rounds slightly differently (up to 63, at Small's 2-point corners).
    - **The same off screen at scales 1 and 2,** for all 19 layouts and both fallback rows, through the same six states: 1,512 cases, all pass. No pixel differs by more than 29 of 255, or 20 away from the curves. Scale 2 is checked on a Retina screen in 5.6.
    - **The two Debug builds side by side under the simulated full load,** at all three sizes in Dark and Light, and the fallback row at Medium: screenshots of the windows differ only in anti-aliasing, as above.
    - **The running app's layers** (the Debug build, under the moving load, at Large and Small): no `Canvas` drawing layer in the window, 15 text layers (10 figures, 2 labels, 2 key words and the overall figure), and no animation on any layer.
    - **The Release build for 10 minutes** at each size side by side, each with a 1-second refresh, Keep on Top on and its own test bundle ID:

      | Size | Timers at minutes 1, 4, 7 and 10 | CPU, minutes 1–10 | Resident |
      |---|---|---|---|
      | Small | 40, 40, 40, 40 | 0.38% of one core | 72.6 → 73.1 MB |
      | Medium | 40, 40, 40, 40 | 0.37% | 72.7 → 73.2 MB |
      | Large | 40, 40, 40, 40 | 0.37% | 73.9 → 74.1 MB |

      The `Canvas` build used about 0.65–0.77% at Medium in 5.2. Ten minutes is too short to judge memory; 5.2's repeated runs do that.
  - **Confirmed by Chris on the M4 and the M1 (Nov 7, 2026): "All pass."** On the M4 from Xcode, and on the M1 from `CPUMeter-5.3-1c1fec1-dirty.zip` (the Release build above), Chris checked all three sizes against the old look, the figures changing under a test load with no fading, colors picked and reset in View → Colors, Light and Dark switched while running, and dragging the window between sizes.

### Increment 5.4 — Free sizing
- **Goal:** The window can be any size from Small up, dragged from any edge or corner, and the meter is Small enlarged at every size. (Requirements v1.17: FR-3, FR-3a–FR-3d, FR-8e, FR-11, FR-20, FR-22, FR-24, NFR-1, NFR-3; UI design §2, §5 and §8 items 5, 7, 8 and 11–13) *(Added in v1.10, at Chris's request, Nov 8, 2026.)*
- **Build:**
  - **First, a probe.** No app code changes for this. A throwaway copy of the app drops the snap and sets three things on SwiftUI's window: `contentAspectRatio` to Small's content size, the minimum content size to Small, and the maximum to the largest size of that shape that fits the screen. Its meter is drawn roughly, at the window's scale. The probe checks:
    - **that SwiftUI leaves the shape and the limits alone** through scene updates: size switches, Keep on Top, a refresh-rate change, a color pick and the meter's own updates. In 0.2, SwiftUI set the window level again on every scene update, and `.windowResizability(.contentSize)` sets the window's size limits from its content, so either could undo them (requirements §8 item 20);
    - **which edges stay in place** for each edge and corner dragged, and how macOS rounds the height during a drag (UI design §2);
    - that the window stops at both limits, and that the meter keeps up while it's redrawn at every size during a drag;
    - what the green button, Window → Fill and the tiling layouts do with a window whose shape is fixed (requirements §8 items 21 and 22).

    Claude reports the results before any app code. If SwiftUI overrides the shape, the window takes its shape when the drag ends instead (requirements §8 item 20). If macOS keeps different edges in place, the UI design records what it does. The probe and its results are kept in `local-tests/inc5.4/probe/`.

    **Probe result (Nov 8–9, 2026, M4, macOS 27.2), three rounds:**
    - **Round 1, the plan above:** SwiftUI set the minimum and maximum sizes again on every update, about once a second, with `.windowResizability(.contentSize)` and `.contentMinSize` alike (57 times in one run), and never touched the aspect ratio. But SwiftUI's window counts the 32-point title bar as content, so `contentAspectRatio` shaped the whole window and the meter came out 32 points short: the green button gave 2259 × 1345, not 2259 × 1377. Menu sizes set from code were exact.
    - **Round 2:** the limits through the meter's own frame, which SwiftUI kept steady, and the shape from an object put in front of SwiftUI's window handling that answers the window's resize question (`windowWillResize(_:to:)`) and the green button's (`windowWillUseStandardFrame(_:defaultFrame:)`), passing every other question on. SwiftUI never replaced it. Every drag ended exactly in shape; the green button went to Large and back with the top-left corner kept; Fill and the tiling layouts, in the green button's menu, ask the window for its size once, so they kept the shape, and macOS centered the window in the tile. But on a side drag macOS centered the other dimension, and corner drags jittered, switching between width and height.
    - **Round 3:** the kind of drag read from the mouse when it starts; the top or left edge put back after each step of a side drag; a corner following the average of what its width and height ask for; the window brought on screen when a drag ends. Chris dragged every edge and corner, down to Small and out to the largest size: every edge UI design §2 names held at every step (the top edge on all 525 steps of the side drags), no flicker, corners smooth (at most one change of direction, against 17–52 in round 2), every drag ending exactly in shape, and three drags that ran off screen brought back. Chris: "The redrawing during scaling is just amazing. Absolutely perfect."
    - **For the code:** the green button's way back came back a point wider (2256 → 2257), because macOS asks for the old size and round 3 worked it out again from the height, so a size already in shape is kept as it is. The largest size on the M4 is 2259 × 1377.
  - **Then the code.** Claude lists the files and waits for Chris's go-ahead. Expected:
    - `MeterSize.swift`: Small, Medium and Large become scales of 1, 1.5 and 2. A size comes from a scale by the UI design's rounding rule (§8 item 11). The saved setting is the scale, and a size saved by an earlier build carries over as its preset (FR-20). The snap rule goes.
    - `MeterLayout.swift`: only Small's numbers. The width rule and "Perf" are worked out once, at Small (FR-3b, FR-8e), and a layout at any other scale is Small's times that scale.
    - `MeterView.swift`: the layers at any scale, with the text sizes, corner radii and the 1-point gap scaled, and pixels snapped as now. The layer tree is rebuilt when the scale changes, as it already is for the layout and the display scale.
    - `WindowAccess.swift`: the resize answers in place of the snap, as in the probe's round 3: the shape at each step of a drag, the top or left edge put back on a side drag, a corner's average, the green button's size, and a size already in shape kept as it is. It works out the largest size for the window's screen and passes it up, again when the screen or its visible area changes (UI design §8 item 13). The presets keep the top-left corner, and FR-22's on-screen rule applies when a drag ends. A preset, or a saved size at launch, that doesn't fit takes the largest size that does. The green button zooms to Large and back, and the new scale is passed back to be saved.
    - `CPUMeterApp.swift`: the saved scale in place of the saved size, View → Size checked only at a preset's width (FR-24), and the meter's frame from Small's size up to the largest size, which sets the window's limits.
- **Verify:**
  - **Headless:**
    - The width rule and layouts for all 19 core layouts and both fallback rows, at the presets and at sizes between and beyond them, up to the largest size on the M4's screen. Medium and Large match requirements §6, "Perf" appears exactly where Small has it, every label fits within its own group at its widest, the figures stay separate at full load, and the top row's spare is measured. UI design §7 expects at least 41.0 points at Medium and 54.6 at Large.
    - Text widths at the presets and the largest size, to confirm that text which fits at Small fits at every size (UI design §7). The results go into UI design §7.
    - The rounding rule and the saved scale: every preset and a range of dragged widths come back exactly from their saved scale, and a Small, Medium or Large saved by an earlier build carries over.
    - The layers rendered at Small and at a few other scales, at display scales 1 and 2: positions match Small's layout times the scale, and Small matches 5.3's renders.
    - The saved checks, 2.3's geometry, 2.4's logic and 4.2's pure checks, adapted where they hold Medium's and Large's old numbers. Claude says what changed in each.
  - **The running app on the M4, Claude's checks:**
    - The resize answers checked directly, since a frame change from code doesn't ask them: AppKit's own proposals from the probe's logged drags of each edge and corner, played back, give the shape at every step, the edges UI design §2 names, the limits, and the green button's way back unchanged. A drag's end simulated with the live-resize notifications, as in 0.3, saves the new scale and keeps the window on screen.
    - The presets and their shortcuts keep the top-left corner, near the screen's edges too. A preset or a saved size larger than the screen takes the largest size that fits. The green button and the checkmark.
    - A 10-minute Release run at Small, a dragged size and the largest size, side by side, as in 5.3: the timer count stays flat, and CPU is near 5.3's 0.37–0.38% of one core. If it isn't, 5.2's hour is repeated. *(Claude's proposal.)*
    - CPU during a drag, since the meter is redrawn at each size (UI design §8 item 8).
  - **Chris on the M4:**
    - a real drag from each edge and corner, down to Small and up to the largest size, and drags near the screen's edges;
    - the presets, their shortcuts and the checkmark;
    - the green button, from below Large and from above it, coming back to exactly the size it had;
    - Fill and a tiling layout, from the green button's menu;
    - the Dock hidden and shown while the window is at its largest;
    - a relaunch at a dragged size;
    - the test loads, Light and Dark, and a color pick at a large size;
    - a comparison with the design canvas.

    Then a shorter pass on the M1, since every Mac draws the new sizes: a drag, the presets and a relaunch.
- **Done when:** Chris confirms the drags and the presets on the M4 and the M1, the widths match requirements §6, and the timer count stays flat at every size tested.
- **Result, the code (Nov 9, 2026), after Chris's go-ahead:** the five files named above changed, and no others.
  - `MeterSize.swift`: Small, Medium and Large are scales of 1, 1.5 and 2. `MeterSizing` holds Small's content size and works out the rest:
    - a size from a width or a scale, by the rounding rule;
    - the scale saved for a width, exactly a preset's at a preset;
    - the largest size of the shape that fits an area;
    - the kind of drag, from where the mouse is when it starts, where within 24 points of a side and of the top or bottom counts as a corner;
    - the answer at each step of a drag, the top or left edge held on a side drag, and the window brought on screen.

    A size saved by an earlier build carries over as its preset's scale. The snap rule is gone.
  - `MeterLayout.swift`: the width rule and "Perf" are worked out once, at Small, and a layout at any other width is Small's times its scale.
  - `MeterView.swift`: the text sizes, corner radii and the gap between a bar's parts scale with the layout. The gap is drawn in whole pixels, at least one.
  - `WindowAccess.swift`: an object in front of SwiftUI's window handling, as in the probe's round 3, answers each step of a resize and the green button's question. It passes every other question on to SwiftUI. It works out the largest size for the window's screen and passes it up, again when the screen or its visible area changes. The presets keep the top-left corner, and a drag's end keeps the window on screen and saves the new scale.
  - `CPUMeterApp.swift`:
    - the saved scale (`meterScale`) in place of the saved size, with a saved `meterSize` carried over once and left in place;
    - View → Size checked only at a preset's width;
    - the meter's frame from Small up to the largest size, which sets the window's limits.
  - **One fix, found by the real drags below.** A top corner dragged up into the menu bar made the window grow past the room above it, and macOS pushed it back down. So the opposite corner moved, held on only 112 of 240 steps, and the top edge jumped up to 8 points into the menu bar and back. Now, while a drag moves the top edge, the size stops where the top reaches the top of the screen's visible area, so the opposite edge or corner stays in place (FR-22). After the fix, the same drags held on 120 of 120 and 240 of 240 steps, with the top exactly at the menu bar.
- **Checks on the M4 (Nov 9, 2026).** Debug and Release build with no warnings. Chris's settings were saved before every run that launched the app and restored exactly after.
  - **Headless** (`test54`): 295,844 checks, none failed.
    - **Layouts:** all 19 layouts and both fallback rows, at the presets and at scales between and beyond them up to the M4's largest, 168 scaled layouts in all. Medium and Large match requirements §6, "Perf" appears at every size on the 10-core M4 and M5 and the MacBook Neo, and nowhere else, every label fits within its own group at its widest, and the figures stay separate at full load. The text and top-row measurements are in UI design §7.
    - **Saved scales:** 54,089 widths, from Small to the largest, come back exactly from their saved scale. A Small, Medium or Large saved by an earlier build carries over.
    - **Resize answers:** 18,980 answers in shape and within the limits. The probe's round 3 drags, played back, give all 232 logged answers. Round 2's 703 answers come out in shape, and its corner drags change direction 0 times, where round 2 changed 105 times.
    - **Not a drag:** a resize that isn't a drag, such as Fill or a tiling layout, keeps a size already in shape, and otherwise takes the largest size of the shape that fits. So the bottom-half tile gives 1103 × 673 rather than the probe's 1104.
  - **The saved checks,** adapted where they held Medium's and Large's old numbers:
    - **2.3's geometry, 14,662,435 checks.** It now also runs at a dragged size (1.22 × Small) and the M4's largest, with the gap between a bar's parts scaled. At a fractional scale, the tracks' ends snap to the nearest pixel, as their sides do. A gap between bars may be up to 1.5 pixels from the design's there, against 1 pixel before, which held for Small's numbers. Within a group, gaps differ by at most 1 pixel, and Small is unchanged.
    - **2.4's logic, 3,463,960 checks,** with Medium's and Large's widths from requirements §6 v1.18 and "Perf" at every size where Small has it.
    - **4.2's pure checks, 63,** with a preset's layout as Small's times its scale. Its 3 live checks pass too.
  - **Renders:**
    - At Small, all 420 of 5.3's test renders are the same pixel for pixel.
    - The layers against the `Canvas` meter from before 5.3, given the scaled gap, off screen at display scales 1 and 2. That covers all 19 layouts and both fallback rows, at the presets, a dragged size (1.22 × Small) and 3 × Small, through 5.3's six states in Dark and Light: 2,520 cases, all pass. No pixel differs by more than 29 of 255. Differences over 20 away from the curves come only at scaled sizes at display scale 1, where text at a fractional size is anti-aliased differently.
  - **The running app** (the Debug build, `runapp54.sh`):
    - Chris's saved Large carried over as scale 2, 492 × 332, with `meterSize` left in place. A saved scale wins over a saved size.
    - The window's limits are 246 × 182 to 2259 × 1409, which is 2259 × 1377 of meter under the 32-point title bar. Keep on Top gives level 3, and off gives 0.
    - The object in front of SwiftUI answers the two resize questions and passes the rest to SwiftUI's own window controller. Asked directly, 400 × 400 gives 400 × 276, 100 × 100 gives Small, 5000 × 5000 gives the largest, and a size in shape, such as 300 × 215, is kept.
    - ⇧⌘S, ⇧⌘M and ⇧⌘L keep the top-left corner, and the checkmark follows, with none at a dragged size. Near the right edge, Large moves left to stay on screen.
    - A drag's end in shape is kept and its scale saved. One out of shape takes the shape (500 × 300 gives 439 × 300), and one partly off the right or bottom edge comes back on screen.
    - The green button, from 300 wide and from 800 wide, goes to Large with the top-left kept, then back to exactly the size before.
    - A scale too large for the screen, whether saved while running or at launch, gives the largest size, saved as 9.1829.
    - A relaunch after ⌘Q keeps a dragged size and its place. File → Close quits with status 0.
    - A change from 6 to 18 simulated cores keeps the scale. At 1.5 the window goes from 360 to 621 wide, moving left near the right edge to stay on screen. At a dragged scale it goes from 293 to 505.
  - **Real drags** (the Release build, `realdrag54`, with posted mouse events, so the cursor moved on screen): every edge and corner, out and back, down past Small, into the menu bar and from just below it. In all, 3,240 steps, every one in Small's shape, with the edges UI design §2 names held on every step.
  - **CPU during a drag:** 8–14% of one core while the window is being dragged, 11.1% over a 26.6-second run of corner drags between Small and about 1,150 wide. At rest before and after, 0.1%.
  - **The Release build for 10 minutes,** each copy with a 1-second refresh, Keep on Top on and its own test bundle ID:

    | Copy | Timers at minutes 1, 4, 7 and 10 | CPU, minutes 1–10 | Resident |
    |---|---|---|---|
    | Small | 40 at each | 0.391% of one core | 88.3 → 88.2 MB |
    | Dragged to 300 wide | 40 at each | 0.411% | 88.7 → 88.7 MB |
    | Largest, 2259 wide | 42 at each | 0.450% | 103.6 → 87.5 MB |

    The timers stay flat at every size. The largest was about a fifth above 5.3's 0.37–0.38%, so 5.2's hour was repeated.
  - **5.2's hour, repeated** (`cpucheck54h.sh`): the largest size behind, with two Small copies and two copies at 300 wide in front, for 65 minutes, the first 5 warm-up:

    | Copy | CPU, minutes 5–65 | Trend per hour | Timers, minute 4 → 65 | Footprint, minute 5 → 65 |
    |---|---|---|---|---|
    | Largest | 0.463% | −0.002% | 53 → 53 | 45.0 → 45.6 MB |
    | Small 1 | 0.457% | +0.001% | 53 → 53 | 30.6 → 30.7 MB |
    | Small 2 | 0.444% | −0.000% | 55 → 55 | 30.5 → 30.5 MB |
    | 300 wide 1 | 0.454% | +0.002% | 55 → 55 | 30.8 → 30.9 MB |
    | 300 wide 2 | 0.441% | +0.000% | 56 → 53 | 30.4 → 29.6 MB |

    - **Level at every size:** every 10-minute figure fell between 0.438% and 0.465%, with no settling this time.
    - **The largest costs about the same as Small:** it differs from the higher Small copy by less than the two Small copies differ from each other. Its extra 15 MB of footprint is its larger layers.
    - **Memory flat:** after minute 20, each footprint held within 0.45 MB at the largest and 0.03 MB at the others. The main thread was 99.5% idle at the largest.
    - **The screensaver didn't start during the run.** The script keeps the display awake. macOS's log shows the screensaver held off at 15:47, 16:07 and 16:27, then starting at 16:47, 47 seconds after the run ended.

    Every copy ran higher than 5.2's 0.33–0.37% once settled, and Small's footprint was 30.5 MB against 5.2's 25.5–26.5. So the two builds were compared directly.
  - **Side by side with the build before free sizing** (`cpucheck54ab.sh`): two copies of be7f4eb's build, whose app code is 5.3's, and two of 5.4's, all at Small, for 12 minutes, the first 2 warm-up:

    | Build | CPU, minutes 2–12, each copy | Mean | Footprint at the end, mean |
    |---|---|---|---|
    | be7f4eb | 0.457%, 0.465% | 0.461% | 30.7 MB |
    | 5.4 | 0.447%, 0.433% | 0.440% | 30.2 MB |

    **5.4 costs the same as the build before it.** The gap between the builds is about the size of the gap between two copies of one build, and both builds' timers stayed flat, at 53–55. So the higher figures in the hour came from the Mac's state that day, not from 5.4.
- **Chris on the M4 (Nov 9, 2026),** from Xcode, all 11 tests passed:
  1. the first launch at Large, carried over;
  2. each edge and corner dragged out and back, with the edges held, no flicker and smooth corners;
  3. the stops at Small and at the largest size;
  4. a top corner into the menu bar, and edges dragged off screen;
  5. the presets, their shortcuts and the checkmark;
  6. the green button from below and above Large, and back;
  7. Fill and a tiling layout;
  8. the Dock hidden and shown at the largest size;
  9. a relaunch at a dragged size;
  10. the test loads in Light and Dark, and a color pick at a large size;
  11. a comparison with the design canvas.
- **Chris on the M1 (Nov 9, 2026),** from `CPUMeter-5.4-be7f4eb-dirty.zip`, the Release build above: a drag from an edge and a corner, the presets and the checkmark, and a relaunch at a dragged size. All passed.
- **Confirmed by Chris on the M4 and the M1 (Nov 10, 2026): "Confirm 5.4."** The scripts and every result are kept in `local-tests/inc5.4/`.

### Increment 5.5 — Accuracy
- **Goal:** Confirm the readings on both Macs. (NFR-6)
- **Build:** None expected.
- **Verify:** On each Mac mini, run 1, 2, 4 and all-core busy loops from a quiet start. Each should raise the overall figure by about N/T of the total, and the readings should follow Activity Monitor at the same refresh rate. The two never sample at the same instant, so this compares trends, not exact numbers.
- **Done when:** Both Macs follow the expected rise, and the results are recorded.
- **Plan (Nov 10, 2026):** no app code. The meter has printed nothing since 2.2, so Claude proposed a recorded check alongside Chris's visual one, and Chris chose it. Every second, a screenshot of the meter's window is taken, and one of Activity Monitor's on its CPU tab. Both are read afterwards, on the M4, with Apple's text recognition, so the reading adds no load during the run. `top`'s CPU line is a third reading. A test tool and a script do this, and the app doesn't change: `local-tests/inc5.5/readmeter55/` and `accuracy55.sh`.
  - **The run:** the Release app at Large, with a 1-second refresh and Keep on Top on, and the user's settings saved first and restored exactly after. A quiet minute comes first, then 1, 2, 4 and every-core busy loops (the test loads' `awk` loop), a minute each with 30 seconds of quiet after each. About 7 minutes.
  - **Each step's figure** is its median over the seconds after its first 10. The rise is from the quiet step before.
- **Result (Nov 10, 2026):** a Release build of `3ab5a05` (binary sha256 81071602f580edc7) on macOS 27.2 (26B123), with Activity Monitor on its CPU tab at View → Update Frequency → Very Often (1 sec). Chris watched the meter beside it on each Mac.
  - **M4, 10 cores.** All 421 meter screenshots read, and 416 of 421 of Activity Monitor's. The other five didn't add up to 100 and were dropped. Figures are % of the whole Mac; Activity Monitor and `top` are User + System:

    | Step | Expected rise | Meter | Rise | Activity Monitor | Rise | `top` | Rise | Perf | Efficiency |
    |---|---|---|---|---|---|---|---|---|---|
    | Quiet | | 7.0 | | 6.6 | | 6.6 | | 6 | 7 |
    | 1 loop | +10 | 16.5 | +9.5 | 16.0 | +9.4 | 16.1 | +9.4 | 30 | 7 |
    | 2 loops | +20 | 25.5 | +18.0 | 25.6 | +18.1 | 25.7 | +18.0 | 55 | 6 |
    | 4 loops | +40 | 46.0 | +39.0 | 46.0 | +39.3 | 46.0 | +39.3 | 100 | 10 |
    | 10 loops | 100 | 100.0 | | 100.0 | | 100.0 | | 100 | 100 |

    The quiet steps between loads read 7.0–7.5 on the meter and 6.7–7.5 on Activity Monitor.
  - **M1, 8 cores,** with 1, 2, 4 and 8 loops. Chris pasted one command into the M1's Terminal and watched through Screen Sharing, which stayed open so the M1 had a screen (FR-17). The results came back through the Drop Box. All 421 meter screenshots read, and 419 of 421 of Activity Monitor's:

    | Step | Expected rise | Meter | Rise | Activity Monitor | Rise | `top` | Rise | Perf | Efficiency |
    |---|---|---|---|---|---|---|---|---|---|
    | First minute | | 25.0 | | 25.3 | | 24.7 | | 8 | 42 |
    | 1 loop | +12.5 | 20.0 | +11.0\* | 20.1 | +10.9\* | 20.0 | +10.9\* | 31 | 9 |
    | 2 loops | +25 | 33.0 | +24.0 | 32.6 | +23.4 | 32.6 | +23.5 | 56 | 9 |
    | 4 loops | +50 | 58.0 | +49.0 | 58.1 | +49.2 | 58.2 | +49.0 | 100 | 16 |
    | 8 loops | 100 | 100.0 | | 100.0 | | 100.0 | | 100 | 100 |

    The quiet steps after each load read 9.0–10.0 on the meter and 8.9–9.8 on Activity Monitor. \* **The M1's first minute wasn't quiet.** Something kept its Efficiency cores about 40% busy for the whole minute, and it stopped about 2 seconds after the first loop started. The meter, Activity Monitor and `top` all show it, so it was real work, not a misreading. The 1-loop rise is therefore taken from the quiet step after it.
  - **Every rise is within 2 points of N/T on both Macs, and slightly under it,** because the loops take cores that were already doing a little background work. The loops land on the Performance cores, as expected: Perf reads about a quarter plus its background with one loop, about half with two and 100% with four, and Efficiency stays low until every core is busy.
  - **The meter follows Activity Monitor second by second.** The median gap between the two in the same second's screenshots is 0.6 points on the M4 and 0.5 on the M1. 95% of seconds are within 3.2 and 3.9 points. The few larger gaps fall almost all at the moment a step starts or stops, when one app has updated and the other hasn't yet. Each step's median agrees with Activity Monitor's within 0.5 points, and with `top`'s within 0.8.
  - The user's settings came back identical on the M4, no busy loop or CPUMeter was left running, and the M1's settings were restored too. A 45-second trial on the M4 came first, to check the reading.
- **Confirmed by Chris on the M4 and the M1 (Nov 10, 2026): "Confirm 5.5."** Every screenshot, reading and summary is kept in `local-tests/inc5.5/`, with the M1's command in `m1-command-55.txt`. After the run, the M1 took macOS 27.2.1, and Chris is updating the M4 to it the same day. A point release keeps the major and minor version, so it doesn't invalidate tests already done (requirements v1.19, §6).

### Increment 5.6 — M3 MacBook Air check
- **Goal:** The two things only the Air can show. (Requirements §6, Test hardware)
- **Build:** None expected.
- **Verify:** Chris runs the Release build on battery for about an hour and reads CPUMeter's line in Activity Monitor's Energy tab. Chris also checks the window on the built-in display: the notch, and text on a Retina screen, at the presets and at a dragged size between them. *(The dragged size added in v1.10.)*
- **Done when:** The results are recorded, and nothing looks wrong near the notch.
- **Plan (Nov 10, 2026):** no app code. Chris mounted the Air's own Drop Box on the M4, so a Release build and a script reached the Air that way, and the results came back the same way. Chris pasted one command into the Air's Terminal. The script, `local-tests/inc5.6/air56.sh`, records what the Air is, its core groups under load as in 5.5, the window at each step Chris takes, and an hour on battery. It opens CPUMeter with `open`, so Activity Monitor's Energy tab shows CPUMeter on its own row rather than under Terminal.
- **Result (Nov 10–11, 2026):** a Release build of `e92f70f` (the same Swift as `3ab5a05`, binary sha256 93a68686680b3ae3) on macOS 27.2.1 (26B131).
  - **The Air:** Mac15,13, Apple M3, with 4 Performance and 4 Efficiency cores, as Apple's specs say. Its built-in Retina display is 1440 × 932 points at scale 2. The visible area is 1440 × 903, below a 29-point menu bar, and the notch spans x 642 to 798 and is 28 points tall.
  - **Core groups:** a screenshot of the meter every second, read afterwards on the M4 as in 5.5. Quiet: Efficiency 19.5%, Performance 4%. A load held to the Efficiency cores (`taskpolicy -b`): Efficiency 43%, Performance 3%. Four busy loops: Performance 100%, Efficiency 15%, all cores 58%. So each label names the right group.
  - **The window:** Small, Medium and Large came out exactly 240, 360 and 480 points wide inside, and a size dragged between Medium and Large came out at 400 × 250, in shape. Moved under the notch as high as it goes, the title bar's top stopped at y 29, just below the menu bar. The text is sharp in every screenshot at scale 2, the first check on a real Retina screen of the text 5.3 and 5.4 checked headlessly.
  - **The first run's last three window steps were redone on Nov 11.** In the first run, the step meant to reach the largest size ended at exactly Large, most likely because at its largest the meter covers the Air's screen and floats over Terminal, so it had to be shrunk to reach Terminal. Its two green-button clicks then changed nothing. The redo checked each step against what it expects, offered a retry, and logged every change in the window every 10 ms (`watch`). From the left edge halfway down, the top edge dragged up grew the window from 480 × 332 to 960 × 632 and stopped at the menu bar's bottom edge, with the bottom and left edges held. The top-right corner did the same, from 960 × 632 to 1200 × 782, with the bottom-left corner held. Dragged from the bottom-right corner, the window grew in shape at every step to 1393 × 903, the screen's whole visible height. The green button then went to Large and back to exactly 1393 × 903, keeping the top-left corner. All seven steps were as expected at the first try.
  - **Energy:** 65 minutes on battery, the first 5 as warm-up. CPUMeter used 0.430% of one core over minutes 5–65, level at 0.418–0.442% per 10 minutes and never pausing. `top`'s Energy Impact for it averaged 0.40, with 0.35 idle wakeups a second, and its memory footprint stayed at 23.1–23.2 MB. The battery, for the whole Mac, went from 91% to 89%. Activity Monitor's Energy tab gave CPUMeter its own row: **Energy Impact 0.3, 12 hr Power 0.76, App Nap No, Preventing Sleep No.**
  - **The hour ran at Large, not Medium as planned.** On the Air, macOS doesn't let Terminal change a sandboxed app's settings once its container exists, so the script's changes after its first launch did nothing, and CPUMeter kept the Large it had. 5.2 found that the three sizes cost the same. The script now checks that its changes took, and otherwise says so and leaves the settings alone. The Air's CPUMeter keeps the settings the tests left; it had none before.
  - **Found on the M4 while preparing the redo:** with the window at Large and no earlier zoom, the green button goes to 459 × 312, AppKit's own way back put into the meter's shape, and the next press returns to Large. Requirements §8 item 21 says only that the button zooms to Large and back, so what it should do at Large is an open point for Chris.
- **Confirmed by Chris on the Air (Nov 11, 2026): "M3 tests completed. Everything as expected."** Every result, screenshot and log is kept in `local-tests/inc5.6/`, with the Air's commands in `air-command-56.txt`.

### Increment 5.7 — Green button
- **Goal:** The green button grows the window to its largest size and back, and at the largest size goes to Large. (Requirements §8 item 21, UI design §8 item 5)
- **Build:** `WindowAccess.swift` only, where CPUMeter already gives the green button its frame. At each press, CPUMeter decides where the window goes. If the window is still exactly where the last press left it, it goes back. Otherwise, at the largest size it goes to Large, and at any other size to the largest, placed as the UI design's §8 item 5 says. The way back stays exact, as 5.4 made it. Fill and the tiling layouts in the green button's menu don't change. `test54`'s green-button checks change to match.
- **Verify:**
  - Headless (`test54`): the frame each press gives from Small, a dragged size, Large, between Large and the largest, and the largest with and without an earlier press, near each edge of the screen, on the M4's visible area and the Air's 1440 × 903. Each frame is in shape and on screen, and each way back is exact.
  - On the M4, a Release build, before Chris: presses through Accessibility from each of those sizes, with `watch` logging every change, as in 5.6's redo. Then Chris presses the button from a preset, a dragged size and the largest size.
  - No M1 or Air pass. The rule depends only on the screen's visible area, which the headless checks cover. *(Claude's proposal.)*
- **Done when:** On the M4, every press goes where requirements §8 item 21 says, in shape and on screen, and every second press comes back to exactly the size and place the window had.
- **Result (Nov 11, 2026):** a Release build of `1dd8630` with 5.7's code (binary sha256 b6e4757a2c9a2580) on macOS 27.2.1 (26B131).
  - **Two files changed, not one.** The rule went into `MeterSize.swift` as well as `WindowAccess.swift`, so `test54` can check it with no window, like 5.4's other rules. Chris approved both files before the code was written.
    - `MeterSize.swift`: `MeterSizing.zoomTarget(from:lastPress:titleBar:largest:visible:)` works out where a press takes the window. It uses the window's frame, the last press and the screen's visible area. `ZoomPress` holds a press's frame before and after, and `isSameFrame` counts frames within half a point of each other as the same.
    - `WindowAccess.swift`: the object in front of SwiftUI's window handling now also answers `windowShouldZoom(_:toFrame:)`. CPUMeter moves the window itself, animated, and tells macOS not to zoom, so AppKit's own idea of zoomed and unzoomed decides nothing. It remembers the last press while the app runs, not across launches. Window → Zoom takes the same path. Fill and the tiling layouts don't change.
  - **Headless:** `test54` ran 316,012 checks with no failures (295,844 before 5.7). Its new part covers every layout on three visible areas: the M4 with the Dock at the left, the M4 without it, and the Air's 1440 × 903. That makes 2,925 starting frames.
    - **From below the largest:** the starting sizes are Small, Medium, a dragged size, Large and halfway to the largest. Each starts at the screen's left, middle and right, and at its top, middle and bottom. The first press reaches the largest size, in shape and on screen, with its top at the top of the visible area. The left edge stays where it was, unless the window would run off the right; then it moves left just far enough. The second press comes back to exactly the frame before, and a press after a move counts as a first press.
    - **From the largest:** a press goes to Large with the top-left corner kept, and the next press goes back to exactly the largest. In 4 cases, wide layouts on the Air, Large is already the largest the screen holds, and the press changes nothing.
    - **A smaller screen:** if the screen got smaller after the press, the way back stays within the largest size and on screen.
    - **The largest content size** is 2259 × 1377 on the M4 and 1393 × 871 on the Air, as measured in 5.4 and 5.6.
    - **The older saved checks,** rebuilt with the new code, pass with the same counts as in 5.4: 2.3's geometry (14,662,435), 2.4's logic (3,463,960) and 4.2's pure checks (63).
  - **On the M4, before Chris** (`local-tests/inc5.7/green57.sh`): real presses of the green button through Accessibility, with every change in the window logged every 10 ms (`watch`). Chris's settings were saved first and restored exactly after. The second run gave 24 of 24 as expected:
    - **Medium at the left edge:** to the largest at the same left edge, top at the menu bar, and back to exactly Medium.
    - **A dragged size,** 700 × 459, near the right edge: to the largest, moved left just enough (to x 301), and back.
    - **Large from its shortcut:** to the largest and back.
    - **The largest reached by a resize, not a press,** twice: a press went to Large with the top-left corner kept, and the next back to the largest.
    - **Pressed to the largest, then moved:** the next press went to Large at the new top-left, and the one after back to the largest.
    - **Window → Zoom:** to the largest and back to Medium.
    - **The saved scale** was Medium's 1.5 at Medium, and the largest's 9.1829 after a press to the largest.
    - **Every change was animated,** in about 25 steps over a third of a second.
  - **The first run gave 17 of 21, for reasons outside the rule:**
    - The script set only the saved scale, and the app opens at the frame it saved last, which was Large. So the steps meant to start from Medium started from Large. The script now chooses Medium with its shortcut first.
    - The two Window → Zoom clicks came while another app was in front, so they reached no window.
    - In one step, the window reached the right frame, and about 0.8 s later it was moved down and to the left, at the uneven speed of a hand on the mouse.

    The second run also logged the mouse buttons and the front app. Someone was using the Mac during it too: there were four clicks, and another app was in front for four steps. None of it landed on the meter.
  - **Chris on the M4 (Nov 11, 2026),** with the Release build above: presses from a preset, a dragged size and the largest size, each followed by a press back. All were as expected.
- **Confirmed by Chris on the M4 (Nov 11, 2026): "All as expected."** The scripts and every result are kept in `local-tests/inc5.7/`.

### Increment 5.8 — Traceability, README and release
- **Goal:** Every requirement is met, deferred, or explicitly removed. → **v1.0**
- **Build:** Walk the requirements top to bottom against the running app and record the evidence, as DriveSpeed's 5.4 did. Fix any drift between the requirements, the design document and the code. Rewrite the README, including exactly what was and wasn't tested. The "Note From The Human" section stays Chris's.
  - *Added after the walk (v1.13):* File → Close closes the window in front, so ⌘W closes the About box when it's in front rather than quitting (requirements v1.21, FR-25), in `CPUMeterApp.swift`. A comment there that still says the green button zooms to Large is brought up to date at the same time.
  - *Added after Chris's check (v1.14):* with the meter in front, File → Close is grayed out and ⌘W does nothing, whatever else is open, so ⌘W never quits (requirements v1.22, FR-25). The About box and the color chooser still close with ⌘W. In `CPUMeterApp.swift`, with a small helper if one is needed to follow which window is in front. SwiftUI may bring the grayed state up to date only when File opens, as it does checkmarks, so Close also does nothing itself while the meter is in front.
- **Verify:** Each requirement is checked off with evidence. For the Close change, on the M4: ⌘W with the About box, the color chooser and the meter each in front, by Claude's script and then by Chris. For v1.14's change, the same cases again: with the meter in front, whatever else is open, File shows Close grayed out and ⌘W leaves the app running, and the meter's close button and ⌘Q still quit.
- **Done when:** Full coverage is confirmed, Chris has written the note, and on Chris's go-ahead a zipped build is published as a GitHub release.

---

## Coverage map (requirement → increment)

| Requirement | Increment |
|---|---|
| FR-1 | 0.1 |
| FR-2 | 0.2 |
| FR-3, FR-3a | 0.2, 0.3, 3.1, 3.4, 5.4 |
| FR-3b | 2.1, 2.3, 2.4, 5.4 |
| FR-3c | 2.1, 5.4 |
| FR-3d | 0.3, 5.4 |
| FR-4 | 0.1 |
| FR-5 | 0.1, 5.1 |
| FR-6 | 1.2, 2.2, 5.3 |
| FR-7 | 2.2, 5.3 |
| FR-8 | 1.2 |
| FR-8a | 1.2, 2.3, 2.4 |
| FR-8b | 1.2, 1.3, 5.6 |
| FR-8c | 1.2, 2.3, 2.4, 4.2 |
| FR-8d | 2.1, 2.2, 2.3, 5.3 |
| FR-8e | 2.3, 2.4, 5.4 |
| FR-9 | 1.3, 2.2, 2.3, 5.3 |
| FR-10 | 1.3, 2.2, 2.3, 5.3 |
| FR-11 | 2.1, 2.2, 2.3, 2.4, 5.3, 5.4 |
| FR-12 | 1.3 |
| FR-13 | 1.1 |
| FR-14 | 1.3, 2.2 |
| FR-15 | 1.1, 1.3 |
| FR-16 | 1.1, 2.4 |
| FR-17 | 4.1 |
| FR-18, FR-18a–d | 3.2 |
| FR-18e | 3.4 |
| FR-19 | 0.2 |
| FR-20 | 0.2, 5.4 |
| FR-21 | 0.1, 0.2 |
| FR-22 | 0.2, 0.3, 3.1, 3.4, 5.4, 5.6 |
| FR-23 | 0.1, 5.8 |
| FR-24 | 0.2, 3.2, 3.3, 5.4 |
| FR-24a | 3.1, 3.4 |
| FR-25 | 0.2, 3.3, 5.8 |
| FR-26 | 0.2 |
| FR-27 | 2.2, 2.3, 5.3 |
| FR-28, FR-28a–e | 3.3, 5.3 |
| NFR-1 | 1.1, 4.2, 5.2, 5.3, 5.4, 5.6 |
| NFR-2 | 1.1 *(pre-verified Nov 1)* |
| NFR-3 | 2.2, 2.3, 5.3, 5.4, 5.6 |
| NFR-4 | 4.1, 4.2 |
| NFR-5 | 2.2, 3.3, 5.3 |
| NFR-6 | 1.3, 5.5 |
| §8 item 21, the green button | 0.3, 5.4, 5.7 |

---

## Prerequisites before Increment 0.1

- [x] Requirements approved (`cpu-meter-requirements.md`).
- [x] UI design approved (`cpu-meter-ui-design.md`).
- [x] Counter source and core-type lookup proven on the M4 under the App Sandbox.
- [x] Test loads and headless rendering proven on the M4.
- [x] Public repo created.
- [x] Chris approved this plan (Nov 2, 2026).
