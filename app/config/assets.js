// Asset indirection: gameplay code refers to type ids only. Replace a placeholder by pointing
// `model` at a balsam-imported QML file (see docs/asset-pipeline.md).
// A JS module (not JSON) because XMLHttpRequest cannot read qrc:/ resources by default, while
// `import "config/assets.js"` works from resources, files and HTTP alike.
//   scale      metres per model unit (TRELLIS.2 output is normalised to a ~1 unit box)
//   footOffset model-space distance from the origin down to the feet/base (lifts it to y = 0)
//   yawOffset  degrees, for models that do not face +Z
//   status     placeholder | qtmesheditor
.pragma library

var units = {
    goblin_worker: {
        displayName: "Goblin Worker", model: "assets/runtime/goblin/Goblin.qml", status: "qtmesheditor",
        scale: 1.35, footOffset: 0.39, yawOffset: 0, portrait: "#7fa64a",
        clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death", gather: "Gather" }
    },
    orc_warrior: {
        displayName: "Orc Warrior", model: "assets/runtime/orc/Orc.qml", status: "qtmesheditor",
        scale: 1.8, footOffset: 0.50, yawOffset: 0, portrait: "#5b7a3a",
        clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death" }
    },
    orc_archer: {
        displayName: "Orc Archer", model: "assets/runtime/orc_archer/OrcArcher.qml", status: "qtmesheditor",
        scale: 1.75, footOffset: 0.51, yawOffset: 0, portrait: "#6b8a4a",
        clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death" }
    },
    ironhide_ogre: {
        displayName: "Ironhide Ogre", model: "assets/runtime/ogre/Ogre.qml", status: "qtmesheditor",
        scale: 2.7, footOffset: 0.43, yawOffset: 0, portrait: "#8a6a4a",
        clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death" }
    },
    placeholder: {
        displayName: "Placeholder", model: "", status: "placeholder",
        scale: 1.0, footOffset: 0, yawOffset: 0, portrait: "#777", clips: {}
    }
}

var buildings = {
    clan_fortress:  { displayName: "Clan Fortress",  model: "assets/runtime/clan_fortress/ClanFortress.qml", status: "qtmesheditor", scale: 10,  footOffset: 0.29, yawOffset: 0,  portrait: "#8a5a3a" },
    war_foundry:    { displayName: "War Foundry",    model: "assets/runtime/war_foundry/WarFoundry.qml",     status: "qtmesheditor", scale: 8,   footOffset: 0.35, yawOffset: 90, portrait: "#7a4a3a" },
    enemy_fortress: { displayName: "Enemy Fortress", model: "assets/runtime/clan_fortress/ClanFortress.qml", status: "qtmesheditor", scale: 10,  footOffset: 0.29, yawOffset: 180, portrait: "#8a3a3a" },
    iron_deposit:   { displayName: "Iron Deposit",   model: "assets/runtime/iron_deposit/IronDeposit.qml",   status: "qtmesheditor", scale: 4,   footOffset: 0.28, yawOffset: 0,  portrait: "#6a6a70" },
    rocks_large:    { displayName: "Rocks",          model: "assets/runtime/large_rocks/LargeRocks.qml",     status: "qtmesheditor", scale: 5,   footOffset: 0.46, yawOffset: 0,  portrait: "#606064" },
    rocks_small:    { displayName: "Rocks",          model: "assets/runtime/small_rocks/SmallRocks.qml",     status: "qtmesheditor", scale: 3,   footOffset: 0.29, yawOffset: 0,  portrait: "#606064" },
    dead_tree:      { displayName: "Dead Ironwood",  model: "assets/runtime/dead_tree/DeadIronwoodtree.qml", status: "qtmesheditor", scale: 6,   footOffset: 0.51, yawOffset: 0,  portrait: "#4a3a30" },
    broken_cart:    { displayName: "Broken Cart",    model: "assets/runtime/broken_cart/BrokenCart.qml",     status: "qtmesheditor", scale: 4,   footOffset: 0.21, yawOffset: 0,  portrait: "#5a4a3a" }
}

var projectiles = {
    arrow: { model: "assets/runtime/arrow/Arrow.qml", status: "qtmesheditor", scale: 0.9, footOffset: 0, yawOffset: 0 }
}

function unit(typeId) { return units[typeId] || units["placeholder"] }
function building(typeId) { return buildings[typeId] || null }
