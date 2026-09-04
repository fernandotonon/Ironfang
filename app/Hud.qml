// In-match HUD: resources + objective (top), selection panel (bottom-left), actions (bottom-right).
import QtQuick

Item {
    id: hud
    property var game: null                  // IronfangGame
    property var selection: []
    property real iron: 0
    property string objective: ""
    property string message: ""
    property real fps: 0
    property bool showFps: false
    property int enemyWave: 0
    property real matchTime: 0

    signal produceRequested(var building, string typeId)
    signal cancelProductionRequested(var building)
    signal pauseRequested()
    signal stopRequested()
    signal returnIronRequested()

    readonly property color gold: "#e0b24a"
    readonly property color ink: "#f2e2c4"
    readonly property color faint: "#9aa0a6"
    readonly property color panel: "#d21b1d22"
    readonly property color edge: "#7a5a2a"

    readonly property var primary: selection.length ? selection[0] : null
    readonly property bool buildingSelected: primary !== null && primary.isBuilding === true && primary.team === "player"
    readonly property int workersSelected: {
        let n = 0; for (const u of selection) if (u.isUnit && u.typeId === "goblin_worker") n++; return n
    }

    component HudButton: Rectangle {
        id: hb
        property string label: ""
        property string sub: ""
        property bool usable: true
        property color tint: "#3b2d19"
        signal clicked()
        width: Math.max(88, lbl.implicitWidth + 20); height: sub !== "" ? 44 : 30; radius: 4
        color: !usable ? "#2a2420" : (ma.pressed ? "#7d5a2a" : (ma.containsMouse ? "#5a4222" : tint))
        border.color: usable ? "#c9973b" : "#5a4a3a"; border.width: 1
        opacity: usable ? 1 : 0.6
        Column {
            anchors.centerIn: parent; spacing: 1
            Text { id: lbl; text: hb.label; color: hud.ink; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
            Text { visible: hb.sub !== ""; text: hb.sub; color: hud.gold; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: if (hb.usable) hb.clicked() }
    }

    function fmtTime(s) { const m = Math.floor(s / 60), r = Math.floor(s % 60); return m + ":" + (r < 10 ? "0" : "") + r }

    // ---- top bar ---------------------------------------------------------------------------
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 40
        color: hud.panel
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
            spacing: 22
            Row {
                spacing: 6
                Rectangle { width: 14; height: 14; radius: 3; color: "#8d8f96"; anchors.verticalCenter: parent.verticalCenter; border.color: "#c8cbd2" }
                Text { text: "Iron  " + Math.floor(hud.iron); color: hud.ink; font.pixelSize: 16; font.bold: true }
            }
            Text { text: hud.objective; color: hud.gold; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            Text { text: hud.fmtTime(hud.matchTime) + (hud.enemyWave ? "   wave " + hud.enemyWave : ""); color: hud.faint; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
            Text { visible: hud.showFps; text: "FPS " + hud.fps.toFixed(0); color: hud.faint; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
        }
        Text {
            anchors { centerIn: parent }
            text: "IRONFANG: FIRST SIEGE"; color: hud.gold; font.pixelSize: 14; font.bold: true; font.letterSpacing: 3
        }
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
            spacing: 8
            HudButton { label: "Pause (P)"; onClicked: hud.pauseRequested() }
        }
    }

    // ---- message ----------------------------------------------------------------------------
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 52 }
        visible: hud.message !== ""
        text: hud.message; color: hud.gold; font.pixelSize: 14
        style: Text.Outline; styleColor: "#000000"
    }

    // ---- selection panel --------------------------------------------------------------------
    Rectangle {
        id: selPanel
        visible: hud.selection.length > 0
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        width: 300; height: 118
        color: hud.panel; radius: 6; border.color: hud.edge
        Row {
            anchors { fill: parent; margins: 10 }
            spacing: 10
            Rectangle {      // portrait
                width: 64; height: 64; radius: 5
                color: hud.primary && hud.primary.typeDef ? hud.primary.typeDef.portrait || "#555" : "#555"
                border.color: hud.edge
                Text {
                    anchors.centerIn: parent
                    text: hud.primary ? (hud.primary.typeDef.displayName || "?").split(" ").map(w => w[0]).join("") : ""
                    color: "#1a1a1a"; font.pixelSize: 22; font.bold: true
                }
            }
            Column {
                spacing: 4
                Text {
                    text: hud.selection.length > 1
                          ? hud.selection.length + " units selected"
                          : (hud.primary && hud.primary.typeDef ? hud.primary.typeDef.displayName : "")
                    color: hud.ink; font.pixelSize: 15; font.bold: true
                }
                Text {
                    visible: hud.selection.length === 1 && hud.primary && hud.primary.maxHp > 0
                    text: hud.primary ? "HP " + Math.ceil(hud.primary.hp) + " / " + hud.primary.maxHp : ""
                    color: hud.ink; font.pixelSize: 12
                }
                Rectangle {
                    visible: hud.selection.length === 1 && hud.primary && hud.primary.maxHp > 0
                    width: 190; height: 8; radius: 3; color: "#2a2620"
                    Rectangle {
                        width: parent.width * (hud.primary && hud.primary.maxHp > 0 ? hud.primary.hp / hud.primary.maxHp : 0)
                        height: parent.height; radius: 3
                        color: parent.width > 0 && hud.primary && hud.primary.hp / hud.primary.maxHp > 0.5 ? "#5fae3c" : (hud.primary && hud.primary.hp / hud.primary.maxHp > 0.25 ? "#d9a63b" : "#c9432e")
                    }
                }
                Text {
                    text: {
                        const p = hud.primary
                        if (!p) return ""
                        if (p.isBuilding) {
                            if (p.stats && p.stats.resource) return "Iron left: " + Math.floor(p.iron)
                            void hud.game.tick; void p.rallyRev
                            const rally = p.rallyTarget ? "Rally: gather at the iron deposit" : (p.rally ? "Rally: point set" : "Rally: none (right-click to set)")
                            if (p.queue && p.queue.items.length) return "Producing: " + p.queue.items.map(t => hud.game.unitName(t)).join(", ") + "\n" + rally
                            return p.team === "enemy" ? "Hostile structure" : (p.team === "player" && p.queue ? "Idle · " + rally : "Idle")
                        }
                        if (p.typeId === "goblin_worker") return p.gatherState !== "idle" ? "Gathering  (carrying " + p.carried + ")" : (p.carried ? "Carrying " + p.carried + " iron" : "Idle")
                        return p.order === "attack" ? "Attacking" : (p.path && p.path.length ? "Moving" : "Idle")
                    }
                    color: hud.faint; font.pixelSize: 12
                }
            }
        }
    }

    // ---- action panel -----------------------------------------------------------------------
    Rectangle {
        id: actionPanel
        visible: hud.buildingSelected && hud.primary.stats && hud.primary.stats.produces && hud.primary.stats.produces.length > 0
                 || hud.workersSelected > 0
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        width: 330; height: 118
        color: hud.panel; radius: 6; border.color: hud.edge
        Column {
            anchors { fill: parent; margins: 10 }
            spacing: 6
            Text {
                text: hud.buildingSelected ? "Produce" : "Orders"
                color: hud.gold; font.pixelSize: 12; font.bold: true
            }
            Flow {
                width: parent.width; spacing: 6
                Repeater {
                    model: hud.buildingSelected && hud.primary.stats.produces ? hud.primary.stats.produces : []
                    HudButton {
                        required property string modelData
                        label: hud.game ? hud.game.unitName(modelData) : modelData
                        sub: hud.game ? hud.game.unitCost(modelData) + " iron · " + hud.game.unitBuildTime(modelData) + "s" : ""
                        usable: hud.game ? hud.iron >= hud.game.unitCost(modelData) : false
                        onClicked: hud.produceRequested(hud.primary, modelData)
                    }
                }
                HudButton { visible: hud.workersSelected > 0 && !hud.buildingSelected; label: "Return iron"; onClicked: hud.returnIronRequested() }
                HudButton { visible: hud.workersSelected > 0 && !hud.buildingSelected; label: "Stop (S)"; onClicked: hud.stopRequested() }
            }
            // production progress
            Row {
                visible: hud.buildingSelected && hud.primary.queue && hud.primary.queue.items.length > 0
                spacing: 8
                Rectangle {
                    width: 200; height: 10; radius: 3; color: "#2a2620"; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: parent.width * (hud.game && hud.primary && hud.primary.queue ? hud.game.queueProgress(hud.primary) : 0)
                        height: parent.height; radius: 3; color: hud.gold
                    }
                }
                Text {
                    text: hud.primary && hud.primary.queue ? hud.primary.queue.items.length + " queued" : ""
                    color: hud.faint; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter
                }
                HudButton { label: "Cancel"; height: 22; width: 60; onClicked: hud.cancelProductionRequested(hud.primary) }
            }
        }
    }

    Text {
        anchors { right: parent.right; top: parent.top; topMargin: 46; rightMargin: 12 }
        text: "LMB select · drag box · Shift add · RMB order · building selected + RMB = rally point (deposit = auto-gather) · WASD/wheel camera · Esc clear"
        color: "#6f7580"; font.pixelSize: 10
    }
}
