# Mission format (format 1)

A mission is a plain JavaScript module in `app/missions/<id>.js` (`.pragma library`) exporting
`var mission = { ... }`. `scripts/Mission.js` validates it, applies the difficulty overrides,
fills defaults and hands the result to the game controller, which builds the world from
`entities`, creates the `Objectives` and `Triggers` state and then only feeds events. Nothing
in `IronfangGame.qml` knows about a particular mission.

The reference definition is `app/missions/classic_siege.js` (the original *First Siege* match).

```js
var mission = {
    id: "classic_siege",              // stable identifier (saves, achievements, unlocks)
    format: 1,
    kind: "scenario",                 // campaign | scenario | survival
    title: "Classic Siege",           // M2: becomes a localisation key
    description: "...",

    map: { size: 64, camera: { x: 18, z: 50, yaw: 0, pitch: 52, distance: 42 } },
    player: { iron: 150 },
    enemy: { producer: "enemy_fortress", target: "player_fortress", waves: { firstWaveDelay: 110 } },   // or omit: no enemy commander
    difficulty: { easy: { player: { iron: 250 }, enemy: { waves: { waveGrowth: 0 } } }, hard: { ... } },

    entities: [ ... ],
    objectives: [ ... ],
    triggers: [ ... ],
    victory: { auto: true },          // all primary objectives complete -> victory (default)
    outcome: { victory: "text", defeat: "text" }
}
```

## Entities

One entry per unit, building, resource node or obstacle. The type decides the kind
(`Balance.units` → unit, `Balance.buildings` → building).

| Field | Meaning | Default |
|---|---|---|
| `type` | `goblin_worker`, `orc_warrior`, `orc_archer`, `ironhide_ogre`, `clan_fortress`, `war_foundry`, `enemy_fortress`, `iron_deposit`, `rocks_large`, `rocks_small`, `dead_tree`, `broken_cart` | required |
| `x`, `z` | metres, inside `0..map.size` | required |
| `team` | `player`, `enemy`, `neutral` | units `player`, buildings `neutral` |
| `tag` | unique name other parts of the mission refer to | none |
| `rally` | `{x, z}` where a producer's finished units go | none |
| `iron` | resource nodes: iron left | `Balance.buildings.iron_deposit.iron` (600) |

Reserved tags the controller understands: `player_fortress` (drop-off, Home key), `player_foundry`,
`enemy_fortress`. `enemy.producer` / `enemy.target` must name tagged buildings.

## Difficulty

`difficulty.<name>` is deep-merged into the definition (objects merge, arrays and scalars
replace), then removed. `Balance.difficulty` (income scale, wave growth, wave interval) still
applies on top through `EnemyAI.create`. Do not fork mission logic by difficulty; override
values.

## Objectives

| Field | Meaning |
|---|---|
| `id`, `text` | required (`text` becomes a key in M2) |
| `optional: true` | optional objective (does not block victory; failing it does not end the mission) |
| `hidden: true` | not shown until an `addObjective` action reveals it |
| `progress` | declarative progress, refreshed every simulation step |

Progress specs:

* `{ type: "entityHp", tag }` — display only ("… (1200 HP)"); a trigger completes the objective.
  The tag may be created later by a `spawnUnits` action (e.g. an assault leader).
* `{ type: "unitCount", team, unitType?, count, op? }` — completes when the count is reached;
  with `op: "<="` it completes when the count drops to `count` (e.g. "no scouts left").
* `{ type: "produced", team?, unitType?, count }` — units produced during the mission.
* `{ type: "resource", amount }` — completes when the player's iron reaches `amount`.
* `{ type: "timer", seconds }` — counts from the moment the objective became active; completes
  at `seconds` ("prepare your defences", "hold the region").
* a plain `target: N` with no spec — a counter driven by `progressObjective { id, delta: 1 }`.

Or none, and triggers call `completeObjective` / `failObjective` / `progressObjective`.

Extra flags:

