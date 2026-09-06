// Objective manager: the list of a mission's objectives and their state.
//   state: hidden -> active -> complete | failed
// Pure JS over a plain state object; the game owns it and re-renders through `rev`.
//
//   var o = Objectives.create(mission.objectives)
//   Objectives.complete(o, "destroy_fortress")   -> emits { type: "objectiveCompleted", id }
//   Objectives.setProgress(o, id, current, target)
//   Objectives.step(o, query)                    -> refreshes declarative progress specs
//   Objectives.activePrimary(o), Objectives.allPrimaryComplete(o), Objectives.visible(o)
// Events are collected in `state.events` and drained by the game (Objectives.drain).
.pragma library

function create(defs) {
    var s = { list: [], byId: {}, events: [], rev: 0 }
    ;(defs || []).forEach(function(d) { add(s, d) })
    return s
}

function add(s, def) {
    if (!def || !def.id) return null
    if (s.byId[def.id]) {                        // re-adding a hidden objective reveals it
        var existing = s.byId[def.id]
        if (existing.state === "hidden") { existing.state = "active"; s.events.push({ type: "objectiveAdded", id: existing.id }); s.rev++ }
        return existing
    }
    var o = {
        id: def.id, text: def.text || def.id,
        primary: def.primary !== false && !def.optional, optional: def.optional === true,
        state: def.hidden ? "hidden" : "active",
        progress: def.progress || null,             // declarative spec (see step)
        completeOnVictory: def.completeOnVictory || null,
        internal: def.internal === true,             // bookkeeping helper: never shown, never counted
        activatedAt: -1,
        current: 0, target: def.target || 0,
        completedAt: -1, failedAt: -1
    }
    s.list.push(o); s.byId[o.id] = o
    if (o.state === "active") s.events.push({ type: "objectiveAdded", id: o.id })
    s.rev++
    return o
}

function get(s, id) { return s.byId[id] || null }

function complete(s, id, time) {
    var o = s.byId[id]
    if (!o || o.state === "complete") return false
    if (o.state === "failed") return false
    o.state = "complete"; o.completedAt = time === undefined ? 0 : time
    if (o.target > 0) o.current = o.target
    s.events.push({ type: "objectiveCompleted", id: id, primary: o.primary })
    s.rev++
    return true
}

function fail(s, id, time) {
    var o = s.byId[id]
    if (!o || o.state === "complete" || o.state === "failed") return false
    o.state = "failed"; o.failedAt = time === undefined ? 0 : time
    s.events.push({ type: "objectiveFailed", id: id, primary: o.primary })
    s.rev++
    return true
}

// Adds `delta` to the objective's counter (triggers: progressObjective { id, delta: 1 }).
function addProgress(s, id, delta, target, time) {
    var o = s.byId[id]
    if (!o || o.state !== "active") return
    setProgress(s, id, o.current + (delta || 1), target !== undefined ? target : o.target, time)
}

// Objectives still active when the mission is won: `completeOnVictory` decides their fate.
//   true | { type: "always" }                       -> complete
//   { type: "entityHpAtLeast", tag, fraction }      -> complete if the entity has >= fraction of its hp
//   { type: "unitsLostAtMost", n }                  -> complete if the player lost <= n units
//   { type: "buildingsLostAtMost", n }
// Others stay active (they count as not completed). `ctx` = { entityByTag, unitsLost, buildingsLost }
function resolveAtVictory(s, ctx, time) {
    for (var i = 0; i < s.list.length; ++i) {
        var o = s.list[i]
        if (o.state !== "active" || !o.completeOnVictory) continue
        var c = o.completeOnVictory === true ? { type: "always" } : o.completeOnVictory
        var ok = false
        if (c.type === "always") ok = true
        else if (c.type === "entityHpAtLeast") { var e = ctx.entityByTag(c.tag); ok = !!e && e.alive && e.maxHp > 0 && e.hp / e.maxHp >= c.fraction }
        else if (c.type === "unitsLostAtMost") ok = ctx.unitsLost <= c.n
        else if (c.type === "buildingsLostAtMost") ok = ctx.buildingsLost <= c.n
        else if (c.type === "timeAtMost") ok = (time || 0) <= c.seconds * (ctx.timerScale || 1)
        if (ok) complete(s, o.id, time); else fail(s, o.id, time)
    }
}

