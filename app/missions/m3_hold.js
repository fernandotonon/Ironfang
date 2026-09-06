// Mission 3 - Hold the Foundry. Defence on the existing wave system: a countdown before the
// first wave, waves from the north plus flank groups from the west and east, an assault leader
// (Ironhide Ogre) after the fifth wave. Completing it unlocks Survival (missions/campaign.js).
.pragma library

var mission = {
    id: "m3_hold",
    format: 1,
    kind: "campaign",
    title: "mission.m3.title",
    description: "mission.m3.tagline",
    briefing: { intro: "m3.brief" },

    map: { size: 64, camera: { x: 32, z: 44, yaw: 0, pitch: 52, distance: 44 } },
    player: { iron: 300 },
    enemy: {
        producer: "enemy_fortress", target: "player_foundry",
        waves: { startIron: 300, passiveIncomePerSecond: 3.0, firstWaveDelay: 150, waveInterval: 90,
                 waveBaseSize: 3, waveGrowth: 2, waveMaxSize: 12, ogreEveryNthWave: 4, garrisonMin: 0,
                 productionOrder: ["orc_warrior", "orc_warrior", "orc_archer"], rallyOffset: { x: 0, z: 8 } }
    },
    difficulty: {
        story:    { enemy: { waves: { firstWaveDelay: 210, waveGrowth: 1, waveMaxSize: 8 } } },
        warchief: { enemy: { waves: { firstWaveDelay: 120, waveBaseSize: 4, ogreEveryNthWave: 3 } } }
    },

    entities: [
        { tag: "player_fortress", type: "clan_fortress", team: "player", x: 32, z: 54, rally: { x: 32, z: 44 } },
        { tag: "player_foundry",  type: "war_foundry",   team: "player", x: 32, z: 38, rally: { x: 32, z: 30 } },
        { type: "iron_deposit", x: 18, z: 52, iron: 700 },
        { type: "iron_deposit", x: 46, z: 52, iron: 700 },
        { type: "iron_deposit", x: 32, z: 62, iron: 500 },
        { tag: "enemy_fortress", type: "enemy_fortress", team: "enemy", x: 32, z: 6, rally: { x: 32, z: 16 } },
        // natural chokepoints north of the foundry
        { type: "rocks_large", x: 20, z: 28 }, { type: "rocks_large", x: 44, z: 28 },
        { type: "rocks_large", x: 12, z: 40 }, { type: "rocks_large", x: 52, z: 40 },
        { type: "rocks_small", x: 26, z: 22 }, { type: "rocks_small", x: 38, z: 22 },
        { type: "dead_tree", x: 8, z: 18 },   { type: "dead_tree", x: 56, z: 18 },
        { type: "dead_tree", x: 14, z: 60 },  { type: "dead_tree", x: 50, z: 60 },
        { type: "broken_cart", x: 32, z: 26 },
        // garrison
        { type: "goblin_worker", team: "player", x: 28, z: 48 }, { type: "goblin_worker", team: "player", x: 30, z: 49 },
        { type: "goblin_worker", team: "player", x: 34, z: 49 }, { type: "goblin_worker", team: "player", x: 36, z: 48 },
        { tag: "rukhar", type: "orc_warrior", team: "player", x: 30, z: 33 },
        { type: "orc_warrior", team: "player", x: 34, z: 33 }, { type: "orc_warrior", team: "player", x: 32, z: 34 },
        { type: "orc_archer", team: "player", x: 29, z: 36 }, { type: "orc_archer", team: "player", x: 35, z: 36 }
    ],

    objectives: [
        { id: "prepare", text: "m3.obj.prepare", progress: { type: "timer", seconds: 150 } },
        { id: "protect", text: "m3.obj.protect", completeOnVictory: true },
        { id: "survive", text: "m3.obj.survive", target: 5 },
        { id: "leader",  text: "m3.obj.leader", hidden: true, progress: { type: "entityHp", tag: "assault_leader" } },
        { id: "foundry_hp", text: "m3.obj.foundry_hp", optional: true, completeOnVictory: { type: "entityHpAtLeast", tag: "player_foundry", fraction: 0.5 } },
        { id: "few_losses", text: "m3.obj.few_losses", optional: true, completeOnVictory: { type: "unitsLostAtMost", n: 5 } }
    ],

    medals: { steel: { optionalAll: true }, gold: { optionalAll: true, time: 1080 } },

    triggers: [
        { id: "intro", when: { type: "missionStarted" },
          actions: [ { type: "showDialogue", speaker: "speaker.rukhar", text: "m3.dlg.intro" } ] },
        { id: "wave_warning", when: { type: "waveLaunched" }, repeat: true,
          actions: [ { type: "message", text: "m3.msg.wave" }, { type: "playAudio", sound: "wave_incoming" } ] },
        { id: "wave_done", when: { type: "waveCompleted" }, repeat: true,
          actions: [ { type: "progressObjective", id: "survive", delta: 1 }, { type: "message", text: "m3.msg.wave_held" } ] },
        // flanks: the second and fourth waves bring groups from the sides
        { id: "flank_west", when: { type: "waveLaunched" }, requires: [], delay: 20,
          actions: [ { type: "spawnUnits", team: "enemy", attack: "player_foundry",
                       units: [ { type: "orc_warrior", x: 3, z: 30 }, { type: "orc_warrior", x: 4, z: 33 }, { type: "orc_archer", x: 2, z: 36 } ] },
                     { type: "message", text: "m3.msg.flank_west" } ] },
        { id: "flank_east", when: { type: "timerElapsed", seconds: 200, after: "flank_west" },
          actions: [ { type: "spawnUnits", team: "enemy", attack: "player_foundry",
                       units: [ { type: "orc_warrior", x: 61, z: 30 }, { type: "orc_warrior", x: 60, z: 33 }, { type: "orc_archer", x: 62, z: 36 }, { type: "orc_archer", x: 61, z: 27 } ] },
                     { type: "message", text: "m3.msg.flank_east" } ] },
        { id: "leader_comes", when: { type: "objectiveCompleted", id: "survive" },
          actions: [ { type: "spawnUnits", team: "enemy", attack: "player_foundry",
                       units: [ { tag: "assault_leader", type: "ironhide_ogre", x: 32, z: 3 }, { type: "orc_warrior", x: 29, z: 4 }, { type: "orc_warrior", x: 35, z: 4 }, { type: "orc_archer", x: 32, z: 1 } ] },
                     { type: "addObjective", id: "leader" },
                     { type: "showDialogue", speaker: "speaker.rukhar", text: "m3.dlg.leader" },
                     { type: "playAudio", sound: "wave_incoming" } ] },
        { id: "leader_down", when: { type: "entityDestroyed", tag: "assault_leader" },
          actions: [ { type: "completeObjective", id: "leader" } ] },
        { id: "foundry_lost", when: { type: "entityDestroyed", tag: "player_foundry" },
          actions: [ { type: "failObjective", id: "protect" } ] },
        { id: "home_lost", when: { type: "entityDestroyed", tag: "player_fortress" },
          actions: [ { type: "endMission", result: "defeat" } ] }
    ],

    outcome: { victory: "m3.victory", defeat: "m3.defeat" }
}