* `completeOnVictory` — resolved when the mission is won instead of during play: `true`
  (always complete), `{ type: "entityHpAtLeast", tag, fraction }`, `{ type: "unitsLostAtMost", n }`,
  `{ type: "buildingsLostAtMost", n }`, `{ type: "timeAtMost", seconds }` (scaled by the
  difficulty's `timerScale`). Such objectives never block the automatic victory rule; unmet ones
  are marked failed on the results screen. Use it for "protect X" and optional challenges.
* `internal: true` — a bookkeeping counter (never shown, never counted in results), e.g.
  "workers lost" feeding a `failObjective` trigger.

State machine: `hidden → active → complete | failed`. With `victory.auto` (default) the mission
is won when every primary objective is complete; a failed primary objective is a defeat.
Every change emits `objectiveAdded` / `objectiveCompleted` / `objectiveFailed` events that
triggers can chain on.

## Triggers

```js
{ id: "fortress_down",                    // optional; needed for `after` references
  when: { type: "entityDestroyed", tag: "enemy_fortress" },
  repeat: false,                          // default: fire once
  delay: 2,                               // optional: seconds between condition and actions
  requires: ["secure_deposits"],          // optional: objective ids that must be complete
  actions: [ { type: "completeObjective", id: "destroy_fortress" } ] }
```

### Conditions

Event conditions (matched against game events; extra fields filter):

| `when.type` | Filters | Emitted when |
|---|---|---|
| `missionStarted` | | the world is built |
| `entityDestroyed` | `tag`, `entityType`, `team` | a unit dies or a building falls |
| `unitProduced` | `unitType`, `team`, `tag` (producer) | a production queue finishes |
| `entitySelected` | `tag`, `entityType` | exactly one entity is selected |
| `objectiveCompleted`, `objectiveFailed` | `id` | objective state changes |
| `waveLaunched` | | the enemy commander sends a wave (`size`, `wave`) |
| `waveCompleted` | | every unit of the latest wave is dead (`wave`) |
| `orderIssued` | `kind`: move, attack, gather, return | the player gives an order |
| `resourceDeposited` | | a worker delivers iron (`amount`, `total`) |
| `productionQueued` | `unitType`, `tag` | the player queues a unit |
| `cameraMoved` | | the camera pivot moved or zoomed noticeably (once) |
| `tutorialStep`, `tutorialFinished` | `id` | tutorial progress (`skipped` on finish) |
| `missionEnded` | | `result`, `medal` |
| `buildingActivated`, `dialogueCompleted`, `checkpointReached` | `id` / `tag` | reserved for M4–M5 |

Polled conditions (evaluated each step, fire on the rising edge — a repeating region trigger
fires once per entry):

| `when.type` | Fields |
|---|---|
| `timerElapsed` | `seconds`, optional `after: <triggerId>` (counted from that trigger firing) |
| `resourceReached` | `amount` |
| `unitCountReached` | `team`, `unitType?`, `count`, `op` (`">="` default or `"<="`) |
| `unitEnteredRegion`, `unitLeftRegion` | `region: {x, z, w, d}`, `team?`, `unitType?` |

### Actions

| `type` | Fields | Effect |
|---|---|---|
| `message` | `text` | HUD flash |
| `showDialogue` | `speaker`, `text` | M1: flash; M5: portrait dialogue |
| `playAudio` | `sound`, `volume` | `AudioController.play` |
| `completeObjective`, `failObjective` | `id` | |
| `addObjective` | objective fields (`id`, `text`, `optional`, `progress`) | adds or reveals |
| `progressObjective` | `id`, `current`, `target` or `delta` | set or increment a counter |
| `addResources` | `amount` | player iron |
| `spawnUnits` | `units: [{type, team?, x?, z?, tag?}]`, `team`, `x`, `z`, `attack: <tag>` | spawns; with `attack`, attack-moves on that entity |
| `startWave` | | the enemy commander launches its next wave now |
| `enableProduction` | `tag`, `enabled` | toggles a producer (HUD buttons grey out) |
| `endMission` | `result: victory|defeat` | |
| `revealArea`, `unlockAbility`, `activateCheckpoint` | | accepted, no-ops until fog/abilities/checkpoints exist (M4/M5) |

Unknown action types are reported in `Triggers` state (`unknownActions`) and skipped, never
thrown; `Mission.validate` rejects them before a mission ships.

## Entity flags

`productionEnabled: false` (a building that cannot produce until an `enableProduction` action;
the HUD greys its buttons and says "not operational"), `hpFraction: 0.6` (starts damaged).

## Tutorial

```js
tutorial: [
    { id: "camera", text: "tutorial.m1.camera", doneWhen: { type: "cameraMoved" } },
    { id: "select", text: "tutorial.m1.select", doneWhen: { type: "entitySelected" }, highlight: "world:rukhar" },
    { id: "produce", text: "tutorial.m1.produce", doneWhen: { type: "productionQueued", unitType: "orc_warrior" }, highlight: "hud:produce" }
]
```

`scripts/Tutorial.js` shows one step at a time in the HUD (`Hud.qml` tutorial panel with a Skip
link). `doneWhen` uses the trigger condition vocabulary (event or polled; `kind` filters
`orderIssued`). Actions already performed count: the manager keeps the mission's event history, so
a step whose event already happened completes at once, and polled steps are evaluated as soon as
they show. `highlight` pulses a HUD panel (`hud:iron`, `hud:objectives`, `hud:selection`,
`hud:produce`) or draws a ring under a tagged world entity (`world:<tag>`). Finishing (not
skipping) sets `progress.tutorial.completed`; the tutorial is replayable through Mission 1.

## Medals

`medals: { steel: { optionalAll: true }, gold: { optionalAll: true, time: 600, maxUnitsLost: 3, maxBuildingsLost: 0 } }`
— published in the briefing and evaluated by `Campaign.medalFor`; `time` is multiplied by the
difficulty's `timerScale`. Iron is always "complete the mission".

## Game events

The controller emits one stream through `gameEvent(type, payload)`; triggers consume it today,
tutorial, achievements, statistics and the QtMesh Games bridge will consume the same stream.
Payloads always carry `time` (match seconds). Current events: `missionStarted {id}`,
`entityDestroyed {tag, entityType, team, isUnit, byTeam, byType}`, `unitProduced {unitType, team,
tag}`, `entitySelected {tag, entityType, team}`, `waveLaunched {size, wave}`,
`objectiveAdded/Completed/Failed {id, primary}`.

## Validation

`Mission.validate(def)` returns a list of problems (unknown types, out-of-map positions, bad
teams, duplicate tags/ids, unknown conditions/actions, dangling tag or objective references,
bad `endMission.result`). `Mission.load` throws when the list is not empty.
`tests/tst_mission.qml` covers the loader, objectives, triggers and the Classic Siege
victory/defeat/restart flow.
