// Archer arrow: flies toward where the target is, applies damage on arrival if the target is
// still alive, otherwise just lands. Stepped by the game's fixed simulation tick.
import QtQuick
import QtQuick3D

Node {
    id: root
    property var target: null
    property var shooter: null
    property real damage: 0
    property real speed: 22
    property real y_: 1.2
    property vector3d aim: Qt.vector3d(0, 1.0, 0)
    property bool done: false
    property string assetBase: ""
    property var typeDef: ({})

    signal hit(var target, real damage, var shooter)
    signal finished()

    y: y_

    function step(dt) {
        if (done) return
        if (target && target.alive) aim = Qt.vector3d(target.x, 1.0 + (target.isBuilding ? 1.5 : 0), target.z)
        const dx = aim.x - x, dy = aim.y - y_, dz = aim.z - z
        const d = Math.sqrt(dx * dx + dy * dy + dz * dz)
        const stepLen = speed * dt
        if (d <= stepLen + 0.05) {
            x = aim.x; y_ = aim.y; z = aim.z
            done = true
            if (target && target.alive) hit(target, damage, shooter)
            finished()
            return
        }
        x += dx / d * stepLen; y_ += dy / d * stepLen; z += dz / d * stepLen
        eulerRotation = Qt.vector3d(-Math.atan2(dy, Math.sqrt(dx * dx + dz * dz)) * 180 / Math.PI,
                                    Math.atan2(dx, dz) * 180 / Math.PI, 0)
    }

    Loader3D {
        id: model
        active: !!root.typeDef.model
        source: !active ? "" : (root.assetBase ? root.assetBase + root.typeDef.model
                                               : Qt.resolvedUrl(root.typeDef.model))
        scale: Qt.vector3d(root.typeDef.scale || 1, root.typeDef.scale || 1, root.typeDef.scale || 1)
    }
    Model {                                  // fallback / while loading: a thin dark shaft
        visible: model.status !== Loader3D.Ready
        source: "#Cube"
        scale: Qt.vector3d(0.0004, 0.0004, 0.008)
        materials: PrincipledMaterial { baseColor: "#3a2a1a"; lighting: PrincipledMaterial.NoLighting }
        pickable: false
    }
}
