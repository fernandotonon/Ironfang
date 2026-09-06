// One unit: QtMeshEditor model (or Box3D placeholder) + team ring + selection frame + health bar.
// Simulation state lives here as plain properties written by the JS systems (Steering, Gather,
// Combat); the Node's x/z are the ground-plane position in metres (y stays 0).
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import Clayground.Lab

Node {
    id: root

    // ---- identity / asset indirection ---------------------------------------------------
    property int entityId: -1
    property alias unitId: root.entityId
    property string typeId: "orc_warrior"
    property string tag: ""                  // mission tag (docs/mission-format.md), "" for anonymous entities
    property var typeDef: ({})               // Assets.units entry
    property var stats: ({})                 // Balance.units entry
    readonly property bool isUnit: true
    readonly property bool isBuilding: false
    property string team: "player"           // player | enemy
    property bool useModel: true
    property string assetBase: ""

    // ---- simulation state -----------------------------------------------------------------
    property real vx: 0
    property real vz: 0
    property real heading: 0                  // degrees around Y
    property real speed: stats.speed !== undefined ? stats.speed : 3.0
    property real radius: stats.radius !== undefined ? stats.radius : 0.5
    property var path: []
    property int pathIndex: 0
    property int blockedTicks: 0
    property bool alive: true
    property real hp: stats.hp !== undefined ? stats.hp : 100
    property real maxHp: stats.hp !== undefined ? stats.hp : 100
    property real deathTimer: 0
    // orders / combat
    property string order: "idle"             // idle | move | attack | gather | attackMove
    property var target: null                 // attack target (unit or building)
    property var orderPoint: null             // {x,z} destination of a move order
    property real cooldown: 0
    property real repathTimer: 0
    property var chaseOrigin: null
    property bool autoAcquired: false         // target came from auto-acquire (leashed)
    property var primaryTarget: null          // attack-move: the destination target to return to
    property bool inWave: false               // enemy units that were sent to attack
    // gathering (workers)
    property real carried: 0
    property string gatherState: "idle"
    property var gatherNode: null
    property real gatherTimer: 0
    property bool gatherArrived: false
    property string prevGatherState: "idle"   // for one-shot gather sound cues

    // ---- presentation state ---------------------------------------------------------------
    property bool selected: false
    property bool hovered: false
    property string clip: "Idle"
    property real camYaw: 0
    property real camPitch: 45
    property real hitFlash: 0

    eulerRotation.y: heading + (typeDef.yawOffset || 0)

    signal arrived(int entityId)
    signal moveRequested(var unit, var point)     // the game answers with a path (moveAlong)

    function play(name) {
        clip = name
        if (modelLoader.item && modelLoader.item.clip !== undefined) {
            // fall back to Idle when this asset lacks the clip (e.g. no Gather)
            const has = !modelLoader.item.clips || modelLoader.item.clips.indexOf(name) >= 0
            modelLoader.item.clip = has ? name : "Idle"
        }
    }

    function moveTo(point) { moveRequested(root, point) }

    function moveAlong(newPath) {
        path = newPath
        pathIndex = 0
        blockedTicks = 0
        if (newPath.length) play("Walk")
        else if (clip === "Walk") play("Idle")
    }

    function stop() {
        path = []
        pathIndex = 0
        if (clip === "Walk") play("Idle")
    }

    function arrive() {
        path = []
        pathIndex = 0
        if (clip === "Walk") play("Idle")
        arrived(entityId)
    }

    function lookAt(other) {
        if (!other) return
        heading = Math.atan2(other.x - x, other.z - z) * 180 / Math.PI
    }

    function die() {
        alive = false
        hp = 0
        path = []
        target = null
        order = "dead"
        gatherState = "idle"
        selected = false
        hovered = false
        play("Death")
    }

    readonly property real bodyHeight: (typeDef.scale || 1.0) * (typeDef.footOffset ? 2 * typeDef.footOffset : 1.0)
    readonly property real modelScale: typeDef.scale !== undefined ? typeDef.scale : 1.0
    readonly property color teamColor: team === "enemy" ? "#c9432e" : "#e0b24a"

    // ---- the model ------------------------------------------------------------------------
    Loader3D {
        id: modelLoader
        active: root.useModel && root.typeDef.model !== undefined && root.typeDef.model !== ""
        source: !active ? "" : (root.assetBase ? root.assetBase + root.typeDef.model
                                               : Qt.resolvedUrl(root.typeDef.model))
        scale: Qt.vector3d(root.modelScale, root.modelScale, root.modelScale)
        y: (root.typeDef.footOffset || 0) * root.modelScale
        opacity: root.alive ? 1 : Math.max(0, 1 - root.deathTimer / 2.4)
        onLoaded: {
            if (item && item.clip !== undefined) root.play(root.clip)
            if (item && item.clipFinished)
                item.clipFinished.connect(function(name) {
                    if (!root.alive) return
                    if (name !== "Death") root.play(root.path.length ? "Walk" : "Idle")
                })
        }
        onStatusChanged: if (status === Loader3D.Error) console.warn("UnitView: failed to load", source)
    }
    readonly property bool modelReady: modelLoader.status === Loader3D.Ready

    // Placeholder: toon-shaded box, bottom-centre origin (Box3D convention).
    Box3D {
        visible: !root.modelReady
        width: root.radius * 1.6
        height: root.bodyHeight
        depth: root.radius * 1.4
        color: root.team === "enemy" ? "#8a3f38" : (root.selected ? "#8fb35c" : "#5b7a3a")
        useToonShading: true
        showEdges: true
        edgeColor: "#1b2414"
        edgeThickness: 1.5
        Box3D { width: 0.25; height: 0.25; depth: 0.3; y: root.bodyHeight * 0.7; z: root.radius * 0.7 + 0.1; color: "#2d2d2d" }
    }

    // team ring: always-on faction readability
    Model {
        source: "#Cylinder"
        y: 0.015
        scale: Qt.vector3d(root.radius * 0.024, 0.0003, root.radius * 0.024)
        opacity: root.alive ? 0.55 : 0
        materials: PrincipledMaterial {
            baseColor: root.hitFlash > 0.01 ? "#ff5a3c" : root.teamColor
            lighting: PrincipledMaterial.NoLighting
            alphaMode: PrincipledMaterial.Blend
        }
        pickable: false
    }

    SelectionFrame3D {
        visible: root.alive
        halfWidth: root.radius * 1.5
        halfDepth: root.radius * 1.5
        selected: root.selected
        hovered: root.hovered && !root.selected
        showNose: false
        tone: root.teamColor
        height: 0.06
        thickness: 0.16
        eulerRotation.y: -root.eulerRotation.y
    }

    HealthBar3D {
        visible: root.alive && (root.selected || root.hovered || root.hp < root.maxHp)
        y: root.bodyHeight + 0.45
        value: root.maxHp > 0 ? root.hp / root.maxHp : 1
        camYaw: root.camYaw - root.eulerRotation.y
        camPitch: root.camPitch
    }

    // carried iron: a small dark cube on the back of a worker
    Model {
        visible: root.carried > 0 && root.alive
        source: "#Cube"
        position: Qt.vector3d(0, root.bodyHeight * 0.75, -root.radius * 0.7)
        scale: Qt.vector3d(0.0035, 0.0035, 0.0035)
        materials: PrincipledMaterial { baseColor: "#8d8f96"; metalness: 0.8; roughness: 0.45 }
        pickable: false
    }
}
