# The Broken Crown — Milestone 0 assessment and staged plan

Written 2026-09-06 against commit `ca1537f` (*First Siege* MVP, live at
fernandotonon.github.io/Ironfang). This is the "preserve and assess" deliverable: what exists,
what is coupled to the single level, where the level goes, and how the expansion is staged.

## 1. Verification of the starting point

| Check | Result |
|---|---|
| Desktop build (`cmake --preset desktop`, Qt 6.11.1 macOS, Clayground v2026.6 submodule) | OK, no warnings from the app target |
| Tests (`ctest --test-dir build-desktop`) | 23/23 pass: `tst_navgrid.qml`, `tst_rules.qml` (economy, production, combat, gather, enemy AI, difficulty scaling, smart tap), Clayground's headless launch smoke test |
| Scripted match (`ironfang --autotest`, 8×) | full match shape, victory forced at step 27, restart OK, 120 FPS, 1.8–2.4 ms per sim step |
| WebAssembly build (`scripts/build-wasm.sh`, Qt 6.11.1 wasm_multithread, Emscripten 4.0.7) | OK; 37 MB wasm + 23 MB assets; browser autotest passes (`scripts/browser-check.mjs`) |
| Live deploy | GitHub Pages, custom loading shell, verified 2026-09-05 |

No existing build failure. Architecture work may begin.

## 2. Current behaviour (the MVP that must be preserved)

**Match flow.** Title → `startMatch(difficulty)` builds the one map from `config/level.js`,
camera to the player base, phase `playing`. Victory when the Enemy Fortress dies, defeat when the
Clan Fortress dies (`checkEnd`). Overlays: pause (P/Esc), victory/defeat with match stats,
Play Again, Back to Title, Asset Showcase, Credits. Difficulty easy/normal/hard scales enemy
income, wave growth and wave interval only.

**Player.** 150 iron, 3 Goblin Workers, 1 Orc Warrior, Clan Fortress (makes workers, drop-off,
2500 HP), War Foundry (warriors 80, archers 110, ogres 280 iron; 1400 HP). Selection by click,
box, Shift-add; orders by right click (attack / gather / return / move) or smart tap on touch;
rally points per producer, deposit rally = auto-gather. Production queues of 5. Camera:
Clayground `OrbitCamera3D` with WASD, wheel, drag, pinch.

**Economy.** 5 deposits of 600 iron; worker carries 10 per 2.6 s cycle. Enemy has no workers:
passive income 2.4 iron/s scaled by difficulty.

**Combat.** Melee reach 0.5 m, archers range 7 (arrow projectiles), ogre ×2.5 vs buildings;
auto-acquire within 9 m every 0.4 s, leash 16 m; death clip lingers 2.4 s then the entity is
destroyed; buildings sink into a scorched slab.

**Enemy.** `EnemyAI.js`: produce in rotation (warrior, warrior, archer; ogre every 3rd wave) →
assemble at the rally → first wave at 110 s, then every 85 s, size 3 + wave×growth (max 12),
garrison of 2 stays home → attack-move on the player fortress.

