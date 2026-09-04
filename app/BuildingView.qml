// A building, resource node or static obstacle: QtMeshEditor model (or Box3D placeholder),
// selection frame, health bar. Gameplay state (hp, team, production queue) lives here as
// plain properties; rules are applied by the JS systems.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import Clayground.Lab

Node {
    id: root

    property int entityId: -1
    property string typeId: "clan_fortress"
    property var typeDef: ({})               // Assets.buildings entry
    property var stats: ({})                 // Balance.buildings entry
    readonly property bool isBuilding: true
    property string team: "neutral"          // player | enemy | neutral
    property string assetBase: ""
    property bool useModel: true

    property real hp: 100
    property real maxHp: 100
    property bool alive: true
    property bool untargetable: stats.obstacle === true || stats.resource === true
    property real iron: 0                    // resource nodes
    property var queue: null                 // Production.createQueue() for producers
    property var rally: null                 // {x, z} where produced units gather (null = next to the building)
    property var rallyTarget: null           // iron deposit: produced workers go gather there
    readonly property bool hasRally: rally !== null || rallyTarget !== null
    property int rallyRev: 0                 // bumped when rally changes (rally is a plain object)
    property bool selected: false
    property bool hovered: false
    property real camYaw: 0
    property real camPitch: 45
    property real hitFlash: 0                // 0..1, decays

    readonly property real footW: stats.footprint ? stats.footprint.w : 4
    readonly property real footD: stats.footprint ? stats.footprint.d : 4
    // combat treats the footprint as a disc
    readonly property real radius: Math.min(footW, footD) * 0.5
    readonly property real modelScale: typeDef.scale !== undefined ? typeDef.scale : 1
    readonly property bool depleted: stats.resource === true && iron <= 0

    eulerRotation.y: typeDef.yawOffset || 0

    function lookAt() {}

    // destruction: the structure sinks and tilts into the ground, leaving a dark scorched slab
    property real ruin: root.alive ? 0 : 1
    Behavior on ruin { NumberAnimation { duration: 1800; easing.type: Easing.InQuad } }

    Loader3D {
        id: modelLoader
        active: root.useModel && !!root.typeDef.model
        source: !active ? "" : (root.assetBase ? root.assetBase + root.typeDef.model
                                               : Qt.resolvedUrl(root.typeDef.model))
        scale: Qt.vector3d(root.modelScale, root.modelScale * (1 - 0.7 * root.ruin), root.modelScale)
        y: (root.typeDef.footOffset || 0) * root.modelScale * (1 - 0.7 * root.ruin) - root.ruin * 0.4
        eulerRotation.z: root.ruin * 7
        opacity: root.depleted ? 0.45 : 1
        onStatusChanged: if (status === Loader3D.Error) console.warn("BuildingView: failed to load", source)
    }
    readonly property bool modelReady: modelLoader.status === Loader3D.Ready

    Box3D {
        visible: !root.modelReady
        width: root.footW * 0.9
        height: root.stats.resource ? 1.6 : (root.stats.obstacle ? 1.8 : 5)
        depth: root.footD * 0.9
        color: root.team === "enemy" ? "#7a3f3a" : (root.team === "player" ? "#6b4f3d" : "#5d6066")
        useToonShading: true
        showEdges: true
        edgeColor: "#26221e"
        edgeThickness: 1.5
    }

    // pick proxy: an invisible-by-height slab covering the footprint so clicks on placeholder
    // buildings and around thin models still hit "the building"
    Model {
        source: "#Cube"
        y: 0.05
        scale: Qt.vector3d(root.footW / 100, 0.001, root.footD / 100)
        materials: PrincipledMaterial { baseColor: "#000000"; opacity: 0.001; alphaMode: PrincipledMaterial.Blend }
        pickable: true
        visible: !root.untargetable || root.stats.resource === true
    }

    SelectionFrame3D {
        visible: !root.stats.obstacle
        halfWidth: root.footW * 0.55
        halfDepth: root.footD * 0.55
        selected: root.selected
        hovered: root.hovered && !root.selected
        showNose: false
        tone: root.team === "enemy" ? "#c9432e" : (root.team === "player" ? "#e0b24a" : "#9ab0c0")
        height: 0.06
        thickness: 0.22
        eulerRotation.y: -root.eulerRotation.y
    }

    HealthBar3D {
        visible: root.maxHp > 0 && (root.selected || root.hovered || root.hp < root.maxHp)
        y: root.stats.resource ? 2.6 : 6.8
        barWidth: Math.max(2, root.footW * 0.6)
        barHeight: 0.28
        value: root.maxHp > 0 ? root.hp / root.maxHp : 1
        camYaw: root.camYaw - root.eulerRotation.y
        camPitch: root.camPitch
    }

    Model {                                  // scorched slab under a destroyed structure
        visible: root.ruin > 0.01
        source: "#Cube"
        y: 0.03
        scale: Qt.vector3d(root.footW / 100 * 1.1, 0.0006, root.footD / 100 * 1.1)
        opacity: root.ruin * 0.9
        materials: PrincipledMaterial { baseColor: "#1b1715"; roughness: 1; alphaMode: PrincipledMaterial.Blend }
        pickable: false
    }

    // hit feedback: a red flash ring on the ground
    Model {
        visible: root.hitFlash > 0.01
        source: "#Cylinder"
        y: 0.04
        scale: Qt.vector3d(root.footW * 0.013, 0.0005, root.footD * 0.013)
        opacity: root.hitFlash * 0.7
        materials: PrincipledMaterial { baseColor: "#e0402a"; lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend }
        pickable: false
    }
}
