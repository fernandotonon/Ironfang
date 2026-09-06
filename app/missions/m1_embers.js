// Mission 1 - Embers of Ironfang. Contextual tutorial: camera, selection, movement, gathering,
// depositing, production, basic combat. No enemy commander; the Bloodmaw scouts are scripted.
// Texts are localisation keys (app/i18n). Format: docs/mission-format.md.
.pragma library

var mission = {
    id: "m1_embers",
    format: 1,
    kind: "campaign",
    title: "mission.m1.title",
    description: "mission.m1.tagline",
    briefing: { intro: "m1.brief" },

    map: { size: 48, camera: { x: 12, z: 40, yaw: 0, pitch: 52, distance: 34 } },
    player: { iron: 20 },
    enemy: null,
    victory: { auto: true },

    entities: [
        // the ruined outpost: a battered fortress and a cold foundry (production disabled until repaired)
        { tag: "player_fortress", type: "clan_fortress", team: "player", x: 30, z: 16, hpFraction: 0.6, rally: { x: 30, z: 25 } },
        { tag: "player_foundry",  type: "war_foundry",   team: "player", x: 38, z: 22, hpFraction: 0.5, productionEnabled: false, rally: { x: 34, z: 29 } },
        { tag: "deposit_near", type: "iron_deposit", x: 24, z: 26, iron: 400 },
        { tag: "deposit_far",  type: "iron_deposit", x: 42, z: 10, iron: 400 },
        { type: "rocks_large", x: 16, z: 30 }, { type: "rocks_small", x: 36, z: 36 },
        { type: "dead_tree", x: 10, z: 12 },  { type: "dead_tree", x: 44, z: 30 },
        { type: "broken_cart", x: 22, z: 38 }, { type: "rocks_small", x: 6, z: 24 },
        // Rukhar's warband arrives from the south-west
        { tag: "w1", type: "goblin_worker", team: "player", x: 8,  z: 42 },
        { tag: "w2", type: "goblin_worker", team: "player", x: 10, z: 43 },
        { tag: "w3", type: "goblin_worker", team: "player", x: 9,  z: 45 },
        { tag: "rukhar", type: "orc_warrior", team: "player", x: 12, z: 41 }
    ],

    objectives: [
        { id: "locate",   text: "m1.obj.locate" },
        { id: "gather",   text: "m1.obj.gather", hidden: true, progress: { type: "resource", amount: 100 } },
        { id: "produce",  text: "m1.obj.produce", hidden: true, progress: { type: "produced", unitType: "orc_warrior", count: 2 } },
        { id: "scouts",   text: "m1.obj.scouts", hidden: true, progress: { type: "unitCount", team: "enemy", op: "<=", count: 0 } },
        { id: "protect",  text: "m1.obj.protect", completeOnVictory: true },
        { id: "no_loss",  text: "m1.obj.no_loss", optional: true, completeOnVictory: true }
    ],

    medals: { steel: { optionalAll: true }, gold: { optionalAll: true, time: 600 } },

    triggers: [
        { id: "intro", when: { type: "missionStarted" },
          actions: [ { type: "showDialogue", speaker: "speaker.rukhar", text: "m1.dlg.intro" } ] },
        { id: "found", when: { type: "unitEnteredRegion", region: { x: 20, z: 8, w: 24, d: 24 }, team: "player" },
          actions: [ { type: "completeObjective", id: "locate" },
                     { type: "showDialogue", speaker: "speaker.foreman", text: "m1.dlg.found" },
                     { type: "addObjective", id: "gather" } ] },
        { id: "forge_lit", when: { type: "objectiveCompleted", id: "gather" },
          actions: [ { type: "enableProduction", tag: "player_foundry", enabled: true },
                     { type: "showDialogue", speaker: "speaker.foreman", text: "m1.dlg.forge" },
                     { type: "playAudio", sound: "produced" },
                     { type: "addObjective", id: "produce" } ] },
        { id: "scouts_arrive", when: { type: "objectiveCompleted", id: "produce" },
          actions: [ { type: "spawnUnits", team: "enemy", attack: "player_fortress",
                       units: [ { type: "orc_warrior", x: 46, z: 3 }, { type: "orc_warrior", x: 45, z: 6 } ] },
                     { type: "addObjective", id: "scouts" },
                     { type: "showDialogue", speaker: "speaker.rukhar", text: "m1.dlg.scouts" },
                     { type: "playAudio", sound: "wave_incoming" } ] },
        { id: "worker_lost", when: { type: "entityDestroyed", entityType: "goblin_worker", team: "player" },
          actions: [ { type: "failObjective", id: "no_loss" } ] },
        { id: "all_workers_lost", when: { type: "unitCountReached", team: "player", unitType: "goblin_worker", count: 0, op: "<=" }, delay: 1,
          actions: [ { type: "failObjective", id: "protect" } ] },
        { id: "home_lost", when: { type: "entityDestroyed", tag: "player_fortress" },
          actions: [ { type: "endMission", result: "defeat" } ] }
    ],

    tutorial: [
        { id: "camera",  text: "tutorial.m1.camera",  doneWhen: { type: "cameraMoved" } },
        { id: "select",  text: "tutorial.m1.select",  doneWhen: { type: "entitySelected" }, highlight: "world:rukhar" },
        { id: "move",    text: "tutorial.m1.move",    doneWhen: { type: "orderIssued", kind: "move" } },
        { id: "locate",  text: "tutorial.m1.locate",  doneWhen: { type: "objectiveCompleted", id: "locate" }, highlight: "world:player_fortress" },
        { id: "gather",  text: "tutorial.m1.gather",  doneWhen: { type: "orderIssued", kind: "gather" }, highlight: "world:deposit_near" },
        { id: "deposit", text: "tutorial.m1.deposit", doneWhen: { type: "resourceDeposited" }, highlight: "hud:iron" },
        { id: "forge",   text: "tutorial.m1.forge",   doneWhen: { type: "objectiveCompleted", id: "gather" }, highlight: "hud:objectives" },
        { id: "produce", text: "tutorial.m1.produce", doneWhen: { type: "productionQueued", unitType: "orc_warrior" }, highlight: "hud:produce" },
        { id: "attack",  text: "tutorial.m1.attack",  doneWhen: { type: "orderIssued", kind: "attack" }, highlight: "hud:selection" },
        { id: "finish",  text: "tutorial.m1.finish",  doneWhen: { type: "objectiveCompleted", id: "scouts" } }
    ],

    outcome: { victory: "m1.victory", defeat: "m1.defeat" }
}
