// Mission 2 - The Stolen Mine. Resource control and small assaults on the First Siege terrain:
// three deposits held by Bloodmaw groups, a Bloodmaw outpost (placeholder model) that sends
// small raids, archers now available. Format: docs/mission-format.md.
.pragma library

var mission = {
    id: "m2_stolen_mine",
    format: 1,
    kind: "campaign",
    title: "mission.m2.title",
    description: "mission.m2.tagline",
    briefing: { intro: "m2.brief" },

    map: { size: 64, camera: { x: 18, z: 50, yaw: 0, pitch: 52, distance: 42 } },
    player: { iron: 200 },
    enemy: {
        producer: "enemy_outpost", target: "player_fortress",
        waves: { startIron: 150, passiveIncomePerSecond: 1.2, firstWaveDelay: 240, waveInterval: 120,
                 waveBaseSize: 2, waveGrowth: 1, waveMaxSize: 6, ogreEveryNthWave: 0, garrisonMin: 1,
                 productionOrder: ["orc_warrior", "orc_archer"], rallyOffset: { x: -6, z: 6 } }
    },
    difficulty: {
        story:    { enemy: { waves: { firstWaveDelay: 320, waveMaxSize: 4 } } },
        warchief: { enemy: { waves: { firstWaveDelay: 200, waveBaseSize: 3, waveMaxSize: 8 } } }
    },

    entities: [
        { tag: "player_fortress", type: "clan_fortress", team: "player", x: 13, z: 51, rally: { x: 24, z: 47 } },
        { tag: "player_foundry",  type: "war_foundry",   team: "player", x: 25, z: 56, rally: { x: 24, z: 47 } },
        { type: "iron_deposit", x: 8, z: 59, iron: 350 },
        // the stolen mines
        { tag: "mine_a", type: "iron_deposit", x: 26, z: 34, iron: 600 },
        { tag: "mine_b", type: "iron_deposit", x: 44, z: 44, iron: 600 },
        { tag: "mine_c", type: "iron_deposit", x: 38, z: 16, iron: 600 },
        { tag: "enemy_outpost", type: "enemy_outpost", team: "enemy", x: 52, z: 12, rally: { x: 46, z: 18 } },
        { type: "iron_deposit", x: 58, z: 26, iron: 400 },
        { type: "rocks_large", x: 34, z: 26 }, { type: "rocks_large", x: 50, z: 34 },
        { type: "rocks_large", x: 9,  z: 9 },  { type: "rocks_small", x: 18, z: 30 },
        { type: "rocks_small", x: 56, z: 51 }, { type: "rocks_small", x: 30, z: 8 },
        { type: "dead_tree",   x: 12, z: 22 }, { type: "dead_tree",   x: 48, z: 52 },
        { type: "dead_tree",   x: 33, z: 60 }, { type: "dead_tree",   x: 60, z: 40 },
        { type: "broken_cart", x: 40, z: 30 },
        // garrisons on the mines
        { type: "orc_warrior", team: "enemy", x: 28, z: 31 }, { type: "orc_archer", team: "enemy", x: 24, z: 31 },
        { type: "orc_warrior", team: "enemy", x: 46, z: 41 }, { type: "orc_warrior", team: "enemy", x: 42, z: 41 }, { type: "orc_archer", team: "enemy", x: 44, z: 40 },
        { type: "orc_warrior", team: "enemy", x: 36, z: 13 }, { type: "orc_warrior", team: "enemy", x: 40, z: 13 }, { type: "orc_archer", team: "enemy", x: 38, z: 12 }, { type: "orc_archer", team: "enemy", x: 41, z: 18 },
        { type: "orc_warrior", team: "enemy", x: 48, z: 16 }, { type: "orc_archer", team: "enemy", x: 50, z: 18 },
        // the warband
        { tag: "w1", type: "goblin_worker", team: "player", x: 15, z: 44 },
        { tag: "w2", type: "goblin_worker", team: "player", x: 17, z: 44 },
        { tag: "w3", type: "goblin_worker", team: "player", x: 19, z: 45 },
        { tag: "rukhar", type: "orc_warrior", team: "player", x: 22, z: 48 },
        { type: "orc_warrior", team: "player", x: 24, z: 49 },
        { type: "orc_archer",  team: "player", x: 21, z: 50 }
    ],

    objectives: [
        { id: "capture", text: "m2.obj.capture", target: 3 },
        { id: "control", text: "m2.obj.control", hidden: true, progress: { type: "timer", seconds: 120 } },
        { id: "outpost", text: "m2.obj.outpost", hidden: true, progress: { type: "entityHp", tag: "enemy_outpost" } },
        { id: "fast",    text: "m2.obj.fast", optional: true, completeOnVictory: { type: "timeAtMost", seconds: 900 } },
        { id: "workers", text: "m2.obj.workers", optional: true, completeOnVictory: true },
        { id: "lost_workers", text: "internal", internal: true, optional: true, target: 2 }
    ],

    medals: { steel: { optionalAll: true }, gold: { optionalAll: true, time: 900 } },

    triggers: [
        { id: "intro", when: { type: "missionStarted" },
          actions: [ { type: "showDialogue", speaker: "speaker.rukhar", text: "m2.dlg.intro" } ] },
        { id: "clear_a", when: { type: "unitLeftRegion", region: { x: 20, z: 28, w: 12, d: 12 }, team: "enemy" },
          actions: [ { type: "progressObjective", id: "capture", delta: 1 }, { type: "message", text: "m2.msg.mine_taken" } ] },
        { id: "clear_b", when: { type: "unitLeftRegion", region: { x: 38, z: 38, w: 12, d: 12 }, team: "enemy" },
          actions: [ { type: "progressObjective", id: "capture", delta: 1 }, { type: "message", text: "m2.msg.mine_taken" } ] },
        { id: "clear_c", when: { type: "unitLeftRegion", region: { x: 32, z: 10, w: 12, d: 12 }, team: "enemy" },
          actions: [ { type: "progressObjective", id: "capture", delta: 1 }, { type: "message", text: "m2.msg.mine_taken" } ] },
        { id: "captured", when: { type: "objectiveCompleted", id: "capture" },
          actions: [ { type: "showDialogue", speaker: "speaker.foreman", text: "m2.dlg.captured" },
                     { type: "addObjective", id: "control" }, { type: "startWave" } ] },
        { id: "controlled", when: { type: "objectiveCompleted", id: "control" },
          actions: [ { type: "showDialogue", speaker: "speaker.rukhar", text: "m2.dlg.control" },
                     { type: "addObjective", id: "outpost" } ] },
        { id: "outpost_down", when: { type: "entityDestroyed", tag: "enemy_outpost" },
          actions: [ { type: "completeObjective", id: "outpost" } ] },
        { id: "wave_warning", when: { type: "waveLaunched" }, repeat: true,
          actions: [ { type: "message", text: "m2.msg.raid" }, { type: "playAudio", sound: "wave_incoming" } ] },
        { id: "w1_lost", when: { type: "entityDestroyed", tag: "w1" }, actions: [ { type: "progressObjective", id: "lost_workers", delta: 1 } ] },
        { id: "w2_lost", when: { type: "entityDestroyed", tag: "w2" }, actions: [ { type: "progressObjective", id: "lost_workers", delta: 1 } ] },
        { id: "w3_lost", when: { type: "entityDestroyed", tag: "w3" }, actions: [ { type: "progressObjective", id: "lost_workers", delta: 1 } ] },
        { id: "too_many_lost", when: { type: "objectiveCompleted", id: "lost_workers" },
          actions: [ { type: "failObjective", id: "workers" } ] },
        { id: "home_lost", when: { type: "entityDestroyed", tag: "player_fortress" },
          actions: [ { type: "endMission", result: "defeat" } ] }
    ],

    outcome: { victory: "m2.victory", defeat: "m2.defeat" }
}
