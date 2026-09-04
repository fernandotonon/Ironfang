// Milestone 0 overlay: status, controls, spawn buttons.
import QtQuick

Item {
    id: hud
    property int unitCount: 0
    property int selectedCount: 0
    property real fps: 0
    property string modelStatus: ""
    property bool useModels: true
    property string lastMessage: ""

    signal spawnRequested(int count)
    signal clearRequested()
    signal toggleModelsRequested()
    signal playRequested(string clip)

    component HudButton: Rectangle {
        property string label: ""
        signal clicked()
        width: Math.max(74, t.implicitWidth + 18); height: 26; radius: 4
        color: ma.pressed ? "#7d5a2a" : (ma.containsMouse ? "#5a4222" : "#3b2d19")
        border.color: "#c9973b"; border.width: 1
        Text { id: t; anchors.centerIn: parent; text: parent.label; color: "#f2e2c4"; font.pixelSize: 12 }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; margins: 10 }
        width: col.implicitWidth + 24
        height: col.implicitHeight + 20
        color: "#cc1b1d22"; radius: 6; border.color: "#7a5a2a"

        Column {
            id: col
            anchors { left: parent.left; top: parent.top; margins: 10 }
            spacing: 5
            Text { text: "IRONFANG: FIRST SIEGE"; color: "#e0b24a"; font.pixelSize: 15; font.bold: true; font.letterSpacing: 2 }
            Text { text: "Milestone 0 - Clayground feasibility spike"; color: "#9aa0a6"; font.pixelSize: 11 }
            Text { text: "FPS " + hud.fps.toFixed(0) + "   units " + hud.unitCount + "   selected " + hud.selectedCount; color: "#f2e2c4"; font.pixelSize: 13 }
            Text { text: "model: " + hud.modelStatus; color: "#c8d0b0"; font.pixelSize: 11 }
            Row {
                spacing: 6
                HudButton { label: "+1 unit"; onClicked: hud.spawnRequested(1) }
                HudButton { label: "+20"; onClicked: hud.spawnRequested(20) }
                HudButton { label: "to 40"; onClicked: hud.spawnRequested(-40) }
                HudButton { label: "clear"; onClicked: hud.clearRequested() }
            }
            Row {
                spacing: 6
                HudButton { label: hud.useModels ? "models: Orc" : "models: boxes"; onClicked: hud.toggleModelsRequested() }
                HudButton { label: "Idle (1)"; onClicked: hud.playRequested("Idle") }
                HudButton { label: "Walk (2)"; onClicked: hud.playRequested("Walk") }
                HudButton { label: "Attack (3)"; onClicked: hud.playRequested("Attack") }
            }
            Text {
                text: "LMB select / drag box  ·  Shift add  ·  RMB click move  ·  RMB drag orbit  ·  wheel zoom\n"
                    + "WASD / arrows pan  ·  1/2/3 Idle/Walk/Attack  ·  4 Hit  5 Death  ·  Esc clear  ·  +  spawn"
                color: "#8b9096"; font.pixelSize: 11
            }
            Text { visible: hud.lastMessage !== ""; text: hud.lastMessage; color: "#e0b24a"; font.pixelSize: 11 }
        }
    }

    Text {
        anchors { right: parent.right; bottom: parent.bottom; margins: 8 }
        text: "Built with Clayground · Forged with QtMeshEditor"
        color: "#6f7580"; font.pixelSize: 11
    }
}
