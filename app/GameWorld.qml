// The 3D scene: view, camera rig, lights, ground, and the roots that entities are parented to.
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import Clayground.Canvas3D

View3D {
    id: view3d
    property real mapSizeX: 64
    property real mapSizeZ: 64
    readonly property alias rig: rig
    readonly property alias unitRoot: unitRoot
    readonly property alias buildingRoot: buildingRoot
    readonly property alias projectileRoot: projectileRoot
    readonly property alias moveMarker: moveMarker

    camera: rig.camera
    environment: SceneEnvironment {
        clearColor: "#1f232a"
        backgroundMode: SceneEnvironment.Color
        antialiasingMode: SceneEnvironment.MSAA
        antialiasingQuality: SceneEnvironment.Medium
    }

    RtsCamera { id: rig; mapSizeX: view3d.mapSizeX; mapSizeZ: view3d.mapSizeZ }

    DirectionalLight {
        eulerRotation.x: -58; eulerRotation.y: -32
        brightness: 1.45
        ambientColor: "#454a52"
    }
    DirectionalLight { eulerRotation.x: -25; eulerRotation.y: 145; brightness: 0.4; color: "#c9d6ff" }

    // ground
    Model {
        source: "#Rectangle"
        eulerRotation.x: -90
        position: Qt.vector3d(view3d.mapSizeX / 2, 0, view3d.mapSizeZ / 2)
        scale: Qt.vector3d(view3d.mapSizeX / 100, view3d.mapSizeZ / 100, 1)
        materials: PrincipledMaterial { baseColor: "#4b4f47"; roughness: 0.95; metalness: 0 }
        pickable: false
    }
    // subtle 8 m grid
    Repeater3D {
        model: Math.floor(view3d.mapSizeX / 8) + 1
        Model {
            source: "#Cube"
            position: Qt.vector3d(index * 8, 0.01, view3d.mapSizeZ / 2)
            scale: Qt.vector3d(0.0003, 0.0002, view3d.mapSizeZ / 100)
            materials: PrincipledMaterial { baseColor: "#565a53"; lighting: PrincipledMaterial.NoLighting }
            pickable: false
        }
    }
    Repeater3D {
        model: Math.floor(view3d.mapSizeZ / 8) + 1
        Model {
            source: "#Cube"
            position: Qt.vector3d(view3d.mapSizeX / 2, 0.01, index * 8)
            scale: Qt.vector3d(view3d.mapSizeX / 100, 0.0002, 0.0003)
            materials: PrincipledMaterial { baseColor: "#565a53"; lighting: PrincipledMaterial.NoLighting }
            pickable: false
        }
    }

    Node { id: buildingRoot }
    Node { id: unitRoot }
    Node { id: projectileRoot }

    // order marker: flat ring that grows and fades
    Node {
        id: moveMarker
        visible: false
        property color tone: "#e0b24a"
        function showAt(x, z, c) { position = Qt.vector3d(x, 0.02, z); tone = c; visible = true; markerAnim.restart() }
        Model {
            id: markerModel
            source: "#Cylinder"
            scale: Qt.vector3d(0.014, 0.0006, 0.014)
            materials: PrincipledMaterial { baseColor: moveMarker.tone; lighting: PrincipledMaterial.NoLighting }
            pickable: false
        }
        SequentialAnimation {
            id: markerAnim
            ParallelAnimation {
                NumberAnimation { target: markerModel; property: "scale.x"; from: 0.004; to: 0.016; duration: 250 }
                NumberAnimation { target: markerModel; property: "scale.z"; from: 0.004; to: 0.016; duration: 250 }
            }
            PauseAnimation { duration: 350 }
            ScriptAction { script: moveMarker.visible = false }
        }
    }
}
