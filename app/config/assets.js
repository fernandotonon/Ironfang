// Asset indirection: gameplay code refers to type ids only. Replace a placeholder by pointing
// `model` at a balsam-imported QML file (see docs/asset-pipeline.md).
// A JS module (not JSON) because XMLHttpRequest cannot read qrc:/ resources by default, while
// `import "config/assets.js"` works from resources, files and HTTP alike.
.pragma library

var units = {
    "orc_warrior": {
        displayName: "Orc Warrior",
        model: "assets/runtime/orc/Orc.qml",
        status: "qtmesheditor",          // placeholder | qtmesheditor
        scale: 1.8,                      // metres of model height (TRELLIS.2 output is ~1 unit)
        footOffset: 0.49,                // model-space half height, lifts the feet to y = 0
        yawOffset: 0,                    // degrees, for models that do not face +Z
        radius: 0.55,                    // separation / selection radius, metres
        speed: 3.2,                      // m/s
        clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death" }
    },
    "placeholder": {
        displayName: "Placeholder",
        model: "",
        status: "placeholder",
        scale: 1.0, footOffset: 0, yawOffset: 0, radius: 0.5, speed: 3.2,
        clips: {}
    }
}

function unit(typeId) { return units[typeId] || units["placeholder"] }
