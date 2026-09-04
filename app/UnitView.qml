// One unit: QtMeshEditor model (or Box3D placeholder) + selection frame + health bar.
// Simulation state (x, z, path, heading) lives here as plain properties written by Steering.js;
// the Node position is derived from them.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import Clayground.Lab

Node {
    id: root

    // ---- identity / asset indirection ---------------------------------------------------
    property int unitId: -1
    property string typeId: "orc_warrior"
    property var typeDef: ({})               // entry from config/assets.json
    readonly property bool isUnit: true
    property bool useModel: true              // false forces the placeholder
    property string assetBase: ""             // "" = relative to this file; or e.g. "file:///game/"

    // ---- simulation state -----------------------------------------------------------------
    // (x, z) of this Node are the ground-plane position in metres (y stays 0)
    property real vx: 0
    property real vz: 0
    property real heading: 0                  // degrees around Y
    property real speed: typeDef.speed !== undefined ? typeDef.speed : 3.0
    property real radius: typeDef.radius !== undefined ? typeDef.radius : 0.5
    property var path: []
    property int pathIndex: 0
    property int blockedTicks: 0
    property bool alive: true
    property real hp: 1.0

    // ---- presentation state ---------------------------------------------------------------
    property bool selected: false
    property bool hovered: false
    property string clip: "Idle"
    property real camYaw: 0
    property real camPitch: 45

    eulerRotation.y: heading + (typeDef.yawOffset || 0)

    signal arrived(int unitId)

    function play(name) {
        clip = name
        if (modelLoader.item && modelLoader.item.clip !== undefined)
            modelLoader.item.clip = name
    }

    function moveAlong(newPath) {
        path = newPath
        pathIndex = 0
        blockedTicks = 0
        if (newPath.length) play("Walk")
        else play("Idle")
    }

    function arrive() {
        path = []
        pathIndex = 0
        play("Idle")
        arrived(unitId)
    }

    // Approximate world height, used for screen-space selection tests.
    readonly property real bodyHeight: 1.8

    // ---- the model ------------------------------------------------------------------------
    readonly property real modelScale: typeDef.scale !== undefined ? typeDef.scale : 1.0

    Loader3D {
        id: modelLoader
        active: root.useModel && root.typeDef.model !== undefined && root.typeDef.model !== ""
        source: !active ? "" : (root.assetBase ? root.assetBase + root.typeDef.model
                                               : Qt.resolvedUrl(root.typeDef.model))
        scale: Qt.vector3d(root.modelScale, root.modelScale, root.modelScale)
        y: (root.typeDef.footOffset || 0) * root.modelScale
        onLoaded: {
            if (item && item.clip !== undefined) item.clip = root.clip
            if (item && item.clipFinished)
                item.clipFinished.connect(function(name) { if (name !== "Death") root.play("Idle") })
        }
        onStatusChanged: if (status === Loader3D.Error) console.warn("UnitView: failed to load", source)
    }
    readonly property bool modelReady: modelLoader.status === Loader3D.Ready

    // Placeholder: toon-shaded box, bottom-centre origin (Box3D convention).
    Box3D {
        visible: !root.modelReady
        width: root.radius * 1.6
        height: 1.8
        depth: root.radius * 1.4
        color: root.selected ? "#8fb35c" : "#5b7a3a"
        useToonShading: true
        showEdges: true
        edgeColor: "#1b2414"
        edgeThickness: 1.5
        // a small "nose" so the facing direction reads on the placeholder
        Box3D { width: 0.25; height: 0.25; depth: 0.3; y: 1.3; z: root.radius * 0.7 + 0.1; color: "#2d2d2d" }
    }

    // Selection / hover decal on the ground (Clayground.Lab shared language).
    SelectionFrame3D {
        halfWidth: root.radius * 1.5
        halfDepth: root.radius * 1.5
        selected: root.selected
        hovered: root.hovered && !root.selected
        showNose: false
        tone: "#e0b24a"
        height: 0.06
        thickness: 0.16
        eulerRotation.y: -root.eulerRotation.y   // keep the frame axis-aligned to the map
    }

    HealthBar3D {
        visible: root.selected || root.hovered || root.hp < 1.0
        y: 2.25
        value: root.hp
        camYaw: root.camYaw - root.eulerRotation.y
        camPitch: root.camPitch
    }
}
