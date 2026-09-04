# Architecture

Ironfang is a QML application built with Clayground. There is no C++ of its own: gameplay
rules are JavaScript modules, presentation and input are QML, and the framework supplies the
3D camera/input rig, the A* pathfinder, selection decals, performance HUD and the build glue.

```
Main.qml (Window)                         desktop / own-WASM build entry (clay_app convention)
web-runtime/Main.qml (Item)               Clayground Web Runtime entry (no build step)
   └── IronfangGame.qml                   game root: state, systems glue, commands, input, overlays
        ├── GameWorld.qml                 View3D: RtsCamera (OrbitCamera3D), lights, ground, entity roots
        │    ├── BuildingView.qml ×N      fortress / foundry / deposits / obstacles
        │    ├── UnitView.qml ×N          workers, warriors, archers, ogres (both teams)
        │    └── Projectile.qml ×N        archer arrows
        ├── Hud.qml                       iron, objective, selection panel, production
        ├── MenuOverlay.qml               title / pause / victory / defeat, difficulty
        └── PerfHud (Clayground)          render stats (F)
scripts/                                   rules, pure JS (.pragma library), unit-tested
   NavGrid.js  Steering.js  Economy.js  Production.js  Combat.js  Gather.js  EnemyAI.js
config/                                    data
   balance.js  level.js  assets.js
```

## Simulation vs presentation

* A `FrameAnimation` in `IronfangGame` accumulates frame time and runs `step(dt)` at a fixed
  **30 Hz** (`Balance.match.simStep`), at most 8 steps per frame (tab throttling cannot cause a
  runaway catch-up). `simSpeed` multiplies the steps for testing/tuning (`[` `]`).
* Rendering is frame-driven. Entity `x/z` are written by the simulation; Qt Quick 3D animates
  nothing on its own except the skeletal clips (`QtQuick.Timeline` in the imported assets).
* Combat outcomes therefore do not depend on frame rate.

`step(dt)` order: Steering (paths, separation, blocked cells) → workers (Gather FSM) → combat
(target validation, auto-acquire every 0.4 s, attack/approach) → production queues → enemy AI →
projectiles → deaths/cleanup → HUD counters → victory/defeat check.

## Entities

Entities are QML objects created imperatively (`createObject`) and kept in plain arrays
(`units`, `buildings`, `projectiles`) — not `Repeater3D` models, which copy plain-JS items and
hide mutations (Clayground pitfall). Their gameplay state is ordinary QML properties (`hp`,
`team`, `order`, `target`, `path`, `carried`, `gatherState`...), so the HUD binds to them
directly. Plain-object state that QML cannot observe (production queues, the enemy AI) is
refreshed through the `tick` counter: HUD bindings read `game.tick` and re-evaluate each step.

An entity's asset is resolved through `config/assets.js` (type id → model file, scale, foot
offset, yaw, clip names, status). `UnitView`/`BuildingView` load it with `Loader3D` and show a
`Box3D` placeholder until it is ready or when the entry is empty.

## Commands and orders

`issueOrder(x, y)` (right click) resolves the target under the cursor through
`OrbitInput3D.pickAt()` / `groundAt()` and dispatches: enemy → `orderAttack`, iron deposit →
`orderGather` (workers) / move (others), own fortress → `orderReturn`, ground → `orderMove`
(destinations distributed by `NavGrid.distribute`, paths by `GridPathfinder`).
Unit `order` values: `idle | move | attack | attackMove | gather | dead`.

## Navigation

`NavGrid.js` owns a 1 m grid over the 64×64 m map; building footprints block cells. Paths come
from Clayground's `GridPathfinder` (A*, diagonal) and are followed by `Steering.js`
(waypoints, soft separation, refusal to enter blocked cells, heading). Combat approaches use
`Combat.approachPoint`, which understands rectangular footprints.

## Enemy AI

`EnemyAI.js` is a small state loop with passive income (documented in `balance.js`): buy units
in rotation → count the garrison → when the wave timer fires, send everything above the garrison
minimum as an attack-move on the player fortress → schedule the next, larger wave.
It is exercised in `tests/tst_rules.qml` with a stub world.

## Web deployment

Two paths share the same QML: the compiled Qt for WebAssembly app (`scripts/build-wasm.sh`,
assets in `qrc:/`) and the Clayground Web Runtime (`scripts/pack-web-runtime.sh`, assets
preloaded into the runtime's `/game/` filesystem, `assetBase: "file:///game/"`).
