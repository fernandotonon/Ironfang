// RTS camera: Clayground's OrbitCamera3D rig (pitch/zoom clamps, height floor, pan leash)
// plus keyboard panning. Wheel/right-drag arrive through OrbitInput3D in IronfangGame.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D

OrbitCamera3D {
    id: rig

    // map extents the pivot may wander over (metres)
    property real mapSizeX: 60
    property real mapSizeZ: 60
    property real keyPanSpeed: 0.9   // fraction of the view's ground width per second

    // keyboard state, fed by the game
    property real keyRight: 0        // -1..1
    property real keyAway: 0         // -1..1

    pivot: Qt.vector3d(mapSizeX / 2, 0, mapSizeZ / 2)
    homePivot: Qt.vector3d(mapSizeX / 2, 0, mapSizeZ / 2)
    panLeash: Math.max(mapSizeX, mapSizeZ) * 0.55
    yaw: 0
    pitch: 52
    distance: 42
    minPitch: 28
    maxPitch: 82
    minDistance: 10
    maxDistance: 95
    minHeight: 3
    smoothMs: 90
    fieldOfView: 50

    // Per-frame keyboard pan. Pan speed scales with zoom so the map scrolls at a constant
    // fraction of the screen regardless of camera distance.
    function tickKeyboard(dt) {
        if (keyRight === 0 && keyAway === 0) return
        const groundWidth = 2 * goalDistance * Math.tan(fieldOfView * Math.PI / 360) * 1.6
        const v = groundWidth * keyPanSpeed * dt
        rig.panBy(keyRight * v, keyAway * v)
    }
}
