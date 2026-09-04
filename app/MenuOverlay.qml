// Title / pause / victory / defeat overlays. `mode`: "" | "title" | "paused" | "victory" | "defeat"
import QtQuick

Item {
    id: overlay
    property string mode: "title"
    property string subtitle: ""
    property string stats: ""
    visible: mode !== ""

    signal startRequested(string difficulty)
    signal resumeRequested()
    signal restartRequested()
    signal showcaseRequested()
    signal creditsRequested()

    readonly property color gold: "#e0b24a"
    readonly property color ink: "#f2e2c4"

    Rectangle { anchors.fill: parent; color: overlay.mode === "title" ? "#e614161a" : "#a814161a" }
    MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    component MenuButton: Rectangle {
        id: mb
        property string label: ""
        property bool primary: false
        signal clicked()
        width: 260; height: 42; radius: 5
        color: ma.pressed ? "#7d5a2a" : (ma.containsMouse ? "#5a4222" : (primary ? "#4a3620" : "#2b2418"))
        border.color: primary ? overlay.gold : "#7a5a2a"; border.width: 1
        Text { anchors.centerIn: parent; text: mb.label; color: overlay.ink; font.pixelSize: 15; font.letterSpacing: 1 }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: mb.clicked() }
    }

    Column {
        anchors.centerIn: parent
        spacing: 14
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: overlay.mode === "victory" ? "VICTORY" : overlay.mode === "defeat" ? "DEFEAT" : overlay.mode === "paused" ? "PAUSED" : "IRONFANG"
            color: overlay.mode === "defeat" ? "#c9432e" : overlay.gold
            font.pixelSize: overlay.mode === "title" ? 64 : 48; font.bold: true; font.letterSpacing: 8
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: overlay.mode === "title" ? "FIRST SIEGE" : overlay.subtitle
            color: overlay.ink; font.pixelSize: overlay.mode === "title" ? 24 : 15; font.letterSpacing: overlay.mode === "title" ? 6 : 0
        }
        Text {
            visible: overlay.mode === "title"
            anchors.horizontalCenter: parent.horizontalCenter
            text: "A micro-RTS forged with QtMeshEditor"
            color: "#9aa0a6"; font.pixelSize: 14
        }
        Text {
            visible: overlay.stats !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            text: overlay.stats; color: "#c8d0b0"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter
        }
        Item { width: 1; height: 10 }
        Column {
            visible: overlay.mode === "title"
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            MenuButton { label: "Start Match — Normal"; primary: true; onClicked: overlay.startRequested("normal") }
            MenuButton { label: "Start Match — Easy"; onClicked: overlay.startRequested("easy") }
            MenuButton { label: "Start Match — Hard"; onClicked: overlay.startRequested("hard") }
            MenuButton { label: "Asset Showcase"; onClicked: overlay.showcaseRequested() }
            MenuButton { label: "Credits"; onClicked: overlay.creditsRequested() }
        }
        Column {
            visible: overlay.mode === "paused"
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            MenuButton { label: "Resume (P)"; primary: true; onClicked: overlay.resumeRequested() }
            MenuButton { label: "Restart Match"; onClicked: overlay.restartRequested() }
        }
        Column {
            visible: overlay.mode === "victory" || overlay.mode === "defeat"
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            MenuButton { label: "Play Again"; primary: true; onClicked: overlay.restartRequested() }
        }
        Item { width: 1; height: 20 }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Built with Clayground  ·  Assets created and processed with QtMeshEditor"
            color: "#6f7580"; font.pixelSize: 12
        }
    }

    Text {
        visible: overlay.mode === "title"
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 26 }
        width: Math.min(parent.width - 40, 760); wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
        text: "Select goblin workers and send them to an iron deposit. Spend iron at the War Foundry on warriors, archers and an ogre. Hold the walls against the waves, then march on the enemy fortress."
        color: "#9aa0a6"; font.pixelSize: 13
    }
}