**Presentation.** QtMeshEditor models for every entity, animation clips via `QtQuick.Timeline`,
team rings, selection frames, health bars, hit flashes, move/attack markers, synthesized audio
(desktop only — Clayground Sound stalls wasm, issue #216), PerfHud, FPS.

**Tooling.** `--autotest`, `--showcase`, `--no-models`, `--mute`; asset pipeline scripts;
`build-wasm.sh` → `deploy/multithread`; `deploy-pages.sh`; CI (Linux desktop + wasm).

## 3. Systems and file inventory

| Layer | Files | Notes |
|---|---|---|
| Entry | `app/Main.qml`, `web-runtime/Main.qml` | Window vs Item root |
| Game root | `app/IronfangGame.qml` (901 lines) | state, level build, entities, selection, commands, sim loop, combat/production/enemy glue, input, overlays, autotest |
| Scene | `GameWorld.qml`, `RtsCamera.qml`, `UnitView.qml`, `BuildingView.qml`, `Projectile.qml`, `HealthBar3D.qml` | imperative entities, `Loader3D` models |
| UI | `Hud.qml`, `MenuOverlay.qml`, `AssetShowcase.qml`, `AudioController.qml` | hard-coded English strings |
| Rules (pure JS, tested) | `scripts/NavGrid.js Steering.js Economy.js Production.js Combat.js Gather.js EnemyAI.js Touch.js` | `.pragma library`, no QML dependencies |
| Data | `config/balance.js` (numbers), `config/level.js` (the map), `config/assets.js` + `assetmeta.js` (asset indirection) | |
| Tests | `tests/tst_navgrid.qml`, `tests/tst_rules.qml` | qmltestrunner through `clay_add_qml_test` |

## 4. Level-specific and tightly coupled logic

Everything below assumes exactly one map with one fortress per side and is what Milestone 1
untangles. Line numbers refer to `app/IronfangGame.qml` at `ca1537f`.

| Coupling | Where | Effect |
|---|---|---|
| Map hard-wired | `import "config/level.js" as Level`; `mapSize: Level.layout.size` (l. 26); `buildLevel()` (l. 107–119) | one layout, one entity set; `Nav.init(mapSize, mapSize)` |
| Named singletons | `playerFortress`, `playerFoundry`, `enemyFortress` properties, assigned in `buildLevel` | HUD objective text, gather drop-off, enemy AI target, victory/defeat all read them |
| Victory/defeat rule in code | `checkEnd()` (l. 641–645): enemy fortress dead → victory, player fortress dead → defeat | no objectives model, no optional objectives, no other win conditions |
| Objective text in the HUD binding | `objective:` binding in the `Hud {}` instance (l. 838–840) | English string built from the fortress HP |
| Start message in code | `flash("Send your goblins…")` in `startMatch` | narrative in the controller |
| Enemy wave config global | `EnemyAI.create(Balance.enemy, difficulty)`; `enemyWorld` adapter targets `playerFortress` | one wave schedule for every map; no per-mission waves or multiple spawn points |
| Enemy production only at "the" fortress | `enemyWorld.canProduce/produce` use `enemyFortress.queue` | a mission with several enemy structures cannot produce |
| Start resources | `Economy.create(Balance.match.startIron)` | not per mission / difficulty |
| Drop-off | `gatherCtx.findDropOff` → `playerFortress` | no alternate depots |
| Result stats | `unitsLost`, `unitsKilled`, `economy.gathered` only; `MenuOverlay.stats` string | results screen needs many more counters |
| Camera start | `Level.layout.cameraStart` | fine, moves into the mission |
| Difficulty names | `easy/normal/hard` in `balance.js` and `MenuOverlay` | becomes Story/Warrior/Warchief (M2) |
| Text | all UI strings inline in QML | localisation (M2/M7) |
| Autotest scenario | `Timer` in the game root drives a fixed 31-step script | should become a scenario of the mission/trigger system or stay as the Classic Siege regression |
| Team model | `"player" | "enemy" | "neutral"` strings; enemy is hostile to player only | rescue/prisoner and captured-deposit mechanics need `owner` changes on entities (M4/M5) |

Not coupled (reusable as is): NavGrid, Steering, Economy, Production, Combat, Gather, EnemyAI
core loop (takes an adapter), Touch, the entity views, the asset indirection, the 30 Hz loop,
the HUD's selection/production panels, the wasm asset preload.

## 5. Which mission does the current level fit?

| Candidate | Fit | Why |
|---|---|---|
| Campaign Mission 1 | poor | M1 is a tutorial from a *ruined* outpost: no Foundry at first, tiny army, scripted scouts. The MVP map starts with a complete base and full production. |
| Campaign Mission 2 | good with re-placement | 5 deposits on two sides, a hostile structure to destroy; but "capture three occupied deposits" needs enemy groups on the deposits and an *outpost* instead of a wave-spawning fortress. |
| Separate Classic Siege scenario | **exact** | It *is* the current match. Keeping it verbatim preserves the MVP as required and gives the expansion a regression baseline and the first skirmish scenario. |

**Decision.** The current level is extracted verbatim as the **Classic Siege** scenario
(`app/missions/classic_siege.js`). Mission 2 is authored later as a variant on the same terrain
(different entity list, no/late waves, outpost). Mission 3 reuses the wave system.

## 6. Target architecture (incremental, no rewrite)

```
IronfangGame.qml           controller: sim loop, entities, commands, input  (shrinks over time)
   mission (data)          app/missions/<id>.js  — declarative definition (docs/mission-format.md)
   Mission.js              loader: defaults, validation, difficulty application, entity list
   Objectives.js           objective state machine: active/complete/failed, progress, primary vs optional
   Triggers.js             conditions × actions, once/repeat, timers, regions, counts
   gameEvent(name, data)   single event stream: triggers, (M2+) tutorial, achievements, stats, shell bridge
   M2: Campaign.js Save.js Storage adapter Localization  · M4: Abilities.js Veterancy.js · M6: Achievements.js Statistics.js Survival
```

Rules: pure JS modules with `.pragma library`, tested with qmltestrunner; QML binds to state and
renders. The controller keeps ownership of entities and the simulation; managers are plain
objects it steps or feeds events into.

## 7. Staged plan

| Milestone | Deliverables | Exit criteria |
|---|---|---|
| **M0 Preserve & assess** (this document) | builds/tests verified, behaviour documented, coupling list, level decision, plan, `docs/product-scope.md`, `docs/story-and-campaign.md` | — |
| **M1 Mission foundation** | `missions/classic_siege.js`; `Mission.js`, `Objectives.js`, `Triggers.js`; controller loads a mission, victory/defeat/objective text driven by objectives+triggers; `gameEvent` stream; per-mission start iron, waves, camera; `tests/tst_mission.qml`; `docs/mission-format.md`; README/architecture updated | Classic Siege plays exactly as before (autotest + browser check); all tests pass; wasm build served and checked |
| **M2 Campaign shell** | main menu, campaign map, briefing, results, `Campaign.js` progression, `Save.js` + storage adapter (desktop file / browser localStorage), Story/Warrior/Warchief, `Localization` foundation (keys + en + pt-BR files, completeness test) | new campaign → mission → results → unlock → continue after restart |
| **M3 Tutorial + Missions 1–3** | `Tutorial` steps in the mission format, Missions 1–3 authored, medals, optional objectives, balance pass | stop for external playtesting |
| **M4 Tactical depth** | abilities (Guard Stance, Focus Fire, Ground Smash, Emergency Repair), veterancy, repair, destructible gates, environmental triggers, richer enemy compositions | tests for cooldowns, repair costs, veterancy |
| **M5 Complete campaign** | Missions 4–7, story presentation, dialogue, checkpoints, finale, campaign balance | all missions have tested victory/defeat |
| **M6 Replayability** | Survival, achievements, statistics, up to 3 skirmish scenarios, Codex | long-session stability measured |
| **M7 Commercial polish** | settings, remapping, accessibility, en + pt-BR complete, audio and VFX passes, loading, credits/licences, save migration and failure handling | no placeholder visible |
| **M8 QtMesh Games readiness** | event bridge finalised, lifecycle validated, shell saves, pause/overlay, desktop packaging, standalone + wasm confirmed, release checklist | definition of done |

After every milestone: desktop build → tests → manual pass → wasm build → HTTP serve and check →
compare with the previous milestone → fix regressions → report → separate commit.

## 8. Risks and constraints noted during assessment

* **Audio on wasm** is disabled (Clayground #216). The commercial target is desktop, so the audio
  pass (M7) is desktop-first; the browser demo stays silent until the upstream fix lands.
* **Text rendering / fonts**: the UI uses the system font. Localisation with pt-BR diacritics is
  fine on desktop; on wasm the bundled Qt fonts cover Latin-1 — verify in M2.
* **Save storage on wasm**: `localStorage` via `Qt.labs.settings`/`QSettings` is limited (~5 MB,
  synchronous). The save is small (KBs); the storage adapter abstracts it anyway.
* **Team model** for rescue/capture needs an `owner` change path on `UnitView`/`BuildingView`
  (team ring colour, selection filters use `team === "player"`) — planned for M4/M5, not M1.
* **Unit limits**: keep ≤ 40 simultaneous units on wasm unless profiling shows headroom.
* **Clayground upstream**: Web Runtime PR #215 pending; none of this plan depends on it.

## 9. Milestone log

### M1 — Mission foundation (2026-09-06)

* `app/missions/classic_siege.js`: the MVP level as a mission (entities, camera, iron, enemy
  commander, one primary objective with HP progress, four triggers: intro, fortress down,
  home lost, repeating wave warning, outcome texts). `config/level.js` removed.
* `scripts/Mission.js` (validate / load / difficulty merge / defaults / enemy config),
  `scripts/Objectives.js` (hidden → active → complete | failed, declarative progress, events),
  `scripts/Triggers.js` (event + polled conditions, once/repeat, delay, requires, unknown
  actions reported not thrown).
* `IronfangGame.qml`: `startMatch(difficulty, definition)`, `buildLevel` from the entity list,
  `gameEvent()` stream, `stepMission()`, action table, enemy producer/target from tags,
  `checkEnd` replaced by the objective rule; new counters `unitsProduced`, `buildingsLost`,
  `buildingsDestroyed`. `UnitView`/`BuildingView` gained `tag`, buildings `productionEnabled`.
* HUD: primary objective line from the mission, objectives panel (top-left) with state markers.
* Tests: `tests/tst_mission.qml` (12 cases) — 23/23 ctest entries green.
* Verified: desktop autotest identical in shape to the pre-M1 run (19 buildings, 7 units, 150
  iron, wave 1 at ~2 min, restart OK, 120 FPS); wasm build served over HTTP runs the same
  autotest at 56–60 FPS, 22.7 MB transferred, no console errors.
* Known limitations: `revealArea`, `unlockAbility`, `activateCheckpoint` are accepted no-ops
  until M4/M5; `showDialogue` is a HUD flash until the campaign shell; difficulty names remain
  easy/normal/hard until M2; texts are still literal English (localisation keys in M2).
