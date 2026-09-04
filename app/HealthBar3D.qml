// World-space health bar billboard: two thin boxes, turned to face the camera.
import QtQuick
import QtQuick3D

Node {
    id: root
    property real value: 1.0          // 0..1
    property real barWidth: 1.2
    property real barHeight: 0.14
    property real camYaw: 0
    property real camPitch: 45

    eulerRotation.y: camYaw
    eulerRotation.x: -camPitch * 0.35

    Model {
        source: "#Cube"
        scale: Qt.vector3d(root.barWidth / 100, root.barHeight / 100, 0.0005)
        materials: PrincipledMaterial { baseColor: "#1e1a17"; lighting: PrincipledMaterial.NoLighting }
        pickable: false
    }
    Model {
        source: "#Cube"
        x: -(root.barWidth * (1 - root.value)) / 2
        z: 0.03
        scale: Qt.vector3d(Math.max(0.0001, root.barWidth * root.value - 0.06) / 100,
                           (root.barHeight - 0.05) / 100, 0.0005)
        materials: PrincipledMaterial {
            baseColor: root.value > 0.5 ? "#5fae3c" : (root.value > 0.25 ? "#d9a63b" : "#c9432e")
            lighting: PrincipledMaterial.NoLighting
        }
        pickable: false
    }
}
