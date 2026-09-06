// In-match HUD: resources + objective (top), selection panel (bottom-left), actions (bottom-right).
import QtQuick

Item {
    id: hud
    property var game: null                  // IronfangGame
    property var selection: []
    property real iron: 0
    property string objective: ""            // active primary objective (one line, top bar)
    property var objectiveRows: []           // all visible objectives: {text, state, optional, current, target, showCount}
    property string message: ""
    property real fps: 0
    property bool showFps: false
    property int enemyWave: 0
    property real matchTime: 0
    property string title: ""
    property string tutorialText: ""
    property string tutorialHighlight: ""
    property int tutorialIndex: 0
    property int tutorialTotal: 0
    signal skipTutorialRequested()

    signal produceRequested(var building, string typeId)
    signal cancelProductionRequested(var building)
    signal pauseRequested()
    signal stopRequested()
    signal returnIronRequested()
    signal deselectRequested()
    signal selectArmyRequested()
    signal selectWorkersRequested()
    signal homeRequested()
    property bool touchMode: false

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
        width: Math.max(hud.touchMode ? 100 : 88, lbl.implicitWidth + 20); height: (sub !== "" ? 44 : 30) + (hud.touchMode ? 10 : 0); radius: 4
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
            id: topRow
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
            spacing: 22
            Row {
                id: ironRow
                spacing: 6
                Rectangle { width: 14; height: 14; radius: 3; color: "#8d8f96"; anchors.verticalCenter: parent.verticalCenter; border.color: "#c8cbd2" }
                Text { text: Loc.tr("hud.iron", { n: Math.floor(hud.iron) }); color: hud.ink; font.pixelSize: 16; font.bold: true }
            }
            Text { text: hud.objective; color: hud.gold; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            Text { text: hud.fmtTime(hud.matchTime) + (hud.enemyWave ? "   " + Loc.tr("hud.wave", { n: hud.enemyWave }) : ""); color: hud.faint; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
            Text { visible: hud.showFps; text: "FPS " + hud.fps.toFixed(0); color: hud.faint; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
        }
        Highlight { key: "hud:iron"; target: ironRow; x: topRow.x + ironRow.x - 6; y: topRow.y + ironRow.y - 4; width: ironRow.width + 12 }
        Text {
            anchors { centerIn: parent }
            text: hud.title.toUpperCase(); color: hud.gold; font.pixelSize: 14; font.bold: true; font.letterSpacing: 3
        }
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
            spacing: 8
            HudButton { label: Loc.tr("hud.pause"); onClicked: hud.pauseRequested() }
        }
    }

    // ---- message ----------------------------------------------------------------------------
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 52 }
        visible: hud.message !== ""
        text: hud.message; color: hud.gold; font.pixelSize: 14
        style: Text.Outline; styleColor: "#000000"
    }

    // ---- tutorial panel (top centre) -----------------------------------------------------------------
    Rectangle {
        visible: hud.tutorialText !== ""
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: hud.message !== "" ? 78 : 52 }
        width: Math.min(hud.width - 40, 620); height: tutCol.implicitHeight + 20; radius: 6
        color: hud.panel; border.color: hud.gold; border.width: 1
        Column {
            id: tutCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 6
            Row {
                width: parent.width
                Text { text: Loc.tr("tutorial.step", { n: hud.tutorialIndex + 1, total: hud.tutorialTotal }); color: hud.gold; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1; width: parent.width - 90 }
                Text {
                    text: Loc.tr("tutorial.skip"); color: hud.faint; font.pixelSize: 11; width: 90; horizontalAlignment: Text.AlignRight
                    MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: hud.skipTutorialRequested() }
                }
            }
            Text { width: parent.width; text: hud.tutorialText; color: hud.ink; font.pixelSize: 14; wrapMode: Text.WordWrap; lineHeight: 1.25 }
        }
    }
    // pulsing frame around a HUD element; `target` = a sibling (positioner children cannot anchor)
    component Highlight: Rectangle {
        property string key: ""
        property Item target: parent
        visible: hud.tutorialHighlight === key
        x: target === parent ? -4 : target.x - 4; y: target === parent ? -4 : target.y - 4
        width: target.width + 8; height: target.height + 8
        radius: 8; color: "transparent"; border.color: hud.gold; border.width: 2; z: 5
        SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.25; to: 1; duration: 600 } NumberAnimation { from: 1; to: 0.25; duration: 600 } }
    }

    // ---- objectives panel (top-left, under the bar) ---------------------------------------------
    Highlight { key: "hud:objectives"; target: objCol; visible: hud.tutorialHighlight === key && objCol.visible }
    Column {
        id: objCol
        visible: hud.objectiveRows.length > 0
        anchors { left: parent.left; top: parent.top; topMargin: 48; leftMargin: 14 }
        spacing: 3
        Repeater {
            model: hud.objectiveRows
            Row {
                required property var modelData
                spacing: 6
                Text {
                    text: modelData.state === "complete" ? "✓" : modelData.state === "failed" ? "✗" : "◦"
                    color: modelData.state === "complete" ? "#5fae3c" : modelData.state === "failed" ? "#c9432e" : hud.gold
                    font.pixelSize: 12; font.bold: true; width: 12
                    style: Text.Outline; styleColor: "#000000"
                }
                Text {
                    text: (modelData.optional ? Loc.tr("objective.optional_prefix") + " " : "") + Loc.trOr(modelData.text)
                          + (modelData.showCount ? "  " + modelData.current + " / " + modelData.target : "")
                    color: modelData.state === "active" ? (modelData.optional ? hud.faint : hud.ink) : "#8b9096"
                    font.pixelSize: 12
                    font.strikeout: modelData.state === "failed"
                    style: Text.Outline; styleColor: "#000000"
                }
            }
        }
    }

    // ---- selection panel --------------------------------------------------------------------
    Rectangle {
        id: selPanel
        visible: hud.selection.length > 0
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        width: 300; height: 118
        color: hud.panel; radius: 6; border.color: hud.edge
        Highlight { key: "hud:selection" }
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
                          ? Loc.tr("hud.units_selected", { n: hud.selection.length })
                          : (hud.primary ? hud.game.entityName(hud.primary) : "")
                    color: hud.ink; font.pixelSize: 15; font.bold: true
                }
                Text {
                    visible: hud.selection.length === 1 && hud.primary && hud.primary.maxHp > 0
                    text: hud.primary ? Loc.tr("hud.hp", { hp: Math.ceil(hud.primary.hp), max: hud.primary.maxHp }) : ""
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
                            if (p.stats && p.stats.resource) return Loc.tr("hud.iron_left", { n: Math.floor(p.iron) })
                            void hud.game.tick; void p.rallyRev
                            const rally = p.rallyTarget ? Loc.tr("hud.rally_deposit") : (p.rally ? Loc.tr("hud.rally_point") : Loc.tr("hud.rally_none"))
                            if (p.queue && p.queue.items.length) return Loc.tr("hud.producing", { list: p.queue.items.map(t => hud.game.unitName(t)).join(", ") }) + "\n" + rally
                            if (p.productionEnabled === false) return Loc.tr("hud.not_operational")
                            return p.team === "enemy" ? Loc.tr("hud.hostile_structure") : (p.team === "player" && p.queue ? Loc.tr("hud.idle") + " · " + rally : Loc.tr("hud.idle"))
                        }
                        if (p.typeId === "goblin_worker") return p.gatherState !== "idle" ? Loc.tr("hud.gathering", { n: p.carried }) : (p.carried ? Loc.tr("hud.carrying", { n: p.carried }) : Loc.tr("hud.idle"))
                        return p.order === "attack" ? Loc.tr("hud.attacking") : (p.path && p.path.length ? Loc.tr("hud.moving") : Loc.tr("hud.idle"))
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
        Highlight { key: "hud:produce" }
        Column {
            anchors { fill: parent; margins: 10 }
            spacing: 6
            Text {
                text: hud.buildingSelected ? Loc.tr("hud.produce") : Loc.tr("hud.orders")
                color: hud.gold; font.pixelSize: 12; font.bold: true
            }
            Flow {
                width: parent.width; spacing: 6
                Repeater {
                    model: hud.buildingSelected && hud.primary.stats.produces ? hud.primary.stats.produces : []
                    HudButton {
                        required property string modelData
                        label: hud.game ? hud.game.unitName(modelData) : modelData
                        sub: hud.game ? Loc.tr("hud.cost", { iron: hud.game.unitCost(modelData), s: hud.game.unitBuildTime(modelData) }) : ""
                        usable: hud.game ? hud.iron >= hud.game.unitCost(modelData) && hud.primary.productionEnabled !== false : false
                        onClicked: hud.produceRequested(hud.primary, modelData)
                    }
                }
                HudButton { visible: hud.workersSelected > 0 && !hud.buildingSelected; label: Loc.tr("hud.return_iron"); onClicked: hud.returnIronRequested() }
                HudButton { visible: hud.workersSelected > 0 && !hud.buildingSelected; label: Loc.tr("hud.stop"); onClicked: hud.stopRequested() }
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
                    text: hud.primary && hud.primary.queue ? Loc.tr("hud.queued", { n: hud.primary.queue.items.length }) : ""
                    color: hud.faint; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter
                }
                HudButton { label: Loc.tr("common.cancel"); height: 22; width: 60; onClicked: hud.cancelProductionRequested(hud.primary) }
            }
        }
    }

    Text {
        visible: !hud.touchMode
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 6 }
        text: Loc.tr("hud.hint_mouse")
        color: "#6f7580"; font.pixelSize: 10
    }

    // ---- touch toolbar (phones/tablets): big targets for what has no gesture -------------------
    Column {
        visible: hud.touchMode
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 8 }
        spacing: 8
        component TouchButton: Rectangle {
            id: tb
            property string label: ""
            property string icon: ""
            signal clicked()
            width: 64; height: 56; radius: 8
            color: ma.pressed ? "#7d5a2a" : "#cc2b2418"; border.color: "#c9973b"; border.width: 1
            Column {
                anchors.centerIn: parent; spacing: 2
                Text { text: tb.icon; color: hud.gold; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: tb.label; color: hud.ink; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
            }
            MouseArea { id: ma; anchors.fill: parent; onClicked: tb.clicked() }
        }
        TouchButton { icon: "⚔"; label: Loc.tr("hud.touch_army"); onClicked: hud.selectArmyRequested() }
        TouchButton { icon: "⛏"; label: Loc.tr("hud.touch_workers"); onClicked: hud.selectWorkersRequested() }
        TouchButton { icon: "✕"; label: Loc.tr("hud.touch_deselect"); onClicked: hud.deselectRequested() }
        TouchButton { icon: "⌂"; label: Loc.tr("hud.touch_home"); onClicked: hud.homeRequested() }
    }
    Text {
        visible: hud.touchMode
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 6 }
        text: hud.selection.length ? Loc.tr("hud.hint_touch_selected") : Loc.tr("hud.hint_touch")
        color: "#8b9096"; font.pixelSize: 11
    }
}
