// Contextual tutorial: an ordered list of steps from the mission definition
//   { id, text, highlight: "hud:<panel>" | "world:<tag>" | "", doneWhen: <condition>, optional }
// One step is shown at a time. A step completes when its `doneWhen` condition holds - the same
// condition vocabulary as triggers (event or polled). Actions the player already performed are
// recognised: events seen since the mission started are remembered, so a step whose event already
// happened completes immediately, and polled conditions are evaluated as soon as the step shows.
// Pure JS; the game feeds handle(ev) and step(dt, query) and renders `current(state)`.
.pragma library
.import "Triggers.js" as Triggers

function create(steps, alreadyCompleted) {
    return {
        steps: steps || [],
        index: 0,
        history: [],                               // events since mission start (capped), for "already done" steps
        finished: !steps || steps.length === 0,
        skipped: false,
        events: [],                                // { type: "tutorialStep", id } / { type: "tutorialFinished", skipped }
        replay: !!alreadyCompleted,                // the player finished it before: every step is skippable
        time: 0,
        shownAt: 0
    }
}

function current(s) { return s.finished ? null : s.steps[s.index] }
function total(s) { return s.steps.length }

function isPolled(type) { return ["timerElapsed", "resourceReached", "unitCountReached", "unitEnteredRegion", "unitLeftRegion"].indexOf(type) >= 0 }

function advance(s) {
    var st = current(s)
    if (!st) return
    s.events.push({ type: "tutorialStep", id: st.id, index: s.index })
    s.index++
    s.shownAt = s.time
    if (s.index >= s.steps.length) { s.finished = true; s.events.push({ type: "tutorialFinished", skipped: false }) }
    else checkAlreadyDone(s)
}

// an event-based step whose event already happened is done before it is even shown
function checkAlreadyDone(s) {
    var st = current(s)
    if (!st || isPolled(st.doneWhen.type)) return
    if (st.doneWhen.type === "timerElapsed") return
    if (st.recognisePast === false) return
    for (var i = 0; i < s.history.length; ++i) if (matches(st.doneWhen, s.history[i])) { advance(s); return }
}

function matches(when, ev) {
    if (!Triggers.matches(when, ev)) return false
    if (when.kind !== undefined && when.kind !== ev.kind) return false
    return true
}

// Feed a game event. Returns true when the current step completed.
function handle(s, ev) {
    s.history.push(ev)
    if (s.history.length > 300) s.history.shift()
    var st = current(s)
    if (!st || isPolled(st.doneWhen.type)) return false
    if (!matches(st.doneWhen, ev)) return false
    advance(s)
    return true
}

// Polled conditions (`query` as for Triggers) and step timers.
function step(s, dt, query) {
    s.time += dt
    var st = current(s)
    if (!st) return false
    var when = st.doneWhen
    if (when.type === "timerElapsed") {
        if (s.time - s.shownAt >= (when.seconds || 0)) { advance(s); return true }
        return false
    }
    if (!isPolled(when.type) || !query) return false
    var fake = { triggers: [], time: s.time }
    if (Triggers.evaluate(fake, null, when, query)) { advance(s); return true }
    return false
}

// Skip: the whole remaining tutorial (the player knows the game).
function skip(s) {
    if (s.finished) return
    s.finished = true; s.skipped = true
    s.events.push({ type: "tutorialFinished", skipped: true })
}

function drain(s) { var ev = s.events; s.events = []; return ev }
