// Save data: versioned, JSON, two independent documents ("progress" and "settings").
// Pure JS: shapes, defaults, serialization, tolerant parsing, migrations (docs/save-format.md).
//   Save.parse(text, "progress") -> { ok, data, migrated, error }   (never throws; data always usable)
//   Save.serialize(data)         -> string
.pragma library

var SCHEMA = 1

function emptyProgress() {
    return {
        version: SCHEMA,
        savedAt: "",
        campaign: {
            completed: {},          // missionId -> true
            best: {},               // missionId -> { difficulty -> { medal, time, optional } }
            lastMission: "",        // last mission played (Continue)
            lastDifficulty: "warrior",
            started: false
        },
        tutorial: { completed: false, skipped: false },
        survival: { bestWave: 0, bestScore: 0 },
        achievements: { unlocked: {}, progress: {} },    // id -> ISO time ; id -> number
        stats: {},                                        // name -> number
        seenNarrative: []
    }
}

function emptySettings() {
    return {
        version: SCHEMA,
        savedAt: "",
        language: "",                                     // "" = follow the system / default (en)
        audio: { master: 1.0, music: 0.35, effects: 0.8, voice: 1.0, muteUnfocused: true },
        controls: { cameraSpeed: 1.0, zoomSensitivity: 1.0, edgeScroll: true, cameraShake: true },
        accessibility: { subtitles: true, textSpeed: 1.0, uiScale: 1.0, reducedShake: false, highContrastSelection: false, colorBlindIndicators: false },
        display: { mode: "windowed", preset: "high" }
    }
}

// Migrations: MIGRATIONS[kind][fromVersion](data) -> data at fromVersion + 1
var MIGRATIONS = {
    progress: {
        0: function(d) { d.version = 1; return d }          // pre-release saves had no version field
    },
    settings: {
        0: function(d) { d.version = 1; return d }
    }
}

function isObject(v) { return v !== null && typeof v === "object" && !Array.isArray(v) }

// Fill missing fields from the defaults without touching what is there (deep, objects only).
function fillDefaults(data, defaults) {
    for (var k in defaults) {
        if (data[k] === undefined || data[k] === null) data[k] = clone(defaults[k])
        else if (isObject(defaults[k]) && isObject(data[k])) fillDefaults(data[k], defaults[k])
        else if (isObject(defaults[k]) && !isObject(data[k])) data[k] = clone(defaults[k])
        else if (Array.isArray(defaults[k]) && !Array.isArray(data[k])) data[k] = clone(defaults[k])
    }
    return data
}

function clone(v) { return v === undefined ? undefined : JSON.parse(JSON.stringify(v)) }

function defaultsFor(kind) { return kind === "settings" ? emptySettings() : emptyProgress() }

function migrate(data, kind) {
    var migrated = false
    var v = typeof data.version === "number" ? data.version : 0
    var table = MIGRATIONS[kind] || {}
    var guard = 0
    while (v < SCHEMA && guard++ < 50) {
        var fn = table[v]
        if (!fn) { data.version = SCHEMA; break }
        data = fn(data); v = typeof data.version === "number" ? data.version : v + 1
        migrated = true
    }
    return { data: data, migrated: migrated }
}

// Tolerant load: bad JSON / wrong shape / newer schema -> ok:false with a fresh default document.
function parse(text, kind) {
    var defaults = defaultsFor(kind)
    if (text === null || text === undefined || text === "") return { ok: true, data: defaults, migrated: false, error: "", empty: true }
    var raw
    try { raw = JSON.parse(text) } catch (e) { return { ok: false, data: defaults, migrated: false, error: "invalid JSON: " + e } }
    if (!isObject(raw)) return { ok: false, data: defaults, migrated: false, error: "not an object" }
    if (typeof raw.version === "number" && raw.version > SCHEMA) return { ok: false, data: defaults, migrated: false, error: "save from a newer version (" + raw.version + " > " + SCHEMA + ")" }
    var m = migrate(raw, kind)
    fillDefaults(m.data, defaults)
    return { ok: true, data: m.data, migrated: m.migrated, error: "", empty: false }
}

function serialize(data) {
    data.version = SCHEMA
    data.savedAt = new Date().toISOString()
    return JSON.stringify(data)
}
