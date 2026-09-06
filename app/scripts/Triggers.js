// Trigger system: `when` conditions x `actions`, each trigger one-shot unless `repeat: true`.
// Two kinds of conditions:
//   * event conditions   - matched against game events fed through handle(): missionStarted,
//     entityDestroyed {tag,type,team}, unitProduced {type,team}, entitySelected {tag,type},
//     objectiveCompleted {id}, objectiveFailed {id}, waveLaunched, waveCompleted,
//     buildingActivated {tag}, dialogueCompleted {id}, checkpointReached {id}
//   * polled conditions  - evaluated in step() against a `query` adapter; they fire on the
//     rising edge (false -> true), so a repeating region trigger fires once per entry:
//     timerElapsed {seconds, after?: triggerId}, resourceReached {amount},
//     unitCountReached {team, unitType?, count, op?: ">="|"<="},
//     unitEnteredRegion / unitLeftRegion {region: {x, z, w, d}, team, unitType?}
// Actions are executed through `actions[type](args, event, trigger)` supplied by the game;
// unknown actions are reported in state.unknownActions (and skipped), never thrown.
// Optional gates on any trigger: `requires: ["objectiveId", ...]` (all complete) and
// `delay: seconds` (fires that long after its condition became true).
.pragma library

function create(defs) {
    var s = { triggers: [], time: 0, fired: [], unknownActions: [] }
    ;(defs || []).forEach(function(d, i) {
        s.triggers.push({
            def: d, id: d.id || ("trigger_" + i), repeat: d.repeat === true,
            count: 0, done: false, was: false, firedAt: -1, pendingAt: -1, pendingEvent: null
        })
    })
    return s
}

function matches(when, ev) {
    if (when.type !== ev.type) return false
    if (when.tag !== undefined && when.tag !== ev.tag) return false
    if (when.id !== undefined && when.id !== ev.id) return false
    if (when.unitType !== undefined && when.unitType !== ev.unitType) return false
    if (when.entityType !== undefined && when.entityType !== ev.entityType) return false
    if (when.team !== undefined && when.team !== ev.team) return false
    return true
}

function gatesOpen(t, ctx) {
    var req = t.def.requires
    if (!req || !req.length) return true
    if (!ctx.objectiveComplete) return false
    for (var i = 0; i < req.length; ++i) if (!ctx.objectiveComplete(req[i])) return false
    return true
}

function inRegion(u, r) {
    return u.x >= r.x && u.x <= r.x + r.w && u.z >= r.z && u.z <= r.z + r.d
}

// polled condition value at this moment
function evaluate(s, t, when, query) {
    switch (when.type) {
    case "timerElapsed": {
        var base = 0
        if (when.after) {
            var other = find(s, when.after)
            if (!other || other.firedAt < 0) return false
            base = other.firedAt
        }
        return s.time - base >= (when.seconds || 0)
    }
    case "resourceReached": return query.iron() >= (when.amount || 0)
    case "unitCountReached": {
        var n = query.countUnits(when.team || "player", when.unitType)
        return (when.op === "<=") ? n <= when.count : n >= when.count
    }
    case "unitEnteredRegion":
        return query.units(when.team, when.unitType).some(function(u) { return inRegion(u, when.region) })
    case "unitLeftRegion":
        return !query.units(when.team, when.unitType).some(function(u) { return inRegion(u, when.region) })
    default: return false
    }
}

function find(s, id) {
    for (var i = 0; i < s.triggers.length; ++i) if (s.triggers[i].id === id) return s.triggers[i]
    return null
}

function fire(s, t, ev, ctx) {
    t.count++; t.firedAt = s.time
    if (!t.repeat) t.done = true
    s.fired.push({ id: t.id, time: s.time })
    var acts = t.def.actions || []
    for (var i = 0; i < acts.length; ++i) {
        var a = acts[i]
        var fn = ctx.actions && ctx.actions[a.type]
        if (typeof fn === "function") fn(a, ev, t)
        else s.unknownActions.push(a.type)
    }
}

// Schedules or fires: honours `delay`.
function arm(s, t, ev, ctx) {
    if (t.def.delay > 0) { if (t.pendingAt < 0) { t.pendingAt = s.time + t.def.delay; t.pendingEvent = ev } }
    else fire(s, t, ev, ctx)
}

// Feed one game event. Returns the number of triggers fired.
function handle(s, ev, ctx) {
    var n = 0
    for (var i = 0; i < s.triggers.length; ++i) {
        var t = s.triggers[i]
        if (t.done || t.pendingAt >= 0) continue
        if (!matches(t.def.when, ev)) continue
        if (!gatesOpen(t, ctx)) continue
        arm(s, t, ev, ctx); n++
    }
    return n
}

// Advance time, evaluate polled conditions (rising edge) and release delayed triggers.
function step(s, dt, ctx) {
    s.time += dt
    for (var i = 0; i < s.triggers.length; ++i) {
        var t = s.triggers[i]
        if (t.done) continue
        if (t.pendingAt >= 0) {
            if (s.time >= t.pendingAt) { t.pendingAt = -1; var pe = t.pendingEvent; t.pendingEvent = null; fire(s, t, pe, ctx) }
            continue
        }
        var when = t.def.when
        if (!ctx.query || ["timerElapsed", "resourceReached", "unitCountReached", "unitEnteredRegion", "unitLeftRegion"].indexOf(when.type) < 0) continue
        var now = evaluate(s, t, when, ctx.query)
        if (now && !t.was && gatesOpen(t, ctx)) arm(s, t, { type: when.type, time: s.time }, ctx)
        t.was = now
    }
}

function firedCount(s, id) { var t = find(s, id); return t ? t.count : 0 }
