// Campaign progression rules over the save's `progress.campaign` document.
//   mission list + unlock order: app/missions/campaign.js
//   medals: iron = victory, steel/gold = the mission's published `medals` criteria
// Pure JS; the game calls recordResult() after a match and saves the returned progress.
.pragma library
.import "../missions/campaign.js" as CampaignDef
.import "../config/balance.js" as Balance

var MEDAL_RANK = { "": 0, iron: 1, steel: 2, gold: 3 }

function missions() { return CampaignDef.missions }
function scenarios() { return CampaignDef.scenarios }

function info(id) {
    for (var i = 0; i < CampaignDef.missions.length; ++i) if (CampaignDef.missions[i].id === id) return CampaignDef.missions[i]
    for (var j = 0; j < CampaignDef.scenarios.length; ++j) if (CampaignDef.scenarios[j].id === id) return CampaignDef.scenarios[j]
    return null
}

function isCampaignMission(id) { return CampaignDef.missions.some(function(m) { return m.id === id }) }
function isAuthored(id) { var m = info(id); return !!(m && m.definition) }
function isCompleted(progress, id) { return !!(progress && progress.campaign.completed[id]) }

// The first mission is always open; each later one opens when its predecessor is complete.
function isUnlocked(progress, id) {
    var list = CampaignDef.missions
    for (var i = 0; i < list.length; ++i) {
        if (list[i].id !== id) continue
        if (i === 0) return true
        return isCompleted(progress, list[i - 1].id)
    }
    return false
}

// Next mission to play: the first unlocked, authored, not yet completed campaign mission.
function nextMission(progress) {
    var list = CampaignDef.missions
    for (var i = 0; i < list.length; ++i)
        if (isUnlocked(progress, list[i].id) && !isCompleted(progress, list[i].id)) return list[i].definition ? list[i].id : ""
    return ""
}

function campaignComplete(progress) {
    return CampaignDef.missions.every(function(m) { return isCompleted(progress, m.id) })
}

function survivalUnlocked(progress) { return isCompleted(progress, CampaignDef.unlocks.survival) }

function bestFor(progress, id, difficulty) {
    var b = progress && progress.campaign.best[id]
    return b && b[difficulty] ? b[difficulty] : null
}

function bestMedalAnyDifficulty(progress, id) {
    var b = progress && progress.campaign.best[id]
    var best = ""
    if (b) for (var d in b) if (MEDAL_RANK[b[d].medal] > MEDAL_RANK[best]) best = b[d].medal
    return best
}

// Published medal criteria of a loaded mission for a difficulty, as data for the UI.
//   -> { steel: [ {key, args} ], gold: [ {key, args} ] }
function criteria(mission, difficultyName) {
    var scale = Balance.difficultyFor(difficultyName).timerScale || 1
    var hasOptional = (mission.objectives || []).some(function(o) { return o.optional })
    function list(spec) {
        var out = []
        if (!spec) return out
        if (spec.optionalAll && hasOptional) out.push({ key: "medal.criteria.optional_all" })
        if (spec.time > 0) out.push({ key: "medal.criteria.time", args: { time: fmt(Math.round(spec.time * scale)) } })
        if (spec.maxUnitsLost !== undefined) out.push({ key: "medal.criteria.units_lost", args: { n: spec.maxUnitsLost } })
        if (spec.maxBuildingsLost !== undefined) out.push({ key: "medal.criteria.buildings_lost", args: { n: spec.maxBuildingsLost } })
        return out
    }
    return { steel: list(mission.medals.steel), gold: list(mission.medals.gold) }
}

function fmt(seconds) { var m = Math.floor(seconds / 60), r = seconds % 60; return m + ":" + (r < 10 ? "0" : "") + r }

function meets(spec, result, scale) {
    if (!spec) return false
    if (spec.optionalAll && result.optionalComplete < result.optionalTotal) return false
    if (spec.time > 0 && result.time > spec.time * scale) return false
    if (spec.maxUnitsLost !== undefined && result.unitsLost > spec.maxUnitsLost) return false
    if (spec.maxBuildingsLost !== undefined && result.buildingsLost > spec.maxBuildingsLost) return false
    return true
}

// result: { victory, time, optionalComplete, optionalTotal, unitsLost, buildingsLost }
function medalFor(mission, result, difficultyName) {
    if (!result.victory) return ""
    var scale = Balance.difficultyFor(difficultyName).timerScale || 1
    if (meets(mission.medals.gold, result, scale)) return "gold"
    if (meets(mission.medals.steel, result, scale)) return "steel"
    return "iron"
}

// Records a finished mission. Returns { medal, previousBest, improved, newlyUnlocked: [missionIds], survivalUnlocked }
function recordResult(progress, missionId, difficultyName, result) {
    var campaignMission = isCampaignMission(missionId)
    var mission = result.mission
    var medal = mission ? medalFor(mission, result, difficultyName) : (result.victory ? "iron" : "")
    var unlockedBefore = CampaignDef.missions.filter(function(m) { return isUnlocked(progress, m.id) }).map(function(m) { return m.id })
    var survivalBefore = survivalUnlocked(progress)
    var previous = bestFor(progress, missionId, difficultyName)
    var improved = false
    progress.campaign.lastMission = missionId
    progress.campaign.lastDifficulty = difficultyName
    progress.campaign.started = true
    if (result.victory) {
        if (campaignMission) progress.campaign.completed[missionId] = true
        var entry = progress.campaign.best[missionId] || (progress.campaign.best[missionId] = {})
        var best = entry[difficultyName]
        if (!best) { entry[difficultyName] = { medal: medal, time: result.time, optional: result.optionalComplete }; improved = true }
        else {
            var better = MEDAL_RANK[medal] > MEDAL_RANK[best.medal] || (MEDAL_RANK[medal] === MEDAL_RANK[best.medal] && result.time < best.time)
            if (better) { best.medal = medal; best.time = result.time; best.optional = result.optionalComplete; improved = true }
        }
    }
    var unlockedAfter = CampaignDef.missions.filter(function(m) { return isUnlocked(progress, m.id) }).map(function(m) { return m.id })
    var newly = unlockedAfter.filter(function(id) { return unlockedBefore.indexOf(id) < 0 })
    return { medal: medal, previousBest: previous, improved: improved, newlyUnlocked: newly,
             survivalUnlocked: !survivalBefore && survivalUnlocked(progress), campaignComplete: campaignComplete(progress) }
}

function resetProgress(progress) {
    progress.campaign = { completed: {}, best: {}, lastMission: "", lastDifficulty: "warrior", started: false }
    progress.tutorial = { completed: false, skipped: false }
    progress.survival = { bestWave: 0, bestScore: 0 }
    progress.achievements = { unlocked: {}, progress: {} }
    progress.stats = {}
    progress.seenNarrative = []
    return progress
}
