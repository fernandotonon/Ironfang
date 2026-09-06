// Mission loader: turns a declarative mission definition (app/missions/*.js, format in
// docs/mission-format.md) into a validated, difficulty-applied, fully defaulted plain object
// the game controller can build a match from. Pure JS, no QML dependencies.
//
//   var m = Mission.load(ClassicSiege.mission, "normal")
//   m.entities            -> [{ kind: "unit"|"building", type, team, x, z, tag, rally, iron }]
//   m.tags                -> { player_fortress: entityDef, ... }
//   m.player.iron, m.map.size, m.map.camera, m.enemy (or null), m.objectives, m.triggers
//   Mission.validate(def) -> [] or a list of human-readable problems
.pragma library
.import "../config/balance.js" as Balance

var FORMAT = 1

var RESERVED_TAGS = ["player_fortress", "player_foundry", "enemy_fortress"]

function clone(v) {
    if (v === null || typeof v !== "object") return v
    if (Array.isArray(v)) return v.map(clone)
    var out = {}
    for (var k in v) out[k] = clone(v[k])
    return out
}

// deep merge `over` into `base` (objects merge, arrays and scalars replace)
function merge(base, over) {
    if (over === null || typeof over !== "object" || Array.isArray(over)) return clone(over)
    var out = clone(base) || {}
    for (var k in over) {
        out[k] = (typeof out[k] === "object" && out[k] !== null && !Array.isArray(out[k]) &&
                  typeof over[k] === "object" && over[k] !== null && !Array.isArray(over[k]))
                 ? merge(out[k], over[k]) : clone(over[k])
    }
    return out
}

function kindOf(type) {
    if (Balance.units[type]) return "unit"
    if (Balance.buildings[type]) return "building"
    return null
}

var EVENT_CONDITIONS = ["missionStarted", "entityDestroyed", "unitProduced", "entitySelected",
                        "objectiveCompleted", "objectiveFailed", "waveLaunched", "waveCompleted",
                        "buildingActivated", "dialogueCompleted", "checkpointReached"]
var POLLED_CONDITIONS = ["timerElapsed", "resourceReached", "unitCountReached",
                         "unitEnteredRegion", "unitLeftRegion"]
var ACTIONS = ["message", "playAudio", "completeObjective", "failObjective", "addObjective",
               "progressObjective", "spawnUnits", "startWave", "addResources", "endMission",
               "showDialogue", "revealArea", "enableProduction", "unlockAbility", "activateCheckpoint"]

function validate(def) {
    var errors = []
    if (!def || typeof def !== "object") return ["mission definition is not an object"]
    if (!def.id || typeof def.id !== "string") errors.push("missing id")
    if (def.format !== undefined && def.format > FORMAT) errors.push("format " + def.format + " newer than supported " + FORMAT)
    if (!def.map || !(def.map.size > 0)) errors.push("map.size must be > 0")
    if (!Array.isArray(def.entities) || def.entities.length === 0) errors.push("entities must be a non-empty array")
    var tags = {}
    var objectiveIds = {}
    ;(def.entities || []).forEach(function(e, i) {
        var where = "entities[" + i + "]"
        if (!e || !kindOf(e.type)) { errors.push(where + ": unknown type '" + (e && e.type) + "'"); return }
        if (!(typeof e.x === "number" && typeof e.z === "number")) errors.push(where + ": x/z must be numbers")
        else if (def.map && (e.x < 0 || e.z < 0 || e.x > def.map.size || e.z > def.map.size)) errors.push(where + ": outside the map")
        if (e.team && ["player", "enemy", "neutral"].indexOf(e.team) < 0) errors.push(where + ": bad team '" + e.team + "'")
        if (e.tag) { if (tags[e.tag]) errors.push(where + ": duplicate tag '" + e.tag + "'"); tags[e.tag] = true }
    })
    ;(def.objectives || []).forEach(function(o, i) {
        if (!o.id) errors.push("objectives[" + i + "]: missing id")
        else if (objectiveIds[o.id]) errors.push("objectives[" + i + "]: duplicate id '" + o.id + "'")
        objectiveIds[o.id] = true
        if (!o.text) errors.push("objectives[" + i + "]: missing text")
        if (o.progress && o.progress.tag && !tags[o.progress.tag]) errors.push("objectives[" + i + "]: progress tag '" + o.progress.tag + "' not found")
    })
    ;(def.triggers || []).forEach(function(t, i) {
        var where = "triggers[" + (t.id || i) + "]"
        if (!t.when || !t.when.type) { errors.push(where + ": missing when.type"); return }
        if (EVENT_CONDITIONS.indexOf(t.when.type) < 0 && POLLED_CONDITIONS.indexOf(t.when.type) < 0) errors.push(where + ": unknown condition '" + t.when.type + "'")
        if (t.when.tag && !tags[t.when.tag]) errors.push(where + ": tag '" + t.when.tag + "' not found")
        if (!Array.isArray(t.actions) || t.actions.length === 0) { errors.push(where + ": no actions"); return }
        t.actions.forEach(function(a, j) {
            if (!a || ACTIONS.indexOf(a.type) < 0) { errors.push(where + ".actions[" + j + "]: unknown action '" + (a && a.type) + "'"); return }
            if ((a.type === "completeObjective" || a.type === "failObjective" || a.type === "progressObjective") && !objectiveIds[a.id])
                errors.push(where + ".actions[" + j + "]: objective '" + a.id + "' not found")
            if (a.type === "endMission" && ["victory", "defeat"].indexOf(a.result) < 0) errors.push(where + ".actions[" + j + "]: endMission.result must be victory|defeat")
            if (a.type === "spawnUnits" && (!Array.isArray(a.units) || a.units.some(function(u) { return kindOf(u.type) !== "unit" })))
                errors.push(where + ".actions[" + j + "]: spawnUnits.units must list unit types")
        })
    })
    if (def.enemy) {
        if (def.enemy.producer && !tags[def.enemy.producer]) errors.push("enemy.producer tag '" + def.enemy.producer + "' not found")
        if (def.enemy.target && !tags[def.enemy.target]) errors.push("enemy.target tag '" + def.enemy.target + "' not found")
    }
    return errors
}

