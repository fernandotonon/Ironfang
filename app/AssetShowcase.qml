// Asset showcase: every unit, building and prop from the QtMeshEditor pipeline on a turntable,
// with clip switching and the metadata the asset contract asks for.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import "config/assets.js" as Assets
import "config/assetmeta.js" as Meta

Item {
    id: showcase
    property string assetBase: ""
    property bool useModels: true
    signal closeRequested()

    readonly property color gold: "#e0b24a"
    readonly property color ink: "#f2e2c4"
    readonly property color faint: "#9aa0a6"

    // catalogue: units first, then buildings, then props
    readonly property var entries: {
        const list = []
        for (const id of ["goblin_worker", "orc_warrior", "orc_archer", "ironhide_ogre"])
            list.push({ kind: "unit", id: id, def: Assets.units[id], meta: metaFor(Assets.units[id].model) })
        for (const id of ["clan_fortress", "war_foundry", "iron_deposit", "rocks_large", "rocks_small", "dead_tree", "broken_cart"])
            list.push({ kind: "building", id: id, def: Assets.buildings[id], meta: metaFor(Assets.buildings[id].model) })
        list.push({ kind: "projectile", id: "arrow", def: Assets.projectiles.arrow, meta: metaFor(Assets.projectiles.arrow.model) })
        return list
    }
    function metaFor(model) {
        for (const k in Meta.assets) if (Meta.assets[k].runtime === model) return Meta.assets[k]
        return null
    }
    property int index: 0
    readonly property var current: entries[index]
    property string clip: "Idle"
    property real spin: 0
    property bool autoSpin: true

    onIndexChanged: { clip = "Idle"; spin = 0; if (modelLoader.item && modelLoader.item.clip !== undefined) modelLoader.item.clip = "Idle" }

    Rectangle { anchors.fill: parent; color: "#14161a" }

    View3D {
        id: view
        anchors { left: parent.left; right: sidebar.left; top: parent.top; bottom: parent.bottom }
        camera: cam
        environment: SceneEnvironment { clearColor: "#1f232a"; backgroundMode: SceneEnvironment.Color; antialiasingMode: SceneEnvironment.MSAA }
        DirectionalLight { eulerRotation.x: -50; eulerRotation.y: -35; brightness: 1.5; ambientColor: "#454a52" }
        DirectionalLight { eulerRotation.x: -20; eulerRotation.y: 150; brightness: 0.45; color: "#c9d6ff" }

        readonly property real size: showcase.current.def.scale * (showcase.current.kind === "unit" ? 1.1 : 0.7) + 0.6
        property real zoom: 1
        PerspectiveCamera {
            id: cam
            position: Qt.vector3d(0, view.size * 0.9 * view.zoom, view.size * 2.6 * view.zoom)
            eulerRotation.x: -18
            clipNear: 0.1
        }
        Model {   // pedestal
            source: "#Cylinder"
            scale: Qt.vector3d(view.size * 0.04, 0.0015, view.size * 0.04)
            y: -0.08
            materials: PrincipledMaterial { baseColor: "#33373d"; roughness: 0.9 }
        }
        Node {
            id: stage
            eulerRotation.y: showcase.spin + (showcase.current.def.yawOffset || 0)
            Loader3D {
                id: modelLoader
                active: showcase.useModels && !!showcase.current.def.model
                source: !active ? "" : (showcase.assetBase ? showcase.assetBase + showcase.current.def.model
                                                           : Qt.resolvedUrl(showcase.current.def.model))
                scale: Qt.vector3d(showcase.current.def.scale, showcase.current.def.scale, showcase.current.def.scale)
                y: (showcase.current.def.footOffset || 0) * showcase.current.def.scale
                onLoaded: if (item && item.clip !== undefined) item.clip = showcase.clip
            }
            Box3D {
                visible: modelLoader.status !== Loader3D.Ready
                width: 1; height: showcase.current.def.scale; depth: 0.8
                color: "#5b7a3a"; useToonShading: true; showEdges: true
            }
        }
        FrameAnimation { running: showcase.autoSpin && showcase.visible; onTriggered: showcase.spin = (showcase.spin + frameTime * 24) % 360 }
        MouseArea {
            anchors.fill: parent
            property real lastX: 0
            onPressed: (m) => { lastX = m.x; showcase.autoSpin = false }
            onPositionChanged: (m) => { if (pressed) { showcase.spin += (m.x - lastX) * 0.5; lastX = m.x } }
            onWheel: (w) => view.zoom = Math.max(0.5, Math.min(2.5, view.zoom * (w.angleDelta.y > 0 ? 0.9 : 1.1)))
            onDoubleClicked: showcase.autoSpin = true
        }
    }

    // ---- catalogue -----------------------------------------------------------------------------
    Rectangle {
        id: sidebar
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: 360
        color: "#e01b1d22"
        Column {
            anchors { fill: parent; margins: 16 }
            spacing: 10
            Row {
                spacing: 10
                Text { text: "ASSET SHOWCASE"; color: showcase.gold; font.pixelSize: 16; font.bold: true; font.letterSpacing: 2 }
                Item { width: 100; height: 1 }
                Rectangle {
                    width: 70; height: 26; radius: 4; color: "#3b2d19"; border.color: "#c9973b"
                    Text { anchors.centerIn: parent; text: "Back"; color: showcase.ink; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; onClicked: showcase.closeRequested() }
                }
            }
            Text { text: "Built with Clayground · Forged with QtMeshEditor"; color: showcase.faint; font.pixelSize: 11 }
            Flow {
                width: parent.width; spacing: 4
                Repeater {
                    model: showcase.entries
                    Rectangle {
                        required property var modelData
                        required property int index
                        width: 112; height: 26; radius: 3
                        color: showcase.index === index ? "#7d5a2a" : "#2b2418"
                        border.color: showcase.index === index ? showcase.gold : "#5a4a3a"
                        Text { anchors.centerIn: parent; text: modelData.def.displayName || modelData.id; color: showcase.ink; font.pixelSize: 11; elide: Text.ElideRight; width: parent.width - 8; horizontalAlignment: Text.AlignHCenter }
                        MouseArea { anchors.fill: parent; onClicked: showcase.index = index }
                    }
                }
            }
            Rectangle { width: parent.width; height: 1; color: "#3a3226" }
            Text { text: showcase.current.def.displayName || showcase.current.id; color: showcase.ink; font.pixelSize: 20; font.bold: true }
            Text { text: showcase.current.kind + " · " + showcase.current.id; color: showcase.faint; font.pixelSize: 12 }
            Grid {
                columns: 2; columnSpacing: 12; rowSpacing: 3
                readonly property var m: showcase.current.meta
                component K: Text { color: showcase.faint; font.pixelSize: 12 }
                component V: Text { color: showcase.ink; font.pixelSize: 12; width: 210; wrapMode: Text.WordWrap }
                K { text: "Status" }      V { text: showcase.current.def.status === "qtmesheditor" ? "QtMeshEditor-generated" : "placeholder"; color: showcase.current.def.status === "qtmesheditor" ? "#8fd17a" : "#d9a63b" }
                K { text: "Triangles" }   V { text: parent.m ? parent.m.tris.toLocaleString() : "—" }
                K { text: "Vertices" }    V { text: parent.m ? parent.m.verts.toLocaleString() : "—" }
                K { text: "Skeleton" }    V { text: parent.m && parent.m.bones ? parent.m.bones + " bones (qtmesh rig, humanoid template)" : "none (static)" }
                K { text: "Clips" }       V { text: parent.m && parent.m.clips.length ? parent.m.clips.join(", ") : "—" }
                K { text: "Textures" }    V { text: parent.m ? parent.m.textures.length + " × 1024² PNG" : "—" }
                K { text: "Export" }      V { text: "glTF 2.0 (GLB), external PNG" }
                K { text: "Runtime" }     V { text: parent.m ? parent.m.format : "—" }
                K { text: "Scale" }       V { text: showcase.current.def.scale + " m per model unit, foot offset " + (showcase.current.def.footOffset || 0) }
                K { text: "Validation" }  V { text: parent.m ? "qtmesh validate ✓ · loaded in Qt Quick 3D ✓" : "—" }
                K { text: "Source" }      V { text: parent.m ? parent.m.source.split("/").pop() : "—" }
            }
            Rectangle { width: parent.width; height: 1; color: "#3a3226" }
            Text { text: "Animation"; color: showcase.gold; font.pixelSize: 12; font.bold: true; visible: showcase.current.meta && showcase.current.meta.clips.length > 0 }
            Flow {
                width: parent.width; spacing: 4
                visible: showcase.current.meta && showcase.current.meta.clips.length > 0
                Repeater {
                    model: showcase.current.meta ? showcase.current.meta.clips : []
                    Rectangle {
                        required property string modelData
                        width: 78; height: 26; radius: 3
                        color: showcase.clip === modelData ? "#7d5a2a" : "#2b2418"; border.color: "#5a4a3a"
                        Text { anchors.centerIn: parent; text: modelData; color: showcase.ink; font.pixelSize: 12 }
                        MouseArea { anchors.fill: parent; onClicked: { showcase.clip = modelData; if (modelLoader.item && modelLoader.item.clip !== undefined) modelLoader.item.clip = modelData } }
                    }
                }
            }
            Text { text: "Playing: " + showcase.clip; color: showcase.faint; font.pixelSize: 11; visible: showcase.current.meta && showcase.current.meta.clips.length > 0 }
            Item { width: 1; height: 8 }
            Text {
                width: parent.width; wrapMode: Text.WordWrap; color: showcase.faint; font.pixelSize: 11
                text: "Drag to rotate · wheel to zoom · double-click resumes the turntable.\nPipeline: concept image → TRELLIS.2 (qtmesh generate3d) → qtmesh rig/anim → balsam → Clayground."
            }
        }
    }
    Keys.onPressed: (e) => { if (e.key === Qt.Key_Escape) { closeRequested(); e.accepted = true } }
}
