// Ironfang balance - every gameplay number lives here (see docs/balancing.md).
// Units: metres, seconds, hit points, iron.
.pragma library

var MELEE = 0                         // range 0 = melee (contact distance = radii + meleeReach)
var meleeReach = 0.5

var units = {
    goblin_worker: {
        name: "Goblin Worker", cost: 50, buildTime: 7,
        hp: 45, damage: 3, range: MELEE, cooldown: 1.2, speed: 3.4, radius: 0.45,
        carry: 10, gatherTime: 2.6,
        producedBy: "clan_fortress", role: "worker"
    },
    orc_warrior: {
        name: "Orc Warrior", cost: 80, buildTime: 9,
        hp: 110, damage: 14, range: MELEE, cooldown: 1.1, speed: 3.2, radius: 0.55,
        producedBy: "war_foundry", role: "melee"
    },
    orc_archer: {
        name: "Orc Archer", cost: 110, buildTime: 11,
        hp: 65, damage: 10, range: 7, cooldown: 1.5, speed: 3.0, radius: 0.5,
        projectileSpeed: 22, preferredRange: 5.5,
        producedBy: "war_foundry", role: "ranged"
    },
    ironhide_ogre: {
        name: "Ironhide Ogre", cost: 280, buildTime: 20,
        hp: 400, damage: 40, range: MELEE, cooldown: 2.0, speed: 2.3, radius: 0.8,
        buildingDamageMultiplier: 2.5,
        producedBy: "war_foundry", role: "siege"
    }
}

var buildings = {
    clan_fortress:  { name: "Clan Fortress",  hp: 2500, produces: ["goblin_worker"], footprint: { w: 10, d: 10 }, dropOff: true },
    war_foundry:    { name: "War Foundry",    hp: 1400, produces: ["orc_warrior", "orc_archer", "ironhide_ogre"], footprint: { w: 8, d: 8 } },
    enemy_fortress: { name: "Enemy Fortress", hp: 2500, produces: [], footprint: { w: 10, d: 10 } },
    iron_deposit:   { name: "Iron Deposit",   hp: 0,    produces: [], footprint: { w: 4, d: 4 }, iron: 600, resource: true },
    rocks_large:    { name: "Rocks",          hp: 0,    produces: [], footprint: { w: 5, d: 4 }, obstacle: true },
    rocks_small:    { name: "Rocks",          hp: 0,    produces: [], footprint: { w: 3, d: 3 }, obstacle: true },
    dead_tree:      { name: "Dead Ironwood",  hp: 0,    produces: [], footprint: { w: 3, d: 3 }, obstacle: true },
    broken_cart:    { name: "Broken Cart",    hp: 0,    produces: [], footprint: { w: 4, d: 3 }, obstacle: true }
}

var match = {
    startIron: 150,
    startWorkers: 3,
    startWarriors: 1,
    aggroRadius: 9,                   // auto-acquire targets within this distance
    leashRadius: 16,                  // stop chasing beyond this from where the chase started
    deathLinger: 2.4,                 // seconds a corpse stays (Death clip length)
    repathInterval: 0.5,
    simStep: 1 / 30
}

// Enemy: passive income instead of a worker economy (documented simplification). The AI
// spends it on a rotation of units and attacks in waves that grow over the match.
var enemy = {
    passiveIncomePerSecond: 2.4,      // ~145 iron/min, comparable to 3 busy workers
    startIron: 200,
    firstWaveDelay: 110,              // seconds before the first attack leaves
    waveInterval: 85,                 // seconds between waves
    waveBaseSize: 3,                  // units in the first wave
    waveGrowth: 1,                    // +units per wave
    waveMaxSize: 12,
    ogreEveryNthWave: 3,              // an ogre joins every 3rd wave
    productionOrder: ["orc_warrior", "orc_warrior", "orc_archer"],
    garrisonMin: 2,                   // defenders that never leave the fortress
    rallyOffset: { x: -8, z: 8 }      // where produced units gather relative to the fortress
}

var difficulty = {
    easy:   { incomeScale: 0.7, waveGrowth: 0, waveInterval: 110 },
    normal: { incomeScale: 1.0, waveGrowth: 1, waveInterval: 85 },
    hard:   { incomeScale: 1.35, waveGrowth: 2, waveInterval: 70 }
}

function unit(typeId) { return units[typeId] }
function building(typeId) { return buildings[typeId] }
