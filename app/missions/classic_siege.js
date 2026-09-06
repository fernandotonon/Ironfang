// Classic Siege - the original "First Siege" match, verbatim, as a mission definition.
// This is the regression baseline for the mission system and the first skirmish scenario.
// Format: docs/mission-format.md. Positions in metres on a `map.size` x `map.size` ground
// plane, origin at a corner, +x right, +z towards the camera (south). Player base south-west,
// enemy north-east.
.pragma library

var mission = {
    id: "classic_siege",
    format: 1,
    kind: "scenario",                        // campaign | scenario | survival
    title: "scenario.classic_siege.title",
    description: "scenario.classic_siege.tagline",

    map: {
        size: 64,
        camera: { x: 18, z: 50, yaw: 0, pitch: 52, distance: 42 }
    },

    player: { iron: 150 },

    // Enemy commander (EnemyAI.js): produces at `producer`, sends waves at `target`.
    // `waves` overrides fields of Balance.enemy; the difficulty table still applies on top.
    enemy: { producer: "enemy_fortress", target: "player_fortress", waves: {} },

    // Difficulty overrides are deep-merged into the definition (player / enemy / objectives...).
    difficulty: {},

    entities: [
        { tag: "player_fortress", type: "clan_fortress", team: "player", x: 13, z: 51, rally: { x: 24, z: 47 } },
        { tag: "player_foundry",  type: "war_foundry",   team: "player", x: 25, z: 56, rally: { x: 24, z: 47 } },
        { type: "iron_deposit", x: 6,  z: 38 },
        { type: "iron_deposit", x: 21, z: 41 },
        { type: "iron_deposit", x: 8,  z: 59 },
        { tag: "enemy_fortress", type: "enemy_fortress", team: "enemy", x: 51, z: 12, rally: { x: 43, z: 20 } },
        { type: "iron_deposit", x: 57, z: 25 },
        { type: "iron_deposit", x: 40, z: 6 },
        { type: "rocks_large", x: 32, z: 33 }, { type: "rocks_large", x: 41, z: 45 },
        { type: "rocks_large", x: 9,  z: 9 },  { type: "rocks_small", x: 22, z: 27 },
        { type: "rocks_small", x: 56, z: 51 }, { type: "rocks_small", x: 36, z: 12 },
        { type: "dead_tree",   x: 12, z: 22 }, { type: "dead_tree",   x: 48, z: 40 },
        { type: "dead_tree",   x: 31, z: 59 }, { type: "dead_tree",   x: 60, z: 34 },
        { type: "broken_cart", x: 34, z: 21 },
        { type: "goblin_worker", team: "player", x: 15, z: 44 },
        { type: "goblin_worker", team: "player", x: 17, z: 44 },
        { type: "goblin_worker", team: "player", x: 19, z: 45 },
        { type: "orc_warrior",   team: "player", x: 22, z: 48 },
        { type: "orc_warrior", team: "enemy", x: 46, z: 18 },
        { type: "orc_warrior", team: "enemy", x: 49, z: 20 },
        { type: "orc_archer",  team: "enemy", x: 44, z: 16 }
    ],

    objectives: [
        { id: "destroy_fortress", text: "classic_siege.objective.destroy", primary: true,
          progress: { type: "entityHp", tag: "enemy_fortress" } }
    ],

    // Victory: every primary objective complete (default). Defeat: declared by a trigger.
    triggers: [
        { id: "intro", when: { type: "missionStarted" },
          actions: [ { type: "message", text: "classic_siege.intro" } ] },
        { id: "fortress_down", when: { type: "entityDestroyed", tag: "enemy_fortress" },
          actions: [ { type: "completeObjective", id: "destroy_fortress" } ] },
        { id: "home_lost", when: { type: "entityDestroyed", tag: "player_fortress" },
          actions: [ { type: "endMission", result: "defeat" } ] },
        { id: "wave_warning", when: { type: "waveLaunched" }, repeat: true,
          actions: [ { type: "message", text: "classic_siege.wave_warning" },
                     { type: "playAudio", sound: "wave_incoming" } ] }
    ],

    outcome: {
        victory: "classic_siege.victory",
        defeat: "classic_siege.defeat"
    }
}
