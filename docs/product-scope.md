# Product scope — Ironfang: The Broken Crown

The commercial expansion of *Ironfang: First Siege* (the MVP that this repository shipped on
2026-09-04). A compact, polished, single-player micro-RTS for distribution through **QtMesh
Games** on Steam (desktop) with the WebAssembly build kept as a playable demo and QtMeshEditor
showcase.

## What ships

| Area | Scope |
|---|---|
| Campaign | 7 missions, 3–5 h first playthrough, illustrated intros, dialogue portraits, short outros, illustrated epilogue |
| Difficulty | Story / Warrior / Warchief — configuration only, no forked mission logic |
| Objectives | one primary at a time (or a clear sequence), ≤ 2 optional per mission, visible progress |
| Ratings | Iron / Steel / Gold medals with published criteria, per mission and difficulty |
| Progression | versioned local save: unlocks, medals, best times, tutorial, survival records, achievements, statistics, settings (separate file), language, seen narrative |
| Tutorial | contextual, event-driven, in Mission 1; replayable; skippable non-essentials |
| Units | the existing four types; one ability each (Guard Stance, Focus Fire, Ground Smash, Emergency Repair) |
| Veterancy | 3 ranks, data-driven, may reset between missions in 1.0 |
| Modes | Survival (unlocked by Mission 3), up to 3 skirmish scenarios (cut to 1 polished one if needed) |
| Meta | 12 achievements with stable string ids, statistics, Codex, "Forged with QtMeshEditor" showcase |
| Platform | platform-neutral event bridge for the QtMesh Games shell; no Steamworks inside Ironfang |
| Localization | English, Brazilian Portuguese; completeness test |
| Settings | display, audio, controls (remappable), accessibility; persisted independently |
| Targets | desktop (commercial), WebAssembly (demo; feature-parity where the browser allows) |

## What does not ship

Multiplayer/networking, a second playable faction, free-form building placement, tech trees,
diplomacy, hero inventories, equipment, formations, procedural campaigns, live services,
accounts, purchases, Steam SDK code, battles beyond the tested unit limits (see
`docs/feasibility-report.md`: 40 units at 60 FPS in the browser, 120 FPS on desktop).

## Guiding rules

* **Preserve the MVP.** The current match stays playable (as the *Classic Siege* scenario) at
  every milestone; its systems (30 Hz simulation, JS rule modules, imperative entities, asset
  indirection, wasm preload) are reused, not rewritten.
* **Data over code.** Missions, waves, objectives, triggers, difficulty, medals, achievements
  and text live in JS/JSON configuration modules; QML renders and binds.
* **Small focused managers**, never one god object: `Mission` (loader), `Objectives`,
  `Triggers`, later `Campaign`, `Save`, `Achievements`, `Statistics`, `Localization`,
  `GameEventBridge`.
* **One event stream.** Objectives, triggers, tutorial, achievements, statistics and the shell
  bridge all consume the same `gameEvent(name, payload)` stream.
* **Desktop-only features go behind a platform abstraction** with a safe browser fallback;
  every intentional platform difference is documented.
* **Every milestone ends verified**: desktop build, automated tests, manual pass, wasm build
  served over HTTP, comparison with the previous milestone, separate commit.

## Success criteria

The definition of done in the product brief: a new player finishes the campaign unaided,
progress survives restarts, all missions have tested victory/defeat, difficulty is fair and
distinct, medals and optional objectives are consistent, Survival is replayable, achievements and
statistics emit platform-neutral events, the shell can launch/pause/resume/save/close the game,
both languages are complete, settings persist, presentation is cohesive, desktop and wasm
performance targets hold, licences are complete, no placeholder is visible.

Related: `docs/story-and-campaign.md`, `docs/broken-crown-plan.md` (assessment and staged plan),
`docs/mission-format.md`, `docs/architecture.md`.