// Returns the defaulted, difficulty-merged mission. Throws on validation errors.
function load(def, difficultyName) {
    var errors = validate(def)
    if (errors.length) throw new Error("mission '" + (def && def.id) + "': " + errors.join("; "))
    var diffName = Balance.difficulty[difficultyName] ? difficultyName : Balance.defaultDifficulty
    var m = clone(def)
    var over = def.difficulty && def.difficulty[diffName]
    // campaign-wide start-iron scale applies unless the mission overrides player.iron for this difficulty
    var ironOverridden = !!(over && over.player && over.player.iron !== undefined)
    if (over) m = merge(m, over)
    delete m.difficulty
    m.difficultyName = diffName
    m.difficultyValues = clone(Balance.difficultyFor(diffName))
    if (!ironOverridden && m.player && m.player.iron !== undefined) m.player.iron = Math.round(m.player.iron * m.difficultyValues.startIronScale)
    m.format = m.format || FORMAT
    m.kind = m.kind || "scenario"
    m.title = m.title || m.id
    m.description = m.description || ""
    m.map.camera = merge({ x: m.map.size / 2, z: m.map.size / 2, yaw: 0, pitch: 52, distance: 42 }, m.map.camera || {})
    m.player = merge({ iron: Math.round(Balance.match.startIron * m.difficultyValues.startIronScale) }, m.player || {})
    if (m.enemy) m.enemy = merge({ producer: null, target: null, waves: {} }, m.enemy)
    else m.enemy = null
    m.objectives = (m.objectives || []).map(function(o) {
        return merge({ primary: !o.optional, optional: false, hidden: false, progress: null }, o)
    })
    m.triggers = (m.triggers || []).map(function(t, i) {
        return merge({ id: "trigger_" + i, repeat: false, actions: [] }, t)
    })
    m.outcome = merge({ victory: "Victory.", defeat: "Defeat." }, m.outcome || {})
    // medals: iron = completed; steel/gold = published criteria (docs/story-and-campaign.md)
    m.medals = merge({ steel: { optionalAll: true }, gold: { optionalAll: true, time: 0 } }, m.medals || {})
    m.briefing = merge({ intro: "", outro: "", illustration: "" }, m.briefing || {})
    m.victory = merge({ auto: true }, m.victory || {})       // auto: all primary objectives -> victory
    m.tags = {}
    m.entities = m.entities.map(function(e) {
        var kind = kindOf(e.type)
        var stats = kind === "unit" ? Balance.units[e.type] : Balance.buildings[e.type]
        var out = merge({ team: kind === "unit" ? "player" : "neutral", tag: null, rally: null }, e)
        out.kind = kind
        if (kind === "building" && out.iron === undefined) out.iron = stats.iron || 0
        if (out.tag) m.tags[out.tag] = out
        return out
    })
    return m
}

// Enemy AI configuration for this mission: Balance.enemy with the mission's overrides.
function enemyConfig(m) {
    return m.enemy ? merge(Balance.enemy, m.enemy.waves || {}) : null
}

function countEntities(m, kind, team) {
    return m.entities.filter(function(e) { return (!kind || e.kind === kind) && (!team || e.team === team) }).length
}