// Explicit progress (counts). Completes the objective when current reaches target (> 0).
function setProgress(s, id, current, target, time) {
    var o = s.byId[id]
    if (!o || o.state !== "active") return
    if (target !== undefined) o.target = target
    if (o.current !== current) { o.current = current; s.rev++ }
    if (o.target > 0 && o.current >= o.target) complete(s, id, time)
}

// Declarative progress specs, refreshed each simulation step:
//   { type: "entityHp", tag }               -> current = hp, target = maxHp (display only)
//   { type: "unitCount", team, unitType, count } -> completes at >= count
//   { type: "resource", amount }            -> completes when the player's iron >= amount
// `query` = { entityByTag(tag), countUnits(team, type), iron() }
function step(s, query, time) {
    for (var i = 0; i < s.list.length; ++i) {
        var o = s.list[i]
        if (o.state !== "active" || !o.progress) continue
        var p = o.progress
        if (p.type === "timer") {                                  // seconds since the objective became active
            if (o.activatedAt < 0) o.activatedAt = time || 0
            setProgress(s, o.id, Math.floor((time || 0) - o.activatedAt), p.seconds, time)
        } else if (p.type === "entityHp") {
            var e = query.entityByTag(p.tag)
            var cur = e ? Math.max(0, Math.ceil(e.hp)) : 0, tgt = e ? e.maxHp : 0
            if (cur !== o.current || tgt !== o.target) { o.current = cur; o.target = tgt; s.rev++ }
        } else if (p.type === "unitCount") {
            var n = query.countUnits(p.team || "player", p.unitType)
            if (p.op === "<=") {                                   // "no enemies left": display only, completes at <= count
                if (o.current !== n) { o.current = n; s.rev++ }
                if (n <= p.count) complete(s, o.id, time)
            } else setProgress(s, o.id, n, p.count, time)
        } else if (p.type === "produced") {                        // units produced during the mission
            setProgress(s, o.id, query.produced ? query.produced(p.team || "player", p.unitType) : 0, p.count, time)
        } else if (p.type === "resource") {
            setProgress(s, o.id, Math.floor(query.iron()), p.amount, time)
        }
    }
}

function visible(s) { return s.list.filter(function(o) { return o.state !== "hidden" && !o.internal }) }

function activePrimary(s) {
    for (var i = 0; i < s.list.length; ++i) if (s.list[i].primary && !s.list[i].internal && s.list[i].state === "active") return s.list[i]
    return null
}

function allPrimaryComplete(s) {
    var any = false
    for (var i = 0; i < s.list.length; ++i) {
        var o = s.list[i]
        if (!o.primary || o.internal) continue
        if (o.state === "active" && o.completeOnVictory) { any = true; continue }   // resolved by resolveAtVictory
        if (o.state === "hidden" || o.state === "active" || o.state === "failed") return false
        any = true
    }
    return any
}

function anyPrimaryFailed(s) {
    return s.list.some(function(o) { return o.primary && !o.internal && o.state === "failed" })
}

// Text for the HUD's primary line, e.g. "Destroy the Enemy Fortress (2500 HP)".
// `translate` (optional) maps the objective text key to the player's language.
function primaryText(s, translate) {
    var o = activePrimary(s)
    if (!o) return ""
    var text = translate ? translate(o.text) : o.text
    if (o.progress && o.progress.type === "entityHp" && o.target > 0) return text + " (" + o.current + " HP)"
    if (o.progress && o.progress.type === "unitCount" && o.progress.op === "<=") return text + " (" + o.current + ")"
    if (o.target > 0) return text + " (" + o.current + "/" + o.target + ")"
    return text
}

function drain(s) { var ev = s.events; s.events = []; return ev }

function summary(s) {
    var shown = s.list.filter(function(o) { return !o.internal })
    return { complete: shown.filter(function(o) { return o.state === "complete" }).length,
             failed: shown.filter(function(o) { return o.state === "failed" }).length,
             optionalComplete: shown.filter(function(o) { return o.optional && o.state === "complete" }).length,
             optionalTotal: shown.filter(function(o) { return o.optional }).length }
}
